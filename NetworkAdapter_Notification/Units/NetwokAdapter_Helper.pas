unit NetwokAdapter_Helper;
//IMG// http://res.cloudinary.com/trt/image/upload/v1553024238/egrmympfglakpszpkmcn.png
interface

Uses Classes, ExtCtrls, SysUtils, Variants, ActiveX, ComObj;

Type
  TOnAdapterListChange    = Procedure( aChangeList: Classes.TStrings ) of object;

Type
  TNetworkAdapter_Helper  = Class(TObject)
  protected
  private
    FOnAdapterListChange    : TOnAdapterListChange;
    FTimer                  : ExtCtrls.TTimer;
    FListe, FListeAnlik     : TStringList;
    FInterval               : Integer;
    function    GetInterval : Integer;
    procedure   SetInterval       ( aInterval: Integer  );
    function    GetEnable   : Boolean;
    procedure   SetEnable         ( aEnable:Boolean     );
    procedure   FTimerOnTimer     ( Sender:TObject      );
    procedure   NetworkAdapterList( aList: TStrings     );
  public
    constructor Create;
    destructor  Destroy; Override;
    property    OnAdapterListChange : TOnAdapterListChange  read FOnAdapterListChange  write FOnAdapterListChange;
    property    Interval  : Integer read GetInterval  write SetInterval;
    property    Enable    : boolean read GetEnable    write SetEnable;
  End;

implementation

{ TNetworkAdapter_Helper }

constructor TNetworkAdapter_Helper.Create;
begin
  Inherited;  // Create'de  daima baþta call edicez...
  //...
  FListe          := TStringList.Create;
  FListeAnlik     := TStringList.Create;

  FInterval       := 5000; // varsayýlan 5 saniye
  FTimer          := ExtCtrls.TTimer.Create(nil);
  FTimer.Interval := FInterval;
  FTimer.Enabled  := False;
  FTimer.OnTimer  := FTimerOnTimer;
end;

destructor TNetworkAdapter_Helper.Destroy;
begin
  FTimer.Enabled := False;
  FTimer.Free;

  FListe.Free;
  FListeAnlik.Free;
  Inherited;  // Destroy'da daima sonda call edicez...
end;

procedure TNetworkAdapter_Helper.FTimerOnTimer(Sender: TObject);
{$j+}
Const IslemSuruyor : Boolean = False;
{$j-}
begin
// Interval bir þekilde çok kýsa ise,
// iþlem bitene kadar TimerOnTimer dikkate alýnmayacaktýr...
  if IslemSuruyor then Exit;

  IslemSuruyor := True;
  if Assigned( FOnAdapterListChange ) then
  begin
    FListeAnlik.Clear;
    NetworkAdapterList( FListeAnlik );
    if FListeAnlik.Text <> FListe.Text then
    begin
      FListe.Assign(  FListeAnlik );
      FOnAdapterListChange( FListe );
    end;
  end;
  IslemSuruyor := False;
end;

procedure TNetworkAdapter_Helper.NetworkAdapterList( aList: TStrings );
Const
  wbemFlagForwardOnly = $00000020;
var
  FSWbemLocator : OLEVariant;
  FWMIService   : OLEVariant;
  FWbemObjectSet: OLEVariant;
  FWbemObject   : OLEVariant;
  oEnum         : IEnumvariant;
  iValue        : LongWord;
  strStat       : String;
  strAdapterType: String;
begin;
  FSWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
  try
    FWMIService   := FSWbemLocator.ConnectServer('localhost', 'root\CIMV2', '', '');
    FWbemObjectSet:= FWMIService.ExecQuery('SELECT * FROM Win32_NetworkAdapter','WQL',wbemFlagForwardOnly);
    oEnum         := IUnknown(FWbemObjectSet._NewEnum) as IEnumVariant;
    while oEnum.Next(1, FWbemObject, iValue) = 0 do
    begin
      if NOT VarIsNull(FWbemObject.NetConnectionStatus) Then
      begin
       // Ref. https://docs.microsoft.com/en-us/dotnet/api/microsoft.powershell.commands.netconnectionstatus?view=powershellsdk-1.1.0
          case FWbemObject.NetConnectionStatus of
            00: strStat := 'Disconnected';
            01: strStat := 'Connecting';
            02: strStat := 'Connected';
            03: strStat := 'Disconnecting';
            04: strStat := 'Hardware Not Present';
            05: strStat := 'Hardware Disabled';
            06: strStat := 'Hardware Malfunction';
            07: strStat := 'Media Disconnected';
            08: strStat := 'Authenticating';
            09: strStat := 'Authentication Succeeded';
            10: strStat := 'Authentication Failed';
            11: strStat := 'Invalid Address';
            12: strStat := 'Credentials Required';
          end;

        if pos('ETHERNET',  UpperCase( String(FWbemObject.NetConnectionID) ) ) > 0
          then strAdapterType := 'Ethernet'
          else
        if pos('WI-FI',     UpperCase( String(FWbemObject.NetConnectionID) ) ) > 0
          then strAdapterType := 'WiFi'
          else strAdapterType := '';

        if  ( strAdapterType <> '' )
        AND ( Pos('VIRTUAL', UpperCase( String(FWbemObject.Name) )) = 0 )
          then aList.Add( Format('[%s] %s : %s',[strAdapterType, String(FWbemObject.Name), strStat]) );
      end;
      FWbemObject :=  Unassigned;
    end;
  finally
    FSWbemLocator  := Unassigned;
    FWMIService    := Unassigned;
    FWbemObjectSet := Unassigned;
    FWbemObject    := Unassigned;
  end;
end;

function TNetworkAdapter_Helper.GetEnable: Boolean;
begin
  Result := FTimer.Enabled;
end;

procedure TNetworkAdapter_Helper.SetEnable(aEnable: Boolean);
begin
  FTimer.Enabled := aEnable;
end;

function TNetworkAdapter_Helper.GetInterval: Integer;
begin
  Result := FInterval;
end;

procedure TNetworkAdapter_Helper.SetInterval(aInterval: Integer);
var
  boolState : Boolean; // Timer son durumuna göre çalýþmaya veya durmaya devam etsin... :)
begin
  boolState       := FTimer.Enabled;

  FInterval       := aInterval;
  FTimer.Enabled  := False;
  FTimer.Interval := FInterval;
  FTimer.Enabled  := boolState;
end;



end.
