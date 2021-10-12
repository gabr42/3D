unit GCode;

interface

uses
  System.Classes;

type
  TGCodeSection = (secHeader, secObject, secEndcode);

  IGCode = interface ['{2A72F9D7-B26D-471C-B816-54F355B9BE29}']
    function  GetErrorMessage: string;
  //
    function AsStream: TStream;
    function AtEnd: boolean;
    function GenerateIndex: boolean;
    function IsComment(const line: AnsiString): boolean;
    function IsEndCode(const line: AnsiString): boolean;
    function IsLayerChange(const line: AnsiString): boolean;
    function IsMove(const line: AnsiString): boolean;
    function ReadLine: AnsiString;
    function RemoveComment(const line: AnsiString): AnsiString;
    function Section: TGCodeSection;
    function Tool: integer;
    property ErrorMessage: string read GetErrorMessage;
  end;

implementation

end.
