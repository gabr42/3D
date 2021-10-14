unit Interleave.Engine.Impl;

interface

uses
  System.Classes, System.Generics.Collections,
  GpStuff, GpStreams,
  Interleave.Engine,
  GCode, GCode.Processor.Impl;

type
  TInterleaveEngine = class(TGCodeProcessor, IInterleaveEngine)
  strict private
    FMasterGCode: integer;
    FRetractions: array of array of extended;
  strict protected
    procedure CopyFooter(const gcode: IGCode);
    procedure CopyHeader(const gcode: IGCode);
    procedure CopyObject(const source: string; z: extended; toolInfo: IToolInfo;
      const gc: IGCode; hasExtraExtrusion, hasExtraRetraction: boolean;
      extraExtrusion, extraRetraction: extended;
      firstLayer, firstTool, lastTool, firstObject, lastObject: boolean);
    procedure CopyObjectsForLayerTool(layerZ: extended; tool: integer;
      isFirstLayer, isFirstTool, isLastTool: boolean);
    procedure CollectToolChangeRetractions;
    procedure ReadObject(const gc: IGCode; endPos: int64; list: TList<AnsiString>);
    procedure RemoveExtraRetraction(const gc: IGCode; list: TList<AnsiString>;
      extraRetraction: extended);
    procedure RemoveToolChanges(list: TList<AnsiString>);
    procedure ReplaceFirstG92(const gc: IGCode; list: TList<AnsiString>; extrude: extended);
  public
    class function Make: IInterleaveEngine;
    procedure AddObject(const gcode: IGpBuffer; isMaster: boolean);
    function  Process: boolean; override;
  end;

implementation

uses
  System.SysUtils, System.AnsiStrings, System.Math,
  System.Generics.Defaults,
  GCode.Impl;

{ TInterleaveEngine }

procedure TInterleaveEngine.AddObject(const gcode: IGpBuffer; isMaster: boolean);
begin
  var idx := GCodeList.Add(TGCode.Make(gcode));
  if isMaster then
    FMasterGCode := idx;
end;

procedure TInterleaveEngine.CollectToolChangeRetractions;
var
  retract    : string;
  retractTool: extended;
begin
  var maxTool := 1;
  for var gc in GCodeList do
    for var layer in gc.Index.Layers do
      if layer.Tools.Count > maxTool then
        maxTool := layer.Tools.Count;

  SetLength(FRetractions, GCodeList.Count, maxTool);

  for var i := 0 to GCodeList.Count - 1 do
    if GCodeList[i].Index.Properties.TryGetValue('retract_length_toolchange', retract) then begin
      var retractions := retract.Split([',']);
      for var j := 0 to High(retractions) do
        if TryStrToFloat(retractions[j], retractTool, GCode.FormatSettings) then
          FRetractions[i, j] := retractTool;
    end;
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

procedure TInterleaveEngine.CopyObject(const source: string; z: extended; toolInfo: IToolInfo;
  const gc: IGCode; hasExtraExtrusion, hasExtraRetraction: boolean;
  extraExtrusion, extraRetraction: extended;
  firstLayer, firstTool, lastTool, firstObject, lastObject: boolean);
begin
  var outputStream := OutputGCode.AsStream;

  outputStream.WritelnAnsi(AnsiString('; interleave start ' + source + ' tool ' + toolInfo.Tool.ToString));
  if firstObject then
    outputStream.WritelnAnsi(AnsiString('T' + toolInfo.Tool.ToString));

  var list := TList<AnsiString>.Create;
  try
    gc.AsStream.Position := toolInfo.StartPos;
    ReadObject(gc, toolInfo.StartPos + toolInfo.Size - 1, list);

    // hasExtraExtrusion  => ~firstLayer & ~firstTool & firstObject => keep
    //                       else                                   => remove
    var startE := toolInfo.FirstPosition.E;
    if hasExtraExtrusion and (not firstLayer) and (firstTool or (not firstObject)) then begin
      startE := startE + extraExtrusion; // undo extra extrusion
      ReplaceFirstG92(gc, list, startE);
    end
    else
      list.Insert(0, AnsiString('G92 E' + Format('%.5f', [startE], GCode.FormatSettings)));

    // hasExtraRetraction => ~lastTool & lastObject   => keep
    //                       else                     => remove
    if hasExtraRetraction and (lastTool or (not lastObject)) then
      RemoveExtraRetraction(gc, list, extraRetraction);

    RemoveToolChanges(list);

    for var s in list do
      outputStream.WritelnAnsi(s);

  finally FreeAndNil(list); end;
  outputStream.WritelnAnsi(AnsiString('; interleave end ' + source + ' tool ' + toolInfo.Tool.ToString));
