unit GCode;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

var
  Null: extended;
  FormatSettings: TFormatSettings;

type
  IPosition = interface ['{97279064-C186-4425-AB5E-3D8B0B2E5192}']
    function GetX: extended;
    function GetY: extended;
    function GetZ: extended;
    function GetE: extended;
  //
    property X: extended read GetX;
    property Y: extended read GetY;
    property Z: extended read GetZ;
    property E: extended read GetE;
  end;

  IToolInfo = interface ['{CA91D8F9-2B92-4FBE-A311-5E4A76E3C87B}']
    function GetTool: integer;
    function GetStartPos: int64;
    function GetSize: int64;
    function GetFirstPosition: IPosition;
    function GetLastPosition: IPosition;
    //
    property Tool: integer read GetTool;
    property StartPos: int64 read GetStartPos;
    property Size: int64 read GetSize;
    property FirstPosition: IPosition read GetFirstPosition;
    property LastPosition: IPosition read GetLastPosition;
  end;

  ILayerInfo = interface ['{E0A4BDCA-B72A-416A-8A0F-E7E1949C18B3}']
    function GetZ: extended;
    function GetStartPos: int64;
    function GetSize: int64;
    function GetFirstPosition: IPosition;
    function GetLastPosition: IPosition;
    function GetTools: TList<IToolInfo>;
  //
    property StartPos: int64 read GetStartPos;
    property Size: int64 read GetSize;
    property Z: extended read GetZ;
    property FirstPosition: IPosition read GetFirstPosition;
    property LastPosition: IPosition read GetLastPosition;
    property Tools: TList<IToolInfo> read GetTools;
  end;

  IGCodeIndex = interface ['{D768FE73-3DD7-4DB5-A539-2EB436FCEBEE}']
    function GetHeader: ILayerInfo;
    function GetLayers: TList<ILayerInfo>;
    function GetFooter: ILayerInfo;
  //
    function FindTool(z: extended; tool: integer): IToolInfo;
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
  FormatSettings := System.SysUtils.FormatSettings;
  FormatSettings.DecimalSeparator := '.';
  FormatSettings.ThousandSeparator := ',';
end.
