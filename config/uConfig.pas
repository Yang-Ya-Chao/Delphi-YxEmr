unit uConfig;

interface

uses
  Classes, SysUtils, IniFiles, Forms, Windows,uEncry;

const
  //≥¨º∂√‹¬Î
  admin = 'yxsoft';
  //JWT√‹¬Î
  HS256Key = 'YxSoft_YxEmr_Server';

  csRegisterSection = 'Register';
  csDBSection = 'DB';
  csSection = 'YxEmr';
  csMQTTSection = 'MQTT';

  {Section: Register}
  csRegisterDate = 'Date';

  {Section: DB}
  csDBServer = 'Server';
  csDBDataBase = 'DataBase';
  csDBUserName = 'UserName';
  csDBPassWord = 'PassWord';

  {Section: YxEmr}
  csAuto = 'Auto';
  csAutoRun = 'AutoRun';
  csMsgLog = 'MsgLog';
  csSqlLog = 'SqlLog';
  csErrLog = 'ErrLog';
  csHttpType = 'HttpType';
  csReBoot = 'ReBoot';
  csHttps = 'Https';
  csBFile = 'BFile';
  csReBootT = 'ReBootT';
  csPools = 'Pools';
  csBSysLog = 'BSysLog';
  csSysLogIP = 'SysLogIP';
  csSysLogPort = 'SysLogPort';
  csPort = 'Port';
  csLogSize = 'LogSize';
  csSocket = 'Socket';
  csMethod = 'Method';
  csTopic = 'Topic';
  csRoot = 'Root';
  csTib = 'Tib';
  csWZUrl = 'WZUrl';

  {Section: MQTT}
  csMQEnable = 'MQEnable';
  csMQHost = 'MQHost';
  csMQPort = 'MQPort';
  csMQUser = 'MQUser';
  csMQPass = 'MQPass';
  csMQClientID = 'MQClientID';
  csMQVerSion = 'MQVerSion';
  csMQSubTop = 'MQSubTop';
  csMQRecQos = 'MQRecQos';
  csMQPubTop = 'MQPubTop';
  csMQPubQos = 'MQPubQos';
  csMQSSL = 'MQSSL';

type
  TIni = class(TObject)
  private
    {Section: Register}
    FRegisterDate: string;

    {Section: DB}
    FDBServer: string;
    FDBDataBase: string;
    FDBUserName: string;
    FDBPassWord: string;

    {Section: YxEmr}
    FAuto: Boolean;
    FAutoRun: Boolean;
    FMsgLog: Boolean;
    FSQLLog: Boolean;
    FErrLog: Boolean;
    FHttpType: Boolean;
    FReBoot: Boolean;
    FHttps: Boolean;
    FBFile: Boolean;
    FReBootT: Integer;
    FPools: Integer;
    FBSysLog: Boolean;
    FSysLogIP: string;
    FSysLogPort: Integer;
    FPort: string;
    FLogSize: Integer;
    FSocket: Boolean;
    FMethod: string;
    FTopic: Integer;
    FRoot:String;
    {Section: MQTT}
    FMQEnable: Boolean;
    FMQHost: string;
    FMQPort: Integer;
    FMQUser: string;
    FMQPass: string;
    FMQClientID: string;
    FMQVerSion: Integer;
    FMQSubTop: string;
    FMQRecQos: Integer;
    FMQPubTop: string;
    FMQPubQos: Integer;
    FMQSSL: Boolean;
  public
    procedure LoadSettings(Ini: TMemIniFile);
    procedure SaveSettings(Ini: TMemIniFile);
    
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);

    {Section: Register}
    property RegisterDate: string read FRegisterDate write FRegisterDate;

    {Section: DB}
    property DBServer: string read FDBServer write FDBServer;
    property DBDataBase: string read FDBDataBase write FDBDataBase;
    property DBUserName: string read FDBUserName write FDBUserName;
    property DBPassWord: string read FDBPassWord write FDBPassWord;

    {Section: YxEmr}
    property Auto: Boolean read FAuto write FAuto;
    property AutoRun: Boolean read FAutoRun write FAutoRun;
    property MsgLog: Boolean read FMsgLog write FMsgLog;
    property SQLLog: Boolean read FSQLLog write FSQLLog;
    property ErrLog: Boolean read FErrLog write FErrLog;
    property HttpType: Boolean read FHttpType write FHttpType;
    property ReBoot: Boolean read FReBoot write FReBoot;
    property Https: Boolean read FHttps write FHttps;
    property BFile: Boolean read FBFile write FBFile;
    property ReBootT: Integer read FReBootT write FReBootT;
    property Pools: Integer read FPools write FPools;
    property BSysLog: Boolean read FBSysLog write FBSysLog;
    property SysLogIP: string read FSysLogIP write FSysLogIP;
    property SysLogPort: Integer read FSysLogPort write FSysLogPort;
    property Port: string read FPort write FPort;
    property LogSize: Integer read FLogSize write FLogSize;
    property Socket: Boolean read FSocket write FSocket;
    property Method: string read FMethod write FMethod;
    property Topic: Integer read FTopic write FTopic;
    property Root: string read FRoot write FRoot;


    {Section: MQTT}
    property MQEnable: Boolean read FMQEnable write FMQEnable;
    property MQHost: string read FMQHost write FMQHost;
    property MQPort: Integer read FMQPort write FMQPort;
    property MQUser: string read FMQUser write FMQUser;
    property MQPass: string read FMQPass write FMQPass;
    property MQClientID: string read FMQClientID write FMQClientID;
    property MQVerSion: Integer read FMQVerSion write FMQVerSion;
    property MQSubTop: string read FMQSubTop write FMQSubTop;
    property MQRecQos: Integer read FMQRecQos write FMQRecQos;
    property MQPubTop: string read FMQPubTop write FMQPubTop;
    property MQPubQos: Integer read FMQPubQos write FMQPubQos;
    property MQSSL: Boolean read FMQSSL write FMQSSL;
  end;

