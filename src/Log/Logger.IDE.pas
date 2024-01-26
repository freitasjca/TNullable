unit Logger.IDE;

interface

uses
  System.Classes,
  System.SysUtils,
  Windows,
  Logger.Intf;

type

  TLogIDE = class( TInterfacedObject , ILog )
  private
  public
    constructor Create;
    class function New: ILog;
    function Log( const AMsg: String ): ILog;
  end;

implementation


{ LogIDE }

constructor TLogIDE.Create;
begin

end;

function TLogIDE.Log(const AMsg: String): ILog;
begin
  OutputDebugString(PChar(AMsg));
end;

class function TLogIDE.New: ILog;
begin
  Result := Self.Create;
end;

end.
