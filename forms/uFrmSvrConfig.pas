unit uFrmSvrConfig;

interface

uses
  Winapi.Windows, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, uConfig,
  uFrmSQLConnect, Winapi.WinSock, TLhelp32, PsAPI,uFrmMQTTClient;
type
  TFrmSvrConfig = class(TForm)
    pnl2: TPanel;
    BtnSQL: TBitBtn;
    BtnCancel: TBitBtn;
    BtnSave: TBitBtn;
    BtnMod: TBitBtn;
    pnl1: TPanel;
    EdtWorkcount: TEdit;
    lbl1: TLabel;
    rbWEB: TRadioButton;
    ckMsg: TCheckBox;
    ckReBoot: TCheckBox;
    rbHTTP: TRadioButton;
    ckAutoRun: TCheckBox;
    ckRun: TCheckBox;
    EdtPort: TEdit;
    lbl2: TLabel;
    BtnCheckPort: TBitBtn;
    BitBtn1: TBitBtn;
    lbl3: TLabel;
    EdtSize: TEdit;
    ckHTTPS: TCheckBox;
    ckSQL: TCheckBox;
    EdtReBootT: TEdit;
    ckEMR: TCheckBox;
    ckSYSLOG: TCheckBox;
    EdtIP: TEdit;
    chkSocket: TCheckBox;
    ckErr: TCheckBox;
    procedure EdtWorkcountExit(Sender: TObject);
    procedure ckReBootClick(Sender: TObject);
    procedure BtnModClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure BtnSQLClick(Sender: TObject);
    procedure BtnCheckPortClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure EdtSizeExit(Sender: TObject);
    procedure EdtReBootTExit(Sender: TObject);
    procedure ckHTTPSClick(Sender: TObject);
    procedure ckSYSLOGClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    SysPort:string;
    YxSCKTINI: string;
    procedure ReadConfig;
    function BSTATUS(ISTATUS: Boolean): boolean;
  end;

var
  FrmSvrConfig: TFrmSvrConfig;

implementation

{$R *.dfm}

procedure TFrmSvrConfig.BitBtn1Click(Sender: TObject);
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

function TFrmSvrConfig.BSTATUS(ISTATUS: Boolean): boolean;
begin
  pnl1.Enabled := ISTATUS;
  BtnCancel.Enabled := ISTATUS;
  BtnSave.Enabled := ISTATUS;
  BtnMod.Enabled := not ISTATUS;
  ckHTTPS.Enabled := false;
  Result := True;
end;

procedure TFrmSvrConfig.ReadConfig;
begin
  CKRUN.CHECKED := ini.Auto;
  CKAUTORUN.CHECKED := ini.AutoRun;
  CKREBOOT.CHECKED := ini.ReBoot;
  EdtReBootT.text := IntToStr(ini.ReBootT);
  CKMsg.CHECKED := ini.MsgLog;
  CKSQL.CHECKED := ini.SQLLog;
  CKErr.CHECKED := ini.ErrLog;
  CKhttps.CHECKED := ini.Https;
  ckEMR.Checked := ini.BFile;
  if ini.HttpType then
    RbHTTP.CHECKED := True
  else
    RbWEB.CHECKED := True;
  EdtWorkCount.text := IntToStr(ini.Pools);
  EdtPort.Text := ini.Port;
  EdtSize.Text := IntToStr(ini.LogSize);
  EdtIP.Text := ini.SysLogIP;
  ckSYSLOG.Checked := ini.BSysLog;
  SysPort := IntToStr(ini.SysLogPort);
  chkSocket.Checked := ini.Socket;
end;

procedure TFrmSvrConfig.BtnCancelClick(Sender: TObject);
begin
  BSTATUS(false);
  ReadConfig;
end;