var
  Ini: TIni = nil;

implementation

procedure TIni.LoadSettings(Ini: TMemIniFile);
begin
  if Ini <> nil then
  begin
    {Section: Register}
    FRegisterDate := Ini.ReadString(csRegisterSection, csRegisterDate, '');

    {Section: DB}
    FDBServer := Trim(Decode(Ini.ReadString(csDBSection, csDBServer, '')));
    FDBDataBase := Trim(Decode(Ini.ReadString(csDBSection, csDBDataBase, '')));
    FDBUserName := Trim(Decode(Ini.ReadString(csDBSection, csDBUserName, '')));
    FDBPassWord := Trim(Decode(Ini.ReadString(csDBSection, csDBPassWord, '')));

    {Section: YxEmr}
    FAuto := Ini.ReadBool(csSection, csAuto, False);
    FAutoRun := Ini.ReadBool(csSection, csAutoRun, False);
    FMsgLog := Ini.ReadBool(csSection, csMsgLog, False);
    FSQLLog := Ini.ReadBool(csSection, csSqlLog, False);
    FErrLog := Ini.ReadBool(csSection, csErrLog, True);
    FHttpType := Ini.ReadBool(csSection, csHttpType, True);
    FReBoot := Ini.ReadBool(csSection, csReBoot, False);
    FHttps := Ini.ReadBool(csSection, csHttps, False);
    FBFile := Ini.ReadBool(csSection, csBFile, False);
    FReBootT := Ini.ReadInteger(csSection, csReBootT, 3);
    FPools := Ini.ReadInteger(csSection, csPools, 32);
    FBSysLog := Ini.ReadBool(csSection, csBSysLog, False);
    FSysLogIP := Ini.ReadString(csSection, csSysLogIP, '127.0.0.1');
    FSysLogPort := Ini.ReadInteger(csSection, csSysLogPort, 514);
    FPort := Ini.ReadString(csSection, csPort, '8080');
    if ParamStr(1) <> '' then
      FPort := ParamStr(1);
    FRoot := Ini.ReadString(csSection, csRoot, '/IWSYXHIS');
    if FRoot = '' then
      FRoot := '/IWSYXHIS';
    if not FHttpType then
      FRoot := '';
    FLogSize := Ini.ReadInteger(csSection, csLogSize, 10);
    FSocket := Ini.ReadBool(csSection, csSocket, False);
    FMethod := Ini.ReadString(csSection, csMethod,'Test');
    FTopic := Ini.ReadInteger(csSection, csTopic, 0);
    {Section: MQTT}
    FMQEnable := Ini.ReadBool(csSection, csMQEnable, False);
    FMQHost := Ini.ReadString(csSection, csMQHost, '127.0.0.1');
    FMQPort := Ini.ReadInteger(csSection, csMQPort, 1883);
    FMQUser := Ini.ReadString(csSection, csMQUser, 'user');
    FMQPass := Ini.ReadString(csSection, csMQPass, '123456');
    FMQClientID := Ini.ReadString(csSection, csMQClientID, 'YxCis');
    FMQVerSion := Ini.ReadInteger(csSection, csMQVerSion, 0);
    FMQSubTop := Ini.ReadString(csSection, csMQSubTop, '');
    FMQRecQos := Ini.ReadInteger(csSection, csMQRecQos, 0);
    FMQPubTop := Ini.ReadString(csSection, csMQPubTop, '');
    FMQPubQos := Ini.ReadInteger(csSection, csMQPubQos, 0);
    FMQSSL := Ini.ReadBool(csSection, csMQSSL, False);
  end;
