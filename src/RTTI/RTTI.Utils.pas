unit RTTI.Utils;

interface

uses
  System.Classes,
  System.RTTI;

function GetVarNames(const AClass : TObject) : TStringList;

implementation

function GetVarNames(const AClass : TObject) : TStringList;
var lType : TRttiType;
  lContext : TRttiContext;
  lProperty : TRttiProperty;
  lField : TRttiField;
begin
  Result := TStringList.create;
  LType := lContext.GetType(AClass. ClassType);
  if assigned(LType) then
  begin
    for LProperty in LType.GetProperties do
    begin
      Result.Add(lProperty.Name);
      //Get current value:
      Result.Add(lProperty.GetValue(AClass).ToString);
    end;
   for lField in LType.GetFields do
   begin
     Result.Add(lField.Name);
     //Get current value:
     Result.Add(lField.GetValue(AClass).ToString);
   end;
 end;
end;


end.