procedure TFrmSvrConfig.BtnCheckPortClick(Sender: TObject);
const
  ANY_SIZE = 1;
  iphlpapi = 'iphlpapi.dll';
  TCP_TABLE_OWNER_PID_ALL = 5;
  MIB_TCP_STATE: array[1..12] of string = ('CLOSED', 'LISTEN', 'SYN-SENT ',
    'SYN-RECEIVED', 'ESTABLISHED', 'FIN-WAIT-1', 'FIN-WAIT-2', 'CLOSE-WAIT',
    'CLOSING', 'LAST-ACK', 'TIME-WAIT', 'delete TCB');
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
  GetExtendedTcpTable: function(pTcpTable: Pointer; dwSize: PDWORD; bOrder: BOOL;
    lAf: ULONG; TableClass: TCP_TABLE_CLASS; Reserved: ULONG): DWord; stdcall;

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
    if GetExtendedTcpTable(nil, @dwSize, FALSE, AF_INET, TCP_TABLE_OWNER_PID_ALL,
      0) = ERROR_INSUFFICIENT_BUFFER then
    begin
      pTcpTable := AllocMem(dwSize);
    //获取TCP连接表
      try
        if GetExtendedTcpTable(pTcpTable, @dwSize, True, AF_INET,
          TCP_TABLE_OWNER_PID_ALL, 0) = NO_ERROR then
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
      MessageBox(Handle, PChar('【' + EdtPort.Text + '】端口已被程序【' + Name +
        '】占用！请更换！'), '提示', MB_ICONWARNING);
      EdtPort.Text := '';
      if EdtPort.CanFocus then
        EdtPort.SetFocus;
      Exit;
    end
    else
      MessageBox(Handle, PChar('【' + EdtPort.Text + '】端口可以正常使用！'), '提示',
        MB_ICONASTERISK and MB_ICONINFORMATION);
  except
    on e: Exception do
      MessageBox(Handle, PChar('端口检测出错！' + e.Message), '提示', MB_ICONERROR);
  end;

end;

procedure TFrmSvrConfig.BtnModClick(Sender: TObject);
begin
  BSTATUS(True);
end;

procedure TFrmSvrConfig.BtnSaveClick(Sender: TObject);

begin
  if (Trim(EdtReBootT.text) = '') then
    EdtReBootT.text := '3';
  ini.Auto := CKRUN.CHECKED;
  ini.AutoRun := CKAUTORUN.CHECKED;
  ini.MsgLog := CKMsg.CHECKED;
  ini.SQLLog := ckSQL.CHECKED;
  ini.ErrLog := ckErr.CHECKED;
  ini.HttpType := RbHTTP.CHECKED;
  ini.Https := CKhttps.CHECKED;
  ini.BFile := CKEMR.CHECKED;
  ini.Pools := StrToIntDef(EdtWorkcount.text,32);
  ini.BSysLog := CKsyslog.CHECKED;
  ini.SysLogIP := Edtip.text;
  ini.SysLogPort := StrToint(SysPort);

  ini.Port := EdtPort.Text;
  if CKhttps.CHECKED then
    ini.Port := '443'
  else if Trim(EdtPort.Text) = '443' then
    ini.Port := '8080';
  ini.LogSize :=  StrToIntDef(EdtSize.Text,10);
  ini.Socket := chkSocket.CHECKED;
  ini.SaveToFile(YxSCKTINI);

  MessageBox(Handle, '配置保存成功！请重启程序生效！', '提示', MB_ICONASTERISK and MB_ICONINFORMATION);
  ReadConfig;
  BSTATUS(false);
end;

procedure TFrmSvrConfig.BtnSQLClick(Sender: TObject);
begin
  with TFrmSQLConnect.Create(self) do
  try
    Position := poScreenCenter;
    ShowModal;
  finally
    Free;
  end;
end;

procedure TFrmSvrConfig.ckHTTPSClick(Sender: TObject);
begin
  if ckHTTPS.Checked then
    EdtPort.Text := '443'
  else
    EdtPort.Text := '8080';
end;

procedure TFrmSvrConfig.ckReBootClick(Sender: TObject);
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


procedure TFrmSvrConfig.ckSYSLOGClick(Sender: TObject);
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

procedure TFrmSvrConfig.EdtReBootTExit(Sender: TObject);
begin
  if trim(EdtReBootT.text) = '' then
    EdtReBootT.text := '3';
  if StrToInt(EdtReBootT.text) <= 1 then
    EdtReBootT.text := '1';
end;

procedure TFrmSvrConfig.EdtSizeExit(Sender: TObject);
begin
  if trim(EdtSize.text) = '' then
    EdtSize.text := '10';
  if StrToInt(EdtSize.text) <= 10 then
    EdtSize.text := '10';
  EdtSize.text := inttostr(strtoint(EdtSize.text));
end;

procedure TFrmSvrConfig.EdtWorkcountExit(Sender: TObject);
begin
  if trim(EdtWorkCount.text) = '' then
    EdtWorkCount.text := '32';
  if StrToInt(EdtWorkCount.text) <= 32 then
    EdtWorkCount.text := '32';
  if StrToInt(EdtWorkCount.text) > 256 then
    EdtWorkCount.text := '256';
  EdtWorkCount.text := inttostr(strtoint(EdtWorkCount.text));
end;

procedure TFrmSvrConfig.FormShow(Sender: TObject);
begin
  BSTATUS(false);
  YxSCKTINI := ChangeFileExt(ParamStr(0), '.ini');
  ReadConfig;
  {$IFDEF Socket}
  //chkSocket.Enabled := True;
  {$ENDIF}

end;

end.

