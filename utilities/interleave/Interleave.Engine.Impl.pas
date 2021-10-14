unit Interleave.Engine.Impl;

interface

uses
  System.Classes,
  GpStuff, GpStreams,
  Interleave.Engine,
  GCode, GCode.Processor.Impl;

type
  TInterleaveEngine = class(TGCodeProcessor, IInterleaveEngine)
  strict private
    FMasterGCode: integer;
  strict protected
    procedure CopyFooter(const gcode: IGCode);
    procedure CopyHeader(const gcode: IGCode);
    procedure CopyLayer(const source: string; z: extended; tool: integer;
      const gc: IGCode; var firstTool: boolean);
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

procedure TInterleaveEngine.CopyLayer(const source: string; z: extended; tool: integer;
  const gc: IGCode; var firstTool: boolean);
begin
  var toolInfo := gc.Index.FindTool(z, tool);
  if assigned(toolInfo) then begin
    OutputGCode.AsStream.WritelnAnsi(AnsiString('; interleave start ' + source + ' tool ' + tool.ToString));
    if firstTool then
      OutputGCode.AsStream.WritelnAnsi(AnsiString('T' + tool.ToString));
    firstTool := false;
    OutputGCode.AsStream.WritelnAnsi(AnsiString('G92 E' + Format('%.5f', [toolInfo.FirstPosition.E], GCode.FormatSettings)));
    gc.AsStream.Position := toolInfo.StartPos;
    OutputGCode.AsStream.CopyFrom(gc.AsStream, toolInfo.Size);
    OutputGCode.AsStream.WritelnAnsi(AnsiString('; interleave end ' + source + ' tool ' + tool.ToString));
  end;
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

  for var layer in GCodeList[FMasterGCode].Index.Layers do
    for var tool in layer.Tools do begin
      var firstTool := true;
      for var i := 0 to GCodeList.Count - 1 do
        CopyLayer('source ' + i.ToString, layer.Z, tool.Tool, GCodeList[i], firstTool);
    end;

  CopyFooter(GCodeList[FMasterGCode]);

  Result := true;
end;

end.
