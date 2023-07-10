unit uFrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AppEvnts, StdCtrls, HTTPApp, Winapi.ShellAPI, System.DateUtils,
  uServer, Vcl.ExtCtrls, Vcl.Menus, Vcl.Themes, Vcl.Styles, Vcl.Buttons, Qlog,
  UpubFun, uFrmSvrConfig, uFrmMonitor, uFrmMQTTClient, About, uFrmAuthManage,
  uConfig, QWorker, Winapi.WinSvc,umain_frm;

const
  WM_BARICON = WM_USER + 200;

type
  TMainForm = class(TForm)
    pm1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    btnStart: TBitBtn;
    btnStop: TBitBtn;
    pm2: TPopupMenu;
    NA: TMenuItem;
    NB: TMenuItem;
    NC: TMenuItem;
    ND: TMenuItem;
    lbl7: TLabel;
    lbl8: TLabel;
    procedure FormDestroy(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure lbl8MouseEnter(Sender: TObject);
    procedure lbl8MouseLeave(Sender: TObject);
    procedure lbl8Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
   //服务到期时间
    StrSJ: string;
    //调用地址
    Url: string;
    //服务接收到的请求数量、成功数、失败数、工作总线程数、当前工作线程数
    IALL, ITrue, IFalse, IWeb, IWebActice: Integer;
    //系统托盘
    lpData: TNotifyIcondataA;
    //当前是否开启服务
    BeginServer: Boolean;
    //HttpApi对象
    FServer: TSynHTTPWebBrokerBridge;
    //开始服务
    procedure StartSvr;
    //停止服务
    procedure StopSvr;
    //创建托盘图标
    procedure CreateTratIcons(Sender: TObject);
     //捕获最小化消息 后程序缩小到托盘区
    procedure MSG_SYSCOMAND(var message: TMessage); message WM_SYSCOMMAND;
    //捕获在托盘区双击图标事件，以恢复FORM
    procedure MSG_BackWindow(var message: TMessage); message WM_BARICON;
    //捕获右键
    procedure MSG_Rbutton(var message: TMessage); message WM_RBUTTONDOWN;
    //关机
    procedure WinExit(var msg: TMessage); message WM_CLOSE;
    //设置连接池
    //procedure SetDACManager;
    //托盘图标闪烁效果
    //procedure ModifyIcon;
    //请求信号处理函数
    procedure DoSignalJobMsgAll(AJob: PQJob);
    //失败信号处理函数
    procedure DoSignalJobMsgFalse(AJob: PQJob);
    //获取程序运行状态，1s刷新一次界面
    procedure GetStatus(AJob: PQJob);
    //定时重启程序
    procedure RBoot(AJob: PQJob);
    //获取服务剩余使用天数
    procedure GetRegistData(AJob: PQJob);
    //主题选择
    procedure SetStyle(Flag: Integer);
    //以Win Service服务方式运行
    procedure RunAsService;
    //查询后台服务状态
    function QueryServiceStatu(const SvrName: string): Boolean;
    //后台初始化
    procedure Init(AJob: PQJob);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormActivate(Sender: TObject);
begin
  //投递接口初始化任务 --投递到后台处理 ，避免界面显示不正常
  Workers.LongtimeJob(Init,nil);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Shell_NotifyIcon(NIM_DELETE, @lpData);
  if BeginServer then
    FServer.Destroy;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = VK_F12) then
  begin
    with TFrmMonitor.Create(self) do
    try
      FormStyle := fsStayOnTop;
      top := MainForm.Top - Trunc((height - MainForm.Height) / 2);
      Left := MainForm.left + MainForm.width;
      Show;
    finally
      //Free;
    end;
  end
  else if  (ssCtrl in Shift) and (Key = VK_F11) then
  begin
    with TFrm_main.Create(self) do
    try
      //FormStyle := fsStayOnTop;
      top := MainForm.Top - Trunc((height - MainForm.Height) / 2);
      Left := MainForm.left + MainForm.width;
      Show;
    finally
      //Free;
    end;
  end
end;

