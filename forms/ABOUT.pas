unit About;

interface

uses WinApi.Windows, System.Classes, Vcl.Graphics,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  QRCode;

type
  TAboutBox = class(TForm)
    OKButton: TButton;
    lbl1: TLabel;
    lblProductName: TLabel;
    lblVersion: TLabel;
    lblCopyright: TLabel;
    img1: TImage;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.dfm}

procedure TAboutBox.FormCreate(Sender: TObject);
var
  zxing: TDelphiZXingQRCode;
begin
  zxing := TDelphiZXingQRCode.Create;
  try
    //二维码外边距
    zxing.QuietZone := 0;
    //可选值qrAuto, qrNumeric, qrAlphanumeric, qrISO88591, qrUTF8NoBOM, qrUTF8BOM
    //zxing.Encoding := qrAuto;
    zxing.EncodeToImage('https://47q480p552.picp.vip/IWSYXHIS', Img1);
  finally
    zxing.Free;
  end;
end;

end.

