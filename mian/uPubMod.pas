//���൥Ԫ--���е�ҵ����Ӧ�ü̳д˵�Ԫ
unit uPubMod;

interface

uses
  System.SysUtils, System.Classes,FireDAC.Comp.Client, DB,
  Qlog,System.Math,FireDAC.DApt,uConfig,Qjson,uObjPools,
  uQueryHelper,Generics.Collections,System.RegularExpressions,
  CnAES;

type
  TPubMod = class(TPersistent)
  private
    { Private declarations }
  public
    { Public declarations }
    FCode:Integer;          //���ش������
    FResultData :string;    //����ֵ
    FError :string;         //������Ϣ
    Rdata: TDateTime;       //���ݿ������ʱ��
    FRdata: string;         //���ݿ������ʱ��--yyyy-MM-dd HH:mm:ss
    FRegDate:String;        //����ʱ��
    FIID:Int64;             //ѩ��ID
    FJson:TQJson;           //ȫ��Qjson����
    FIJson:TQJson;          //ȫ��Qjson-Item����
    DATABASE: TFDConnection;//MSSQL���ݿ�����
    SQLiteDB: TFDConnection;//SQLite���ݿ�����
    QryCX:TFDQuery;
    QryExec:TFDQuery;
    SQLiteQry:TFDQuery;     //SQLiteQuery

//------------------------------------------------------------------------------
    /// <summary>�ⲿ����-����ֵ</summary>
    property AResultData: string read FResultData;
    /// <summary>�ⲿ����-������Ϣ</summary>
    property AERROR: string read FError;
    //��ʼ��--
    constructor Create;
    destructor Destroy; override;
    /// <summary>ִ��SQL���</summary>
    /// <param name="ExecFlag">True:ִ��,False:��ѯ</param>
    function ExeSql(AQuery: TFDQuery; CSQL: string; ExecFlag: Boolean): Boolean; overload;
    function ExeSql(AQuery: TFDQuery; CSQL: string): Integer; overload;
    /// <summary>ִ��SQL���-������</summary>
    function DoExeSQL(CSQL: string): Boolean;
    /// <summary>��ȡ���ݿ������ʱ��</summary>
    function GetRdata: Tdatetime;
    /// <summary>if True Result 1 else Result 0</summary>
    function BoolToStr(B: Boolean): string;
    /// <summary>iif����</summary>
    function iif(Expr: Boolean; vTrue, vFalse: string): string; overload;
    function iif(Expr: Boolean; vTrue, vFalse: integer): integer; overload;
    function iif(Expr: Boolean; vTrue, vFalse: TDateTime): TDateTime; overload;
    function iif(Expr: Boolean; vTrue, vFalse: Boolean): Boolean; overload;
    /// <summary>�Ƿ���������</summary>
    function InTransaction: Boolean;
    /// <summary>��ʼ����</summary>
    function StartTransaction(AutoRollBack: Boolean = True): IInterface;
    /// <summary>�ύ����</summary>
    procedure Commit;
    /// <summary>�ع�����</summary>
    procedure Rollback;
    ///  <summary>���ַ���ǰ���''</summary>
    function QuotedStr(const S: string): string;overload;
    ///<summary>ȡURL�����������ֵ</summary>
    //����:url := http://127.0.0.1/GetActivityinformation?language=Chinese&name=westwind
    //�÷�:
    //    sLang := GetParamValue(url,'language'); //��ȡlanguage
    //    sName := GetParamValue(url,'name');    //��ȡname
    function GetParamValue(UrlStr, ParamName: string;Pos:string='='): string;

    //ҵ��ʵ�ʴ����麯��
    function Execute(Invalue,Method:string):Boolean;virtual;abstract;
  end;


implementation


type
  TAutoRollback = class(TInterfacedObject)
  private
    uMod: TPubMod;
  public
    destructor Destroy; override;
  end;

destructor TAutoRollback.Destroy;
begin
  if uMod.InTransaction then
  begin
    //�ع�
    uMod.Rollback;
    //��־
    uMod.FError := '�Զ��ع�������:' + uMod.FError;
  end;
  inherited;
end;


{ TPubMod }


destructor TPubMod.Destroy;
begin
  FJson.Free;
  with QryPool do
  begin
    PutObj(QryExec);
    PutObj(QryCX);
    PutObj(SQLiteQry);
  end;
  DBPool.PutObj(DATABASE);
  SQLiteDBPool.PutObj(SQLiteDB);
  inherited;
end;

function TPubMod.QuotedStr(const S: string): string;
var
  I: Integer;
