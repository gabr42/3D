unit GCode;

interface

uses
  System.Classes, System.Generics.Collections;

var
  Null: extended;

type
  IToolInfo = interface ['{CA91D8F9-2B92-4FBE-A311-5E4A76E3C87B}']
    function GetTool: integer;
    function GetStartPos: int64;
    function GetLastX: extended;
    function GetLastE: extended;
    //
    property Tool: integer read GetTool;
    property StartPos: int64 read GetStartPos;
    property LastX: extended read GetLastX;
    property LastE: extended read GetLastE;
  end;

  ILayerInfo = interface ['{E0A4BDCA-B72A-416A-8A0F-E7E1949C18B3}']
    function GetZ: extended;
    function GetStartPos: int64;
    function GetLastY: extended;
    function GetLastZ: extended;
    function GetTools: TList<IToolInfo>;
  //
    property Z: extended read GetZ;
    property StartPos: int64 read GetStartPos;
    property LastY: extended read GetLastY;
    property LastZ: extended read GetLastZ;
    property Tools: TList<IToolInfo> read GetTools;
  end;

  IGCodeIndex = interface ['{D768FE73-3DD7-4DB5-A539-2EB436FCEBEE}']
    function GetHeader: ILayerInfo;
    function GetLayers: TList<ILayerInfo>;
    function GetFooter: ILayerInfo;
  //
    property Header: ILayerInfo read GetHeader;
    property Layers: TList<ILayerInfo> read GetLayers;
    property Footer: ILayerInfo read GetFooter;
  end;

  TGCodeSection = (secHeader, secObject, secEndcode);

  IGCode = interface ['{2A72F9D7-B26D-471C-B816-54F355B9BE29}']
    function  GetErrorMessage: string;
    function  GetIndex: IGCodeIndex;
  //
    function AsStream: TStream;
    function AtEnd: boolean;
    function IsComment(const line: AnsiString): boolean;
    function IsEndCode(const line: AnsiString): boolean;
    function IsLayerChange(const line: AnsiString): boolean;
    function IsMove(const line: AnsiString): boolean;
    function ReadLine: AnsiString;
    function RemoveComment(const line: AnsiString): AnsiString;
    function Section: TGCodeSection;
    function Tool: integer;
    property ErrorMessage: string read GetErrorMessage;
    property Index: IGCodeIndex read GetIndex;
  end;

implementation

uses
  System.Math;

initialization
  Null := Power(2, -20);
end.
