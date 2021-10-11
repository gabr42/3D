unit Mirror.Engine;

interface

uses
  GpStuff,
  GCode.Processor;

type
  IMirrorEngine = interface(IGCodeProcessor) ['{A0CCEB35-B67C-40A4-9DA7-38F9AB0F3544}']
    function  GetBaseGcode: IGpBuffer;
    function  GetMirrorX: real;
    function  GetMirrorY: real;
    procedure SetBaseGcode(const value: IGpBuffer);
    procedure SetMirrorX(const value: real);
    procedure SetMirrorY(const value: real);
  //
    property BaseGcode: IGpBuffer read GetBaseGcode write SetBaseGcode;
    property MirrorX: real read GetMirrorX write SetMirrorX;
    property MirrorY: real read GetMirrorY write SetMirrorY;
  end;

implementation

end.
