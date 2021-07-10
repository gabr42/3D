unit Mirror.Engine;

interface

uses
  GpStuff;

type
  IMirrorEngine = interface ['{A0CCEB35-B67C-40A4-9DA7-38F9AB0F3544}']
    function  GetBaseGcode: IGpBuffer;
    function  GetErrorMessage: string;
    function  GetMirrorX: real;
    function  GetMirrorY: real;
    function  GetOutputGcode: IGpBuffer;
    procedure SetBaseGcode(const value: IGpBuffer);
    procedure SetMirrorX(const value: real);
    procedure SetMirrorY(const value: real);
  //
    function Process: boolean;
    property BaseGcode: IGpBuffer read GetBaseGcode write SetBaseGcode;
    property ErrorMessage: string read GetErrorMessage;
    property MirrorX: real read GetMirrorX write SetMirrorX;
    property MirrorY: real read GetMirrorY write SetMirrorY;
    property OutputGcode: IGpBuffer read GetOutputGcode;
  end;

implementation

end.
