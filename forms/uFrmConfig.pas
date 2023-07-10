unit uFrmConfig;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  uConfig, UpubFun, Winapi.WinSock, TLhelp32, PsAPI,
  uFrmMQTTClient, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.Menus, Data.DB,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, FireDAC.Comp.Client, qdialog_builder, uObjPools,
  uQueryHelper, uEncry, Winapi.Messages,Vcl.Clipbrd,Snowflake,SynCrypto;
const
  iHtoH = 15; //行间距
  iWtoW = 20; //列间距
  iWidth = 100; //按钮宽度
  InputBoxMessage = WM_USER + 200;
type
  TFrmConfig = class(TForm)
    pnl2: TPanel;
    BtnCancel: TBitBtn;
    BtnSave: TBitBtn;
    BtnMod: TBitBtn;
    pnl1: TPanel;
    pgc1: TPageControl;
    ts1: TTabSheet;
    ts2: TTabSheet;
    pnl3: TPanel;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl5: TLabel;
    edtWorkcount: TEdit;
    ckMsg: TCheckBox;
    ckReBoot: TCheckBox;
    ckAutoRun: TCheckBox;
    ckRun: TCheckBox;
    edtPort: TEdit;
    btnBtnCheckPort: TBitBtn;
    edtSize: TEdit;
    ckSQL: TCheckBox;
    edtReBootT: TEdit;
    ckEMR: TCheckBox;
    ckSYSLOG: TCheckBox;
    edtIP: TEdit;
    ckErr: TCheckBox;
    ckAES: TCheckBox;
    cbbip: TComboBox;
    ckCache: TCheckBox;
    ts3: TTabSheet;
    ds1: TDataSource;
    pm1: TPopupMenu;
    mniN1: TMenuItem;
    mnioken1: TMenuItem;
    pnl4: TPanel;
    grp1: TGroupBox;
    pnl5: TPanel;
    Grid1: TDBGrid;
    btnrefresh: TButton;
    btnDel: TBitBtn;
    btnAdd: TBitBtn;
    pnl6: TPanel;
    lblUser: TLabel;
    lblUser1: TLabel;
    GB1: TRadioGroup;
    edtTime: TEdit;
    edtUser: TEdit;
    ts4: TTabSheet;
    btnCSLJ: TBitBtn;
    pnl7: TPanel;
    lbl4: TLabel;
    edtServer: TEdit;
    edtDBName: TEdit;
    lbl6: TLabel;
    lbl7: TLabel;
    edtUserName: TEdit;
    edtPass: TEdit;
    ck1: TCheckBox;
    lbl8: TLabel;
    Grid2: TDBGrid;
    procedure edtWorkcountExit(Sender: TObject);
    procedure ckReBootClick(Sender: TObject);
    procedure BtnModClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure btnBtnCheckPortClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure edtSizeExit(Sender: TObject);
    procedure edtReBootTExit(Sender: TObject);
    procedure ckSYSLOGClick(Sender: TObject);
    procedure ckAESClick(Sender: TObject);
    procedure ckCacheClick(Sender: TObject);
    procedure pgc1Change(Sender: TObject);
    procedure btnCSLJClick(Sender: TObject);
    procedure ck1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Grid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure mniN1Click(Sender: TObject);
    procedure mnioken1Click(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure btnrefreshClick(Sender: TObject);
  private
    function UpdateSQL(con: TFDConnection): Boolean;
    procedure AfterScroll(DataSet: TDataSet);
    procedure Reset;
    procedure GetAuthGrid;
    function CheckGLY: Boolean;
    { Private declarations }
  public
    { Public declarations }
    iPerLine: integer; //每行个数
    Checkboxs: array of TCheckBox;
    MethodList: TStringlist;
    FCSQL: string; //刷新时sql语句
    ILX: Integer; //0:新增，1:修改，2:刷新
    CID: string;
    DB: TFDConnection;
    Qry: TFDQuery;
    SysPort: string;
    YxSCKTINI: string;
    procedure ReadConfig;
    function BSTATUS(ISTATUS: Boolean): boolean;
    procedure InputBoxSetPasswordChar(var Msg: TMessage); message InputBoxMessage;//声明
  end;

var
  FrmConfig: TFrmConfig;



implementation

{$R *.dfm}

procedure TFrmConfig.BitBtn1Click(Sender: TObject);
begin
  MessageBox(Handle, '功能未开放！', '提示', MB_ICONERROR);
  exit;
  with TFrmMQClient.Create(self) do
  try
    Position := poScreenCenter;
    ShowModal;
  finally
    Free;
  end;
end;

function TFrmConfig.BSTATUS(ISTATUS: Boolean): boolean;
begin
  pnl3.Enabled := ISTATUS;
  pnl4.Enabled := ISTATUS;
  pnl5.Enabled := ISTATUS;
  pnl7.Enabled := ISTATUS;
  BtnCancel.Enabled := ISTATUS;
  BtnSave.Enabled := ISTATUS;
  BtnMod.Enabled := not ISTATUS;
  GB1.ItemIndex := -1;
end;

procedure TFrmConfig.ReadConfig;
begin
  CKRUN.CHECKED := ini.Auto;
  CKAUTORUN.CHECKED := ini.AutoRun;
  CKREBOOT.CHECKED := ini.ReBoot;
  EdtReBootT.text := ini.ReBootT.ToString;
  CKMsg.CHECKED := ini.MsgLog;
  CKSQL.CHECKED := ini.SQLLog;
  CKErr.CHECKED := ini.ErrLog;
  ckEMR.Checked := ini.BFile;
  EdtWorkCount.text := ini.Pools.ToString;
  EdtPort.Text := ini.Port;
  EdtSize.Text := ini.LogSize.ToString;
  EdtIP.Text := ini.SysLogIP;
  ckSYSLOG.Checked := ini.BSysLog;
  SysPort := ini.SysLogPort.ToString;
  ckAES.Checked := ini.AES;
  if Ini.IP = '' then
  begin
    cbbip.ItemIndex := cbbip.Items.IndexOf(GetLocalIP(False));
  end
  else
    cbbip.ItemIndex := cbbip.Items.IndexOf(Ini.IP);
  ckCache.Checked := Ini.UseCache;
  EdtServer.Text := ini.DBServer;
  EdtDBName.Text := ini.DBDataBase;
  EdtUserName.Text := ini.DBUserName;
  EdtPass.Text := ini.DBPassWord;
end;

procedure TFrmConfig.BtnCancelClick(Sender: TObject);
begin
  BSTATUS(false);
  GetAuthGrid ;
  ReadConfig;
end;

function TFrmConfig.UpdateSQL(con: TFDConnection): Boolean;
var
  ABuilder: IDialogBuilder;
  AHint: TLabel;
  AProgress: TProgressBar;
  I: Integer;
  T: Cardinal;
  UpQry: TFDQuery;
  str: string;
begin
  Result := False;
  var List := Tstringlist.Create;
  UpQry := TFDQuery.Create(nil);
  List.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'UpdateSQL.sql');
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
    for I := 0 to List.count - 1 do
    begin
      AHint.Caption := '正在升级脚本，已完成' + IntToStr(Trunc((I + 1) / (List.count) * 100)) + '%';
      AProgress.Position := I;
      T := GetTickCount;
      while GetTickCount - T < 100 do
      begin
        Application.ProcessMessages;
        if ABuilder.Dialog.ModalResult = mrCancel then
          Break;
      end;
      if List[I] = 'go' then
      begin
        UpQry.ExecSQL(str);
        str := '';
        continue;
      end;
      str := str + List[I] + #13#10;
    end;
  finally
    ABuilder._Release;
    UpQry.Free;
    List.Free;
  end;
  Result := True;
