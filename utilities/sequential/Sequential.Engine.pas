unit Sequential.Engine;

interface

uses
  GpStuff;

type
  ISequentialEngine = interface ['{2B84556A-67FB-4704-875D-296B046EBD3A}']
    function  GetErrorMessage: string;
    function  GetOutputGCode: IGpBuffer;
  //
    procedure AddObject(const gcode: IGpBuffer);
    function  Process: boolean;
    property ErrorMessage: string read GetErrorMessage;
    property OutputGCode: IGpBuffer read GetOutputGCode;
  end;

implementation

end.
