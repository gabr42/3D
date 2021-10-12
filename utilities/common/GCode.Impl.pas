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
    FFormat      : TFormatSettings;
    FGCode       : IGpBuffer;
    FGCodeStream : TStream;
    FIndex       : IGCodeIndex;
    FRelativeMode: boolean;
    FSection     : TGCodeSection;
    FTool        : integer;
  strict protected
    function GenerateIndex: boolean;
    function GetErrorMessage: string;
    function GetIndex: IGCodeIndex;
    function SetError(const errorMsg: string): boolean;
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
  IToolInfoEx = interface ['{4CECAB05-4233-465C-832C-094FA420F839}']
    procedure SetLastX(value: extended);
    procedure SetLastE(value: extended);
  end;

  TToolInfo = class(TInterfacedObject, IToolInfo, IToolInfoEx)
  strict private
    FTool    : integer;
    FStartPos: int64;
    FLastX   : extended;
    FLastE   : extended;
  strict protected
    function GetTool: integer;
    function GetStartPos: int64;
    function GetLastX: extended;
    function GetLastE: extended;
    procedure SetLastX(value: extended);
    procedure SetLastE(value: extended);
  public
    constructor Create(ATool: integer; ALinePos: int64);
    class function Make(ATool: integer; ALinePos: int64): IToolInfo;
    property Tool: integer read GetTool;
    property StartPos: int64 read GetStartPos;
    property LastX: extended read GetLastX;
    property LastE: extended read GetLastE;
  end;

  ILayerInfoEx = interface ['{8568ABA2-F572-4E42-BE32-54FDBF81803C}']
    function Activate(tool: integer): boolean; overload;
    procedure Activate(tool: IToolInfo); overload;
    function ActiveTool: IToolInfo;
    procedure SetLastY(value: extended);
    procedure SetLastZ(value: extended);
  end;

  TLayerInfo = class(TInterfacedObject, ILayerInfo, ILayerInfoEx)
  strict private
    FActiveTool: integer;
    FZ         : real;
    FStartPos  : int64;
    FLastY     : extended;
    FLastZ     : extended;
    FTools     : TList<IToolInfo>;
  strict protected
    function GetZ: extended;
    function GetStartPos: int64;
    function GetLastY: extended;
    function GetLastZ: extended;
    function GetTools: TList<IToolInfo>;
    function Activate(tool: integer): boolean; overload;
    procedure Activate(tool: IToolInfo); overload;
    function ActiveTool: IToolInfo;
    procedure SetLastY(value: extended);
    procedure SetLastZ(value: extended);
  public
    constructor Create(AZ: real; ALinePos: int64; ATool: integer);
    class function Make(AZ: real; ALinePos: int64; ATool: integer): ILayerInfo;
    destructor  Destroy; override;
    property Z: extended read GetZ;
    property StartPos: int64 read GetStartPos;
    property LastY: extended read GetLastY;
    property LastZ: extended read GetLastZ;
    property Tools: TList<IToolInfo> read GetTools;
  end;

  IGCodeIndexEx = interface ['{9EC9E635-3386-47A1-A990-A56D1B460AF0}']
    function ActiveLayer: ILayerInfo;
    procedure SetFooter(const value: ILayerInfo);
  end;

  TGCodeIndex = class(TInterfacedObject, IGCodeIndex, IGCodeIndexEx)
  strict private
    FHeader: ILayerInfo;
    FLayers: TList<ILayerInfo>;
    FFooter: ILayerInfo;
  strict protected
    function ActiveLayer: ILayerInfo;
    function GetHeader: ILayerInfo;
    function GetLayers: TList<ILayerInfo>;
    function GetFooter: ILayerInfo;
    procedure SetFooter(const value: ILayerInfo);
  public
    constructor Create;
    destructor Destroy; override;
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
  FFormat := FormatSettings;
  FFormat.ThousandSeparator := ',';
  FFormat.DecimalSeparator := '.';
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
  if not TryStrToFloat(param.Remove(0, 1), Result, FFormat) then
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
    if not TryStrToFloat(string(line), z, FFormat) then
      Exit(SetError('Unexpected Z-value format: ' + string(line)));

    Result := true;
  end;
end;

function TGCode.GenerateIndex: boolean;
var
  x, y, z, e: extended;
