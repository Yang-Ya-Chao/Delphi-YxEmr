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
  Winapi.Windows,
  System.SysUtils,
  Vcl.Themes,
  Vcl.Styles,
  uFrmMain in 'uFrmMain.pas' {MainForm},
  uFrmMQTTClient in 'MQTT\uFrmMQTTClient.pas' {FrmMQClient},
  uWebModule in 'serve\uWebModule.pas' {WebModule1: TWebModule},
  SoapImpl in 'serve\SoapImpl.pas',
  SoapIntf in 'serve\SoapIntf.pas',
  uServer in 'serve\uServer.pas',
  UpubFun in 'public\UpubFun.pas',
  uConfig in 'config\uConfig.pas',
  ABOUT in 'forms\ABOUT.pas' {AboutBox},
  uFrmAuthManage in 'forms\uFrmAuthManage.pas' {FrmAuthManage},
  uFrmMonitor in 'forms\uFrmMonitor.pas' {FrmMonitor},
  uFrmRegist in 'forms\uFrmRegist.pas' {FrmRegist},
  uFrmSQLConnect in 'forms\uFrmSQLConnect.pas' {FrmSQLConnect},
  uFrmSvrConfig in 'forms\uFrmSvrConfig.pas' {FrmSvrConfig},
  uQueryHelper in 'helpher\uQueryHelper.pas',
  uPubMod in 'mian\uPubMod.pas',
  uRouter in 'mian\uRouter.pas',
  uObjPools in 'pool\uObjPools.pas',
  uGetAuth in 'module\uGetAuth.pas',
  uTest in 'module\uTest.pas';

{$R *.res}
{$R Source.RES}
{$SetPEFlags IMAGE_FILE_LARGE_ADDRESS_AWARE}
var
  hMutex: HWND;
  Ret: Integer;

begin
  //Reportmemoryleaksonshutdown:=True;
  hMutex := 0;
  try
    Application.Initialize;
    TStyleManager.SetStyle('Glossy');
    //初始化程序中使用的时间格式
    formatsettings.LongDateFormat := 'yyyy-MM-dd';
    formatsettings.ShortDateFormat := 'yyyy-MM-dd';
    formatsettings.LongTimeFormat := 'HH:nn:ss';
    formatsettings.ShortTimeFormat := 'HH:nn:ss';
    formatsettings.DateSeparator := '-';
    formatsettings.TimeSeparator := ':';
    Application.Title := 'YxEmr应用服务器';
    //Socket只在W8以上才有
    {$IFDEF Socket}
    if GetVersion < 8 then
    begin
      MessageBox(Application.Handle, '当前系统版本过低！不支持此服务！'+#13#10+#13#10
        +'请更换Windows 8 或者Windows Server 2012 以上版本系统！'
        , '提示', MB_ICONASTERISK and MB_ICONINFORMATION);
      Exit;
    end;
    {$ENDIF}
    //禁止启动多个EXE
    if ParamStr(1) = '' then
    begin
      hMutex := CreateMutex(nil, False, 'YxEmr Server');
      Ret := GetLastError;
      if Ret = ERROR_ALREADY_EXISTS then
      begin
        MessageBox(Application.Handle, '程序已运行！', '错误', MB_ICONERROR);
        Exit;
      end;
    end;
    //检查注册信息
    if not CheckCPUID then
    begin
      Application.CreateForm(TFrmRegist, FrmRegist);
      Application.Run;
    end;
    Application.CreateForm(TMainForm, MainForm);
    Application.Run;
  finally
    if hMutex <> 0 then
      CloseHandle(hMutex);
  end;
end.

