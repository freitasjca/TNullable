unit Nullable;

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

SOLUTION: Custom Managed Record ( only after Delphi 10.4)


https://blogs.embarcadero.com/a-nullable-post/
https://dalijap.blogspot.com/2020/05/delphi-nullable-with-custom-managed.html
}



interface


uses
  System.Classes,
  Generics.Collections,
  Generics.Defaults,
  System.SysUtils,
  System.TypInfo,
  System.Rtti,
  System.Variants;

type
  TValue = System.Rtti.TValue;
  PValue = ^TValue;


  TNullable<T> = record
  private
   {$IF (CompilerVersion >= 34)} // RAD Studio 10.4 Sydney
    FHasValue: boolean;
   {$ELSE}
    //FHasValue: Boolean;    //Boolean is unmanaged type and can hold a random value
    FHasValue: IInterface;   //To avoid not being inicialized.
   {$ENDIF}
    FValue: T;
    procedure Clear;
    function GetValue: T;
    procedure SetValue(AValue: T);
    function GetValueOrDefault: T;
    function GetIsNull: Boolean;
    //class function GetEmpty: Nullable<T>; static;
    function GetEmpty: TNullable<T>;

    class procedure CheckNullOperation(Left, Right: TNullable<T>); static;
    
  public
    constructor Create(AValue: T);
    {$IF (CompilerVersion >= 34)} // From RAD Studio 10.4 Sydney
    class operator Initialize(out Dest: TNullable<T>);
    class operator Finalize(var Dest: TNullable<T>);
    {$ENDIF}
    function ToString: string;
    function ToVariant: Variant;
    { Gets the stored value. Returns <c>False</c> if it does not contain value. }
    function TryGetValue(out value: T): Boolean; inline;

    property HasValue: boolean read FHasValue;
    property Value: T read GetValue write SetValue;
    property IsNull: Boolean read GetIsNull;
    property ValueOrDefault: T read GetValueOrDefault;

    //class property Empty: Nullable<T> read GetEmpty;
    property Empty: TNullable<T> read GetEmpty;

    class operator NotEqual(const ALeft, ARight: TNullable<T>): Boolean;
    class operator Equal(ALeft, ARight: TNullable<T>): Boolean;

    {$IF (CompilerVersion >= 34)} // From RAD Studio 10.4 Sydney
    class operator Implicit(Value: TNullable<T>): T;
    class operator Implicit(Value: T): TNullable<T>;
    class operator Explicit(Value: TNullable<T>): T;

    class operator GreaterThan(Left, Right: TNullable<T>): Boolean;
    class operator GreaterThanOrEqual(Left, Right: TNullable<T>): Boolean;
    class operator LessThan(Left, Right: TNullable<T>): Boolean;
    class operator LessThanOrEqual(Left, Right: TNullable<T>): Boolean;
    {$ENDIF}
  end;

  ENullValueException = class(Exception)
  public
    constructor Create;
  end;
  ENullConvertException = class(Exception)
  public
    constructor Create(ATypeInfo: PTypeInfo);
  end;


{$IF (CompilerVersion < 34)} // Previous to RAD Studio 10.4 Sydney
procedure SetFlagInterface(var Intf: IInterface);
{$ENDIF}



implementation

uses
  Logger.Intf;


{$IF (CompilerVersion < 34)} // Previous to RAD Studio 10.4 Sydney
function NopAddref(inst: Pointer): Integer; stdcall;
begin
  Result := -1;
end;

function NopRelease(inst: Pointer): Integer; stdcall;
begin
  Result := -1;
end;

function NopQueryInterface(inst: Pointer; const IID: TGUID; out Obj): HResult; stdcall;
begin
  Result := E_NOINTERFACE;
end;

const
  FlagInterfaceVTable: array[0..2] of Pointer =
  (
    @NopQueryInterface,
    @NopAddref,
    @NopRelease
  );

  FlagInterfaceInstance: Pointer = @FlagInterfaceVTable;

procedure SetFlagInterface(var Intf: IInterface);
begin
  Intf := IInterface(@FlagInterfaceInstance);
end;
{$ENDIF}

{ ENullValueException }

constructor ENullValueException.Create;
begin
  inherited Create('Nullable: Cannot operate with SNull value.');
end;
{ ENullConvertException<T> }
constructor ENullConvertException.Create(ATypeInfo: PTypeInfo);
begin
  inherited Create('Nullable: Cannot convert SNull into ' + GetTypeName(ATypeInfo));;
end;


class procedure TNullable<T>.CheckNullOperation(Left, Right: TNullable<T>);
begin
  if not Left.FHasValue or not Right.FHasValue then
    raise ENullValueException.Create;
end;

{
class function Nullable<T>.GetEmpty: Nullable<T>;
begin
  Result.Clear;
end;
}

function TNullable<T>.GetEmpty: TNullable<T>;
begin
  Result := Self;
  Clear;
end;

