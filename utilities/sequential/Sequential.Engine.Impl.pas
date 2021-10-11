unit Sequential.Engine.Impl;

interface

uses
  System.Classes, System.Generics.Collections,
  GpStuff,
  GCode, GCode.Processor.Impl,
  Sequential.Engine;

type
  TSequentialEngine = class(TGCodeProcessor, ISequentialEngine)
  strict protected
    procedure AppendToOutput(const gcode: IGCode; copyStartGcode, copyEndGcode: boolean);
    procedure PrefetchXYMove(const gcode: IGCode; outGcode: TStream; var line: AnsiString);
  public
    class function Make: ISequentialEngine;
    procedure AddObject(const gcode: IGpBuffer);
    function  Process: boolean; override;
  end;

implementation

uses
  System.SysUtils, System.StrUtils, System.AnsiStrings,
  GpStreams,
  GCode.Impl;

{ TSequentialEngine }

procedure TSequentialEngine.AddObject(const gcode: IGpBuffer);
begin
  GCodeList.Add(TGCode.Make(gcode));
end;

procedure TSequentialEngine.AppendToOutput(const gcode: IGCode;
  copyStartGcode, copyEndGcode: boolean);
begin
  var outGcode := OutputGCode.AsStream;
  while not gcode.AsStream.AtEnd do begin
    var prevSection := gcode.Section;
    var line := gcode.ReadLine;
    if (prevSection = secHeader) and (gcode.Section = secObject) then begin
      if not copyStartGcode then
        PrefetchXYMove(gcode, outGcode, line);
    end;

    if (prevSection <> secEndcode) and (gcode.Section = secEndcode) and (not copyEndGCode) then
      break;

    if ((gcode.Section = secHeader) and copyStartGcode) or (gcode.Section <> secHeader) then
      outGcode.WritelnAnsi(line);
  end;
end;

class function TSequentialEngine.Make: ISequentialEngine;
begin
  Result := TSequentialEngine.Create;
end;

procedure TSequentialEngine.PrefetchXYMove(const gcode: IGCode; outGcode: TStream; var line: AnsiString);
var
  buffer: TList<AnsiString>;

  function IsXYMove(const line: AnsiString): boolean;
  begin
    if not gcode.IsMove(line) then
      Exit(false);

    var s := gcode.RemoveComment(line);
    Result := ((Pos(AnsiString('X'), s) > 0)
              or (Pos(AnsiString('Y'), s) > 0));
  end;

begin
  buffer := TList<AnsiString>.Create;
  try
    outGcode.WritelnAnsi(line);
    while not gcode.AtEnd do begin
      line := gcode.ReadLine;
      if line = '' then
        outGcode.Writeln
      else if gcode.IsComment(line) then begin
        outGcode.WritelnAnsi(line);
        line := '';
      end
      else if IsXYMove(line) then begin
        outGcode.WritelnAnsi(line);
        if buffer.Count > 0 then begin
          line := buffer[buffer.Count - 1];
          buffer.Delete(buffer.Count - 1);
        end
        else
          line := gcode.ReadLine;
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
  inherited Process;

  for var i := 0 to GCodeList.Count - 1 do
    AppendToOutput(GCodeList[i], i = 0, i = (GCodeList.Count - 1));

  Result := (ErrorMessage = '');
end;

end.