end;

procedure TIni.SaveSettings(Ini: TMemIniFile);
begin
  if Ini <> nil then
  begin
    {Section: Register}
    Ini.WriteString(csRegisterSection, csRegisterDate, FRegisterDate);

    {Section: DB}
    Ini.WriteString(csDBSection, csDBServer, Encode(FDBServer));
    Ini.WriteString(csDBSection, csDBDataBase, Encode(FDBDataBase));
    Ini.WriteString(csDBSection, csDBUserName, Encode(FDBUserName));
    Ini.WriteString(csDBSection, csDBPassWord, Encode(FDBPassWord));

    {Section: YxEmr}
    Ini.WriteBool(csSection, csAuto, FAuto);
    Ini.WriteBool(csSection, csAutoRun, FAutoRun);
    Ini.WriteBool(csSection, csMsgLog, FMsgLog);
    Ini.WriteBool(csSection, csSQLLog, FSQLLog);
    Ini.WriteBool(csSection, csErrLog, FErrLog);
    Ini.WriteBool(csSection, csHttpType, FHttpType);
    Ini.WriteBool(csSection, csReBoot, FReBoot);
    Ini.WriteBool(csSection, csHttps, FHttps);
    Ini.WriteBool(csSection, csBFile, FBFile);
    Ini.WriteInteger(csSection, csReBootT, FReBootT);
    Ini.WriteInteger(csSection, csPools, FPools);
    Ini.WriteBool(csSection, csBSysLog, FBSysLog);
    Ini.WriteString(csSection, csSysLogIP, FSysLogIP);
    Ini.WriteInteger(csSection, csSysLogPort, FSysLogPort);
    Ini.WriteString(csSection, csPort, FPort);
    Ini.WriteInteger(csSection, csLogSize, FLogSize);
    Ini.WriteBool(csSection, csSocket, FSocket);
    Ini.WriteString(csSection, csMethod, FMethod);
    Ini.WriteInteger(csSection, csTopic, FTopic);
    Ini.WriteString(csSection,csRoot,FRoot);
    {Section: MQTT}
    Ini.WriteBool(csSection, csMQEnable, FMQEnable);
    Ini.WriteString(csSection, csMQHost, FMQHost);
    Ini.WriteInteger(csSection, csMQPort, FMQPort);
    Ini.WriteString(csSection, csMQUser, FMQUser);
    Ini.WriteString(csSection, csMQPass, FMQPass);
    Ini.WriteString(csSection, csMQClientID, FMQClientID);
    Ini.WriteInteger(csSection, csMQVerSion, FMQVerSion);
    Ini.WriteString(csSection, csMQSubTop, FMQSubTop);
    Ini.WriteInteger(csSection, csMQRecQos, FMQRecQos);
    Ini.WriteString(csSection, csMQPubTop, FMQPubTop);
    Ini.WriteInteger(csSection, csMQPubQos, FMQPubQos);
    Ini.WriteBool(csSection, csMQSSL, FMQSSL);
  end;
end;

procedure TIni.LoadFromFile(const FileName: string);
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(FileName);
  try
    LoadSettings(Ini);
  finally
    Ini.Free;
  end;
end;

procedure TIni.SaveToFile(const FileName: string);
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(FileName);
  try
    SaveSettings(Ini);
    Ini.UpdateFile;
  finally
    Ini.Free;
  end;
end;

initialization
  Ini := TIni.Create;
  Ini.LoadFromFile(ChangeFileExt(ParamStr(0), '.ini'));
finalization
  Ini.SaveToFile(ChangeFileExt(ParamStr(0), '.ini'));
  Ini.Free;
end.