procedure TMainForm.DoSignalJobMsgFalse(AJob: PQJob);
begin
  IFalse := AJob.Runs + 1;
end;

procedure TMainForm.DoSignalJobMsgAll(AJob: PQJob);
begin
  IAll := AJob.Runs + 1;
end;

procedure TMainForm.GetRegistData(AJob: PQJob);
begin
  FDate := GetRegisTime;
end;

procedure TMainForm.GetStatus(AJob: PQJob);
begin
  try
    Lbl2.Caption := Format('CPU: %0.2f%%,内存: %sMB,线程: %d', [GetCpuUsage, CurrentMemoryUsage.ToString, GetProcessThreadCount]);
    if Ini.HttpType then
      Lbl3.Caption := Format('%s', [GetRunTimeInfo])
    else
    begin
      IWebActice := 0;
      if BeginServer then
        IWebActice := FServer.ActiveCount;
      Lbl3.Caption := Format('%d/%d,%s', [IWebActice, IWeb, GetRunTimeInfo]);
    end;
    lbl6.Caption := Format('All:%s,Err:%s', [SetHTTPCount(IAll), SetHTTPCount(IFalse)]);

  except
  end;
end;

procedure TMainForm.Init(AJob: PQJob);
var
  rs: TResourceStream;
  LogPath: string;
