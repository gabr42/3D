unit Interleave.Engine.Impl;

interface

uses
  GpStuff,
  Interleave.Engine,
  GCode.Processor.Impl;

type
  TInterleaveEngine = class(TGCodeProcessor)
  public
    class function Make: IInterleaveEngine;
    procedure AddObject(const gcode: IGpBuffer);
    function  Process: boolean; override;
  end;

implementation

uses
  GCode.Impl;

{ TInterleaveEngine }

procedure TInterleaveEngine.AddObject(const gcode: IGpBuffer);
begin
  GCodeList.Add(TGCode.Make(gcode));
end;

class function TInterleaveEngine.Make: IInterleaveEngine;
begin
  Result := TInterleaveEngine.Make;
end;

function TInterleaveEngine.Process: boolean;
begin
  //
end;

end.
