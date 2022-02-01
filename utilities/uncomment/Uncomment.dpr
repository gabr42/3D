program Uncomment;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes;

procedure Usage;
begin
  Writeln('Usage: uncomment gcode_file_in gfile_uncommented_out');
end;

begin
  if ParamCount <> 2 then begin
    Usage;
    Exit;
  end;

  var sl := TStringList.Create;
  try
    sl.LoadFromFile(ParamStr(1));
    for var i := 0 to sl.Count - 1 do begin
      var p := Pos(';', sl[i]);
      if p > 0 then
        sl[i] := Copy(sl[i], 1, p-1);
    end;
    sl.SaveToFile(ParamStr(2));
  finally FreeAndNil(sl); end;
end.