begin
   //获取程序开始运行时刻
  StartRunTime := GetTickCount64;
  //初始化变量
  IALL := 0;
  ITrue := 0;
  IFalse := 0;
  IWeb := 0;
  IWebActice := 0;
  Url := '';
  //设置程序界面显示风格
  case ini.Topic of
    0:
      TStyleManager.SetStyle('Glossy');
    1:
      TStyleManager.SetStyle('Aqua Light Slate');
    2:
      TStyleManager.SetStyle('Charcoal Dark Slate');
    3:
      TStyleManager.SetStyle('Tablet Dark');
  end;
  pm2.Items[ini.Topic].Checked := True;
  //程序系统菜单添加菜单选项
  appendmenu(GetSystemMenu(Handle, False), MF_SEPARATOR, 0, nil);
  appendmenu(GetSystemMenu(Handle, False), MF_POPUP, pm2.Handle, '主题...');
  appendmenu(GetSystemMenu(Handle, False), MF_ByPosition + MF_String, 2, '以服务运行...');
  appendmenu(GetSystemMenu(Handle, False), MF_ByPosition + MF_String, 3, '接口配置...');
  appendmenu(GetSystemMenu(Handle, False), MF_ByPosition + MF_String, 4, '权限配置...');
  appendmenu(GetSystemMenu(Handle, False), MF_ByPosition + MF_String, 1, '关于...');
  //设置界面标题显示：版本:端口
  self.Caption := FExe + '应用服务器V' + GetBuildInfo + '：' + Ini.Port;
  //设置界面显示调用地址
  if not ini.HttpType then
    Url := '/wsdl/IWSYXHIS';
  var IP := Ini.IP;
  if IP = '' then
    IP := GetLocalIP(False);
  Url := 'Http://' + IP + ':' + Ini.Port + Url + Ini.Root;
  lbl8.Caption := Url + ' ';

  //自动开始服务
  if ini.Auto or ini.reboot or (ini.NG) then
    StartSvr;
  //程序开机自启动
  SelfAutoRun(ini.AutoRun);
  //从资源文件中加载favicon.ico，保存到本地
  if not FileExists('favicon.ico') then
  begin
    if 0 <> FindResource(hInstance, 'favicon', 'DLL') then
    begin
      try
        rs := TResourceStream.Create(hInstance, 'favicon', 'DLL');
        try
          rs.SaveToFile('favicon.ico');
        finally
          FreeAndNil(rs);
        end;
      except
      end;
    end;
  end;
  IWeb := ini.Pools;
  DeleteFile(ExtractFilePath(ParamStr(0)) + 'ReBoot.bat');
  //设置日志文件 (输出syslog服务器)
  if ini.BSysLog then
  begin
    var AWriter := TQLogSocketWriter.Create;
    AWriter.ServerHost := ini.SysLogIP;
    AWriter.ServerPort := ini.SysLogPort;
    AWriter.UseTCP := False;
    Logs.Castor.AddWriter(AWriter);
  end;
  //设置日志文件 (输出到文件)
  //SetDefaultLogFile(LogPath + '\Log.TXT', LogSize * 1048576, True, True);
  //错误日志
  var ExeParh := ChangeFileExt(ParamStr(0), '') + 'log\';
  LogPath := ExeParh + 'Errlog\log.txt';
  if ini.NG then
    LogPath := ExeParh + 'Errlog\' + ParamStr(1) + '\Log.TXT';
  var ErrWriter := TQLogFileWriter.Create(LogPath);
  ErrWriter.MaxSize := ini.LogSize * 1048576;   //单日志文件大小 10M
  ErrWriter.CreateMode := lcmRename;
  ErrWriter.OneFilePerDay := True;
  ErrWriter.AcceptLevels := [llError];
  ErrWriter.MaxLogHistories := Ini.LogMax;
  Logs.Castor.AddWriter(ErrWriter);
  ErrWriter.Enabled := Ini.ErrLog;
  //调用参数日志
  LogPath := ExeParh + 'Msglog\log.txt';
  if ini.NG then
    LogPath := ExeParh + 'Msglog\' + ParamStr(1) + '\Log.TXT';
  var MsgWriter := TQLogFileWriter.Create(LogPath);
  MsgWriter.MaxSize := ini.LogSize * 1048576;   //单日志文件大小 10M
  MsgWriter.CreateMode := lcmRename;
  MsgWriter.OneFilePerDay := True;
  MsgWriter.AcceptLevels := [llmessage];
  MsgWriter.MaxLogHistories := Ini.LogMax;
  Logs.Castor.AddWriter(MsgWriter);
  MsgWriter.Enabled := ini.MsgLog;
  //sql语句日志
  LogPath := ExeParh + 'Sqllog\log.txt';
  if ini.NG then
    LogPath := ExeParh + 'Sqllog\' + ParamStr(1) + '\Log.TXT';
  var SqlWriter := TQLogFileWriter.Create(LogPath);
  SqlWriter.MaxSize := ini.LogSize * 1048576;   //单日志文件大小 10M
  SqlWriter.CreateMode := lcmRename;
  SqlWriter.OneFilePerDay := True;
  SqlWriter.AcceptLevels := [llDebug];
  SqlWriter.MaxLogHistories := Ini.LogMax;
  Logs.Castor.AddWriter(SqlWriter);
  SqlWriter.Enabled := ini.SQLLog;
  //注册所有请求接收信号
  SignalAllID := Workers.RegisterSignal('http.ALL');
  Workers.Wait(DoSignalJobMsgAll, SignalAllID, false);
  //注册失败请求接收信号
  SignalFalseID := Workers.RegisterSignal('http.FALSE');
  Workers.Wait(DoSignalJobMsgFalse, SignalFalseID, false);
  //投递状态刷新作业
  Workers.Post(GetStatus, Q1Second, nil, True);
  //投递重启作业 --重启时间间隔到达之后凌晨2点执行
  if ini.ReBoot then
  begin
    var ATime := strtodatetime(FormatDateTime('YYYY-MM-DD', IncDay(Now, Q1Day * Ini.ReBootT)) + ' 02:30:00:000');
    Workers.At(RBoot, ATime, 0, nil, false);
  end;
  //投递获取服务剩余时间作业 --每天凌晨2点执行
  Workers.Plan(GetRegistData, '0 0 2 * * * "每天2点重复的作业" ', nil, false);
  //注册对象池状态信号量
  SignalPools := Workers.RegisterSignal('ObjPools');
  FDate := GetRegisTime;
  StrSJ := '服务到期时间:' + FormatDateTime('YYYY-MM-DD', Now + FDate);
  //创建系统托盘
  CreateTratIcons(Self);
end;

procedure TMainForm.lbl8Click(Sender: TObject);
begin
  if not BeginServer then
    Exit;
  ShellExecute(0, nil, PChar(Url), nil, nil, SW_SHOWNOACTIVATE);
