unit uGetAuth;
//业务单元--GetAuth,获取授权码

interface
  //引用基础类
  uses uPubMod,System.Classes;


//创建TPubMod的子类业务类-TAuth
type
  TAuth = class(TPubMod)
  private
  public
   //实际业务处理函数，入参为请求提交的body数据
   function Execute(Invalue,Method:string):Boolean;override;
  end;
implementation
//本单元需要引用的类
uses  System.SysUtils,SynCrypto,uConfig,QJson,System.Rtti;

{ TAuth }
//实际业务处理函数，FResultData为返回值,FError为错误信息

(*
//
    Get请求地址  http://localhost:8080/IWSYXHIS/GetAuth?AuthCode=386155828740231168

//出参
  成功：{
          "Result": {
            "Code": 1,
            "Msg": {
              "Authorization": "xxxxx.yyyyy.zzzzz"
            },
            "Error": ""
          }
        }

 失败：{
          "Result": {
            "Code": 0,
            "Msg": {},
            "Error": "详细错误信息"
          }
       }

*)
function TAuth.Execute(Invalue,Method:string): Boolean;
var
  aCToken,aCUser:string;
  aJWTIn,aJWTOut: TJWTAbstract;
  aJWTContent:TJWTContent;
  aTime:Integer;
  Auth:string;
begin
  Result := False;

  Auth := GetParamValue(InValue, 'AuthCode');
  if Auth = admin then
  begin
    FJson.Clear;
    FJson.Add('Authorization',admin,jdtString);
    FResultData := FJson.AsJson;
    Exit(True);
  end;
  var CSQL := 'Select UserName,TokenCode,TimeOut from TBYxEmrAuthManage Where IID='+Auth;
  SQLiteQry.Open(CSQL);
  if SQLiteQry.IsEmpty then
  begin
    FError := '未查询到['+Auth+']的相关授权信息！';
    Exit;
  end;
  aCToken := SQLiteQry.S['TokenCode'];
  aCUser := SQLiteQry.S['UserName'];
  aTime := SQLiteQry.I['TimeOut'];
  aJWTIn := TJWTHS256.Create(UTF8Encode(HS256Key), 0, [], [], 30);
  aJWTIn.Options := [joHeaderParse, joAllowUnexpectedClaims];
  aJWTIn.Verify(UTF8Encode(aCToken), aJWTContent);
  try
    if not (aJWTContent.result = jwtValid) then
    begin
      FCode := Ord(aJWTContent.result)+100;
      //FError := '['+aCUser+']授权验证失败['+TRttiEnumerationType.GetName<TJWTResult>(aJWTContent.result)+'],';
      Exit;
    end;
    {if aJWTContent.result = jwtExpired then
    begin
      FError := '['+aCUser+']授权已到期！无法提供服务！请联系公司处理！';
      Exit;
    end;  }
    aJWTOut := TJWTHS256.Create(UTF8Encode(HS256Key), 1,
      [jrcIssuer, jrcSubject, jrcAudience, jrcIssuedAt,jrcJwtID],
      [], aTime);
    FJson.Add('Authorization',UTF8Decode(aJWTOut.Compute(['id:',Auth],
        'YxEmr Server', aJWTContent.reg[jrcSubject], aCUser) ),jdtString);
    FResultData := FJson.AsJson;
  finally
    if FCode > 0 then
      FError := '错误的注册信息！错误代码['+IntToStr(FCode)+']！' ;
    aJWTOut.Free;
    aJWTIn.Free;
  end;
  Result := True;
end;

//注册子类TAuth
initialization
  RegisterClassAlias(TAuth,'GetAuth');
finalization
  System.Classes.UnRegisterClass(TAuth)
end.

