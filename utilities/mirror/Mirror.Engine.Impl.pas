unit Mirror.Engine.Impl;

interface

uses
  System.SysUtils, System.Classes,
  GpStuff,
  Mirror.Engine;

type
  TMirrorEngine = class(TInterfacedObject, IMirrorEngine)
  strict private
    FAbsolute    : boolean;
    FBaseGcode   : IGpBuffer;
    FErrorMessage: string;
    FFloatFormat : TFormatSettings;
    FMirrorX     : real;
    FMirrorY     : real;
    FOutputGcode : IGpBuffer;
  strict protected
    function  ReadLine(const gcode: TStream): AnsiString;
    function  GetBaseGcode: IGpBuffer;
    function  GetErrorMessage: string;
    function  GetMirrorX: real;
    function  GetMirrorY: real;
    function  GetOutputGcode: IGpBuffer;
    function  MirrorLine(line: AnsiString): AnsiString;
    function  MirrorPart(part: AnsiString): AnsiString;
    procedure SetBaseGcode(const value: IGpBuffer);
    procedure SetMirrorX(const value: real);
    procedure SetMirrorY(const value: real);
  public
    constructor Create;
    class function Make: IMirrorEngine;
    function Process: boolean;
    property BaseGcode: IGpBuffer read GetBaseGcode write SetBaseGcode;
    property ErrorMessage: string read GetErrorMessage;
    property MirrorX: real read GetMirrorX write SetMirrorX;
    property MirrorY: real read GetMirrorY write SetMirrorY;
    property OutputGcode: IGpBuffer read GetOutputGcode;
  end;

implementation

uses
  GpStreams,
  AnsiStrings;

constructor TMirrorEngine.Create;
begin
  inherited Create;
  FMirrorX := -1;
  FMirrorY := -1;
  FFloatFormat.ThousandSeparator := ',';
  FFloatFormat.DecimalSeparator := '.';
  FAbsolute := true;
end;

function TMirrorEngine.GetBaseGcode: IGpBuffer;
begin
  Result := FBaseGcode;
end;

function TMirrorEngine.GetErrorMessage: string;
begin
  Result := FErrorMessage;
end;

function TMirrorEngine.GetMirrorX: real;
begin
  Result := FMirrorX;
end;

function TMirrorEngine.GetMirrorY: real;
begin
  Result := FMirrorY;
end;

function TMirrorEngine.GetOutputGcode: IGpBuffer;
begin
  Result := FOutputGcode;
end;

class function TMirrorEngine.Make: IMirrorEngine;
begin
  Result := TMirrorEngine.Create;
end;

function TMirrorEngine.MirrorLine(line: AnsiString): AnsiString;
begin
  if line = '' then
    Exit(line);
  var cmd := Copy(line, 1, 3);
  if not (SameText(cmd, AnsiString('G0 ')) or SameText(cmd, AnsiString('G1 '))
          or SameText(cmd, AnsiString('G2 ')) or SameText(cmd, AnsiString('G3 '))) then
    Exit(line);

  if SameText(cmd, AnsiString('G90')) then
    FAbsolute := true
  else if SameText(cmd, AnsiString('G91')) then
    FAbsolute := false;

  Result := '';
  while line <> '' do begin
    if line[1] = '' then begin
      Result := AddToList(Result, AnsiString(' '), line);
      line := '';
    end
    else begin
      var p := Pos(AnsiString(' '), line);
      if p = 0 then begin
        Result := AddToList(Result, AnsiString(' '), MirrorPart(line));
        line := '';
      end
      else begin
        var part := Copy(line, 1, p-1);
        Delete(line, 1, p);
        Result := AddToList(Result, AnsiString(' '), MirrorPart(part));
      end;
    end;
  end;
end;

function TMirrorEngine.MirrorPart(part: AnsiString): AnsiString;
var
  value: double;
begin
  if (MirrorX >= 0) and (part[1] = 'X') then begin
    if not TryStrToFloat(string(Copy(part, 2)), value, FFloatFormat) then
      Result := part
    else if FAbsolute then
      Result := AnsiString(Format('X%f', [MirrorX + (MirrorX - value)], FFLoatFormat))
    else
      Result := AnsiString(Format('X%f', [-value], FFLoatFormat));
  end
  else if (MirrorY >= 0) and (part[1] = 'Y') then begin
    if not TryStrToFloat(string(Copy(part, 2)), value, FFloatFormat) then
      Result := part
    else if FAbsolute then
      Result := AnsiString(Format('Y%f', [MirrorY + (MirrorY - value)], FFLoatFormat))
    else
      Result := AnsiString(Format('Y%f', [-value], FFLoatFormat));
  end
  else
    Result := part;
end;

function TMirrorEngine.Process: boolean;
begin
  FErrorMessage := '';
  FOutputGcode := TGpBuffer.Make;

  var input := FBaseGcode.AsStream;
  input.GoToStart;

  while not input.AtEnd do begin
    var line := ReadLine(input);
    line := MirrorLine(line);
    FOutputGcode.AsStream.WriteAnsiStr(line);
    FOutputGcode.AsStream.WriteAnsiStr(#$0A);
  end;

  Result := FErrorMessage = '';
end;

function TMirrorEngine.ReadLine(const gcode: TStream): AnsiString;
var
  ch: byte;
begin
  var pos := gcode.Position;
  while (gcode.ReadData(ch) = 1) and (ch <> $0A) do
    ;
  SetLength(Result, gcode.Position - pos - Ord(ch = $0A));
  if Result <> '' then begin
    gcode.Position := pos;
    gcode.Read(Result[1], Length(Result));
    if ch = $0A then
      gcode.ReadData(ch);
  end;
end;

procedure TMirrorEngine.SetBaseGcode(const value: IGpBuffer);
begin
  FBaseGcode := value;
end;

procedure TMirrorEngine.SetMirrorX(const value: real);
begin
  FMirrorX := value;
end;

procedure TMirrorEngine.SetMirrorY(const value: real);
begin
  FMirrorY := value;
end;

end.