end;

procedure TMainForm.lbl8MouseEnter(Sender: TObject);
begin
  lbl8.Font.Style := [fsBold, fsItalic, fsUnderline];
  lbl8.Cursor := crHandpoint;
end;

procedure TMainForm.lbl8MouseLeave(Sender: TObject);
begin
  lbl8.Font.Style := [fsBold, fsItalic];
  lbl8.Cursor := crDefault;
end;

procedure TMainForm.btnStartClick(Sender: TObject);
begin
  StartSvr;
end;

procedure TMainForm.btnStopClick(Sender: TObject);
begin
  StopSvr;
end;

procedure TMainForm.StartSvr;
begin
  if QueryServiceStatu('MainService') then
  begin
    MessageBox(Application.Handle, '当前已有服务在后台运行中！', '错误', MB_ICONERROR);
    Exit;
  end;
  FServer := TSynHTTPWebBrokerBridge.Create(Self);
  BeginServer := True;
  BtnStart.Enabled := False;
  BtnStop.Enabled := True;
  //SetDACManager;
  //是否使用MQTT
  if ini.MQEnable then
    StartMQTT;
  PostMessage(Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

procedure TMainForm.StopSvr;
begin
  BtnStart.Enabled := True;
  BtnStop.Enabled := False;
  FServer.Destroy;
  BeginServer := False;
  if ini.MQEnable then
    StopMQTT;
end;

//查询当前服务的状态
function TMainForm.QueryServiceStatu(const SvrName: string): Boolean;
var
  sMgr, sHandle: SC_HANDLE;
  d: TServiceStatus;
begin
  Result := False;
  sMgr := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);
  if sMgr <= 0 then
    Exit;
  sHandle := OpenService(sMgr, PChar(SvrName), SERVICE_ALL_ACCESS);
  if sHandle <= 0 then
    Exit;
  try
    QueryServiceStatus(sHandle, d);
    Result := d.dwCurrentState in [SERVICE_RUNNING, SERVICE_START_PENDING, SERVICE_CONTINUE_PENDING, SERVICE_PAUSE_PENDING];
    CloseServiceHandle(sMgr);
    CloseServiceHandle(sHandle);
  except
    CloseServiceHandle(sMgr);
    CloseServiceHandle(sHandle);
  end;
end;

procedure TMainForm.CreateTratIcons(Sender: TObject);
var
  I: Integer;
  s: PAnsiChar;
