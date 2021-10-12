unit Interleave.Engine;

interface

uses
  GpStuff,
  GCode.Processor;

type
  IInterleaveEngine = interface(IGCodeProcessor) ['{E6B6AACE-F7CB-4454-8C64-1833E85D8138}']
    procedure AddObject(const gcode: IGpBuffer; isMaster: boolean);
  end;

implementation

end.
