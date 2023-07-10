unit uConfig;

interface

uses
  Classes, SysUtils, IniFiles, Forms, Windows, uEncry, Qjson;

const

//------------------------------------------------------------------------------
//各种加密算法密码变量
  //超级密码
  admin = 'yxsoft';
  //JWT密码
  HS256Key = 'YxSoft_YxEmr_JWT';
  //AES密码
  AESKey = 'YxSoft_YxEmr_AES';
  //SM4密码
  SM4Key = 'YxSoft_YxEmr_SM4';
  //数据库密码
  DBKey = 'AbCd1EFG2h3I4j5kLm9no4PQr8Stu6Vw5X7yz';
//------------------------------------------------------------------------------

type
  TIni = record
  public
    //注册码
    RegisterDate: string;

    {Section: DB}
    DBServer: string;
    DBDataBase: string;
    DBUserName: string;
    DBPassWord: string;
    {Section: YxEmr}
    Auto: Boolean;
    AutoRun: Boolean;
    MsgLog: Boolean;
    SQLLog: Boolean;
    ErrLog: Boolean;
    HttpType: Boolean;
    ReBoot: Boolean;
    Https: Boolean;
    BFile: Boolean;
    ReBootT: Integer;
    Pools: Integer;
    BSysLog: Boolean;
    SysLogIP: string;
    SysLogPort: Integer;
    Port: string;
    LogSize: Integer;
    Socket: Boolean;
    Method: string;
    Topic: Integer;
    Root: string;
    Aes: Boolean;
    NG: Boolean;
    IP: string;
    UseCache: Boolean;
    LogMax: Integer;
   {Section: MQTT}
    MQEnable: Boolean;
    MQHost: string;
    MQPort: Integer;
    MQUser: string;
    MQPass: string;
    MQClientID: string;
    MQVerSion: Integer;
    MQSubTop: string;
    MQRecQos: Integer;
    MQPubTop: string;
    MQPubQos: Integer;
    MQSSL: Boolean;
    {Section: Url}
    WZUrl: string;
    ReportUrl: string;
    RemoveUrl: string;
    DoQSUrl: string;
    DoZXUrl: string;
    HisReportUrl: string;
  end;

procedure SaveToFile;

procedure LoadFromFile;

var
  Ini: TIni;
  ConfJson: TQjson;
  //配置文件全局变量 YxEmr.json
  YxEmrINI: string;
  //服务剩余注册天数
  FDate: Int64;
  //程序名称
  FExe: string;
implementation

procedure LoadSettings;
begin
  ConfJson.ToRecord(Ini);
  with Ini do
  begin
    FDate := 3;
    DBServer := Trim(Decode(DBServer));
    DBDataBase := Trim(Decode(DBDataBase));
    DBUserName := Trim(Decode(DBUserName));
    DBPassWord := Trim(Decode(DBPassWord));
    HttpType := true;
    if ReBootT = 0 then
      ReBootT := 3;
    if Pools = 0 then
      Pools := 32;
    if SysLogPort = 0 then
      SysLogPort := 514;
    if LogSize = 0 then
      LogSize := 10;
    if LogMax = 0 then
      LogMax := 10;
    if MQPort = 0 then
      MQPort := 1883;
    if Port = '' then
      Port := '8080';
    NG := False;
    if StrToIntDef(ParamStr(1), 0) <> 0 then
    begin
      NG := True;
      Port := ParamStr(1);
    end;
    if Root = '' then
      Root := '/IWSYXHIS';
    if not HttpType then
      Root := '';
    if WZUrl = '' then
      WZUrl := 'http://127.0.0.1:8085';
    if HisReportUrl = '' then
      HisReportUrl := 'http://127.0.0.1:5503/TBs_JKJC_LWBG/HisReport';
    if DoZXUrl = '' then
      DoZXUrl := 'http://127.0.0.1:5503/TBs_JKJC_LWBG/DoPerform';
    if ReportUrl = '' then
      ReportUrl := 'http://127.0.0.1:5503/TBs_JKJC_LWBG/WriteReport';
    if RemoveUrl = '' then
      RemoveUrl := 'http://127.0.0.1:5503/TBs_JKJC_LWBG/RemoveReport';
    if DoQSUrl = '' then
      DoQSUrl := 'http://127.0.0.1:5503/TBs_JKJC_LWBG/DoTransact';

    FExe := ChangeFileExt(ExtractFileName(ParamStr(0)), '');
  end;
end;

procedure SaveSettings;
begin
//  with Ini do
//  begin
//    DBServer := Trim(EnCode(DBServer));
//    DBDataBase := Trim(EnCode(DBDataBase));
//    DBUserName := Trim(EnCode(DBUserName));
//    DBPassWord := Trim(EnCode(DBPassWord));
//  end;
  ConfJson.FromRecord(Ini);
  ConfJson.ForcePath('DBServer').AsString := EnCode(Ini.DBServer);
  ConfJson.ForcePath('DBDataBase').AsString := EnCode(Ini.DBDataBase);
  ConfJson.ForcePath('DBUserName').AsString := EnCode(Ini.DBUserName);
  ConfJson.ForcePath('DBPassWord').AsString := EnCode(Ini.DBPassWord);
end;

procedure LoadFromFile;
begin
  if FileExists(YxEmrINI) then
    ConfJson.LoadFromFile(YxEmrINI);
  LoadSettings;

end;

procedure SaveToFile;
begin
  SaveSettings;
  ConfJson.SaveToFile(YxEmrINI);
end;

initialization
  YxEmrINI := ChangeFileExt(ParamStr(0), '.json');
  ConfJson := TQjson.Create;
  LoadFromFile;

finalization
  SaveToFile;
  ConfJson.Free;

end.