begin
  Result := S;
  for I := Result.Length - 1 downto 0 do
    if Result.Chars[I] = '''' then Result := Result.Insert(I, '''');
  Result := 'N''' + Result + '''';
  //if Ini.Tib then
  //Result := 'N'+Result;

end;

function TPubMod.DoExeSQL(CSQL: string): Boolean;
begin
  Result := False;
  if CSQL = '' then
  begin
    FError:= 'SQL����Ϊ�գ�';
    Exit;
  end;
  try
    try
      StartTransaction;
      if not ExeSql(QryExec, CSQL, True) then
        Exit;
      Commit;
    except
      on E: Exception do
      begin
        FError := 'SQLִ��ʧ��:' + E.Message;
        Exit;
      end;
    end;
  finally
    Rollback;
  end;
  Result := True;
end;

function TPubMod.GetRdata: TDateTime;
begin
  Result := Now;
  try
    var CSQL := 'SELECT GetDate() Rdata ';
    if not ExeSql(QryCX, CSQL, False) then
      Exit;
    Result := QryCX.T['Rdata'];
  finally
    if FError <> '' then
      raise Exception.Create(FError);
  end;
end;

function TPubMod.iif(Expr: Boolean; vTrue, vFalse: string): string;
begin
  if Expr then
    Result := vTrue
  else
    Result := vFalse;
end;

function TPubMod.iif(Expr: Boolean; vTrue, vFalse: integer): integer;
begin
  if Expr then
    Result := vTrue
  else
    Result := vFalse;
end;

function TPubMod.iif(Expr, vTrue, vFalse: Boolean): Boolean;
begin
  if Expr then
    Result := vTrue
  else
    Result := vFalse;
end;

function TPubMod.iif(Expr: Boolean; vTrue, vFalse: TDateTime): TDateTime;
begin
  if Expr then
    Result := vTrue
  else
    Result := vFalse;
end;

function TPubMod.BoolToStr(B: Boolean): string;
begin
  if B then
    Result := '1'
  else
    Result := '0';
end;

function TPubMod.ExeSql(AQuery: TFDQuery; CSQL: string): Integer;
begin
  Result := 0;
  if (DATABASE = nil) then
  begin
    FError := '�����ݿ����ӣ�';
    Exit;
  end;
  if CSQL = '' then
  begin
    FError := '��SQL��䣡';
    Exit;
  end;
  //if Ini.SQLLog then
  PostLog(llDebug,CSQL);
  AQuery.Connection := DATABASE;
  with AQuery do
  begin
    close;
    Sql.clear;
    Sql.Add(CSQL);
    try
      ExecSQL;
      Result := RowsAffected;
    except
      on E: Exception do
      begin
        Result := -1;
        close;
        FError := '������Ϣ:' + E.Message + ';SQL=' + CSQL;
        Exit;
      end;
    end;
  end;
end;

function TPubMod.ExeSql(AQuery: TFDQuery; CSQL: string; ExecFlag: Boolean): Boolean;
begin
  Result := False;
  if (DATABASE = nil) then
  begin
    FError := '�����ݿ����ӣ�';
    Exit;
  end;
  if CSQL = '' then
  begin
    FError := '��SQL��䣡';
    Exit;
  end;
  //if Ini.SQLLog then
  PostLog(llDebug,CSQL);
  AQuery.Connection := DATABASE;
  with AQuery do
  begin
    Close;
    Sql.Clear;
    Sql.Add(CSQL);
    try
      if ExecFlag then
        ExecSQL
      else
        Open;
    except
      on E: Exception do
      begin
        Close;
        FError := '������Ϣ:' + E.Message + #13#10 + ' SQL:' + CSQL;
        Exit;
      end;
    end;
  end;
  Result := True;
end;

function TPubMod.InTransaction: Boolean;
begin
  Result := False;
  if Assigned(DATABASE) then
  begin
    Result := Result or DATABASE.InTransaction;
  end;
end;

function TPubMod.StartTransaction(AutoRollBack: Boolean): IInterface;
var
  aAutoObject: TAutoRollback;
begin
  if Assigned(DATABASE) then
  begin
    Rollback;
    //���ñ�StartTransaction��������̽����󽫣��������ڣ������Զ��ع�����
    if AutoRollBack then
    begin
      aAutoObject := TAutoRollback.Create;
      aAutoObject.uMod := self;
      Result := aAutoObject as IInterface;
    end;
    //��ʼ����
    try
      DATABASE.StartTransaction;
      //Break;
    except
      on e:Exception do
      begin
        FError := '���ݿ�������ʧ�ܣ������ԣ�'+e.Message;
        raise Exception.Create(FError);
      end;
    end;
  end;
end;

procedure TPubMod.Commit;
begin
  if Assigned(DATABASE) then
    if InTransaction then
      DATABASE.Commit;
end;

constructor TPubMod.Create;
begin

  FCode := 0;
  SQLiteDB := SQLiteDBPool.GetObj;
  with QryPool do
  begin
    QryExec := GetObj;
    QryCX := GetObj;
    SQLiteQry := GetObj;
  end;
  SQLiteQry.Connection := SQLiteDB;
  FJson := TQjson.create;
  DATABASE := DBPool.GetObj;
  Rdata := GetRdata;
  FRdata := FormatDateTime('yyyy-MM-dd HH:nn:ss', Rdata);
end;

procedure TPubMod.Rollback;
begin
  if Assigned(DATABASE) then
    if InTransaction then
      DATABASE.Rollback;
end;

function TPubMod.GetParamValue(UrlStr, ParamName, Pos: string): string;
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

end.
