unit Interleave.Engine.Impl;

interface

uses
  GpStuff,
  Interleave.Engine,
  GCode, GCode.Processor.Impl;

type
  TInterleaveEngine = class(TGCodeProcessor, IInterleaveEngine)
  strict private
    FMasterGCode: integer;
  strict protected
    procedure CopyHeader(const gcode: IGCode);
    procedure CopyFooter(const gcode: IGCode);
  public
    class function Make: IInterleaveEngine;
    procedure AddObject(const gcode: IGpBuffer; isMaster: boolean);
    function  Process: boolean; override;
  end;

implementation

uses
  System.SysUtils,
  GCode.Impl;

{ TInterleaveEngine }

procedure TInterleaveEngine.AddObject(const gcode: IGpBuffer; isMaster: boolean);
begin
  var idx := GCodeList.Add(TGCode.Make(gcode));
  if isMaster then
    FMasterGCode := idx;
end;

procedure TInterleaveEngine.CopyFooter(const gcode: IGCode);
begin
  gcode.AsStream.Position := gcode.Index.Footer.StartPos;
  OutputGCode.AsStream.CopyFrom(gcode.AsStream, gcode.AsStream.Size - gcode.AsStream.Position);
end;

procedure TInterleaveEngine.CopyHeader(const gcode: IGCode);
begin
  gcode.AsStream.Position := gcode.Index.Header.StartPos;
  OutputGCode.AsStream.CopyFrom(gcode.AsStream, gcode.Index.Layers[0].StartPos - gcode.AsStream.Position);
end;

class function TInterleaveEngine.Make: IInterleaveEngine;
begin
  Result := TInterleaveEngine.Create;
end;

function TInterleaveEngine.Process: boolean;
begin
  inherited Process;

  for var i := 0 to GCodeList.Count - 1 do
    if not assigned(GCodeList[i].Index) then
      Exit(SetError(Format('[%d] %s', [i, GCodeList[i].ErrorMessage])));

  CopyHeader(GCodeList[FMasterGCode]);
  CopyFooter(GCodeList[FMasterGCode]);

  Result := SetError('Not implemented');
  Result := true;
end;

end.
