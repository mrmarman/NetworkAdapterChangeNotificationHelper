program NetworkAdapterNotify;

uses
  Vcl.Forms,
  Unit1 in 'Units\Unit1.pas' {Form1},
  NetwokAdapter_Helper in 'Units\NetwokAdapter_Helper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
