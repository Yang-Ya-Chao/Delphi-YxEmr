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
  //��windows service��ʽ����
  if FindCmdLineSwitch('svc', True) or FindCmdLineSwitch('install', True) or FindCmdLineSwitch('uninstall', True) then
  begin
    if not svcmgr.Application.DelayInitialize or svcmgr.Application.Installing then
      svcmgr.Application.Initialize;
    //��ʼ��������ʹ�õ�ʱ���ʽ
    formatsettings.LongDateFormat := 'yyyy-MM-dd';
    formatsettings.ShortDateFormat := 'yyyy-MM-dd';
    formatsettings.LongTimeFormat := 'HH:nn:ss';
    formatsettings.ShortTimeFormat := 'HH:nn:ss';
    formatsettings.DateSeparator := '-';
    formatsettings.TimeSeparator := ':';
    svcmgr.Application.CreateForm(TMainService, MainService);
  svcmgr.Application.run;
  end
  else   //��exe��ʽ����
  begin
    hMutex := 0;
    try
      forms.Application.Initialize;
      TStyleManager.SetStyle('Glossy');
      //��ʼ��������ʹ�õ�ʱ���ʽ
      formatsettings.LongDateFormat := 'yyyy-MM-dd';
      formatsettings.ShortDateFormat := 'yyyy-MM-dd';
      formatsettings.LongTimeFormat := 'HH:nn:ss';
      formatsettings.ShortTimeFormat := 'HH:nn:ss';
      formatsettings.DateSeparator := '-';
      formatsettings.TimeSeparator := ':';
      forms.Application.Title := FExe + 'Ӧ�÷�����';
      //�����������
      //��ֹ�������EXE
//      if ParamStr(1) = '' then
//      begin
//        hMutex := CreateMutex(nil, False, 'YxEmr Server');
//        if GetLastError = ERROR_ALREADY_EXISTS then
//        begin
//          MessageBox(forms.Application.Handle, '���������У�', '����', MB_ICONERROR);
//          Exit;
//        end;
//      end;
    //Socketֻ��W8���ϲ���
    {$IFDEF Socket}
      if GetVersion < 8 then
      begin
        MessageBox(forms.Application.Handle, '��ǰϵͳ�汾���ͣ���֧�ִ˷���' + #13#10 + #13#10
          + '�����Windows 8 ����Windows Server 2012 ���ϰ汾ϵͳ��', '��ʾ', MB_ICONASTERISK and MB_ICONINFORMATION);
        Exit;
      end;
    {$ENDIF}
      //���ע����Ϣ
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

