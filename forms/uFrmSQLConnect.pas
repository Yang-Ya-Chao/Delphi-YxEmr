unit uFrmSQLConnect;
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Comp.Client, Vcl.Buttons,uConfig,
  qdialog_builder;

type
  TFrmSQLConnect = class(TForm)
    lbl1: TLabel;
    EdtServer: TEdit;
    EdtDBName: TEdit;
    lbl2: TLabel;
    lbl3: TLabel;
    EdtUserName: TEdit;
    EdtPass: TEdit;
    EdtPort: TEdit;
    lbl4: TLabel;
    lbl5: TLabel;
    BtnCSLJ: TBitBtn;
    BtnMod: TBitBtn;
    BtnSave: TBitBtn;
    BtnCancel: TBitBtn;
    ck1: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure ReadConfig;
    procedure BtnModClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnCSLJClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure ck1Click(Sender: TObject);
  private
    function UpdateSQL(con: TFDConnection): Boolean;
    { Private declarations }
  public
    { Public declarations }

    YxSCKTINI: string;
    function BSTATUS(ISTATUS: Boolean): Boolean;
  end;

var
  FrmSQLConnect: TFrmSQLConnect;

implementation

{$R *.dfm}

procedure TFrmSQLConnect.BtnCancelClick(Sender: TObject);
begin
  ReadConfig;
  BSTATUS(false);
end;

function TFrmSQLConnect.UpdateSQL(con:TFDConnection):Boolean;
var
  ABuilder: IDialogBuilder;
  AHint: TLabel;
  AProgress: TProgressBar;
  I: Integer;
  T: Cardinal;
  UpQry:TFDQuery;
  str:string;
begin
  Result := False;
  var List:=Tstringlist.Create;
  UpQry := TFDQuery.Create(nil);
  List.LoadFromFile(ExtractFilePath(ParamStr(0))+'UpdateSQL.sql');
  ABuilder := NewDialog('进度窗口');
  try
    UpQry.Connection := con;
    ABuilder.ItemSpace := 10;
    ABuilder.AutoSize := True;
    ABuilder.Dialog.Padding.SetBounds(5, 5, 5, 5);
    AHint := TLabel(ABuilder.AddControl(TLabel).Control);
    AHint.Caption := '正在升级脚本，已完成0%...';
    AHint.AlignWithMargins := True;
    AProgress := TProgressBar(ABuilder.AddControl(TProgressBar).Control);
    AProgress.AlignWithMargins := True;
    with ABuilder.AddContainer(amHorizCenter) do
    begin
      Height := 24;
      with TButton(AddControl(TButton).Control) do
      begin
        Caption := '取消';
        ModalResult := mrCancel;
      end;
    end;
    ABuilder.CanClose := False;
    ABuilder.Realign;
    ABuilder.Width := Self.Width;
    ABuilder.Popup(Self);
    AProgress.Max := List.count;
    if List.count < 1 then
      AHint.Caption := '无升级脚本文件[UpdateSQL.sql]';
    for I := 0 to List.count-1 do
    begin
      AHint.Caption := '正在升级脚本，已完成' + IntToStr(Trunc((I+1)/(List.count)*100)) + '%';
      AProgress.Position := I;
      T := GetTickCount;
      while GetTickCount - T < 100 do
      begin
        Application.ProcessMessages;
        if ABuilder.Dialog.ModalResult = mrCancel then
          Break;
      end;
      if List[i] = 'go' then
      begin
        UpQry.ExecSQL(str);
        str := '';
        continue;
      end;
      str := str+List[i]+#13#10;
    end;
  finally
    ABuilder._Release;
    UpQry.Free;
    List.Free;
  end;
  Result := True;
end;


procedure TFrmSQLConnect.BtnCSLJClick(Sender: TObject);
var
  FConnObj: TFDConnection; //数据库连接对象
  str: string;
  i:integer;
begin
  FConnObj := TFDConnection.Create(nil);
  try
    str := 'DriverID=MSSQL;Server=' + EdtServer.Text + ';Database=' + EdtDBName.Text
      + ';User_name=' + EdtUserName.Text + ';Password=' + EdtPASS.Text;
    with FConnObj do
    begin
      //ConnectionTimeout:=18000;
      ConnectionString := str;
      try
        Connected := True;
      except
        on e: Exception do
        begin
          MessageBox(Handle, PChar('数据库连接失败！' + e.Message), '错误', MB_ICONERROR);
          Exit;
        end;
      end;
      if not FileExists(ExtractFilePath(ParamStr(0))+'UpdateSQL.sql') then
        MessageBox(Handle, '数据库连接成功！', '提示', MB_ICONASTERISK and MB_ICONINFORMATION)
      else
      if MessageBox(Handle, '数据库连接成功！是否升级脚本？', '询问', MB_OKCANCEL + MB_ICONQUESTION)=IDOK then
      begin
        if not UpdateSQL(FConnObj) then
          MessageBox(Handle, PChar('脚本升级失败！请手动升级！' ), '错误', MB_ICONERROR);
      end;
    end;
  finally
    FConnObj.Connected := False;
    FConnObj.Free;
  end;
end;

procedure TFrmSQLConnect.BtnModClick(Sender: TObject);
begin
  BSTATUS(True);
end;

procedure TFrmSQLConnect.BtnSaveClick(Sender: TObject);

begin
  ini.DBServer := Edtserver.Text;
  ini.DBDataBase := Edtdbname.Text;
  ini.DBUserName := Edtusername.Text;
  ini.DBPassWord := Edtpass.Text;
  ini.SaveToFile(YxSCKTINI);
  MessageBox(Handle, '链接保存成功！请重启程序生效！', '提示', MB_ICONASTERISK and MB_ICONINFORMATION);
  ReadConfig;
  BSTATUS(false);
end;

procedure TFrmSQLConnect.ck1Click(Sender: TObject);
begin
  if ck1.Checked then
    EdtPass.PasswordChar := #0
  else if not ck1.checked then
    EdtPass.PasswordChar := '*';

end;


function TFrmSQLConnect.BSTATUS(ISTATUS: Boolean): boolean;
begin
  EdtServer.Enabled := ISTATUS;
  EdtDBName.Enabled := ISTATUS;
  EdtUserName.Enabled := ISTATUS;
  Edtpass.Enabled := ISTATUS;
  BtnCancel.Enabled := ISTATUS;
  BtnSave.Enabled := ISTATUS;
  BtnMod.Enabled := not ISTATUS;
  Result := True;
end;

procedure TFrmSQLConnect.FormShow(Sender: TObject);
begin
  BSTATUS(false);
  YxSCKTINI := ChangeFileExt(ParamStr(0), '.ini');
  ini.LoadFromFile(YxSCKTINI);
  ReadConfig;
  ck1.SetFocus;
end;

procedure TFrmSQLConnect.ReadConfig;
begin
  EdtServer.Text := ini.DBServer;
  EdtDBName.Text := ini.DBDataBase;
  EdtUserName.Text := ini.DBUserName;
  EdtPass.Text := ini.DBPassWord;
end;

end.

