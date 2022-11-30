//ҵ��ַ�·��
unit uRouter;

interface

uses
  SysUtils, System.Classes, System.RegularExpressions, SynCrypto, Qjson,uConfig;

type
  Router = class
  private
    //�������ȡquery����
    function GetParamValue(UrlStr, ParamName: string; Pos: string = ':'): string;
    //JWT��Ȩ
    function CheckAuth(Auth, Method: string; out OutValue: string): Boolean;
    //��ȡUrl����·������/IWSYXHIS/GetUser?...�е�GetUser
    function GetUrlPath(UrlStr: string): string;
  public

//==============================================================================
// �ⲿ�������DoExcute����ҵ�񣬷ַ������庯���н��д���
    function DoExcute(Header, InValue: string; out OutValue: string): Boolean;
//==============================================================================
  end;
  /// <summary>���÷���ֵ��ʽ</summary>
  /// <param name="Code">0���ɹ���1��ʧ��</param>
  /// <param name="Msg">��Ϣ˵��</param>
  /// <param name="Error">������Ϣ</param>

function SetResultInfo(Code: Integer = 0; Msg: string = ''): string;

implementation

uses
  uPubMod;

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
          Add('Msg', Msg, jdtObject);
        Add('Error', '', jdtString);
      end;
    end;

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
    if Pos('?',UrlStr) < 1 then
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
  if Method = 'GetAuth' then Exit(True);
  if Method = '' then
  begin
    OutValue := 'ҵ������Ч��';
    Exit;
  end;
  if Auth = '' then
  begin
    OutValue := '��Ȩ����Ч��';
    Exit;
  end;
  if Auth = admin then Exit(True);
  LJWT := TJWTHS256.Create(UTF8Encode(HS256Key), 0, [], [], 30);
  try
    if not Assigned(LJWT) then
    begin
      OutValue := '��Ȩ��Ч��';
      Exit;
    end;
    LJWT.Options := [joHeaderParse, joAllowUnexpectedClaims];
    LJWT.Verify(UTF8Encode(Auth), LJWTContent);
    if not (LJWTContent.result = jwtValid) then
    begin
        //TRttiEnumerationType.GetName<TJWTResult>(LJWTContent.result)
      FCode := Ord(LJWTContent.result) + 100;
        //FError := '��Ȩ��֤ʧ�ܣ��������'+IntToStr(FCode)+'��' ;
      Exit;
    end;
    if Pos('|' + Method + '|', '|' + LJWTContent.reg[jrcSubject] + '|') < 1 then
    begin
      FCode := 113;
        //FError := 'Ȩ�޲��㣡��['+Header+']ҵ��Ȩ�ޣ�' ;
      Exit;
    end;
  finally
    if FCode > 0 then
      OutValue := '�������Ȩ��Ϣ���������[' + IntToStr(FCode) + ']��';
    LJWT.Free;
  end;
  Result := True;
end;

function Router.DoExcute(Header, InValue: string; out OutValue: string): Boolean;
var
  Authorization, Method: string;
begin
  Result := False;
  //�ȴ�Get�����url·���л�ȡҵ����
  Method := Trim(GetUrlPath(InValue));
  //�����post�����������ͷ�л�ȡҵ����
  if Method = '' then
    Method := Trim(GetParamValue(Header, 'Method'));
  Authorization := Trim(GetParamValue(Header, 'Authorization'));
  //jwt��Ȩ
  if not CheckAuth(Authorization,Method,OutValue) then Exit;
  try
    if GetClass(Method) = nil then
    begin
      OutValue := 'ҵ�������';
      Exit;
    end;
    with TPubMod(FindClass(Method).NewInstance).Create do
    begin

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
      OutValue := '�쳣��' + e.message;
      Exit;
    end
  end;
  Result := True;
end;

end.

