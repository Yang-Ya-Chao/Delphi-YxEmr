unit uFrmRegister;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,uEncry,Clipbrd;

type
  TFrmMain = class(TForm)
    lbl2: TLabel;
    lbl1: TLabel;
    EdtCode: TEdit;
    EdtRegist: TEdit;
    BtnSET: TBitBtn;
    BtnGet: TBitBtn;
    EdtDATA: TEdit;
    cbb1: TComboBox;
    procedure BtnSETClick(Sender: TObject);
    procedure BtnGetClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}


procedure TFrmMain.BtnGetClick(Sender: TObject);
begin
  Clipboard.SetTextBuf(PWideChar(EdtRegist.Text));
end;

procedure TFrmMain.BtnSETClick(Sender: TObject);
var
  SDATE: string;
  DATA:Integer;
  ID:Integer;
begin
  if Trim(EdtCode.Text) = '' then
  begin
    MessageBox(Handle, '«Î ‰»Îª˙∆˜¬Î£°', '¥ÌŒÛ', MB_ICONERROR);
    Exit;
  end;
  if EdtDATA.Text = '' then  EdtDATA.Text := '6';
  case cbb1.ItemIndex of
    0:ID := 1;
    1:ID := 30;
    2:ID := 365;
  end;
  DATA := strtoint(EdtDATA.Text);
  SDATE := EdtCode.Text+'_'+FormatDateTime('YYYYMMDD', Now + ID*DATA);
  EdtRegist.Text := EnCode(SDATE,Trim(EdtCode.Text));
end;

end.
