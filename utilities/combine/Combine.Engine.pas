unit Combine.Engine;

interface

uses
  GpStuff,
  GCode.Processor;

type
  ICombinerEngine = interface(IGCodeProcessor) ['{EAA073BA-0754-49C5-A519-37643CAE5DB5}']
    function  GetBaseGcode: IGpBuffer;
    procedure SetBaseGcode(const value: IGpBuffer);
  //
    procedure ChangeAtLayer(layer: real; const gcode: IGpBuffer);
    property BaseGcode: IGpBuffer read GetBaseGcode write SetBaseGcode;
  end;

implementation

end.
