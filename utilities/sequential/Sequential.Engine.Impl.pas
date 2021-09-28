unit Sequential.Engine.Impl;

interface

uses
  System.Classes, System.Generics.Collections,
  GpStuff,
  Sequential.Engine;

type
  TSequentialEngine = class(TInterfacedObject, ISequentialEngine)
  strict private
    FErrorMessage: string;
    FObjects     : TList<IGpBuffer>;
    FOutputGCode : IGpBuffer;
  strict protected
    procedure AppendToOutput(const buffer: IGpBuffer; copyStartGcode, copyEndGcode: boolean);
    function  GetOutputGCode: IGpBuffer; protected
    function  GetErrorMessage: string;
    procedure PrefetchXYMove(gcode, outGcode: TStream; var line: AnsiString);
    function  ReadLine(const gcode: TStream): AnsiString;
  public
    constructor Create;
    destructor  Destroy; override;
    class function Make: ISequentialEngine;
    procedure AddObject(const gcode: IGpBuffer);
    function  Process: boolean;
    property ErrorMessage: string read GetErrorMessage;
    property OutputGCode: IGpBuffer read GetOutputGCode;
  end;

implementation

uses
  System.SysUtils, System.StrUtils, System.AnsiStrings,
  GpStreams;

{ TSequentialEngine }

procedure TSequentialEngine.AddObject(const gcode: IGpBuffer);
begin
  FObjects.Add(gcode);
end;

procedure TSequentialEngine.AppendToOutput(const buffer: IGpBuffer;
  copyStartGcode, copyEndGcode: boolean);
begin
  var inHeader := true;
  var gcode := buffer.AsStream;
  var outGcode := FOutputGCode.AsStream;
  while not gcode.AtEnd do begin
    var line := ReadLine(gcode);
    if inHeader and SameText(line, AnsiString(';LAYER_CHANGE')) then begin
      inHeader := false;
      if not copyStartGcode then
        PrefetchXYMove(gcode, outGcode, line);
    end;

    if (not inHeader) and SameText(line, AnsiString('; Filament-specific end gcode')) and (not copyEndGCode) then
      break;

    if (inHeader and copyStartGcode) or (not inHeader) then
      outGcode.WritelnAnsi(line);
  end;
end;

constructor TSequentialEngine.Create;
begin
  inherited Create;
  FObjects := TList<IGpBuffer>.Create;
end;

destructor TSequentialEngine.Destroy;
begin
  FreeAndNil(FObjects);
  inherited;
end;

function TSequentialEngine.GetErrorMessage: string;
begin
  Result := FErrorMessage;
end;

function TSequentialEngine.GetOutputGCode: IGpBuffer;
begin
  Result := FOutputGCode;
end;

class function TSequentialEngine.Make: ISequentialEngine;
begin
  Result := TSequentialEngine.Create;
end;

procedure TSequentialEngine.PrefetchXYMove(gcode, outGcode: TStream; var line: AnsiString);
var
  buffer: TList<AnsiString>;
begin
  buffer := TList<AnsiString>.Create;
  try
    outGcode.WritelnAnsi(line);
    while not gcode.AtEnd do begin
      line := ReadLine(gcode);
      if line = '' then
        outGcode.Writeln
      else if line[1] = ';' then begin
        outGcode.WritelnAnsi(line);
        line := '';
      end
      else if   (SameText(Copy(line, 1, 3), AnsiString('G0 '))
                or SameText(Copy(line, 1, 3), AnsiString('G1 ')))
              and
                ((Pos(AnsiString('X'), line) > 0)
                 or (Pos(AnsiString('Y'), line) > 0))
      then begin
        outGcode.WritelnAnsi(line);
        if buffer.Count > 0 then begin
          line := buffer[buffer.Count - 1];
          buffer.Delete(buffer.Count - 1);
        end
        else
          line := ReadLine(gcode);
        break; // while
      end
      else
        buffer.Add(line);
    end;

    for var s in buffer do
      outGcode.WritelnAnsi(s);
  finally FreeAndNil(buffer); end;
end;

function TSequentialEngine.Process: boolean;
begin
  FErrorMessage := '';
  FOutputGCode := TGpBuffer.Make;

  for var i := 0 to FObjects.Count - 1 do
    AppendToOutput(FObjects[i], i = 0, i = (FObjects.Count - 1));

  Result := (FErrorMessage = '');
end;

function TSequentialEngine.ReadLine(const gcode: TStream): AnsiString;
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

end.