end;

procedure TFrmConfig.BtnCSLJClick(Sender: TObject);
var
  FConnObj: TFDConnection; //数据库连接对象
  str: string;
  i: integer;
begin
  FConnObj := TFDConnection.Create(nil);
  try
    str := 'DriverID=MSSQL;Server=' + EdtServer.Text + ';Database=' + EdtDBName.Text + ';User_name=' + EdtUserName.Text + ';Password=' + EdtPASS.Text;
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
      if not FileExists(ExtractFilePath(ParamStr(0)) + 'UpdateSQL.sql') then
        MessageBox(Handle, '数据库连接成功！', '提示', MB_ICONASTERISK and MB_ICONINFORMATION)
      else if MessageBox(Handle, '数据库连接成功！是否升级脚本？', '询问', MB_OKCANCEL + MB_ICONQUESTION) = IDOK then
      begin
        if not UpdateSQL(FConnObj) then
          MessageBox(Handle, PChar('脚本升级失败！请手动升级！'), '错误', MB_ICONERROR);
      end;
    end;
  finally
    FConnObj.Connected := False;
    FConnObj.Free;
  end;
end;

procedure TFrmConfig.btnDelClick(Sender: TObject);
begin

  BSTATUS(False);
  if pgc1.ActivePageIndex = 3 then
  begin
    if Qry.IsEmpty then Exit;
    if not CheckGLY then Exit;
    try
      if MessageBox(Handle, Pchar('确认删除授权码['+CID+']？'), '提示', MB_YESNO+MB_ICONQUESTION) = IDYES then
      begin
        var CSQL := 'Delete From TBYxEmrAuthManage where iid='+CID;
        Qry.SQL.Text := CSQL;
        try
          Qry.ExecSQL;
        except
          on e:Exception do
          begin
            MessageBox(Handle, PChar(e.message+'SQL='+CSQL), '错误', MB_ICONERROR);
            Exit;
          end;
        end;
      end;
    finally
      GetAuthGrid ;
    end;
  end;