function TNullable<T>.GetIsNull: Boolean;
begin
  Result := not FHasValue;
end;

function TNullable<T>.GetValue: T;
begin
  if not FHasValue then
    raise ENullConvertException.Create(TypeInfo(T));

  Result := FValue;
end;

function TNullable<T>.GetValueOrDefault: T;
begin
  if FHasValue then
    Result := FValue
  else
    Result := Default(T);
end;

class operator TNullable<T>.GreaterThan(Left, Right: TNullable<T>): Boolean;
begin
  CheckNullOperation(Left, Right);
  Result := TComparer<T>.Default.Compare(Left, Right) > 0;
end;

class operator TNullable<T>.GreaterThanOrEqual(Left, Right: TNullable<T>): Boolean;
begin
  CheckNullOperation(Left, Right);
  Result := TComparer<T>.Default.Compare(Left, Right) >= 0;
end;

procedure TNullable<T>.SetValue(AValue: T);
begin
  FHasValue := True;
  FValue := AValue;
end;

function TNullable<T>.ToString: string;
var
  v: TValue;
begin
  if HasValue then
  begin
    v := TValue.From<T>(FValue);
    Result := v.ToString;
  end
  else
    Result := 'Null';
end;


function TNullable<T>.ToVariant: Variant;
var
  v: TValue;
begin
  if FHasValue then
  begin
    v := TValue.From<T>(FValue);
    if v.IsType<Boolean> then
      Result := v.AsBoolean
    else
      Result := v.AsVariant;
  end
  else
    Result := Null;
end;


function TNullable<T>.TryGetValue(out value: T): Boolean;
begin
  Result := FHasValue;
  if Result then
    value := FValue;
end;


{$IF (CompilerVersion >= 34)} // From RAD Studio 10.4 Sydney
class operator TNullable<T>.Initialize(out Dest: TNullable<T>);
begin
  Dest.FHasValue := False;

  Log( Format('Initialize %s %s', [ GetTypeName(TypeInfo(TNullable<T>)),
                                    IntToHex (Integer(Pointer(@Dest)))]
             ) );
end;

class operator TNullable<T>.Finalize(var Dest: TNullable<T>);
begin
  Log( Format('destroyed %s %s', [ GetTypeName(TypeInfo(TNullable<T>)),
                                   IntToHex (Integer(Pointer(@Dest)))]
             ) );
end;
{$ENDIF}


procedure TNullable<T>.Clear;
begin
  FHasValue := False;
  FValue := Default(T);

  Log( Format('clear %s %s', [ GetTypeName(TypeInfo(TNullable<T>)),
                               IntToHex (Integer(Pointer(@Self)))]
             ) );
end;

constructor TNullable<T>.Create(AValue: T);
begin
  {$IF (CompilerVersion >= 34)} // Previous to RAD Studio 10.4 Sydney
  FHasValue := True;
  FValue := AValue;
  {$ELSE}
  FValue := AValue;
  SetFlagInterface(FHasValue);
  {$ENDIF}

  Log( Format('create %s %s', [ GetTypeName(TypeInfo(TNullable<T>)),
                               IntToHex (Integer(Pointer(@Self)))]
             ) );
end;

class operator TNullable<T>.Equal(ALeft, ARight: TNullable<T>): Boolean;
var
  Comparer: IEqualityComparer<T>;
begin
  if ALeft.HasValue and ARight.HasValue then
  begin
    Comparer := TEqualityComparer<T>.Default;
    Result := Comparer.Equals(ALeft.Value, ARight.Value);
  end else
    Result := ALeft.HasValue = ARight.HasValue;
end;

{$IF (CompilerVersion >= 34)} // From RAD Studio 10.4 Sydney
class operator TNullable<T>.Explicit(Value: TNullable<T>): T;
begin
  Result := Value.Value;
end;


class operator TNullable<T>.Implicit(Value: TNullable<T>): T;
begin
  Result := Value.Value;
end;

class operator TNullable<T>.Implicit(Value: T): TNullable<T>;
begin
  Result := TNullable<T>.Create(Value);
end;

class operator TNullable<T>.LessThanOrEqual(Left, Right: TNullable<T>): Boolean;
begin
  CheckNullOperation(Left, Right);
  Result := TComparer<T>.Default.Compare(Left, Right) <= 0;
end;

class operator TNullable<T>.LessThan(Left, Right: TNullable<T>): Boolean;
begin
  CheckNullOperation(Left, Right);
  Result := TComparer<T>.Default.Compare(Left, Right) < 0;
end;

class operator TNullable<T>.NotEqual(const ALeft, ARight: TNullable<T>): Boolean;
var
  Comparer: IEqualityComparer<T>;
begin
  if ALeft.HasValue and ARight.HasValue then
  begin
    Comparer := TEqualityComparer<T>.Default;
    Result := not Comparer.Equals(ALeft.Value, ARight.Value);
  end else
    Result := ALeft.HasValue <> ARight.HasValue;
end;
{$ENDIF}

end.
