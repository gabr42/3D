unit GCode.Processor.Impl;

interface

uses
  System.Generics.Collections,
  GpStuff,
  GCode, GCode.Processor;

type
  TGCodeProcessor = class(TInterfacedObject, IGCodeProcessor)
  strict private
    FErrorMessage: string;
    FGCode       : TList<IGCode>;
    FOutputGCode : IGpBuffer;
  strict protected
    function  GetErrorMessage: string; virtual;
    function  GetGCodeList: TList<IGCode>; virtual;
    function  GetOutputGCode: IGpBuffer; virtual;
  public
    constructor Create;
    destructor  Destroy; override;
    function  Process: boolean; virtual;
    property ErrorMessage: string read GetErrorMessage;
    property GCodeList: TList<IGCode> read GetGCodeList;
    property OutputGCode: IGpBuffer read GetOutputGCode;
  end;

implementation

uses
  System.SysUtils;

{ TGCodeProcessor }

constructor TGCodeProcessor.Create;
begin
   inherited Create;
   FGCode := TList<IGCode>.Create;
end;

destructor TGCodeProcessor.Destroy;
begin
  FreeAndNil(FGCode);
  inherited;
end;

function TGCodeProcessor.GetErrorMessage: string;
begin
  Result := FErrorMessage;
end;

function TGCodeProcessor.GetGCodeList: TList<IGCode>;
begin
  Result := FGCode;
end;

function TGCodeProcessor.GetOutputGCode: IGpBuffer;
begin
  Result := FOutputGCode;
end;

function TGCodeProcessor.Process: boolean;
begin
  FErrorMessage := '';
  FOutputGcode := TGpBuffer.Make;
  Result := true;
end;

end.
