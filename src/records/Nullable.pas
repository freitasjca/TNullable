unit Nullable;


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

  TNullRecord = record
  end;
  

  TNullable<T> = record
  private
   {$IF (CompilerVersion >= 34)} // RAD Studio 10.4 Sydney
    FHasValue: boolean;      //Boolean is unmanaged type and can hold a random value
   {$ELSE}
    FHasValue: IInterface;   //To avoid not being inicialized.
   {$ENDIF}
    FValue: T;
    procedure Clear;
    function GetValue: T;
    procedure SetValue(AValue: T);
    function GetValueOrDefault: T;
    function GetIsNull: Boolean;
    class function GetEmpty: TNullable<T>; static;

    class procedure CheckNullOperation(Left, Right: TNullable<T>); static;
  public
    constructor Create(const Value: T); overload;
    constructor Create(const Value: Variant); overload;
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

    class property Empty: TNullable<T> read GetEmpty;

    {$IF (CompilerVersion >= 34)} // From RAD Studio 10.4 Sydney
    class operator Implicit(const Value: TNullable<T>): T;
    class operator Implicit(const Value: TNullable<T>): Variant;
    class operator Implicit(const Value: Pointer): TNullable<T>;
    class operator Implicit(const Value: T): TNullable<T>;
    class operator Implicit(const Value: Variant): TNullable<T>;
    class operator Implicit(const Value: TNullRecord): TNullable<T>;

    class operator Explicit(const Value: TNullable<T>): T;

    class operator Equal(const Left, Right: TNullable<T>): Boolean;
    class operator NotEqual(const Left, Right: TNullable<T>): Boolean;

    class operator GreaterThan(const Left, Right: TNullable<T>): Boolean;
    class operator GreaterThanOrEqual(const Left, Right: TNullable<T>): Boolean;

    class operator LessThan(const Left, Right: TNullable<T>): Boolean;
    class operator LessThanOrEqual(const Left, Right: TNullable<T>): Boolean;
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

  NullString = TNullable<string>;
  NullBoolean = TNullable<Boolean>;
  NullInteger = TNullable<Integer>;
  NullInt64 = TNullable<Int64>;
  NullDouble = TNullable<Double>;
  NullDateTime = TNullable<TDateTime>;
  NullDate = TNullable<TDate>;
  NullTime = TNullable<TTime>;
  NullCurrency = TNullable<Currency>;
  NullGuid = TNullable<TGUID>;
{$IFNDEF NEXTGEN}
  NullWideString = TNullable<WideString>;
  {$ENDIF}
  

{$IF (CompilerVersion < 34)} // Previous to RAD Studio 10.4 Sydney
procedure SetFlagInterface(var Intf: IInterface);
{$ENDIF}

var
  SNull: TNullRecord;

implementation

{$IFDEF LOG}
uses
  Logger.Intf;
{$ENDIF}

{$REGION 'Previous to RAD Studio 10.4 Sydney'}
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
{$ENDREGION}


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

class function TNullable<T>.GetEmpty: TNullable<T>;
begin
  Result.Clear;
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

{$IF (CompilerVersion >= 34)} // From RAD Studio 10.4 Sydney
class operator TNullable<T>.GreaterThan(const Left, Right: TNullable<T>): Boolean;
begin
  CheckNullOperation(Left, Right);
  Result := TComparer<T>.Default.Compare(Left, Right) > 0;
end;

class operator TNullable<T>.GreaterThanOrEqual(const Left, Right: TNullable<T>): Boolean;
begin
  CheckNullOperation(Left, Right);
  Result := TComparer<T>.Default.Compare(Left, Right) >= 0;
end;
{$ENDIF}

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


  {$IFDEF LOG}
  Log( Format('Initialize %s %s', [ GetTypeName(TypeInfo(TNullable<T>)),
                                    IntToHex (Integer(Pointer(@Dest)))]
             ) );
  {$ENDIF}

end;

