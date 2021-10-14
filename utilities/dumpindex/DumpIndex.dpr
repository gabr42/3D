program DumpIndex;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  GpStuff, GpStreams,
  GCode, GCode.Impl;

  function PositionToStr(const pos: IPosition): string;
  begin
    Result := Format('X=%.3f, Y=%.3f, Z=%.3f, E=%.5f', [pos.X, pos.Y, pos.Z, pos.E], GCode.FormatSettings);
  end;

  procedure DumpLayer(const name: string; const layer: ILayerInfo; dumpTools: boolean);
  begin
    Writeln(name);
    Writeln('  Data: ', layer.StartPos, '-', layer.StartPos + layer.Size - 1);
    Writeln('  First: ', PositionToStr(layer.FirstPosition));
    Writeln('  Last: ', PositionToStr(layer.LastPosition));
    if dumpTools then
      for var tool in layer.Tools do begin
        Writeln('  T', tool.Tool);
        Writeln('    Data: ', tool.StartPos, '-', tool.StartPos + tool.Size - 1);
        Writeln('    First: ', PositionToStr(tool.FirstPosition));
        Writeln('    Last: ', PositionToStr(tool.LastPosition));
      end
  end;

begin
  try
    if ParamCount <> 1 then
      Writeln('Usage: dumpindex file.gcode')
    else begin
      var buf: IGpBuffer;
      if not ReadFromFile(ParamStr(1), buf) then
        Writeln('File does not exist: ', ParamStr(1))
      else begin
        var gcode := TGCode.Make(buf);
        var index := gcode.Index;
        if not assigned(index) then
          Writeln('Failed to reindex file. ', gcode.ErrorMessage)
        else begin
          DumpLayer('Header', index.Header, false);
          for var layer in index.Layers do
            DumpLayer('Layer ' + Format('%.2f', [layer.Z]), layer, true);
          DumpLayer('Footer', index.Footer, false);
        end;
      end;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
