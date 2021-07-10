program Mirror;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  GpStuff,
  GpStreams,
  Mirror.Engine in 'Mirror.Engine.pas',
  Mirror.Engine.Impl in 'Mirror.Engine.Impl.pas';

procedure Usage;
begin
  Writeln('Usage: mirror gcode_out gcode_in [X<num>] [Y<num>]');
end;

begin
  try
    var engine := TMirrorEngine.Make;
    if ParamCount < 3 then begin
      Usage;
      Exit;
    end;

    var buffer: IGpBuffer;
    if not ReadFromFile(ParamStr(2), buffer) then begin
      Writeln('File does not exist: ', ParamStr(2));
      Exit;
    end;
    engine.BaseGcode := buffer;

    for var i := 3 to ParamCount do begin
      var s := ParamStr(i);
      if not (s.StartsWith('X', true) or s.StartsWith('Y', true)) then begin
        Usage;
        Exit;
      end;
      var mirrorLine: double;
      var floatFormat: TFormatSettings;
      floatFormat.ThousandSeparator := ',';
      floatFormat.DecimalSeparator := '.';
      if not TryStrToFloat(Copy(s, 2), mirrorLine, floatFormat) then begin
        Writeln('Invalid mirror line: ', s);
        Exit;
      end;
      if s.StartsWith('X', true) then
        engine.MirrorX := mirrorLine
      else
        engine.MirrorY := mirrorLine;
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
