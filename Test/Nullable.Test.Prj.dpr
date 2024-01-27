program Nullable.Test.Prj;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.SyncObjs,
  Nullable.WithIssue in '..\src\records\Nullable.WithIssue.pas',
  Nullable in '..\src\records\Nullable.pas',
  Logger.Console in '..\src\Log\Logger.Console.pas',
  Logger.IDE in '..\src\Log\Logger.IDE.pas',
  Logger.Intf in '..\src\Log\Logger.Intf.pas',
  Logger.Manager in '..\src\Log\Logger.Manager.pas',
  Logger.TextFile in '..\src\Log\Logger.TextFile.pas',
  RTTI.Utils in '..\src\RTTI\RTTI.Utils.pas';

type

  TestRecord = record
  private
    FHasValue: Boolean;
  public
    property HasValue: Boolean read FHasValue;
  end;

var
  //lNullInt1,
  //lNullInt2: Nullable.WithIssue.Nullable<Integer>;
  FManualClockCorrectionLock: TLightweightMREW;

  lNullInt1,
  lNullInt2: TNullable<Integer>;
  //NS : TestRecord;

  procedure Log( const AMsg: String; const ANull: TNullable<Integer> ); overload;
  begin
    Logger.Intf.Log( Format('%s.HasValue: %s' , [ AMsg, BoolToStr(ANull.HasValue, True)]));

    if ANull.HasValue then
      Logger.Intf.Log(Format('%s.Value: %d' , [ AMsg, ANull.Value ]))
    else
      Logger.Intf.Log(Format('%s.Value: not initialized', [AMsg]));
  end;

  procedure Log( const AMsg: String ); overload;
  begin
    Logger.Intf.Log( AMsg );
  end;






begin
  if IsConsole then
    Log('The application is running as a console application.')
  else
    Log('The application is not running as a console application.');


  var s: String := 'Test Log';
  Log( s );
  try
    { TODO -oUser -cConsole Main : Insert code here }
    lNullInt1.Value:=  10;

    Log( 'NullInt1', lNullInt1 );
    Log( 'NullInt2', lNullInt2 );

    lNullInt2 := lNullInt1;

    Log( sLineBreak + 'NullInt2 = NullInt1' + sLineBreak );

    Log( 'NullInt1', lNullInt1 );
    Log( 'NullInt2', lNullInt2 );

    lNullInt2.Empty;
    Log( sLineBreak + 'Empty NullInt2' + sLineBreak );

    Log( 'NullInt1', lNullInt1 );
    Log( 'NullInt2', lNullInt2 );

    if lNullInt2.IsNull then
      lNullInt2.Value := 20;

    Log( sLineBreak + 'set NullInt2.Value' + sLineBreak );

    Log( 'NullInt1', lNullInt1 );
    Log( 'NullInt2', lNullInt2 );


    //Inline Variable

    var  lNullInt3: TNullable<Integer> := TNullable<Integer>.Create( 45 );
    Log( sLineBreak + 'Create inline NullInt3' + sLineBreak );

    Log( 'NullInt3', lNullInt3 );



    readln( s );

  except
    on E: Exception do
    begin
      Log( Format( '%s : %s', [E.ClassName, E.Message]) );
      readln( s );
    end;
  end;
end.
