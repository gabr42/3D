unit GCode.Impl;

interface

uses
  System.Classes,
  GpStuff,
  GCode;

type
  TGCode = class(TInterfacedObject, IGCode)
  strict private
    FGCode       : IGpBuffer;
    FGCodeStream : TStream;
    FSection     : TGCodeSection;
    FTool        : integer;
  public
    constructor Create(const buffer: IGpBuffer);
    class function Make(const buffer: IGpBuffer): IGCode;
    function AsStream: TStream;
    function AtEnd: boolean;
    function IsComment(const line: AnsiString): boolean;
    function IsEndCode(const line: AnsiString): boolean;
    function IsLayerChange(const line: AnsiString): boolean;
    function IsMove(const line: AnsiString): boolean;
    function ReadLine: AnsiString;
    function RemoveComment(const line: AnsiString): AnsiString;
    function Section: TGCodeSection;
    function Tool: integer;
  end;

implementation

uses
  System.SysUtils, System.AnsiStrings,
  GpStreams;

{ TGCode }

function TGCode.AsStream: TStream;
begin
  Result := FGCodeStream;
end;

function TGCode.AtEnd: boolean;
begin
  Result := FGCodeStream.AtEnd;
end;

constructor TGCode.Create(const buffer: IGpBuffer);
begin
  inherited Create;
  FGCode := buffer;
  FGCodeStream := FGCode.AsStream;
  FSection := secHeader;
end;

function TGCode.IsComment(const line: AnsiString): boolean;
begin
  Result := (line <> '') and (line[1] = ';');
end;

function TGCode.IsEndCode(const line: AnsiString): boolean;
begin
  Result := SameText(line, AnsiString('G91 ;Relative positioning'));
end;

function TGCode.IsLayerChange(const line: AnsiString): boolean;
begin
  Result := SameText(line, AnsiString(';LAYER_CHANGE'));
end;

function TGCode.IsMove(const line: AnsiString): boolean;
begin
  Result := SameText(Copy(line, 1, 3), AnsiString('G0 '))
            or SameText(Copy(line, 1, 3), AnsiString('G1 '));
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

function TGCode.Tool: integer;
begin
  Result := FTool;
end;

end.