end;

procedure TInterleaveEngine.CopyObjectsForLayerTool(layerZ: extended; tool: integer;
  isFirstLayer, isFirstTool, isLastTool: boolean);
var
  i: integer;
begin
  var firstGC := GCodeList.Count;
  var lastGC := -1;
  for i := 0 to GCodeList.Count - 1 do begin
    if GCodeList[i].Index.FindToolIdx(layerZ, tool) >= 0 then begin
      if i < firstGC then
        firstGC := i;
      lastGC := i;
    end;
  end;

  if lastGC < 0 then
    Exit;

  for i := firstGC to lastGC do begin
    var _layer := GCodeList[i].Index.FindLayer(layerZ);
    if assigned(_layer) then begin
      var idx := _layer.FindToolIdx(tool);
      if idx >= 0 then begin
        var _tool := _layer.Tools[idx];
        CopyObject('source ' + i.ToString, layerZ, _tool, GCodeList[i],
          (idx > 0), (idx < (_layer.Tools.Count - 1)),
          FRetractions[i, _tool.Tool], FRetractions[i, _tool.Tool],
          isFirstLayer, isFirstTool, isLastTool, i = firstGC, i = lastGC);
      end;
    end;
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

  CollectToolChangeRetractions;

  for var iLayer := 0 to GCodeList[FMasterGCode].Index.Layers.Count - 1 do begin
    var layer := GCodeList[FMasterGCode].Index.Layers[iLayer];
    for var iTool := 0 to layer.Tools.Count - 1 do
      CopyObjectsForLayerTool(layer.Z, layer.Tools[iTool].Tool, iLayer = 0, iTool = 0, iTool = (layer.Tools.Count - 1));
  end;

  CopyFooter(GCodeList[FMasterGCode]);

  Result := true;
end;

procedure TInterleaveEngine.ReadObject(const gc: IGCode; endPos: int64;
  list: TList<AnsiString>);
begin
  while gc.AsStream.Position <= endPos do
    list.Add(gc.ReadLine);
end;

procedure TInterleaveEngine.RemoveExtraRetraction(const gc: IGCode; list: TList<AnsiString>;
  extraRetraction: extended);
var
  x, y, z, e: extended;
begin
  for var i := list.Count - 1 downto 0 do begin
    var line := list[i];
    var cmd := Copy(line, 1, 3);
    if SameText(cmd, AnsiString('G0 ')) or SameText(cmd, AnsiString('G1 ')) then begin
      gc.ExtractPositions(line, x, y, z, e);
      if e <> GCode.Null then begin
        e := e + extraRetraction;
        list[i] := gc.UpdatePositions(line, x, y, z, e);
        break; //for i
      end;
    end;
  end;
end;

procedure TInterleaveEngine.RemoveToolChanges(list: TList<AnsiString>);
begin
  for var i := list.Count - 1 downto 0 do
    if SameText(Copy(list[i], 1, 1), AnsiString('T')) then
      list.Delete(i);
end;

procedure TInterleaveEngine.ReplaceFirstG92(const gc: IGCode; list: TList<AnsiString>;
  extrude: extended);
var
  x, y, z, e: extended;
begin
  for var i := 0 to list.Count - 1 do begin
    var cmd := UpperCase(Copy(list[i], 1, 3));
    if cmd = 'G92' then begin
      gc.ExtractPositions(list[i], x, y, z, e);
      if e <> GCode.Null then begin
        list[i] := gc.UpdatePositions(list[i], x, y, z, extrude);
        Exit;
      end;
    end
    else if (cmd = 'G0 ') or (cmd = 'G1 ') or (cmd = 'G2 ') or (cmd = 'G3 ') then
      break; //for
  end;
  list.Insert(0, AnsiString('G92 E' + Format('%.5f', [extrude], GCode.FormatSettings)));
end;

end.
