unit Logger.Console;


interface

uses
  System.SysUtils,
  Logger.Intf;

type

  TLogConsole = class( TInterfacedObject , ILog )
  private
  public
    constructor Create;
    class function New: ILog;
    function Log( const AMsg: String ): ILog;
  end;

implementation


{ LogIDE }

constructor TLogConsole.Create;
begin

end;

function TLogConsole.Log(const AMsg: String): ILog;
begin
  System.writeln( AMsg );
end;

class function TLogConsole.New: ILog;
begin
  Result := Self.Create;
end;

end.
