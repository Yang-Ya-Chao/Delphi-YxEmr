unit uSvrMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs,uServer,Qlog,uConfig, Registry,UpubFun;

type
  TMainService = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceBeforeInstall(Sender: TService);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceDestroy(Sender: TObject);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
  private
    { Private declarations }
    //日志对象
    ErrWriter,MsgWriter,SqlWriter:TQLogFileWriter;
    AWriter:TQLogSocketWriter;
    //HttpApi对象
    FServer: TSynHTTPWebBrokerBridge;
    procedure RegWinService(R: Boolean);
    procedure Star;
    procedure Stop;
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  MainService: TMainService;
const
  CSRegServiceURL = 'SYSTEM\CurrentControlSet\Services\';
  CSRegDescription = 'Description';
  CSRegImagePath = 'ImagePath';
  CSServiceDescription = '医星HIS电子病历标准服务';
implementation

{$R *.dfm}

procedure TMainService.Star;
begin
  //设置日志文件 (输出syslog服务器)
  if  ini.BSysLog then
  begin
    AWriter := TQLogSocketWriter.Create;
    AWriter.ServerHost := ini.SysLogIP;
    AWriter.ServerPort := ini.SysLogPort;
    AWriter.UseTCP := False;
    Logs.Castor.AddWriter(AWriter);
  end;
  //设置日志文件 (输出到文件)
  //SetDefaultLogFile(LogPath + '\Log.TXT', LogSize * 1048576, True, True);
  //错误日志
  var ExeParh := ChangeFileExt(ParamStr(0), '') + 'log\';
  var LogPath := ExeParh + 'Errlog\log.txt';
  ErrWriter := TQLogFileWriter.Create(LogPath);
  ErrWriter.MaxSize := ini.LogSize * 1048576;   //单日志文件大小 10M
  ErrWriter.CreateMode := lcmRename;
  ErrWriter.OneFilePerDay := True;
  ErrWriter.AcceptLevels := [llError];
  ErrWriter.MaxLogHistories := 30;
  Logs.Castor.AddWriter(ErrWriter);
  ErrWriter.Enabled := Ini.ErrLog;
  //调用参数日志
  LogPath := ExeParh + 'Msglog\log.txt';
  MsgWriter := TQLogFileWriter.Create(LogPath);
  MsgWriter.MaxSize := ini.LogSize * 1048576;   //单日志文件大小 10M
  MsgWriter.CreateMode := lcmRename;
  MsgWriter.OneFilePerDay := True;
  MsgWriter.AcceptLevels := [llmessage];
  MsgWriter.MaxLogHistories := 10;
  Logs.Castor.AddWriter(MsgWriter);
  MsgWriter.Enabled := ini.MsgLog;
  //sql语句日志
  LogPath := ExeParh + 'Sqllog\log.txt';
  SqlWriter := TQLogFileWriter.Create(LogPath);
  SqlWriter.MaxSize := ini.LogSize * 1048576;   //单日志文件大小 10M
  SqlWriter.CreateMode := lcmRename;
  SqlWriter.OneFilePerDay := True;
  SqlWriter.AcceptLevels := [llDebug];
  SqlWriter.MaxLogHistories := 5;
  Logs.Castor.AddWriter(SqlWriter);
  SqlWriter.Enabled := ini.SQLLog;
  FServer := TSynHTTPWebBrokerBridge.Create(nil);
end;
procedure TMainService.Stop;
begin
  Logs.Castor.RemoveWriter(SqlWriter);
  Logs.Castor.RemoveWriter(MsgWriter);
  Logs.Castor.RemoveWriter(ErrWriter);
  Logs.Castor.RemoveWriter(AWriter);
  SqlWriter.Free;
  MsgWriter.Free;
  ErrWriter.Free;
  AWriter.Free;
  FServer.Free;
end;

procedure TMainService.RegWinService(R: Boolean);
const
  KEY_WOW64_64KEY = $0100;
var
  RegF: TRegistry;
begin
  if isWoW64 then
    RegF := TRegistry.Create(KEY_WRITE or KEY_READ or KEY_WOW64_64KEY)
  else
    RegF := TRegistry.Create;
  RegF.RootKey := HKEY_LOCAL_MACHINE;
  try
    RegF.OpenKey(CSRegServiceURL+Name, True);
    try
      if R then
      begin
        RegF.WriteString(CSRegDescription, CSServiceDescription);
        RegF.WriteString(CSRegImagePath, ParamStr(0)+' -svc');
      end
      else
      begin
        if RegF.KeyExists(CSRegImagePath) then
          RegF.DeleteKey(CSRegImagePath);
      end;
    finally
      RegF.CloseKey;
      RegF.Destroy
    end;
  except
    //nothing...
  end;
end;


procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  MainService.Controller(CtrlCode);
end;

function TMainService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TMainService.ServiceAfterInstall(Sender: TService);
begin
  RegWinService(True);
end;

procedure TMainService.ServiceBeforeInstall(Sender: TService);
begin
  RegWinService(False);
end;

procedure TMainService.ServiceContinue(Sender: TService;
  var Continued: Boolean);
begin
  Star;
end;

procedure TMainService.ServiceDestroy(Sender: TObject);
begin
  Stop;
end;

procedure TMainService.ServicePause(Sender: TService; var Paused: Boolean);
begin
  Stop;
end;

procedure TMainService.ServiceShutdown(Sender: TService);
begin
  Stop;
end;

procedure TMainService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  Star;
end;

procedure TMainService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  Stop;
end;

end.