begin
  //创建托盘图标
  lpData.cbSize := sizeof(TNotifyIcondataA);
  //取应用程序主窗体的句柄
  lpData.Wnd := handle;
  //用户自定义的一个数值，在uCallbackMessage参数指定的消息中使用
  lpData.uID := 0;
  //指定在该结构中uCallbackMessage、hIcon和szTip参数都有效
  lpData.uFlags := NIF_ICON + NIF_TIP + NIF_MESSAGE;
  //指定的窗口消息
  lpData.uCallbackMessage := WM_BARICON;
  //指定系统状态栏显示应用程序的图标句柄
  lpData.hIcon := Application.Icon.handle;
  //当鼠标停留在系统状态栏该图标上时，出现该提示信息
  s := PAnsiChar(AnsiString(FExe + '应用服务器:' + Ini.Port + #13#10 + StrSJ));
  for I := 0 to Length(s) - 1 do
    lpData.szTip[I] := s[I];
  //lpData.szTip := 'YxCis应用服务器';
  //系统右下角添加托盘图标
  shell_notifyicona(NIM_ADD, @lpData);
end;

procedure TMainForm.SetStyle(Flag: Integer);
begin
  pm2.Items[Flag].Checked := True;
  ini.Topic := Flag;
end;

procedure TMainForm.MSG_SYSCOMAND(var message: TMessage);
begin
  if (message.WParam = SC_MINIMIZE) then
  begin
    shell_notifyicona(NIM_ADD, @lpData);
    MainForm.Visible := False;
  end
  else if message.WParam in [6, 7, 8, 9] then
    SetStyle(message.WParam - 6)
  else if message.WParam = 1 then
  begin
    with TAboutBox.Create(self) do
    try
      Position := poScreenCenter;
      ShowModal;
    finally
      Free;
    end;
  end
  else if message.WParam = 2 then
  begin
    RunAsService;
  end
  else if message.WParam = 3 then
  begin
    with TFrmSvrConfig.Create(self) do
    try
      Position := poScreenCenter;
      ShowModal;
    finally
      Free;
    end;
  end
  else if message.WParam = 4 then
  begin
    with TFrmAuthManage.Create(self) do
    try
      Position := poScreenCenter;
      ShowModal;
    finally
      Free;
    end;
  end
  else
    DefWindowProc(MainForm.Handle, message.Msg, message.WParam, message.LParam);
end;

procedure TMainForm.N1Click(Sender: TObject);
begin
  StartSvr;
end;

procedure TMainForm.N2Click(Sender: TObject);
begin
  StopSvr;
end;

procedure TMainForm.N3Click(Sender: TObject);
var
  message: TMessage;
begin
  message.LPARAM := WM_LBUTTONDBLCLK;
  MSG_BackWindow(message);
end;

procedure TMainForm.N4Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TMainForm.RBoot(AJob: PQJob);
var
  F: TextFile;
begin
  Shell_NotifyIconA(NIM_DELETE, @lpData);
  try
    AssignFile(F, 'ReBoot.bat');
    Rewrite(F);
    Writeln(F, BatAdmin);
    Writeln(F, 'echo 重启服务');
    Writeln(F, 'taskkill /f /im ' + ExtractFileName(ParamStr(0)));
    Writeln(F, 'start ' + ParamStr(0));
  finally
    CloseFile(F);
  end;
  SaveToFile;
  WinExec('Reboot.bat', SW_HIDE);
end;

procedure TMainForm.RunAsService;
var
  F: TextFile;
begin
  Shell_NotifyIconA(NIM_DELETE, @lpData);
  try
    AssignFile(F, '服务注册.bat');
    Rewrite(F);
    Writeln(F, BatAdmin);
    Writeln(F, 'echo 关闭程序进程');
    Writeln(F, 'taskkill /f /im ' + ExtractFileName(ParamStr(0)));
    Writeln(F, 'echo 注册Win Service服务');
    Writeln(F, ParamStr(0) + ' /install');
    Writeln(F, 'echo 启动服务');
    Writeln(F, 'net start ' + FExe);
  finally
    CloseFile(F);
  end;
  try
    AssignFile(F, '服务停止.bat');
    Rewrite(F);
    Writeln(F, BatAdmin);
    Writeln(F, 'echo 停止服务');
    Writeln(F, 'net stop ' + FExe);
  finally
    CloseFile(F);
  end;
  try
    AssignFile(F, '服务卸载.bat');
    Rewrite(F);
    Writeln(F, BatAdmin);
    Writeln(F, 'echo 停止服务');
    Writeln(F, 'net stop ' + FExe);
    Writeln(F, 'echo 卸载Win Service服务');
    Writeln(F, ParamStr(0) + ' /uninstall');
  finally
    CloseFile(F);
  end;
  WinExec('服务注册.bat', SW_SHOW);
end;

procedure TMainForm.MSG_BackWindow(var message: TMessage);
begin
  if (message.LParam = WM_LBUTTONDBLCLK) then
  begin
    shell_notifyicona(NIM_DELETE, @lpData);
    MainForm.Visible := True;
  end
  else if (message.LParam = WM_RBUTTONDOWN) then
    MSG_Rbutton(message);
end;

procedure TMainForm.MSG_Rbutton(var message: TMessage);
begin
  if BeginServer then
  begin
    N1.Enabled := False;
    N2.Enabled := True;
  end
  else
  begin
    N1.Enabled := True;
    N2.Enabled := False;
  end;
  PM1.Popup(Mouse.CursorPos.x, Mouse.CursorPos.y);
end;

procedure TMainForm.WinExit(var msg: TMessage);
begin
  shell_notifyicona(NIM_DELETE, @lpData);
  Application.Terminate;
end;

end.

