unit U_NormalvsFunctionalProgrammig;

interface

uses
  System.Classes,
  System.Diagnostics;

const
  MAXVALUE =  100000000000; //High(Int64);

type


(*
  Teste seem to have similar results on a direct call for each case
  
    Log( 'Start of Test Normal' );
    Log( Format('Elapsed Time Normal:        %d ms', [ TestNormal ]));
    Log( 'Start of Test TestFuncional' );
    Log( Format('Elapsed Time TestFuncional: %d ms', [ TestFuncional ]));
    Log( 'Start of Test TestGetValue' );
    Log( Format('Elapsed Time TestGetValue:  %d ms', [ TestGetValue ]));
    Log( 'End of TestGetValue' );
*)

 ITest = interface
   ['{70F2D26E-850E-4797-8030-F373433F5C62}']
   procedure TestNormal;
   procedure TestFuncional;
   function Value: Integer; overload;
   function Value( AValue: integer ): ITest ; overload;
 end;

 TTest = class( TInterfacedObject, ITest)
 private
   FCount: integer;
   FValue : Integer;
    procedure SetValue(const AValue: Integer);
    function GetValue: Integer;
 public
   constructor Create;
   class function New: ITest;
   procedure TestNormal;
   procedure TestFuncional;
   function Value: Integer; overload;
   function Value( AValue: integer ): ITest ; overload;
   property _Value: Integer read GetValue write SetValue;
 end;

function TestNormal: Int64;
function TestFuncional: Int64;
function TestGetValue: Int64;


implementation


function TestNormal: Int64;
var
  Normalwatch: TStopwatch;
  var LNormalTest: ITest;
begin
  Result := 0;
  //Test Normal vs Funciona
  Normalwatch.StartNew;
  LNormalTest := TTest.Create;
  for var i: Int64 := 0 to MAXVALUE do
  begin
    LNormalTest.TestNormal;
  end;
  Normalwatch.Stop;
  Result := Normalwatch.ElapsedMilliseconds;
end;


function TestFuncional: Int64;
var
  FunctionalStopwatch: TStopwatch;
  LFunctionalTest: ITest;
begin
  Result := 0;
  //Test Normal vs Funciona
  FunctionalStopwatch.StartNew;
  LFunctionalTest := TTest.Create;
  for var i: Int64 := 0 to MAXVALUE do
  begin
    LFunctionalTest.TestFuncional;
  end;
  FunctionalStopwatch.Stop;
  Result := FunctionalStopwatch.ElapsedMilliseconds;
end;



function TestGetValue: Int64;
var
  FGetValueStopwatch: TStopwatch;
  LGetValueTest: ITest;
begin
  Result := 0;
  //Test proceduralGet
  FGetValueStopwatch.StartNew;
  LGetValueTest := TTest.Create;
  for var i: Int64 := 0 to MAXVALUE do
  begin
    LGetValueTest.Value;
  end;
  FGetValueStopwatch.Stop;
  Result := FGetValueStopwatch.ElapsedMilliseconds;
end;

{ TTest }

constructor TTest.Create;
begin
  FCount := 0;
end;

function TTest.GetValue: Integer;
begin
  Result := FValue;
end;

class function TTest.New: ITest;
begin
  Result := Self.Create;
end;

procedure TTest.SetValue(const AValue: Integer);
begin
  FValue := AValue;
end;

procedure TTest.TestFuncional;
begin
  Inc( FCount);
end;


procedure TTest.TestNormal;
begin
  Inc( FCount);
end;

function TTest.Value(AValue: integer): ITest;
begin
  Result := Self;
  FValue := AValue;
end;

function TTest.Value: Integer;
begin
  Result := FValue;
end;

end.
