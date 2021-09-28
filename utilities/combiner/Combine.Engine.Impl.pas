unit Combine.Engine.Impl;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  GpStuff,
  Combine.Engine;

type
  TCombinerEngine = class(TInterfacedObject, ICombinerEngine)
  strict private type
    TLayerChange = record
    private
      FLayer: real;
      FGcode: IGpBuffer;
    public
      constructor Create(ALayer: real; const AGcode: IGpBuffer);
    end;
  const
    Eps = 0.00000001;
  var
    FBaseGcode       : IGpBuffer;
    FCurrentLayer    : integer;
    FErrorMessage    : string;
    FFloatFormat     : TFormatSettings;
    FLayerChanges    : TList<TLayerChange>;
    FLayerChangeAt   : real;
    FOutputGcode     : IGpBuffer;
    FPotentialTrigger: boolean;
  strict protected
    function  ActiveLayerGcode: TStream; inline;
    function  FastForwardGcode(layer: real): boolean;
    function  GetBaseGcode: IGpBuffer;
    function  GetErrorMessage: string;
    function  GetNextLine(var line: AnsiString): boolean;
    function  GetOutputGcode: IGpBuffer;
    function  ReadLine(const gcode: TStream): AnsiString;
    procedure SetBaseGcode(const value: IGpBuffer);
  public
    constructor Create;
    destructor  Destroy; override;
    class function Make: ICombinerEngine;
    procedure ChangeAtLayer(layer: real; const gcode: IGpBuffer);
    function  Process: boolean;
    property BaseGcode: IGpBuffer read GetBaseGcode write SetBaseGcode;
    property ErrorMessage: string read GetErrorMessage;
    property OutputGcode: IGpBuffer read GetOutputGcode;
  end;

implementation

uses
  System.AnsiStrings,
  GpStreams;

{ TCombinerEngine }

constructor TCombinerEngine.Create;
begin
  inherited Create;
  FLayerChanges := TList<TLayerChange>.Create;
  FFloatFormat.ThousandSeparator := ',';
  FFloatFormat.DecimalSeparator := '.';
end;

destructor TCombinerEngine.Destroy;
begin
  FreeAndNil(FLayerChanges);
  inherited;
end;

function TCombinerEngine.FastForwardGcode(layer: real): boolean;
begin
  Result := false;

  Assert(layer >= 0);

  var gcode := ActiveLayerGcode;

  while not gcode.AtEnd do begin
    var line := ReadLine(gcode);
    if SameText(line, AnsiString(';AFTER_LAYER_CHANGE')) then begin
      if gcode.AtEnd then
        Exit;
      line := ReadLine(gcode);
      if (line <> '') and (line[1] = ';') then begin
        var s := line;
        Delete(s, 1, 1);
        var glayer: double;
        if TryStrToFloat(string(s), glayer, FFloatFormat) and (glayer >= (layer - Eps)) then
          Exit(true);
      end;
    end;
  end;
end;

function TCombinerEngine.ActiveLayerGcode: TStream;
begin
  Result := FLayerChanges[FCurrentLayer].FGcode.AsStream;
end;

procedure TCombinerEngine.ChangeAtLayer(layer: real; const gcode: IGpBuffer);
begin
  FLayerChanges.Add(TLayerChange.Create(layer, gcode));
end;

function TCombinerEngine.GetBaseGcode: IGpBuffer;
begin
  Result := FBaseGcode;
end;

function TCombinerEngine.GetErrorMessage: string;
begin
  Result := FErrorMessage;
end;

function TCombinerEngine.GetNextLine(var line: AnsiString): boolean;
begin
  var gcode := ActiveLayerGcode;
  if gcode.AtEnd then
    Exit(false);

//We're looking for:
//;AFTER_LAYER_CHANGE
//;0.7

  line := ReadLine(gcode);

  if FPotentialTrigger and (FLayerChangeAt >= 0) then begin
    if (line <> '') and (line[1] = ';') then begin
      var s := line;
      Delete(s, 1, 1);
      var layer: double;
      if TryStrToFloat(string(s), layer, FFloatFormat) and (layer >= (FLayerChangeAt - Eps)) then begin
        var hasGcode := false;
        while (FCurrentLayer < (FLayerChanges.Count - 1)) and (not hasGcode) do begin
          Inc(FCurrentLayer);
          hasGcode := FastForwardGcode(FLayerChangeAt);
          if FCurrentLayer < (FLayerChanges.Count - 1) then
            FLayerChangeAt := FLayerChanges[FCurrentLayer + 1].FLayer
          else
            FLayerChangeAt := -1;
        end;
Writeln('Switched to file ', FCurrentLayer, '/', FLayerChanges.Count - 1, ' at ', layer);
      end;
    end;
  end;

  FPotentialTrigger := SameText(line, AnsiString(';AFTER_LAYER_CHANGE'));
  Result := true;
end;

function TCombinerEngine.GetOutputGcode: IGpBuffer;
begin
  Result := FOutputGcode;
end;

class function TCombinerEngine.Make: ICombinerEngine;
begin
  Result := TCombinerEngine.Create;
end;

function TCombinerEngine.Process: boolean;
begin
  FErrorMessage := '';
  FOutputGcode := TGpBuffer.Make;
  FPotentialTrigger := false;

  FLayerChanges.Insert(0, TLayerChange.Create(0, BaseGcode));
  try
    for var lc in FLayerChanges do
      lc.FGcode.AsStream.GoToStart;

    FCurrentLayer := 0;
    if FLayerChanges.Count > 1 then
      FLayerChangeAt := FLayerChanges[1].FLayer
    else
      FLayerChangeAt := -1;

    var line: AnsiString;
    while GetNextLine(line) do begin
      FOutputGcode.AsStream.WriteAnsiStr(line);
      FOutputGcode.AsStream.WriteAnsiStr(#$0A);
    end;

    Result := FErrorMessage = '';
  finally FLayerChanges.Delete(0); end;
end;

function TCombinerEngine.ReadLine(const gcode: TStream): AnsiString;
var
  ch: byte;
begin
  var pos := gcode.Position;
  while (gcode.ReadData(ch) = 1) and (ch <> $0A) do
    ;
  SetLength(Result, gcode.Position - pos - Ord(ch = $0A));
  if Result <> '' then begin
    gcode.Position := pos;
    gcode.Read(Result[1], Length(Result));
    if ch = $0A then
      gcode.ReadData(ch);
  end;
end;

procedure TCombinerEngine.SetBaseGcode(const value: IGpBuffer);
begin
  FBaseGcode := value;
end;

{ TCombinerEngine.TLayerChange }

constructor TCombinerEngine.TLayerChange.Create(ALayer: real; const AGcode: IGpBuffer);
begin
  FLayer := ALayer;
  FGcode := AGcode;
end;

end.
