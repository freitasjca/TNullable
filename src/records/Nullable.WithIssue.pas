unit Nullable.WithIssue;

{
Nullables are a rather simple concept.
All you need is a value, and some flag that will tell you whether or
not the value has been explicitly set or not.


ISSUE: Records are not automatically initialized and that your FHasValue boolean
       can hold a random value.

       Declaring a variable of type Nullable<T> where T is some concrete type,
       would leave the resulting structure uninitialized.

       Delphi, managed types (like strings, interfaces, Dynamic Arrays) when put
       in record will be automatically initialized even when such a record is
       declared as local variable.

       "managed types" typically refers to types that are automatically managed
       by the Delphi runtime system in terms of memory allocation and deallocation.

       Delphi managed types:
         - Strings
         - Dynamic Arrays
         - Interface
         - Dynamic Records ( starting with Delphi 2009 if contain managed type fields)

       Delphi unmanaged types:
         - Static Arrays
         - Ordinary Records
         - Enumerations
         - Sets
         - Integers
         - Booleans

SOLUTION:


https://blogs.embarcadero.com/a-nullable-post/
https://dalijap.blogspot.com/2020/05/delphi-nullable-with-custom-managed.html
}

interface

uses
  Generics.Defaults,
  SysUtils;


type
  Nullable<T> = record
  private
    FHasValue: boolean;
    FValue: T;
    function GetValue: T;
    procedure SetValue(AValue: T);
  public
    property HasValue: boolean read FHasValue;
    property Value: T read GetValue write SetValue;
  end;

implementation

function Nullable<T>.GetValue: T;
begin
  if FHasValue then
    Result := FValue
  else
    raise Exception.Create('Invalid operation, Nullable type has no value');
end;

procedure Nullable<T>.SetValue(AValue: T);
begin
  FHasValue := True;
  FValue := AValue;
end;

end.
