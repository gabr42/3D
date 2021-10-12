unit GCode.Impl;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  GpStuff, GpStreams,
  GCode;

type
  TGCode = class(TInterfacedObject, IGCode)
  strict private
  type
    TToolChange = record
      Tool   : integer;
      LinePos: int64;
      constructor Create(ATool: integer; ALinePos: int64);
    end;
    TLayerChange = record
    public
      Z          : real;
      LinePos    : int64;
      Tool       : integer;
      ToolChanges: TList<TToolChange>;
      constructor Create(AZ: real; ALinePos: int64; ATool: integer);
    end;
    TGCodeIndex = record
    public
      FirstLayer: int64;
      EndCode   : int64;
      Layers    : TList<TLayerChange>;
      class operator Initialize (out Dest: TGCodeIndex);
      class operator Finalize (var Dest: TGCodeIndex);
      function ActiveLayer: TLayerChange;
    end;
  var
    FErrorMsg    : string;
    FFormat      : TFormatSettings;
    FGCode       : IGpBuffer;
    FGCodeStream : TStream;
    FIndex       : TGCodeIndex;
    FSection     : TGCodeSection;
    FTool        : integer;
  strict protected
    function GetErrorMessage: string;
    function SetError(const errorMsg: string): boolean;
  public
    constructor Create(const buffer: IGpBuffer);
    class function Make(const buffer: IGpBuffer): IGCode;
    function AsStream: TStream; inline;
    function AtEnd: boolean; inline;
    function GenerateIndex: boolean;
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
  end;

implementation

uses
  System.AnsiStrings;

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

function TGCode.AsStream: TStream; {inline}
begin
  Result := FGCodeStream;
end;

function TGCode.AtEnd: boolean; {inline}
begin
  Result := FGCodeStream.AtEnd;
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
  Result := SameText(Copy(line, 1, 3), AnsiString('G0 '))
            or SameText(Copy(line, 1, 3), AnsiString('G1 '));
end;

function TGCode.LookaheadLayerZHeight(var z: extended): boolean;
begin
  with KeepStreamPosition(FGCodeStream) do begin
    var line := ReadLine;
    if not SameText(Copy(line, 1, 3), AnsiString(';Z:')) then
      Exit(SetError('Unexpected layer change  start: ' + string(line)));

    Delete(line, 1, 3);
    if not TryStrToFloat(line, z, FFormat) then
      Exit(SetError('Unexpected Z-value format: ' + string(line)));

    Result := true;
  end;
end;

function TGCode.GenerateIndex: boolean;
var
  z: extended;
begin
  Result := true;
  FGCodeStream.GoToStart;
  while not AtEnd do begin
    var linePos := FGCodeStream.Position;
    var prevSect := Section;
    var prevTool := Tool;
    var line := ReadLine;

    if prevSect <> Section then begin
      if Section = secObject then
        FIndex.FirstLayer := linePos
      else if Section = secEndcode then
        FIndex.EndCode := linePos;
    end;

    if IsLayerChange(line) then begin
      if not LookaheadLayerZHeight(z) then
        Exit(false);
      FIndex.Layers.Add(TLayerChange.Create(z, linePos, Tool));
    end;

    if (Section <> secHeader) and (Tool <> prevTool) then
      FIndex.ActiveLayer.ToolChanges.Add(TToolChange.Create(Tool, linePos));
  end;
end;

function TGCode.GetErrorMessage: string;
begin
  Result := FErrorMsg;
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

{ TGCode.TGCodeIndex }

class operator TGCode.TGCodeIndex.Initialize(out Dest: TGCodeIndex);
begin
  Dest.FirstLayer := -1;
  Dest.EndCode    := -1;
  Dest.Layers := TList<TLayerChange>.Create;
end;

class operator TGCode.TGCodeIndex.Finalize(var Dest: TGCodeIndex);
begin
  FreeAndNil(Dest.Layers);
end;

function TGCode.TGCodeIndex.ActiveLayer: TLayerChange;
begin
  Result := Layers[Layers.Count-1];
end;

{ TGCode.TLayerChange }

constructor TGCode.TLayerChange.Create(AZ: real; ALinePos: int64; ATool: integer);
begin
  Z := AZ;
  LinePos := ALinePos;
  Tool := ATool;
end;

{ TGCode.TToolChange }

constructor TGCode.TToolChange.Create(ATool: integer; ALinePos: int64);
begin
  Tool := ATool;
  LinePos := ALinePos;
end;

end.
