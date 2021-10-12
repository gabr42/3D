program Interleave;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  GpStuff,
  GpStreams,
  Interleave.Engine in 'Interleave.Engine.pas',
  Interleave.Engine.Impl in 'Interleave.Engine.Impl.pas';

procedure Usage;
begin
  Writeln('Usage: interleave gcode_out [+]gcode_fileA [+]gcode_fileB ... [+]gcode_fileZ');
  Writeln('       Mark the "master" file (containing preamble and endcode) with a "+"');
end;

begin
  try
    var engine := TInterleaveEngine.Make;
    // commandline: output-file file file file ... +file
    if ParamCount < 3 then begin
      Usage;
      Exit;
    end;

    for var i := 2 to ParamCount do begin
      var buffer: IGpBuffer;
      var fName := ParamStr(i);
      var isMaster := false;
      if fName.StartsWith('+') then begin
        isMaster := true;
        Delete(fName, 1, 1);
      end;
      if not ReadFromFile(fName, buffer) then begin
        Writeln('File does not exist: ', fName);
        Exit;
      end;
      engine.AddObject(buffer, isMaster);
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

