program Sequential;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  GpStuff,
  GpStreams,
  Sequential.Engine in 'Sequential.Engine.pas',
  Sequential.Engine.Impl in 'Sequential.Engine.Impl.pas';

procedure Usage;
begin
  Writeln('Usage: sequential gcode_out gcode_fileA gcode_fileB ... gcode_fileZ');
end;

begin
  try
    var engine := TSequentialEngine.Make;
    // commandline: output-file file1 file2 file3 ... fileN
    if ParamCount < 3 then begin
      Usage;
      Exit;
    end;

    for var i := 2 to ParamCount do begin
      var buffer: IGpBuffer;
      if not ReadFromFile(ParamStr(i), buffer) then begin
        Writeln('File does not exist: ', ParamStr(i));
        Exit;
      end;
      engine.AddObject(buffer);
    end;

    if not engine.Process then begin
      Writeln('Error: ', engine.ErrorMessage);
      Exit;
    end;

    if not WriteToFile(ParamStr(1), engine.OutputGcode) then begin
      Writeln('Failed to write to file: ', ParamStr(1));
      Exit;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
