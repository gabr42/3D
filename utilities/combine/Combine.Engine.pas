unit Combine.Engine;

interface

uses
  GpStuff;

type
  ICombinerEngine = interface ['{EAA073BA-0754-49C5-A519-37643CAE5DB5}']
    function  GetBaseGcode: IGpBuffer;
    function  GetErrorMessage: string;
    function  GetOutputGcode: IGpBuffer;
    procedure SetBaseGcode(const value: IGpBuffer);
  //
    procedure ChangeAtLayer(layer: real; const gcode: IGpBuffer);
    function  Process: boolean;
    property BaseGcode: IGpBuffer read GetBaseGcode write SetBaseGcode;
    property ErrorMessage: string read GetErrorMessage;
    property OutputGcode: IGpBuffer read GetOutputGcode;
  end;

implementation

end.
