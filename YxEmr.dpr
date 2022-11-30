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
//             ���汣��       ����崻�      ����BUG               //
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
    //��ʼ��������ʹ�õ�ʱ���ʽ
    formatsettings.LongDateFormat := 'yyyy-MM-dd';
    formatsettings.ShortDateFormat := 'yyyy-MM-dd';
    formatsettings.LongTimeFormat := 'HH:nn:ss';
    formatsettings.ShortTimeFormat := 'HH:nn:ss';
    formatsettings.DateSeparator := '-';
    formatsettings.TimeSeparator := ':';
    Application.Title := 'YxEmrӦ�÷�����';
    //Socketֻ��W8���ϲ���
    {$IFDEF Socket}
    if GetVersion < 8 then
    begin
      MessageBox(Application.Handle, '��ǰϵͳ�汾���ͣ���֧�ִ˷���'+#13#10+#13#10
        +'�����Windows 8 ����Windows Server 2012 ���ϰ汾ϵͳ��'
        , '��ʾ', MB_ICONASTERISK and MB_ICONINFORMATION);
      Exit;
    end;
    {$ENDIF}
    //��ֹ�������EXE
    if ParamStr(1) = '' then
    begin
      hMutex := CreateMutex(nil, False, 'YxEmr Server');
      Ret := GetLastError;
      if Ret = ERROR_ALREADY_EXISTS then
      begin
        MessageBox(Application.Handle, '���������У�', '����', MB_ICONERROR);
        Exit;
      end;
    end;
    //���ע����Ϣ
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

