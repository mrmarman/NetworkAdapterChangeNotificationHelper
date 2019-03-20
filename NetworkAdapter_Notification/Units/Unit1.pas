unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure NetworkOnAdapterListChange(aChangeList: TStrings);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses NetwokAdapter_Helper;

var
  aNetwork : TNetworkAdapter_Helper;

procedure TForm1.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;

  aNetwork          := TNetworkAdapter_Helper.Create;
  aNetwork.OnAdapterListChange  := NetworkOnAdapterListChange;
  aNetwork.Interval := 1000; // (1) saniyede bir Liste Tazeler...
end;

procedure TForm1.NetworkOnAdapterListChange( aChangeList: TStrings );
begin
  Memo1.Lines.AddStrings( aChangeList );
  Memo1.Lines.Add('------------------')
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  aNetwork.Enable := true;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
  aNetwork.Enable := false;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  aNetwork.Enable := False;
  aNetwork.Free;
end;


end.