end;

procedure TFrmConfig.btnAddClick(Sender: TObject);
begin
  BSTATUS(True);
  if pgc1.ActivePageIndex = 3 then
  begin
    if not CheckGLY then Exit;
    ILX := 0;
    var IID := IdGenerator.NextId();
    CID := IID.ToString;
    Reset;
  end;


end;

procedure TFrmConfig.btnBtnCheckPortClick(Sender: TObject);
const
  ANY_SIZE = 1;
  iphlpapi = 'iphlpapi.dll';
  TCP_TABLE_OWNER_PID_ALL = 5;
  MIB_TCP_STATE: array[1..12] of string = ('CLOSED', 'LISTEN', 'SYN-SENT ', 'SYN-RECEIVED', 'ESTABLISHED', 'FIN-WAIT-1', 'FIN-WAIT-2', 'CLOSE-WAIT', 'CLOSING', 'LAST-ACK', 'TIME-WAIT', 'delete TCB');
type
  TCP_TABLE_CLASS = Integer;

  PMibTcpRowOwnerPid = ^TMibTcpRowOwnerPid;

  TMibTcpRowOwnerPid = packed record
    dwState: DWORD;
    dwLocalAddr: DWORD;
    dwLocalPort: DWORD;
    dwRemoteAddr: DWORD;
    dwRemotePort: DWORD;
    dwOwningPid: DWORD;
  end;

  PMibTcpTableOwnerPID = ^TPMibTcpTableOwnerPID;

  TPMibTcpTableOwnerPID = packed record
    dwNumEntries: DWord;
    table: array[0..ANY_SIZE - 1] of TMibTcpRowOwnerPid;
  end;
