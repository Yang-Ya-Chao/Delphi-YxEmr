unit uGetAuth;
//ҵ��Ԫ--GetAuth,��ȡ��Ȩ��

interface
  //���û�����
  uses uPubMod,System.Classes,Data.DB;


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
  //ע��JWT
  aJWTIn := TJWTHS256.Create(UTF8Encode(HS256Key), 0, [], [], 30);
  //��ȨJWT
  aJWTOut := TJWTHS256.Create(UTF8Encode(HS256Key), 1,
      [jrcIssuer, jrcSubject, jrcAudience, jrcIssuedAt,jrcJwtID],
      [], aTime);
  aJWTIn.Options := [joHeaderParse, joAllowUnexpectedClaims];
  aJWTIn.Verify(UTF8Encode(aCToken), aJWTContent);
  try
    if not (aJWTContent.result = jwtValid) then
    begin
      FCode := Ord(aJWTContent.result);
      //FError := '['+aCUser+']��Ȩ��֤ʧ��['+TRttiEnumerationType.GetName<TJWTResult>(aJWTContent.result)+'],';
      Exit;
    end;
    if aTime = 0 then
      FJson.Add('Authorization',aCToken,jdtString)
    else
      FJson.Add('Authorization',UTF8ToString(aJWTOut.Compute(['id:',Auth],
        'YxEmr Server', aJWTContent.reg[jrcSubject], aCUser) ),jdtString);
    FResultData := FJson.AsJson;
  finally
    if FCode > 0 then
      FError := '�����ע����Ϣ��'+TRttiEnumerationType.GetName<TJWTResultErr>(TJWTResultErr(FCode))+'��' ;
    aJWTOut.Free;
    aJWTIn.Free;
  end;
  Result := True;
end;

//ע������TAuth
initialization
  RegisterClassAlias(TAuth,'GetAuth');
  AMethodName.Add('GetAuth','��Ȩ');
finalization
  System.Classes.UnRegisterClass(TAuth)
end.