begin
  Result := true;

  FIndex := TGCodeIndex.Create;
  var indexEx := (FIndex as IGCodeIndexEx);

  FGCodeStream.GoToStart;
  while not AtEnd do begin
    var linePos := FGCodeStream.Position;
    var prevSect := Section;
    var prevTool := Tool;
    var line := ReadLine;

    if prevSect <> Section then begin
      if Section = secEndcode then
        indexEx.SetFooter(TLayerInfo.Make(indexEx.ActiveLayer.LastZ, linePos, Tool));
    end;

    if IsLayerChange(line) then begin
      if not LookaheadLayerZHeight(z) then
        Exit(false);
      FIndex.Layers.Add(TLayerInfo.Make(z, linePos, Tool));
    end
    else if (Section <> secHeader) and (Tool <> prevTool) then begin
      var activeLayerEx := indexEx.ActiveLayer as ILayerInfoEx;
      if not activeLayerEx.Activate(Tool) then
        activeLayerEx.Activate(TToolInfo.Make(Tool, linePos));
    end
    else begin
      var cmd := UpperCase(Copy(line, 1, 3));
      if (cmd = 'G0') or (cmd = 'G1') or (cmd = 'G2') or (cmd = 'G3') or (cmd = 'G92') then begin
        ExtractPositions(line, x, y, z, e);
        var activeLayerEx := indexEx.ActiveLayer as ILayerInfoEx;
        var activeToolEx := activeLayerEx.ActiveTool as IToolInfoEx;
        if x <> GCode.Null then
          if FRelativeMode then
            activeToolEx.SetLastX(activeLayerEx.ActiveTool.LastX)
          else
            activeToolEx.SetLastX(x);
        if y <> GCode.Null then
          if FRelativeMode then
            activeLayerEx.SetLastY(indexEx.ActiveLayer.LastY + y)
          else
            activeLayerEx.SetLastY(y);
        if z <> GCode.Null then
          if FRelativeMode then
            activeLayerEx.SetLastZ(indexEx.ActiveLayer.LastZ + z)
          else
            activeLayerEx.SetLastZ(z);
        if e <> GCode.Null then
          if FRelativeMode then
            activeToolEx.SetLastE(activeLayerEx.ActiveTool.LastE + e)
          else
            activeToolEx.SetLastE(e);
      end
      else if cmd = 'M83' then
        Exit(SetError('Relative E is not supported'))
      else if cmd = 'G90' then
        FRelativeMode := false
      else if cmd = 'G91' then
        FRelativeMode := true;
    end;
  end;
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

{ TGCodeIndex }

constructor TGCodeIndex.Create;
begin
  inherited Create;
  FLayers := TList<ILayerInfo>.Create;
  FHeader := TLayerInfo.Make(0, 0, 0);
end;

destructor TGCodeIndex.Destroy;
begin
  FreeAndNil(FLayers);
  inherited;
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
  FFooter := value;
end;

function TGCodeIndex.GetFooter: ILayerInfo;
begin
  Result := FFooter;
end;

{ TGCodeIndex.TLayerInfo }

constructor TLayerInfo.Create(AZ: real; ALinePos: int64; ATool: integer);
begin
  inherited Create;
  FZ := AZ;
  FStartPos := ALinePos;
  FTools := TList<IToolInfo>.Create;
  FTools.Add(TToolInfo.Make(ATool, ALinePos));
  FLastY := GCode.Null;
  FLastZ := GCode.Null;
end;

destructor TLayerInfo.Destroy;
begin
  FreeAndNil(Tools);
  inherited;
end;

class function TLayerInfo.Make(AZ: real; ALinePos: int64; ATool: integer): ILayerInfo;
begin
  Result := TLayerInfo.Create(AZ, ALinePos, ATool);
end;

procedure TLayerInfo.SetLastY(value: extended);
begin
  FLastY := value;
end;

procedure TLayerInfo.SetLastZ(value: extended);
begin
  FLastZ := value;
end;

function TLayerInfo.GetLastY: extended;
begin
  REsult := FLastY;
end;

function TLayerInfo.GetLastZ: extended;
begin
  Result := FLastZ;
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

procedure TLayerInfo.Activate(tool: IToolInfo);
begin
  FActiveTool := Tools.Add(tool);
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

{ TToolInfo }

constructor TToolInfo.Create(ATool: integer; ALinePos: int64);
begin
  inherited Create;
  FTool := ATool;
  FStartPos := ALinePos;
  FLastX := GCode.Null;
  FLastE := GCode.Null;
end;

class function TToolInfo.Make(ATool: integer; ALinePos: int64): IToolInfo;
begin
  Result := TToolInfo.Create(ATool, ALinePos);
end;

procedure TToolInfo.SetLastE(value: extended);
begin
  FLastE := value;
end;

procedure TToolInfo.SetLastX(value: extended);
begin
  FLastX := value;
end;

function TToolInfo.GetLastE: extended;
begin
  Result := FLastE;
end;

function TToolInfo.GetLastX: extended;
begin
  Result := FLastX;
end;

function TToolInfo.GetStartPos: int64;
begin
  Result := FStartPos;
end;

function TToolInfo.GetTool: integer;
begin
  Result := FTool;
end;

end.
