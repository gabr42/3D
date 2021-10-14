unit GCode.Impl;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  GpStuff, GpStreams,
  GCode;

type
  TGCode = class(TInterfacedObject, IGCode)
  strict private
    FErrorMsg    : string;
    FGCode       : IGpBuffer;
    FGCodeStream : TStream;
    FIndex       : IGCodeIndex;
    FRelativeE   : boolean;
    FRelativeMode: boolean;
    FSection     : TGCodeSection;
    FTool        : integer;
  strict protected
    function GenerateIndex: boolean;
    function GetErrorMessage: string;
    function GetIndex: IGCodeIndex;
    function SetError(const errorMsg: string): boolean;
    function UpdatePosition(var pos: extended; update: extended; relativeMode: boolean): boolean;
  public
    constructor Create(const buffer: IGpBuffer);
    class function Make(const buffer: IGpBuffer): IGCode;
    function AsStream: TStream; inline;
    function AtEnd: boolean; inline;
    procedure ExtractPositions(const line: AnsiString; var x, y, z, e: extended);
    function ExtractValue(const param: string): extended;
    function IsArc(const line: AnsiString): boolean; inline;
    function IsComment(const line: AnsiString): boolean; inline;
    function IsEndCode(const line: AnsiString): boolean; inline;
    function IsLayerChange(const line: AnsiString): boolean; inline;
    function IsMove(const line: AnsiString): boolean; inline;
    function LookaheadLayerZHeight(var z: extended): boolean;
    function ReadLine: AnsiString;
    function RemoveComment(const line: AnsiString): AnsiString;
    function Section: TGCodeSection;
    function Tool: integer;
    property ErrorMessage: string read GetErrorMessage;
    property Index: IGCodeIndex read GetIndex;
  end;

implementation

uses
  System.AnsiStrings, System.Math;

type
  IPositionEx = interface ['{AF07D4E7-5B66-4D1E-BC40-8112A82FE4F7}']
    procedure SetPositions(x, y, z, e: extended);
  end;

  TPosition = class(TInterfacedObject, IPosition, IPositionEx)
  strict private
    FX: extended;
    FY: extended;
    FZ: extended;
    FE: extended;
  strict protected
    function GetX: extended;
    function GetY: extended;
    function GetZ: extended;
    function GetE: extended;
    procedure SetPositions(x, y, z, e: extended);
  public
    constructor Create(AX, AY, AZ, AE: extended);
    property X: extended read GetX;
    property Y: extended read GetY;
    property Z: extended read GetZ;
    property E: extended read GetE;
  end;

  IToolInfoEx = interface ['{4CECAB05-4233-465C-832C-094FA420F839}']
    procedure SetSize(value: int64);
  end;

  TToolInfo = class(TInterfacedObject, IToolInfo, IToolInfoEx)
  strict private
    FTool         : integer;
    FStartPos     : int64;
    FSize         : int64;
    FFirstPosition: IPosition;
    FLastPosition : IPosition;
  strict protected
    function GetTool: integer;
    function GetStartPos: int64;
    function GetSize: int64;
    function GetFirstPosition: IPosition;
    function GetLastPosition: IPosition;
    procedure SetSize(value: int64);
  public
    constructor Create(ATool: integer; AX, AY, AZ, AE: extended; ALinePos: int64);
    class function Make(ATool: integer; AX, AY, AZ, AE: extended; ALinePos: int64): IToolInfo;
    property Tool: integer read GetTool;
    property StartPos: int64 read GetStartPos;
    property Size: int64 read GetSize;
    property FirstPosition: IPosition read GetFirstPosition;
    property LastPosition: IPosition read GetLastPosition;
  end;

  ILayerInfoEx = interface ['{8568ABA2-F572-4E42-BE32-54FDBF81803C}']
    function Activate(tool: integer): boolean;
    function ActiveTool: IToolInfo;
    procedure AddTool(tool: IToolInfo);
    procedure SetSize(value: int64);
  end;

  TLayerInfo = class(TInterfacedObject, ILayerInfo, ILayerInfoEx)
  strict private
    FActiveTool   : integer;
    FZ            : real;
    FStartPos     : int64;
    FSize         : int64;
    FFirstPosition: IPosition;
    FLastPosition : IPosition;
    FTools        : TList<IToolInfo>;
  strict protected
    function GetZ: extended;
    function GetStartPos: int64;
    function GetSize: int64;
    function GetFirstPosition: IPosition;
    function GetLastPosition: IPosition;
    function GetTools: TList<IToolInfo>;
    function Activate(tool: integer): boolean;
    function ActiveTool: IToolInfo;
    procedure AddTool(tool: IToolInfo);
    procedure SetSize(value: int64);
  public
    constructor Create(LayerZ, AX, AY, AZ, AE: extended; ALinePos: int64; ATool: integer);
    class function Make(LayerZ, AX, AY, AZ, AE: extended; ALinePos: int64; ATool: integer): ILayerInfo;
    destructor  Destroy; override;
    property Z: extended read GetZ;
    property StartPos: int64 read GetStartPos;
    property Size: int64 read GetSize;
    property FirstPosition: IPosition read GetFirstPosition;
    property LastPosition: IPosition read GetLastPosition;
    property Tools: TList<IToolInfo> read GetTools;
  end;

  IGCodeIndexEx = interface ['{9EC9E635-3386-47A1-A990-A56D1B460AF0}']
    function ActiveLayer: ILayerInfo;
    procedure AddLayer(const layer: ILayerInfo);
    procedure SetFooter(const value: ILayerInfo);
  end;

  TGCodeIndex = class(TInterfacedObject, IGCodeIndex, IGCodeIndexEx)
  strict private
    FHeader: ILayerInfo;
    FLayers: TList<ILayerInfo>;
    FFooter: ILayerInfo;
  strict protected
    function ActiveLayer: ILayerInfo;
    procedure AddLayer(const layer: ILayerInfo);
    function GetHeader: ILayerInfo;
    function GetLayers: TList<ILayerInfo>;
    function GetFooter: ILayerInfo;
    procedure SetFooter(const value: ILayerInfo);
    procedure UpdateLastSegmentSize(newPos: int64);
  public
    constructor Create;
    destructor Destroy; override;
    function FindTool(z: extended; tool: integer): IToolInfo;
    property Header: ILayerInfo read GetHeader;
    property Layers: TList<ILayerInfo> read GetLayers;
    property Footer: ILayerInfo read GetFooter;
  end;

