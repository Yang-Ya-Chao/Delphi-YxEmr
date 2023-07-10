//业务分发路由
unit uRouter;

interface

uses
  SysUtils, System.Classes,System.StrUtils, System.RegularExpressions,System.Rtti;

type
  Router = class
  private
    //正则表达，获取query参数
    function GetParamValue(UrlStr, ParamName: string; Pos: string = ':'): string;
    //JWT鉴权
    function CheckAuth(Auth, Method: string; out OutValue: string): Boolean;
    //获取Url参数路径，即/IWSYXHIS/GetUser?...中的GetUser
    function GetUrlPath(UrlStr: string): string;
  public

//==============================================================================
// 外部服务调用DoExcute解析业务，分发到具体函数中进行处理
    function DoExcute(Header, InValue: string; out OutValue: string): Boolean;
//==============================================================================
  end;
  /// <summary>设置返回值格式</summary>
  /// <param name="Code">0：成功，1：失败</param>
  /// <param name="Msg">信息说明</param>
  /// <param name="Error">错误信息</param>

function SetResultInfo(Code: Integer = 0; Msg: string = ''): string;

implementation

uses
  uPubMod, SynCrypto, Qjson,uConfig,uEncry;

function SetResultInfo(Code: Integer; Msg: string): string;
var
  aJson, bJson: TQJson;
begin
  aJson := TQJson.Create;
  bJson := TQJson.Create;
  try
    with aJson.Add('Result', jdtObject) do
    begin
      Add('Code', Code);
      if Code = 0 then
      begin
        Add('Msg', jdtObject);
        Add('Error', Msg, jdtString)
      end
      else if Code = 1 then
      begin
        if not bJson.TryParse(Msg) then
          Add('Msg', Msg, jdtString)
        else
        begin
          if bJson.DataType = jdtArray then
            Add('Msg', Msg, jdtArray)
          else
            Add('Msg', Msg, jdtObject);
        end;
        Add('Error', '', jdtString);
      end;
    end;
    if Ini.Aes then
      Result := AESEncode(aJson.AsJson)
    else
      Result := aJson.AsJson;
  finally
    aJson.Free;
    bJson.Free;
  end;
end;


function Router.GetParamValue(UrlStr, ParamName, Pos: string): string;
var
  Reg: TRegEx;
  Match: TMatch;
begin
  Result := '';
  Match := Reg.Match(UrlStr, '(?<=' + ParamName + Pos + ')[^&]*');
  if Match.Success then
  begin
    Result := Match.Value;
  end;
end;

function Router.GetUrlPath(UrlStr:string):string;
  var
    Reg: TRegEx;
    Match: TMatch;
  begin
    Result := '';
    if not UrlStr.Contains('?') then
      UrlStr := UrlStr+ '?';
    Match := Reg.Match(UrlStr, '(?<='+Ini.Root+'/).*?(?=\?)');
    if Match.Success then
    begin
      Result := Match.Value;
    end;
  end;

function Router.CheckAuth(Auth, Method: string; out OutValue: string): Boolean;
var
  FCode:integer;
  LJWT: TJWTAbstract;
  LJWTContent: TJWTContent;
begin
  Result := False;
  OutValue := '';
  FCode := 0;
  if Method = 'GetAuth' then Exit(True);
  if Method = '' then
  begin
    OutValue := '业务码无效！';
    Exit;
  end;
  if Auth = '' then
  begin
    OutValue := '授权码无效！';
    Exit;
  end;
  if Auth = admin then
  begin
    if FDate < 1 then
    begin
      OutValue := '服务已到期！请联系公司进行处理！';
      Exit;
    end;
    Exit(True);
  end;
  LJWT := TJWTHS256.Create(UTF8Encode(HS256Key), 0, [], [], 30);
  try
    if not Assigned(LJWT) then
    begin
      OutValue := '授权无效！';
      Exit;
    end;
    LJWT.Options := [joHeaderParse, joAllowUnexpectedClaims];
    LJWT.Verify(UTF8Encode(Auth), LJWTContent);
    if not (LJWTContent.result = jwtValid) then
    begin
        //TRttiEnumerationType.GetName<TJWTResult>(LJWTContent.result)
      FCode := Ord(LJWTContent.result);
      Exit;
    end;
    if Pos('|' + Method + '|', '|' + LJWTContent.reg[jrcSubject] + '|') < 1 then
    begin
      FCode := 13;
        //FError := '权限不足！无['+Header+']业务权限！' ;
      Exit;
    end;
  finally
    if FCode > 0 then
      OutValue := '错误的授权信息！'+TRttiEnumerationType.GetName<TJWTResultErr>(TJWTResultErr(FCode))+'！' ;
      //'错误的授权信息！错误代码[' + FCode.ToString + ']！';
    LJWT.Free;
  end;
  Result := True;
end;

function Router.DoExcute(Header, InValue: string; out OutValue: string): Boolean;
var
  CDBLX, Authorization, Method: string;
begin
  Result := False;
  //先从Get请求的url路径中获取业务名
  Method := Trim(GetUrlPath(InValue));
  //如果是post请求，则从请求头中获取业务名
  if Method = '' then
    Method := Trim(GetParamValue(Header, 'Method'));
  Authorization := Trim(GetParamValue(Header, 'Authorization').Replace('Bearer','',[rfIgnoreCase]));
  CDBLX := Trim(GetParamValue(Header, 'CDBLX'));
  //jwt鉴权
  if not CheckAuth(Authorization,Method,OutValue) then Exit;
  try
    if GetClass(Method) = nil then
    begin
      OutValue := '业务码错误！';
      Exit;
    end;
    //应卫健委要求，入参出参均使用aes加密传输
    if Ini.AES then
      InValue := AESDecode(InValue);
    with TPubMod(FindClass(Method).NewInstance).Create do
    begin
      SDBLX := CDBLX;
      SYXHIS := 'YXHIS'+SDBLX;
      SYXYKT := 'YXYKT'+SDBLX;
      try
        if not Execute(InValue,Method) then
        begin
           OutValue := AERROR;
           Exit;
        end;
        FJson.Clear;
        if AResultData = '' then
          OutValue := FJson.AsJson
        else
          OutValue := AResultData;
      finally
        Free;
      end;
    end;
  except
    on e:Exception do
    begin
      OutValue := '异常：' + e.message;
      Exit;
    end
  end;
  Result := True;
end;

end.

