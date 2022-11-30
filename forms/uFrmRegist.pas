//注册检测单元
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
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
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
  if BtnSET.Caption = '试用' then
    EdtRegist.Text := EnCode(EdtCode.Text+'_'+FormatDateTime('YYYYMMDD', Now + 3),Trim(EdtCode.Text));
  if Trim(EdtRegist.Text) = '' then
  begin
    MessageBox(Handle, '请先输入注册码！', '错误', MB_ICONERROR);
    Exit;
  end;
  if not RegisterCPUID(EdtRegist.Text) then
  begin
    if not FileExists(ChangeFileExt(ParamStr(0), '.ini')) then
      MessageBox(Handle, PChar('['+ChangeFileExt(ParamStr(0), '.ini')+']文件创建失败！请使用管理员运行或者放置非系统盘启动！')
        , '错误', MB_ICONERROR)
    else
      MessageBox(Handle, pchar('['+ChangeFileExt(ParamStr(0), '.ini')+']文件读写失败！请检查文件属性！')
        , '错误', MB_ICONERROR);
  end
  else
  begin
    if CheckCPUID then
    begin
      if BtnSET.Caption = '注册' then
      begin
        MessageBox(Handle, '服务注册成功！请重启程序！', '提示', MB_ICONASTERISK and MB_ICONINFORMATION);
        Application.Terminate;
      end
      else
      begin
        MessageBox(Handle, '服务试用成功！请重启程序！'+#13#10
          +'当前授权码仅可试用三天，请及时联系公司处理！', '提示', MB_ICONASTERISK and MB_ICONINFORMATION);
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
      MessageBox(Handle, '注册码不正确！请联系QQ******！', '错误', MB_ICONERROR);
      EdtRegist.Text := '';
      if EdtRegist.CanFocus then
        EdtRegist.SetFocus;
    end;
  end;

end;

procedure TFrmRegist.FormCreate(Sender: TObject);
begin
  if FileExists(ChangeFileExt(ParamStr(0), '.db')) then
    BtnSET.Caption := '试用';
end;

procedure TFrmRegist.FormShow(Sender: TObject);
begin
  EdtCode.Text := GetCPUIDStr;
end;

end.

