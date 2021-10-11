unit GCode.Processor;

interface

uses
  System.Generics.Collections,
  GpStuff,
  GCode;

type
  IGCodeProcessor = interface ['{449ACABC-D251-400C-8621-08F4471C5717}']
    function  GetErrorMessage: string;
    function  GetGCodeList: TList<IGCode>;
    function  GetOutputGCode: IGpBuffer;
  //
    function  Process: boolean;
    property ErrorMessage: string read GetErrorMessage;
    property GCodeList: TList<IGCode> read GetGCodeList;
    property OutputGCode: IGpBuffer read GetOutputGCode;
  end;

implementation

end.