class operator TNullable<T>.Finalize(var Dest: TNullable<T>);
begin
  {$IFDEF LOG}
  Log( Format('destroyed %s %s', [ GetTypeName(TypeInfo(TNullable<T>)),
                                   IntToHex (Integer(Pointer(@Dest)))]
             ) );
  {$ENDIF}
end;

{$ENDIF}


procedure TNullable<T>.Clear;
begin
  FHasValue := False;
  FValue := Default(T);

  {$IFDEF LOG}
  Log( Format('clear %s %s', [ GetTypeName(TypeInfo(TNullable<T>)),
                               IntToHex (Integer(Pointer(@Self)))]
             ) );
  {$ENDIF}
end;

constructor TNullable<T>.Create(const Value: Variant);
begin
  if not VarIsNull(Value) and not VarIsEmpty(Value) then
    Create(TValue.FromVariant(Value).AsType<T>)
  else
    Clear;

  {$IFDEF LOG}
  Log( Format('create %s %s', [ GetTypeName(TypeInfo(TNullable<T>)),
                               IntToHex (Integer(Pointer(@Self)))]
             ) );
  {$ENDIF}
end;

constructor TNullable<T>.Create(const Value: T);
begin
  {$IF (CompilerVersion >= 34)} // Previous to RAD Studio 10.4 Sydney
  FValue := Value;
  FHasValue := True;
  {$ELSE}
  FValue := Value;
  SetFlagInterface(FHasValue);
  {$ENDIF}

  {$IFDEF LOG}
  Log( Form at('create %s %s', [ GetTypeName(TypeInfo(TNullable<T>)),
                               IntToHex (Integer(Pointer(@Self)))]
             ) );
  {$ENDIF}
end;

{$IF (CompilerVersion >= 34)} // From RAD Studio 10.4 Sydney
class operator TNullable<T>.Explicit(const Value: TNullable<T>): T;
begin
  Result := Value.Value;
end;

class operator TNullable<T>.Implicit(const Value: TNullable<T>): T;
begin
  Result := Value.Value;
  end;

class operator TNullable<T>.Implicit(const Value: TNullable<T>): Variant;
begin
  if Value.HasValue then
  Result := TValue.From<T>(Value.Value).AsVariant
  else
  Result := Null;
end;

class operator TNullable<T>.Implicit(const Value: T): TNullable<T>;
begin
  Result := TNullable<T>.Create(Value);
end;

class operator TNullable<T>.Implicit(const Value: Pointer): TNullable<T>;
begin
  if Value = nil then
    Result.Clear
  else
    Result := TNullable<T>.Create(T(Value^));
end;

class operator TNullable<T>.Implicit(const Value: Variant): TNullable<T>;
begin
  Result := TNullable<T>.Create(Value);
end;

class operator TNullable<T>.Implicit(const Value: TNullRecord): TNullable<T>;
begin
  Result.FHasValue := False;
end;


class operator TNullable<T>.LessThanOrEqual(const Left, Right: TNullable<T>): Boolean;
begin
  CheckNullOperation(Left, Right);
  Result := TComparer<T>.Default.Compare(Left, Right) <= 0;
end;

class operator TNullable<T>.LessThan(const Left, Right: TNullable<T>): Boolean;
begin
  CheckNullOperation(Left, Right);
  Result := TComparer<T>.Default.Compare(Left, Right) < 0;
end;

class operator TNullable<T>.Equal(const Left, Right: TNullable<T>): Boolean;
var
  Comparer: IEqualityComparer<T>;
begin
  if Left.HasValue and Right.HasValue then
  begin
    Comparer := TEqualityComparer<T>.Default;
    Result := Comparer.Equals(Left.Value, Right.Value);
  end else
    Result := Left.HasValue = Right.HasValue;
end;


class operator TNullable<T>.NotEqual(const Left, Right: TNullable<T>): Boolean;
var
  Comparer: IEqualityComparer<T>;
begin
  if Left.HasValue and Right.HasValue then
  begin
    Comparer := TEqualityComparer<T>.Default;
    Result := not Comparer.Equals(Left.Value, Right.Value);
  end else
    Result := Left.HasValue <> Right.HasValue;
end;
{$ENDIF}

end.
