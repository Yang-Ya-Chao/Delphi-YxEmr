unit uFrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AppEvnts, StdCtrls, HTTPApp, Winapi.ShellAPI,
  uServer, Vcl.ExtCtrls, Vcl.Menus, Vcl.Themes, Vcl.Styles,Vcl.Buttons,
  Qlog, UpubFun, uFrmSvrConfig,uFrmMonitor,
  uFrmMQTTClient,About,uFrmAuthManage,uConfig,QWorker;

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
    procedure FormCreate(Sender: TObject);
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
    StrSJ:string;
    //调用地址
    Url :string;
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
    procedure ModifyIcon;
    //请求信号处理函数
    procedure DoSignalJobMsgAll(AJob: PQJob);
    //失败信号处理函数
    procedure DoSignalJobMsgFalse(AJob: PQJob);
    //获取程序运行状态，1s刷新一次界面
    procedure GetStatus(AJob: PQJob);
    //定时重启程序
    procedure RBoot(AJob:PQJob);
    //主题选择
    procedure SetStyle(Flag:Integer);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}


procedure TMainForm.FormCreate(Sender: TObject);
begin
  //获取程序开始运行时刻
  StartRunTime := GetTickCount64;
  IALL := 0;
  ITrue := 0;
  IFalse := 0;
  IWeb := 0;
  IWebActice := 0;
  case ini.Topic of
    0:TStyleManager.SetStyle('Glossy');
    1:TStyleManager.SetStyle('Aqua Light Slate');
    2:TStyleManager.SetStyle('Charcoal Dark Slate');
    3:TStyleManager.SetStyle('Tablet Dark');
  end;
  pm2.Items[ini.Topic].Checked := True;
  //程序系统菜单添加菜单选项
  appendmenu(GetSystemMenu(Handle, False), MF_SEPARATOR, 0, nil);
  appendmenu(GetSystemMenu(Handle, False), MF_POPUP , pm2.Handle, '主题...');
  appendmenu(GetSystemMenu(Handle, False), MF_ByPosition + MF_String, 666, '打开浏览器...');
  appendmenu(GetSystemMenu(Handle, False), MF_ByPosition + MF_String, 777, '接口配置...');
  appendmenu(GetSystemMenu(Handle, False), MF_ByPosition + MF_String, 888, '权限配置...');
  appendmenu(GetSystemMenu(Handle, False), MF_ByPosition + MF_String, 999, '关于...');

  StrSJ := '服务到期时间:'+FormatDateTime('YYYY-MM-DD', Now+GetRegisTime);
  //创建系统托盘
  CreateTratIcons(Self);
  self.Caption := self.Caption+':'+Ini.Port;
  if not ini.HttpType then
    Url := '/wsdl/IWSYXHIS';
  Url := 'Http://'+GetLocalIP+':'+Ini.Port+Url+Ini.Root;
  lbl8.Caption := Url+' ';
end;

procedure TMainForm.FormActivate(Sender: TObject);
var
  rs: TResourceStream;
  LogPath: string;
begin
  //自动开始服务
  if ini.Auto
    or ini.reboot
    or (ParamStr(1) <> '') then
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
  DeleteFile(ExtractFilePath(ParamStr(0)) + 'ReBoot.cmd');
  //设置日志文件 (输出syslog服务器)
  if  ini.BSysLog then
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
  LogPath := ExtractFilePath(ParamStr(0)) + 'Svrlog\Errlog\log.txt';
  if ParamStr(1) <> '' then
    LogPath := ExtractFilePath(ParamStr(0)) + 'Svrlog\Errlog\'+ParamStr(1)+'\Log.TXT';
  var ErrWriter := TQLogFileWriter.Create(LogPath);
  ErrWriter.MaxSize := ini.LogSize * 1048576;   //单日志文件大小 10M
  ErrWriter.CreateMode := lcmRename;
  ErrWriter.OneFilePerDay := True;
  ErrWriter.AcceptLevels := [llError];
  ErrWriter.MaxLogHistories := 30;
  Logs.Castor.AddWriter(ErrWriter);
  ErrWriter.Enabled := Ini.ErrLog;
  //调用参数日志
  LogPath := ExtractFilePath(ParamStr(0)) + 'Svrlog\Msglog\log.txt';
  if ParamStr(1) <> '' then
    LogPath := ExtractFilePath(ParamStr(0)) + 'Svrlog\Msglog\'+ParamStr(1)+'\Log.TXT';
  var MsgWriter := TQLogFileWriter.Create(LogPath);
  MsgWriter.MaxSize := ini.LogSize * 1048576;   //单日志文件大小 10M
  MsgWriter.CreateMode := lcmRename;
  MsgWriter.OneFilePerDay := True;
  MsgWriter.AcceptLevels := [llmessage];
  MsgWriter.MaxLogHistories := 10;
  Logs.Castor.AddWriter(MsgWriter);
  MsgWriter.Enabled := ini.MsgLog;
  //sql语句日志
  LogPath := ExtractFilePath(ParamStr(0)) + 'Svrlog\Sqllog\log.txt';
  if ParamStr(1) <> '' then
    LogPath := ExtractFilePath(ParamStr(0)) + 'Svrlog\Sqllog\'+ParamStr(1)+'\Log.TXT';
  var SqlWriter := TQLogFileWriter.Create(LogPath);
  SqlWriter.MaxSize := ini.LogSize * 1048576;   //单日志文件大小 10M
  SqlWriter.CreateMode := lcmRename;
  SqlWriter.OneFilePerDay := True;
  SqlWriter.AcceptLevels := [llDebug];
  SqlWriter.MaxLogHistories := 5;
  Logs.Castor.AddWriter(SqlWriter);
  SqlWriter.Enabled := ini.SQLLog;
  //注册所有请求接收信号
  SignalAllID := Workers.RegisterSignal('http.ALL');
  Workers.Wait(DoSignalJobMsgAll, SignalAllID,false);
  //注册失败请求接收信号
  SignalFalseID :=  Workers.RegisterSignal('http.FALSE');
  Workers.Wait(DoSignalJobMsgFalse, SignalFalseID,false);
  //投递状态刷新作业
  Workers.Post(GetStatus,Q1Second,nil,True);
  //投递重启作业
  if ini.ReBoot then
    Workers.Post(RBoot,ini.ReBootT*Q1Day,nil,False);
  //注册对象池状态信号量
  SignalPools := Workers.RegisterSignal('ObjPools');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Shell_NotifyIcon(NIM_DELETE, @lpData);
  if BeginServer then
    FServer.Destroy;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in shift) and (key = VK_F12) then
  begin
    with TFrmMonitor.Create(self) do
    try
      FormStyle := fsStayOnTop;
      top :=  MainForm.Top - Trunc((height-MainForm.Height)/2);
      Left := MainForm.left + MainForm.width;
      Show;
    finally
      //Free;
    end;
  end;