var
  GetExtendedTcpTable: function(pTcpTable: Pointer; dwSize: PDWORD; bOrder: BOOL; lAf: ULONG; TableClass: TCP_TABLE_CLASS; Reserved: ULONG): DWord; stdcall;

  function GetProcessNameById(const AID: Integer): string;
  var
    h: thandle;
    f: boolean;
    lppe: tprocessentry32;
  begin
    Result := '';
    h := CreateToolhelp32Snapshot(TH32cs_SnapProcess, 0);
    lppe.dwSize := sizeof(lppe);
    f := Process32First(h, lppe);
    while integer(f) <> 0 do
    begin
      if Integer(lppe.th32ProcessID) = AID then
      begin
        Result := StrPas(lppe.szExeFile);
        break;
      end;
      f := Process32Next(h, lppe);
    end;
  end;

  function FindPidByTcpPort(port: Cardinal): string;
  var
    pTcpTable: PMibTcpTableOwnerPID;
    dwSize: DWORD;
    i: Integer;
    PID: integer;
    libHandle: THandle;
  begin
    Result := '';
    dwSize := 0;
    PID := 0;
    libHandle := LoadLibrary(iphlpapi);
    GetExtendedTcpTable := GetProcAddress(libHandle, 'GetExtendedTcpTable');
  //查询大小
    if GetExtendedTcpTable(nil, @dwSize, FALSE, AF_INET, TCP_TABLE_OWNER_PID_ALL, 0) = ERROR_INSUFFICIENT_BUFFER then
    begin
      pTcpTable := AllocMem(dwSize);
    //获取TCP连接表
      try
        if GetExtendedTcpTable(pTcpTable, @dwSize, True, AF_INET, TCP_TABLE_OWNER_PID_ALL, 0) = NO_ERROR then
        begin
          port := htons(port);

          for i := 0 to pTcpTable.dwNumEntries - 1 do
          begin
            if pTcpTable.table[i].dwLocalPort = port then
            begin
              PID := pTcpTable.table[i].dwOwningPid;
              Break;
            end;
          end;
          if PID > 0 then
            Result := GetProcessNameById(PID);
        end;
      finally
        FreeMem(pTcpTable);
      end;
    end;
  end;

  function IsPortUsed(const aPort: Integer): Boolean;
  var
    _vSock: TSocket;
    _vWSAData: TWSAData;
    _vAddrIn: TSockAddrIn;
  begin
    Result := False;
    if WSAStartup(MAKEWORD(2, 2), _vWSAData) = 0 then
    begin
      _vSock := Socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
      try
        if _vSock <> SOCKET_ERROR then
        begin
          _vAddrIn.sin_family := AF_INET;
          _vAddrIn.sin_addr.S_addr := htonl(INADDR_ANY);
          _vAddrIn.sin_port := htons(aPort);
          if Bind(_vSock, _vAddrIn, SizeOf(_vAddrIn)) <> 0 then
            if WSAGetLastError = WSAEADDRINUSE then
              Result := True;
        end;
      finally
        CloseSocket(_vSock);
        WSACleanup();
      end;
    end;
  end;

var
  Name: string;
begin
  if Trim(EdtPort.Text) = '' then
  begin
    MessageBox(Handle, '请输入端口！', '提示', MB_ICONWARNING);
    if EdtPort.CanFocus then
      EdtPort.SetFocus;
    Exit;
  end;
  try
    if IsPortUsed(StrToInt(Trim(EdtPort.Text))) then
    begin
      Name := FindPidByTcpPort(StrToInt(Trim(EdtPort.Text)));
      MessageBox(Handle, PChar('【' + EdtPort.Text + '】端口已被程序【' + Name + '】占用！请更换！'), '提示', MB_ICONWARNING);
      EdtPort.Text := '';
      if EdtPort.CanFocus then
        EdtPort.SetFocus;
      Exit;
    end
    else
      MessageBox(Handle, PChar('【' + EdtPort.Text + '】端口可以正常使用！'), '提示', MB_ICONASTERISK and MB_ICONINFORMATION);
  except
    on e: Exception do
      MessageBox(Handle, PChar('端口检测出错！' + e.Message), '提示', MB_ICONERROR);
  end;

