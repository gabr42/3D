program Combine;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  GpStuff,
  GpStreams,
  Combine.Engine in 'Combine.Engine.pas',
  Combine.Engine.Impl in 'Combine.Engine.Impl.pas';

procedure Usage;
begin
  Writeln('Usage: combiner gcode_out gcode_fileA layerA gcode_fileB layerB ... gcode_fileY layerY gcode_fileZ');
end;

begin
  try
    var engine := TCombinerEngine.Make;
    // commandline: output-file file layer file layer file layer ... file layer file
    if ParamCount < 4 then begin
      Usage;
      Exit;
    end;

    var buffer: IGpBuffer;
    if not ReadFromFile(ParamStr(2), buffer) then begin
      Writeln('File does not exist: ', ParamStr(2));
      Exit;
    end;
    engine.BaseGcode := buffer;

    var i := 3;
    while i < ParamCount do begin
      if (i + 1) > ParamCount then begin
        Usage;
        Exit;
      end;
      var layer: double;
      var floatFormat: TFormatSettings;
      floatFormat.ThousandSeparator := ',';
      floatFormat.DecimalSeparator := '.';
      if not TryStrToFloat(ParamStr(i), layer, floatFormat) then begin
        Writeln('Invalid layer height: ', ParamStr(i));
        Exit;
      end;
      if not ReadFromFile(ParamStr(i+1), buffer) then begin
        Writeln('File does not exist: ', ParamStr(i+1));
        Exit;
      end;
      engine.ChangeAtLayer(layer, buffer);
      Inc(i, 2);
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
