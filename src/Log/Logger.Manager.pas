unit Logger.Manager;

interface

uses
  Logger.Intf;

type


  TLogManager = class( TInterfacedObject, ILogManager )
  private
{$IFDEF DEBUG}
    FLogIDE: ILog;
{$ENDIF}
    FLogConsole: ILog;
  public
    constructor Create;
    class function New: ILogManager;
    function Log( const AMsg: String ): ILogManager;
  end;

implementation

uses
{$IFDEF DEBUG}
  Logger.IDE,
{$ENDIF}
  Logger.Console;

{ TLogManager }

constructor TLogManager.Create;
begin
{$IFDEF DEBUG}
  FLogIDE := TLogIDE.New;
{$ENDIF}
  FLogConsole := TLogConsole.New;
end;

function TLogManager.Log(const AMsg: String): ILogManager;
begin
{$IFDEF DEBUG}
  FLogIDE.Log( AMsg );
{$ENDIF}
  if IsConsole then
    FLogConsole.Log( AMsg );
end;


class function TLogManager.New: ILogManager;
begin
  Result := Self.Create;
end;


end.