end;

procedure TFrmConfig.BtnModClick(Sender: TObject);
begin
  BSTATUS(True);
  if pgc1.ActivePageIndex = 3 then
  begin
    if Qry.IsEmpty then Exit;
    if not CheckGLY then Exit;
    ILX := 1;
  end;
end;

procedure TFrmConfig.btnrefreshClick(Sender: TObject);
begin
  try
    ILX := 2;
    while not Qry.Eof do
    begin
      btnSaveClick(Self);
      Qry.Next;
    end;
    if FCSQL <> '' then
    begin
      Qry.SQL.Text := FCSQL;
      try
        Qry.ExecSQL;
      except
        on e:Exception do
        begin
          MessageBox(Handle, PChar(e.message+'SQL='+FCSQL), '错误', MB_ICONERROR);
          Exit;
        end;
      end;
      GetAuthGrid ;
    end;
  finally
    FCSQL := ''
  end;
end;

procedure TFrmConfig.BtnSaveClick(Sender: TObject);
var
  CSQL:String;
  Invalue:string;
  Token:string;
  //LToken: TJWT;
  SAuth:string;
  LJWT:TJWTAbstract;
  i:Integer;
begin
  if (Trim(EdtReBootT.text) = '') then
    EdtReBootT.text := '3';
  ini.Auto := CKRUN.CHECKED;
  ini.AutoRun := CKAUTORUN.CHECKED;
  ini.MsgLog := CKMsg.CHECKED;
  ini.SQLLog := ckSQL.CHECKED;
  ini.ErrLog := ckErr.CHECKED;
  ini.BFile := CKEMR.CHECKED;
  ini.Pools := StrToIntDef(EdtWorkcount.text, 32);
  ini.BSysLog := CKsyslog.CHECKED;
  ini.SysLogIP := Edtip.text;
  ini.SysLogPort := StrToint(SysPort);

  ini.Port := EdtPort.Text;
  ini.LogSize := StrToIntDef(EdtSize.Text, 10);
  Ini.AES := ckAES.Checked;
  Ini.IP := cbbip.Text;
  Ini.UseCache := ckCache.Checked;
  ini.DBServer := Edtserver.Text;
  ini.DBDataBase := Edtdbname.Text;
  ini.DBUserName := Edtusername.Text;
  ini.DBPassWord := Edtpass.Text;
  if Trim(edtuser.Text) = '' then
  begin
    MessageBox(Handle, '请填写用户！', '错误', MB_ICONERROR);
    edtuser.SetFocus;
    Exit;
  end;
  if edtTime.Text = '' then
    edtTime.Text := '30';
  for I := 0 to Length(Checkboxs)-1 do
  begin
    if SAuth <> '' then
      SAuth := SAuth+'|';
    if Checkboxs[i].Checked then
      SAuth := SAuth+Checkboxs[i].Caption;
  end;
  //SAuth := AuthList.Text.Replace(#13#10,'|').Replace(#0,'');
  Invalue := EnCode(CID+'=|'+SAuth+'|');
  LJWT := TJWTHS256.Create(UTF8Encode(HS256Key), 1,
    [jrcIssuer, jrcSubject, jrcAudience, jrcIssuedAt,jrcJwtID],
    [], GetRegisTime*24*60);
  try
    Token := UTF8Decode(LJWT.Compute(['id:',CID],
        Ini.Exe+' Server', SAuth, Trim(edtuser.Text)));
  finally
    LJWT.Free;
  end;

  case ILX of
    0:CSQL := 'Insert Into TBYxEmrAuthManage (IID,UserName,AuthCode,TokenCode,TimeOut) values('
      + CID + ',' + Quotedstr(Trim(edtuser.Text)) + ',' + QuotedStr(Invalue)
      + ',' + Quotedstr(Token) + ',' + edtTime.Text +')';
    1:CSQL := 'Update TBYxEmrAuthManage Set UserName=' + Quotedstr(Trim(edtuser.Text))
      +',AuthCode=' + QuotedStr(Invalue) + ',TokenCode='+ Quotedstr(Token)
      +',TimeOut=' + edtTime.Text +' Where IID=' + CID;
    2:FCSQL := FCSQL +#13#10+ ' Update TBYxEmrAuthManage Set UserName=' + Quotedstr(Trim(edtuser.Text))
      +',AuthCode=' + QuotedStr(Invalue) + ',TokenCode='+ Quotedstr(Token)
      +',TimeOut=' + edtTime.Text +' Where IID=' + CID+';';
  end;
  if ILX <> 2 then
  begin
    Qry.SQL.Text := CSQL;
    try
      Qry.ExecSQL;
    except
      on e:Exception do
      begin
        MessageBox(Handle, PChar(e.message+'SQL='+CSQL), '错误', MB_ICONERROR);
        Exit;
      end;
    end;
  end;
  ini.SaveToFile(YxSCKTINI);
  MessageBox(Handle, '配置保存成功！请重启程序生效！', '提示', MB_ICONASTERISK and MB_ICONINFORMATION);
  ReadConfig;
  GetAuthGrid ;
  BSTATUS(false);