end;

procedure TMainForm.DoSignalJobMsgFalse(AJob: PQJob);
begin
  IFalse := AJob.Runs+1;
end;

procedure TMainForm.DoSignalJobMsgAll(AJob:PQJob);
begin
  IAll := AJob.Runs+1;
end;

procedure TMainForm.GetStatus(AJob: PQJob);
begin
  try
    Lbl2.Caption := Format('CPU: %f%%,内存: %sMB,线程: %d',
      [GetCPURate, inttostr(CurrentMemoryUsage),GetProcessThreadCount]);
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

procedure TMainForm.lbl8Click(Sender: TObject);
begin
  if not BeginServer then Exit;
  ShellExecute(0,nil,PChar(Url), nil, nil, SW_SHOWNOACTIVATE);
end;

procedure TMainForm.lbl8MouseEnter(Sender: TObject);
begin
  lbl8.Font.Style := [fsBold,fsItalic,fsUnderline];
  lbl8.Cursor:=crHandpoint;
end;

procedure TMainForm.lbl8MouseLeave(Sender: TObject);
begin
  lbl8.Font.Style := [fsBold,fsItalic];
  lbl8.Cursor:=crDefault;
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

procedure TMainForm.CreateTratIcons(Sender: TObject);
var
  I:Integer;
  s:PAnsiChar;
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
  s := PAnsiChar(AnsiString('YxEmr应用服务器:'+Ini.Port+#13#10+StrSJ));
  for I := 0 to Length(S)-1 do
     lpData.szTip[I] := S[I] ;
  //lpData.szTip := 'YxCis应用服务器';
  //系统右下角添加托盘图标
  shell_notifyicona(NIM_ADD, @lpData);
end;

procedure TMainForm.SetStyle(Flag:Integer);
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
  else if message.WParam = 666 then
  begin
    if not BeginServer then
    begin
      MessageBox(Handle, '请先开启服务！', '提示', MB_ICONERROR);
      Exit;
    end;
    ShellExecute(0,
        nil,
        PChar(Url), nil, nil, SW_SHOWNOACTIVATE);
  end
  else if message.WParam = 777 then
  begin
    with TFrmSvrConfig.Create(self) do
    try
      Position := poScreenCenter;
      ShowModal;
    finally
      Free;
    end;
  end
  else if message.WParam = 888 then
  begin
    with TFrmAuthManage.Create(self) do
    try
      Position := poScreenCenter;
      ShowModal;
    finally
      Free;
    end;
  end
  else if message.WParam = 999 then
  begin
    with TAboutBox.Create(self) do
    try
      Position := poScreenCenter;
      ShowModal;
    finally
      Free;
    end;
  end
  else if message.WParam in [6,7,8,9] then
    SetStyle(message.WParam-6)
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

procedure TMainForm.RBoot(AJob:PQJob);
var
  F: TextFile;
begin
  Shell_NotifyIconA(NIM_DELETE, @lpData);
  try
    AssignFile(F, 'ReBoot.cmd');
    Rewrite(F);
    Writeln(F, '@echo 重启服务');
    Writeln(F, 'taskkill /f /im '+ExtractFileName(ParamStr(0)));
    Writeln(F, 'start ' + ParamStr(0));
  finally
    CloseFile(F);
  end;
  WinExec('Reboot.cmd', SW_HIDE);
end;


procedure TMainForm.ModifyIcon;
//var
  //i:integer;
begin
  {tmr4.Enabled := False;
  try
    if  MainForm.Visible = True then Exit;
    for I := 0 to 2 do
    begin
      lpData.hIcon := LoadIcon(hInstance,'ICON1');
      shell_notifyicona(NIM_MODIFY, @lpData);
      Sleep(100);

      lpData.hIcon := LoadIcon(hInstance,'ICON2');
      shell_notifyicona(NIM_MODIFY, @lpData);
      Sleep(100);

      lpData.hIcon := LoadIcon(hInstance,'ICON3');
      shell_notifyicona(NIM_MODIFY, @lpData);
      Sleep(100);

      lpData.hIcon := Application.Icon.handle;
      shell_notifyicona(NIM_MODIFY, @lpData);
      Sleep(100);
    end;
  finally
    tmr4.Enabled := True;
  end;   }
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

