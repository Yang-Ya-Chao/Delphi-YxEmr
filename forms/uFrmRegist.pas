//ע���ⵥԪ
unit uFrmRegist;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, UpubFun,
  Clipbrd,uEncry,uFrmAuthManage;

type
  TFrmRegist = class(TForm)
    lbl1: TLabel;
    lbl2: TLabel;
    EdtRegist: TEdit;
    EdtCode: TEdit;
    BtnGet: TBitBtn;
    BtnSET: TBitBtn;
    procedure BtnGetClick(Sender: TObject);
    procedure BtnSETClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EdtRegistChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Test:string;
  end;

var
  FrmRegist: TFrmRegist;

implementation

{$R *.dfm}

procedure TFrmRegist.BtnGetClick(Sender: TObject);
begin
  Clipboard.SetTextBuf(PWideChar(EdtCode.Text));
end;

procedure TFrmRegist.BtnSETClick(Sender: TObject);
begin
  if BtnSET.Caption = '����' then
  begin
    if EdtRegist.Text = '' then
      EdtRegist.Text := Test;
  end;

  if Trim(EdtRegist.Text) = '' then
  begin
    MessageBox(Handle, '��������ע���룡', '����', MB_ICONERROR);
    Exit;
  end;
  if not RegisterCPUID(EdtRegist.Text) then
  begin
    if not FileExists(ChangeFileExt(ParamStr(0), '.ini')) then
      MessageBox(Handle, PChar('['+ChangeFileExt(ParamStr(0), '.ini')+']�ļ�����ʧ�ܣ���ʹ�ù���Ա���л��߷��÷�ϵͳ��������')
        , '����', MB_ICONERROR)
    else
      MessageBox(Handle, pchar('['+ChangeFileExt(ParamStr(0), '.ini')+']�ļ���дʧ�ܣ���ȥ���ļ�ֻ�����ԣ�')
        , '����', MB_ICONERROR);
  end
  else
  begin
    if CheckCPUID then
    begin
      if EdtRegist.Text <> Test then
      begin
        MessageBox(Handle, '����ע��ɹ�������������', '��ʾ', MB_ICONASTERISK and MB_ICONINFORMATION);
        Application.Terminate;
      end
      else
      begin
        MessageBox(Handle, '�������óɹ�������������'+#13#10
          +'��ǰ��Ȩ������������죬�뼰ʱ��ϵ��˾����', '��ʾ', MB_ICONASTERISK and MB_ICONINFORMATION);
        with TFrmAuthManage.Create(self) do
        try
          Position := poScreenCenter;
          Show;
          visible := False;
          btnrefresh.Click;
        finally
          //Free;
        end;
        Application.Terminate;
      end;
    end
    else
    begin
      MessageBox(Handle, 'ע���벻��ȷ�����ѵ��ڣ�����ϵ��˾����', '����', MB_ICONERROR);
      EdtRegist.Text := '';
      if EdtRegist.CanFocus then
        EdtRegist.SetFocus;
    end;
  end;

end;

procedure TFrmRegist.EdtRegistChange(Sender: TObject);
begin
  if (EdtRegist.Text <> '') and (Test <> '') then
    BtnSET.Caption := 'ע��'
  else if (EdtRegist.Text = '') and (Test <>'') then
    BtnSET.Caption := '����';
end;

procedure TFrmRegist.FormCreate(Sender: TObject);
begin
  EdtCode.Text := GetCPUIDStr;
  if FileExists(ChangeFileExt(ParamStr(0), '.db')) then
  begin
    BtnSET.Caption := '����';
    Test := EnCode(EdtCode.Text+'_'+FormatDateTime('YYYYMMDD', Now + 3),Trim(EdtCode.Text));
  end;

end;

procedure TFrmRegist.FormShow(Sender: TObject);
begin
  if Test <> '' then
  begin
    BtnSET.SetFocus;
    EdtRegist.TextHint := '���ò���дע����';
  end;
end;

end.