end;

procedure TFrmConfig.ck1Click(Sender: TObject);
begin
  if ck1.Checked then
    EdtPass.PasswordChar := #0
  else if not ck1.checked then
    EdtPass.PasswordChar := '*';
end;

procedure TFrmConfig.ckAESClick(Sender: TObject);
begin
//  if ckAES.Checked then
//    MessageBox(Handle, '勾选此项时接口所有的数据传输将加密！'+#10#13+'此功能用于卫键委安全要求，如无要求，请不要勾选！', '提示', MB_ICONASTERISK and MB_ICONINFORMATION);
end;

procedure TFrmConfig.ckCacheClick(Sender: TObject);
begin
//  if ckCache.Checked then
//    MessageBox(Handle, '勾选此项时需要在本机启动Redis服务！', '提示', MB_ICONASTERISK and MB_ICONINFORMATION);
end;

procedure TFrmConfig.ckReBootClick(Sender: TObject);
begin
  if CkReBoot.Checked then
  begin
    EdtReBootT.Visible := True;
    //EdtReBootT.SetFocus;
  end
  else
  begin
    EdtReBootT.Visible := False;
  end;

end;

procedure TFrmConfig.ckSYSLOGClick(Sender: TObject);
begin
  if CkSysLog.Checked then
  begin
    EdtIP.Visible := True;
    //EdtReBootT.SetFocus;
  end
  else
  begin
    EdtIP.Visible := False;
  end;
end;

procedure TFrmConfig.edtReBootTExit(Sender: TObject);
begin
  if trim(EdtReBootT.text) = '' then
    EdtReBootT.text := '3';
  if StrToInt(EdtReBootT.text) <= 1 then
    EdtReBootT.text := '1';
end;

procedure TFrmConfig.edtSizeExit(Sender: TObject);
begin
  if trim(EdtSize.text) = '' then
    EdtSize.text := '10';
  if StrToInt(EdtSize.text) <= 10 then
    EdtSize.text := '10';
end;

procedure TFrmConfig.edtWorkcountExit(Sender: TObject);
begin
  if trim(EdtWorkCount.text) = '' then
    EdtWorkCount.text := '32';
  if StrToInt(EdtWorkCount.text) <= 32 then
    EdtWorkCount.text := '32';
  if StrToInt(EdtWorkCount.text) > 256 then
    EdtWorkCount.text := '256';
end;

procedure TFrmConfig.FormDestroy(Sender: TObject);
begin
  Checkboxs := nil;
  Qry.Free;
  SQLiteDBPool.PutObj(DB);
  MethodList.Free;
end;

