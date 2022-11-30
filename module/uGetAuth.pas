unit uGetAuth;
//ҵ��Ԫ--GetAuth,��ȡ��Ȩ��

interface
  //���û�����
  uses uPubMod,System.Classes;


//����TPubMod������ҵ����-TAuth
type
  TAuth = class(TPubMod)
  private
  public
   //ʵ��ҵ�����������Ϊ�����ύ��body����
   function Execute(Invalue,Method:string):Boolean;override;
  end;
implementation
//����Ԫ��Ҫ���õ���
uses  System.SysUtils,SynCrypto,uConfig,QJson,System.Rtti;

{ TAuth }
//ʵ��ҵ��������FResultDataΪ����ֵ,FErrorΪ������Ϣ

(*
//
    Get�����ַ  http://localhost:8080/IWSYXHIS/GetAuth?AuthCode=386155828740231168

//����
  �ɹ���{
          "Result": {
            "Code": 1,
            "Msg": {
              "Authorization": "xxxxx.yyyyy.zzzzz"
            },
            "Error": ""
          }
        }

 ʧ�ܣ�{
          "Result": {
            "Code": 0,
            "Msg": {},
            "Error": "��ϸ������Ϣ"
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
    FError := 'δ��ѯ��['+Auth+']�������Ȩ��Ϣ��';
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
      //FError := '['+aCUser+']��Ȩ��֤ʧ��['+TRttiEnumerationType.GetName<TJWTResult>(aJWTContent.result)+'],';
      Exit;
    end;
    {if aJWTContent.result = jwtExpired then
    begin
      FError := '['+aCUser+']��Ȩ�ѵ��ڣ��޷��ṩ��������ϵ��˾����';
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
      FError := '�����ע����Ϣ���������['+IntToStr(FCode)+']��' ;
    aJWTOut.Free;
    aJWTIn.Free;
  end;
  Result := True;
end;

//ע������TAuth
initialization
  RegisterClassAlias(TAuth,'GetAuth');
finalization
  System.Classes.UnRegisterClass(TAuth)
end.

