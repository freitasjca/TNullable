unit DUnitX.NullableTests;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TNullableTests = class
  public
    [Setup]
    procedure Setup;
    [SetupFixture]
    procedure SetupFixture;
    [TearDown]
    procedure TearDown;
    [TearDownFixture]
    procedure TearDownFixture;
    // Sample Methods
    // Simple single Test
    [Test]
    [Ignore('This is only for demo')]
    procedure Test1;
    // Test with TestCase Attribute to supply parameters.
    [Test]
    [TestCase('TestA','1,2')]
    [TestCase('TestB','3,4')]
    [Ignore('This is only for demo')]
    procedure Test2(const AValue1 : Integer;const AValue2 : Integer);
    [Test]
    [TestCase('IsNullableEqual1','5,5,true')]
    [TestCase('IsNullableEqual2','6,5,false')]
    [TestCase('IsNullableEqual3','6,5,true')]
    procedure IsNullableEqual(const AValue1 : Integer;const AValue2 : Integer; AResult: Boolean);
    [Test]
    [TestCase('IsNullableEqualVariableAssignement','5,true')]
    procedure IsNullableEqualVariableAssignement(const AValue1 : Integer;AResult: Boolean);
  end;

implementation

uses
  Nullable;

procedure TNullableTests.IsNullableEqual(const AValue1, AValue2: Integer; AResult: Boolean);
var
  lNullInt1,
  lNullInt2: TNullable<Integer>;
begin
  lNullInt1.Value:=  AValue1;
  lNullInt2.Value:=  AValue2;
  Assert.AreEqual(AResult, lNullInt1 = lNullInt2 );
end;

procedure TNullableTests.IsNullableEqualVariableAssignement(
  const AValue1: Integer; AResult: Boolean);
var
  lNullInt1,
  lNullInt2: TNullable<Integer>;
begin
  lNullInt1.Value:=  AValue1;
  lNullInt2 :=  lNullInt1;
  Assert.AreEqual(AResult, lNullInt1 = lNullInt2 );
end;

procedure TNullableTests.Setup;
begin
end;

procedure TNullableTests.SetupFixture;
begin

end;

procedure TNullableTests.TearDown;
begin
end;

procedure TNullableTests.TearDownFixture;
begin

end;

procedure TNullableTests.Test1;
begin
end;

procedure TNullableTests.Test2(const AValue1 : Integer;const AValue2 : Integer);
begin
end;

initialization
  TDUnitX.RegisterTestFixture(TNullableTests);

end.