procedure TFrmConfig.FormShow(Sender: TObject);
begin
  BSTATUS(false);
  cbbip.Items.Text := GetIPList;
  YxSCKTINI := ChangeFileExt(ParamStr(0), '.ini');
  ReadConfig;
  {$IFDEF Socket}
  //chkSocket.Enabled := True;
  {$ENDIF}
  pgc1.ActivePageIndex := 0;
  //权限管理


  DB := SQLiteDBPool.GetObj;
  Qry := TFDQuery.Create(nil);
  Qry.Connection := DB;
  MethodList := TStringList.Create;
  var tmplist := TStringList.Create;
  ReportClassGroups(tmplist);
  var tmp := tmplist.Text.Replace(' ', '');
  var mmp := Copy(tmp, Pos('ClassAliases', tmp) + Length('ClassAliases'), Pos('Group[1]-Active:True', tmp) - Pos('ClassAliases', tmp) - Length('ClassAliases'));
  tmplist.Text := mmp.TrimLeft;
  for var I := 0 to tmplist.Count - 1 do
    MethodList.add(tmplist.Names[I]);
  //MethodList.Text := Ini.Method.Replace('|',#13#10);
  SetLength(Checkboxs, MethodList.Count);
  iPerLine := grp1.ClientWidth div (iWidth + iWtoW);
  for var I := 0 to MethodList.Count - 1 do
  begin
    Checkboxs[I] := TCheckBox.Create(Self);
    Checkboxs[I].Parent := grp1;        //组  GroupBox控件名
    Checkboxs[I].OnClick := nil;
    Checkboxs[I].Tag := I;
    Checkboxs[I].Caption := MethodList[I];
    Checkboxs[I].Top := iHtoH + (30 + iHtoH) * ((I + 1) div iPerLine - integer(((I + 1) mod iPerLine) = 0));
    Checkboxs[I].Left := iWtoW + (iWidth + iWtoW) * ((I) mod iPerLine);

  end;
  tmplist.free;

  if DB = nil then
  begin
    PostMessage(Self.Handle, WM_CLOSE, 0, 0);
    Exit;
  end;
  ILX := 0;
  var CSQL := 'SELECT * FROM sqlite_master where type=''table'' and name = ''TBYxEmrAuthManage'' ';
  Qry.Open(CSQL);
  if Qry.IsEmpty then
  begin
    CSQL := 'CREATE TABLE TBYxEmrAuthManage (' + #13#10 + 'IID BIGINT Primary key Not null,' + #13#10 + 'UserName VARCHAR(100) null,' + #13#10 + 'TokenCode VARCHAR(1000)  null,' + #13#10 + 'TimeOut BIGINT not null,' + #13#10 + 'AuthCode VARCHAR(1000) not null )';
    Qry.ExecSQL(CSQL);
  end;
  GetAuthGrid;
end;

procedure TFrmConfig.GetAuthGrid;
begin
  Qry.AfterScroll := nil;
  var CSQL := 'Select IID ,UserName ,AuthCode ,TokenCode ,TimeOut from TBYxEmrAuthManage';
  Qry.SQL.Text := CSQL;
  try
    Qry.AfterScroll := AfterScroll;
    Qry.Open;
  except
    on e: Exception do
    begin
      MessageBox(Handle, PChar(e.message + 'SQL=' + CSQL), '错误', MB_ICONERROR);
      Exit;
    end;
  end;
  ds1.DataSet := Qry;
  Grid1.columns[0].Title.alignment := taCenter;
  Grid1.columns[1].Title.alignment := taCenter;
  Grid1.columns[2].Title.alignment := taCenter;
  Grid1.columns[0].alignment := taCenter;
  Grid1.columns[1].alignment := taCenter;
  Grid1.columns[2].alignment := taCenter;
  Grid1.columns[0].Width := 300;
  Grid1.columns[1].Width := 200;
  Grid1.columns[2].Width := 100;
  if Qry.IsEmpty then
    Reset;
end;