{ TGCode }

constructor TGCode.Create(const buffer: IGpBuffer);
begin
  inherited Create;
  FGCode := buffer;
  FGCodeStream := FGCode.AsStream;
  FSection := secHeader;
end;

procedure TGCode.ExtractPositions(const line: AnsiString; var x, y, z, e: extended);
begin
  x := GCode.Null; y := GCode.Null; z := GCode.Null; e := GCode.Null;
  var parts := string(RemoveComment(line)).Split([' ', #$0D, #$0A], TStringSplitOptions.ExcludeEmpty);
  for var s in parts do
    if (s[1] = 'x') or (s[1] = 'X') then
      x := ExtractValue(s)
    else if (s[1] = 'y') or (s[1] = 'Y') then
      y := ExtractValue(s)
    else if (s[1] = 'z') or (s[1] = 'Z') then
      x := ExtractValue(s)
    else if (s[1] = 'e') or (s[1] = 'E') then
      e := ExtractValue(s);
end;

function TGCode.ExtractValue(const param: string): extended;
begin
  var s := param.Remove(0,1);
  if not TryStrToFloat(param.Remove(0, 1), Result, GCode.FormatSettings) then
    raise Exception.Create('Unsupported format: ' + param);
end;

function TGCode.AsStream: TStream; {inline}
begin
  Result := FGCodeStream;
end;

function TGCode.AtEnd: boolean; {inline}
begin
  Result := FGCodeStream.AtEnd;
end;

function TGCode.IsArc(const line: AnsiString): boolean;
begin
  var cmd := Copy(line, 1, 3);
  Result := SameText(cmd, AnsiString('G2 '))
            or SameText(cmd, AnsiString('G3 '));
end;

function TGCode.IsComment(const line: AnsiString): boolean; {inline}
begin
  Result := (line <> '') and (line[1] = ';');
end;

function TGCode.IsEndCode(const line: AnsiString): boolean; {inline}
begin
  Result := SameText(line, AnsiString('G91 ;Relative positioning'));
end;

function TGCode.IsLayerChange(const line: AnsiString): boolean; {inline}
begin
  Result := SameText(line, AnsiString(';LAYER_CHANGE'));
end;

function TGCode.IsMove(const line: AnsiString): boolean; {inline}
begin
  var cmd := Copy(line, 1, 3);
  Result := SameText(cmd, AnsiString('G0 '))
            or SameText(cmd, AnsiString('G1 '));
end;

function TGCode.LookaheadLayerZHeight(var z: extended): boolean;
begin
  with KeepStreamPosition(FGCodeStream) do begin
    var line := ReadLine;
    if not SameText(Copy(line, 1, 3), AnsiString(';Z:')) then
      Exit(SetError('Unexpected layer change  start: ' + string(line)));

    Delete(line, 1, 3);
    if not TryStrToFloat(string(line), z, GCode.FormatSettings) then
      Exit(SetError('Unexpected Z-value format: ' + string(line)));

    Result := true;
  end;
end;

function TGCode.GenerateIndex: boolean;
var
  gx, gy, gz, ge: extended;
  ux, uy, uz, ue: extended;
  z: extended;
begin
  Result := true;

  FIndex := TGCodeIndex.Create;
  var indexEx := (FIndex as IGCodeIndexEx);

  gx := 0; gy := 0; gz := 0; ge := 0;

  FGCodeStream.GoToStart;
  while not AtEnd do begin
    var linePos := FGCodeStream.Position;
    var prevSect := Section;
    var prevTool := Tool;
    var line := ReadLine;

    if prevSect <> Section then begin
      if Section = secEndcode then
        indexEx.SetFooter(TLayerInfo.Make(gz, gx, gy, gz, ge, linePos, Tool));
    end;

    if IsLayerChange(line) then begin
      if not LookaheadLayerZHeight(z) then
        Exit(false);
      indexEx.AddLayer(TLayerInfo.Make(z, gx, gy, gz, ge, linePos, Tool));
    end
    else if (Section <> secHeader) and (Tool <> prevTool) then begin
      var activeLayerEx := indexEx.ActiveLayer as ILayerInfoEx;
      if not activeLayerEx.Activate(Tool) then
        activeLayerEx.AddTool(TToolInfo.Make(Tool, gx, gy, gz, ge, linePos));
    end
    else begin
      var cmd := UpperCase(Copy(line, 1, 3));
      if (cmd = 'G0 ') or (cmd = 'G1 ') or (cmd = 'G2 ') or (cmd = 'G3 ') or (cmd = 'G92') then begin
        ExtractPositions(line, ux, uy, uz, ue);
        var activeLayerEx := indexEx.ActiveLayer as ILayerInfoEx;
        var activeToolEx := activeLayerEx.ActiveTool as IToolInfoEx;
        if not UpdatePosition(gx, ux, FRelativeMode) then
          Exit(SetError('Cannot update Null X: ' + string(line)));
        if not UpdatePosition(gy, uy, FRelativeMode) then
          Exit(SetError('Cannot update Null Y: ' + string(line)));
        if not UpdatePosition(gz, uz, FRelativeMode) then
          Exit(SetError('Cannot update Null Z: ' + string(line)));
        if not UpdatePosition(ge, ue, FRelativeE) then
          Exit(SetError('Cannot update Null E: ' + string(line)));
        (indexEx.ActiveLayer.LastPosition as IPositionEx).SetPositions(gx, gy, gz, ge);
        (activeLayerEx.ActiveTool.LastPosition as IPositionEx).SetPositions(gx, gy, gz, ge);
      end
      else if cmd = 'M83' then
        Exit(SetError('Relative E is not supported'))
      else if cmd = 'G90' then begin
        FRelativeMode := false;
        FRelativeE := false;
      end
      else if cmd = 'G91' then begin
        FRelativeMode := true;
        FRelativeE := true;
      end
      else if cmd = 'M82' then
        FRelativeE := false
      else if cmd = 'M83' then
        FRelativeE := true;
    end;
  end;

  (FIndex.Footer as ILayerInfoEx).SetSize(FGCodeStream.Position - FIndex.Footer.StartPos);
end;

function TGCode.GetErrorMessage: string;
begin
  Result := FErrorMsg;
end;

function TGCode.GetIndex: IGCodeIndex;
begin
  if not assigned(FIndex) then begin
    if not GenerateIndex then
      FIndex := nil;
  end;

  Result := FIndex;
end;

class function TGCode.Make(const buffer: IGpBuffer): IGCode;
begin
  Result := TGCode.Create(buffer);
end;

function TGCode.ReadLine: AnsiString;
var
  ch: byte;
begin
  var pos := FGCodeStream.Position;
  while (FGCodeStream.ReadData(ch) = 1) and (ch <> $0A) do
    ;
  SetLength(Result, FGCodeStream.Position - pos - Ord(ch = $0A));
  if Result <> '' then begin
    FGCodeStream.Position := pos;
    FGCodeStream.Read(Result[1], Length(Result));
    if ch = $0A then
      FGCodeStream.ReadData(ch);
  end;

  if (Section = secHeader) and IsLayerChange(Result) then
    FSection := secObject
  else if (Section = secObject) and IsEndCode(Result) then
    FSection := secEndcode;
  if (Result <> '') and ((Result[1] = 'T') or (Result[1] = 't')) then
    FTool := StrToInt(Copy(string(RemoveComment(Result)).Trim, 2));
end;

function TGCode.RemoveComment(const line: AnsiString): AnsiString;
begin
  Result := line;
  var p := Pos(AnsiString(';'), line);
  if p > 0 then
    Delete(Result, p, Length(Result));
end;

function TGCode.Section: TGCodeSection;
begin
  Result := FSection;
end;

function TGCode.SetError(const errorMsg: string): boolean;
begin
  FErrorMsg := errorMsg;
  Result := false;
end;

function TGCode.Tool: integer;
begin
  Result := FTool;
end;

function TGCode.UpdatePosition(var pos: extended; update: extended;
  relativeMode: boolean): boolean;
begin
  Result := true;
  if update = GCode.Null then
    Exit;

  if not relativeMode then
    pos := update
  else
    if pos = GCode.Null then
      Result := false
    else
      pos := pos + update;
end;

{ TGCodeIndex }

constructor TGCodeIndex.Create;
begin
  inherited Create;
  FLayers := TList<ILayerInfo>.Create;
  FHeader := TLayerInfo.Make(0, 0, 0, 0, 0, 0, 0);
end;

destructor TGCodeIndex.Destroy;
begin
  FreeAndNil(FLayers);
  inherited;
end;

procedure TGCodeIndex.AddLayer(const layer: ILayerInfo);
begin
  UpdateLastSegmentSize(layer.StartPos);
  FLayers.Add(layer);
end;

function TGCodeIndex.FindTool(z: extended; tool: integer): IToolInfo;
begin
  Result := nil;
  for var layer in Layers do
    if SameValue(z, layer.Z) then
      for var t in layer.Tools do
        if tool = t.Tool then
          Exit(t);
end;

function TGCodeIndex.ActiveLayer: ILayerInfo;
begin
  if assigned(Footer) then
    Result := Footer
  else if Layers.Count = 0 then
    Result := Header
  else
    Result := Layers[Layers.Count-1];
end;

function TGCodeIndex.GetHeader: ILayerInfo;
begin
  Result := FHeader;
end;

function TGCodeIndex.GetLayers: TList<ILayerInfo>;
begin
  Result := FLayers;
end;

procedure TGCodeIndex.SetFooter(const value: ILayerInfo);
begin
  UpdateLastSegmentSize(value.StartPos);
  FFooter := value;
end;

procedure TGCodeIndex.UpdateLastSegmentSize(newPos: int64);
begin
  if FLayers.Count = 0 then
    (FHeader as ILayerInfoEx).SetSize(newPos - FHeader.StartPos)
  else begin
    var lastLayer := Layers[Layers.Count - 1];
    (lastLayer as ILayerInfoEx).SetSize(newPos - lastLayer.StartPos);
    var lastTool := lastLayer.Tools[lastLayer.Tools.Count - 1];
    (lastTool as IToolInfoEx).SetSize(newPos - lastTool.StartPos);
  end;
end;

function TGCodeIndex.GetFooter: ILayerInfo;
begin
  Result := FFooter;
end;

{ TGCodeIndex.TLayerInfo }

constructor TLayerInfo.Create(LayerZ, AX, AY, AZ, AE: extended;
  ALinePos: int64; ATool: integer);
begin
  inherited Create;
  FZ := LayerZ;
  FStartPos := ALinePos;
  FTools := TList<IToolInfo>.Create;
  FTools.Add(TToolInfo.Make(ATool, AX, AY, AZ, AE, ALinePos));
  FFirstPosition := TPosition.Create(AX, AY, AZ, AE);
  FLastPosition := TPosition.Create(AX, AY, AZ, AE);
end;

destructor TLayerInfo.Destroy;
begin
  FreeAndNil(Tools);
  inherited;
end;

class function TLayerInfo.Make(LayerZ, AX, AY, AZ, AE: extended;
  ALinePos: int64; ATool: integer): ILayerInfo;
begin
  Result := TLayerInfo.Create(LayerZ, AX, AY, AZ, AE, ALinePos, ATool);
end;

procedure TLayerInfo.SetSize(value: int64);
begin
  FSize := value;
end;

function TLayerInfo.GetFirstPosition: IPosition;
begin
  Result := FFirstPosition;
end;

function TLayerInfo.GetLastPosition: IPosition;
begin
  Result := FLastPosition;
end;

function TLayerInfo.GetSize: int64;
begin
  Result := FSize;
end;

function TLayerInfo.GetStartPos: int64;
begin
  Result := FStartPos;
end;

function TLayerInfo.GetTools: TList<IToolInfo>;
begin
  Result := FTools;
end;

function TLayerInfo.GetZ: extended;
begin
  Result := FZ;
end;

function TLayerInfo.Activate(tool: integer): boolean;
begin
  for var i := 0 to Tools.Count - 1 do
    if Tools[i].Tool = tool then begin
      FActiveTool := i;
      Exit(true);
    end;

  Result := false;
end;

function TLayerInfo.ActiveTool: IToolInfo;
begin
  Result := Tools[FActiveTool];
end;

procedure TLayerInfo.AddTool(tool: IToolInfo);
begin
  if Tools.Count > 0 then begin
    var lastTool := Tools[Tools.Count - 1];
    (lastTool as IToolInfoEx).SetSize(tool.StartPos - lastTool.StartPos);
  end;
  FActiveTool := Tools.Add(tool);
end;

{ TToolInfo }

constructor TToolInfo.Create(ATool: integer; AX, AY, AZ, AE: extended; ALinePos: int64);
begin
  inherited Create;
  FTool := ATool;
  FStartPos := ALinePos;
  FFirstPosition := TPosition.Create(AX, AY, AZ, AE);
  FLastPosition := TPosition.Create(AX, AY, AZ, AE);
end;

class function TToolInfo.Make(ATool: integer; AX, AY, AZ, AE: extended; ALinePos: int64): IToolInfo;
begin
  Result := TToolInfo.Create(ATool, AX, AY, AZ, AE, ALinePos);
end;

function TToolInfo.GetFirstPosition: IPosition;
begin
  Result := FFirstPosition;
end;

function TToolInfo.GetLastPosition: IPosition;
begin
  Result := FLastPosition;
end;

function TToolInfo.GetSize: int64;
begin
  Result := FSize;
end;

function TToolInfo.GetStartPos: int64;
begin
  Result := FStartPos;
end;

function TToolInfo.GetTool: integer;
begin
  Result := FTool;
end;

procedure TToolInfo.SetSize(value: int64);
begin
  FSize := value;
end;

{ TPosition }

constructor TPosition.Create(AX, AY, AZ, AE: extended);
begin
  inherited Create;
  FX := AX;
  FY := AY;
  FZ := AZ;
  FE := AE;
end;

function TPosition.GetE: extended;
begin
  Result := FE;
end;

function TPosition.GetX: extended;
begin
  Result := FX;
end;

function TPosition.GetY: extended;
begin
  Result := FY;
end;

function TPosition.GetZ: extended;
begin
  Result := FZ;
end;

procedure TPosition.SetPositions(x, y, z, e: extended);
begin
  FX := x;
  FY := y;
  FZ := z;
  FE := e;
end;

end.
