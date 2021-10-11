unit Sequential.Engine;

interface

uses
  GpStuff,
  GCode.Processor;

type
  ISequentialEngine = interface(IGCodeProcessor) ['{2B84556A-67FB-4704-875D-296B046EBD3A}']
  //
    procedure AddObject(const gcode: IGpBuffer);
  end;

implementation

end.