procedure TFrmConfig.Grid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ssCtrl in Shift then
    case Key of
      Ord('C'):Clipboard.AsText := TFDQuery(Grid1.DataSource.DataSet).S['IID'];
    end;
end;

procedure TFrmConfig.InputBoxSetPasswordChar(var Msg: TMessage);
var
  hInputForm, hEdit, hButton: HWND;
begin
  hInputForm := Screen.Forms[0].Handle;
  if (hInputForm <> 0) then
  begin
      hEdit := FindWindowEx(hInputForm, 0, 'TEdit', nil);
      SendMessage(hEdit, EM_SETPASSWORDCHAR, Ord('*'), 0);
        // Change button text:
      hButton := FindWindowEx(hInputForm, 0, 'TButton', 'Cancel');
      SendMessage(hButton, WM_SETTEXT,0, Integer(PChar('取消')));
      hButton := FindWindowEx(hInputForm, 0, 'TButton', 'OK');
      SendMessage(hButton, WM_SETTEXT,0, Integer(PChar('确定')));
  end;
end;

procedure TFrmConfig.mniN1Click(Sender: TObject);
begin
  Clipboard.AsText := TFDQuery(Grid1.DataSource.DataSet).S['IID'];
end;

procedure TFrmConfig.mnioken1Click(Sender: TObject);
begin
  Clipboard.AsText :=  TFDQuery(Grid1.DataSource.DataSet).S['TokenCode'];
end;

procedure TFrmConfig.pgc1Change(Sender: TObject);
begin
  btnAdd.Visible := pgc1.ActivePageIndex in [2, 3];
  btnDel.Visible := pgc1.ActivePageIndex in [2, 3];
  btnrefresh.Visible := pgc1.ActivePageIndex = 3;
  btnCSLJ.Visible := pgc1.ActivePageIndex = 1;
end;
function TFrmConfig.CheckGLY: Boolean;
var
  S:string;
begin
  Result := False;
  PostMessage(Handle, InputBoxMessage, 0, 0);
  if not InputQuery('管理员验证','请输入管理员密码：',S) then Exit;
  if S <> admin then
  begin
    MessageBox(Handle, '密码错误！', '错误', MB_ICONERROR);
    Exit;
  end;
  Result := True;
end;

procedure TFrmConfig.Reset;
var
  i: Integer;
begin
  edtUser.Text := '';
  edtTime.Text := '30';
  for i := 0 to grp1.ControlCount - 1 do
    TCheckBox(grp1.Controls[i]).Checked := False;
end;

procedure TFrmConfig.AfterScroll(DataSet: TDataSet);
var
  AuthCode, sTmp: string;
  AuthList: TStringList;
begin
  if DataSet.IsEmpty then
    Exit;
  Reset;
  AuthList := TStringList.Create;
  try
    edtUser.Text := TFDQuery(DataSet).S['UserName'];
    edtTime.Text := TFDQuery(DataSet).S['TimeOut'];
    CID := TFDQuery(DataSet).S['IID'];
    AuthCode := DeCode(TFDQuery(DataSet).S['AuthCode']);
    sTmp := Copy(AuthCode, 1, Pos('=', AuthCode) - 1);
    if CID <> sTmp then
    begin
      MessageBox(Handle, PChar('授权码[' + CID + ']权限非法！请重置！'), '错误', MB_ICONERROR);
      Exit;
    end;
    AuthCode := Copy(AuthCode, Pos('=', AuthCode) + 1, Length(AuthCode));
    AuthList.Text := AuthCode.Replace('|', #13#10).Replace(#0, '');
    for sTmp in AuthList do
    begin
      if Trim(sTmp) = '' then
        Continue;
      //Tag := Ord(TRttiEnumerationType.GetValue<TAuth>(sTmp));
      //TCheckBox(grp1.Controls[Tag]).Checked := True;
      Checkboxs[MethodList.IndexOf(sTmp)].Checked := True;
    end;
  finally
    AuthList.free;
  end;
end;

end.

