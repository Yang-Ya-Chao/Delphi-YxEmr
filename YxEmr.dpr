////////////////////////////////////////////////////////////////////
//                          _ooOoo_                               //
//                         o8888888o                              //
//                         88" . "88                              //
//                         (| ^_^ |)                              //
//                         O\  =  /O                              //
//                      ____/`---'\____                           //
//                    .'  \\|     |//  `.                         //
//                   /  \\|||  :  |||//  \                        //
//                  /  _||||| -:- |||||-  \                       //
//                  |   | \\\  -  /// |   |                       //
//                  | \_|  ''\---/''  |   |                       //
//                  \  .-\__  `-`  ___/-. /                       //
//                ___`. .'  /--.--\  `. . ___                     //
//              ."" '<  `.___\_<|>_/___.'  >'"".                  //
//            | | :  `- \`.;`\ _ /`;.`/ - ` : | |                 //
//            \  \ `-.   \_ __\ /__ _/   .-` /  /                 //
//      ========`-.____`-.___\_____/___.-`____.-'========         //
//                           `=---='                              //
//      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        //
//             佛祖保佑       永不宕机      永无BUG               //
////////////////////////////////////////////////////////////////////
program YxEmr;

uses
  FastMM5,
  Forms,
  SvcMgr,
  Winapi.Windows,
  System.SysUtils,
  Vcl.Themes,
  Vcl.Styles,
  uConfig,
  UpubFun,
  uFrmMain in 'uFrmMain.pas' {MainForm},
  uSvrMain in 'uSvrMain.pas' {MainService: TService},
  uFrmMQTTClient in 'MQTT\uFrmMQTTClient.pas' {FrmMQClient},
  uWebModule in 'serve\uWebModule.pas' {WebModule1: TWebModule},
  SoapImpl in 'serve\SoapImpl.pas',
  SoapIntf in 'serve\SoapIntf.pas',
  uServer in 'serve\uServer.pas',
  ABOUT in 'forms\ABOUT.pas' {AboutBox},
  uFrmAuthManage in 'forms\uFrmAuthManage.pas' {FrmAuthManage},
  uFrmMonitor in 'forms\uFrmMonitor.pas' {FrmMonitor},
  uFrmRegist in 'forms\uFrmRegist.pas' {FrmRegist},
  uFrmSQLConnect in 'forms\uFrmSQLConnect.pas' {FrmSQLConnect},
  uFrmSvrConfig in 'forms\uFrmSvrConfig.pas' {FrmSvrConfig},
  uPubMod in 'mian\uPubMod.pas',
  uRouter in 'mian\uRouter.pas',
  uGetAuth in 'module\uGetAuth.pas',
  uTest in 'module\uTest.pas';

{$R *.res}
{$R Source.RES}
{$SetPEFlags IMAGE_FILE_LARGE_ADDRESS_AWARE}

var
  hMutex: HWND;

begin
  //以windows service方式启动
  if FindCmdLineSwitch('svc', True) or FindCmdLineSwitch('install', True) or FindCmdLineSwitch('uninstall', True) then
  begin
    if not svcmgr.Application.DelayInitialize or svcmgr.Application.Installing then
      svcmgr.Application.Initialize;
    //初始化程序中使用的时间格式
    formatsettings.LongDateFormat := 'yyyy-MM-dd';
    formatsettings.ShortDateFormat := 'yyyy-MM-dd';
    formatsettings.LongTimeFormat := 'HH:nn:ss';
    formatsettings.ShortTimeFormat := 'HH:nn:ss';
    formatsettings.DateSeparator := '-';
    formatsettings.TimeSeparator := ':';
    svcmgr.Application.CreateForm(TMainService, MainService);
  svcmgr.Application.run;
  end
  else   //以exe方式启动
  begin
    hMutex := 0;
    try
      forms.Application.Initialize;
      TStyleManager.SetStyle('Glossy');
      //初始化程序中使用的时间格式
      formatsettings.LongDateFormat := 'yyyy-MM-dd';
      formatsettings.ShortDateFormat := 'yyyy-MM-dd';
      formatsettings.LongTimeFormat := 'HH:nn:ss';
      formatsettings.ShortTimeFormat := 'HH:nn:ss';
      formatsettings.DateSeparator := '-';
      formatsettings.TimeSeparator := ':';
      forms.Application.Title := FExe + '应用服务器';
      //允许启动多个
      //禁止启动多个EXE
//      if ParamStr(1) = '' then
//      begin
//        hMutex := CreateMutex(nil, False, 'YxEmr Server');
//        if GetLastError = ERROR_ALREADY_EXISTS then
//        begin
//          MessageBox(forms.Application.Handle, '程序已运行！', '错误', MB_ICONERROR);
//          Exit;
//        end;
//      end;
    //Socket只在W8以上才有
    {$IFDEF Socket}
      if GetVersion < 8 then
      begin
        MessageBox(forms.Application.Handle, '当前系统版本过低！不支持此服务！' + #13#10 + #13#10
          + '请更换Windows 8 或者Windows Server 2012 以上版本系统！', '提示', MB_ICONASTERISK and MB_ICONINFORMATION);
        Exit;
      end;
    {$ENDIF}
      //检查注册信息
      if not CheckCPUID then
      begin
        forms.Application.CreateForm(TFrmRegist, FrmRegist);
        forms.Application.Run;
      end;
      forms.Application.CreateForm(TMainForm, MainForm);
      forms.Application.Run;
    finally
      if hMutex <> 0 then
        CloseHandle(hMutex);
    end;
  end;
end.

