unit Logger.Intf;

interface

type
  ILog = interface
    ['{4D1D19A0-7502-4830-B532-742DD206E9FB}']
    function Log( const AMsg: String ): ILog;
  end;


  ILogManager = interface
    ['{C65EBC36-98B2-4E01-B774-C98D509E4C34}']
    function Log( const AMsg: String ): ILogManager;
  end;

procedure Log( const AMsg: String );


implementation


uses
  Logger.Manager;

var
  FLog : ILogManager;

procedure Log( const AMsg: String );
begin
  if not Assigned( FLog ) then
    FLog := TLogManager.New;
  FLog.Log( AMsg );
end;

end.
