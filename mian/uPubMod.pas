//���൥Ԫ--���е�ҵ����Ӧ�ü̳д˵�Ԫ
unit uPubMod;

interface

uses
  System.SysUtils, System.StrUtils, System.Classes, FireDAC.Comp.Client, DB,
  Qlog, System.Math, FireDAC.DApt, uConfig, Qjson, uObjPools, FireDAC.Stan.Intf,
  uQueryHelper, Generics.Collections, System.RegularExpressions,
  FireDAC.Stan.StorageJSON, CnAES, uEncry, Redis.Commons, Redis.Client,
  redis.NetLib.INDY, Redis.Values, rtti;

type
  //������Ϊ��
  //����
  SADDNotEmpty = class(TCustomAttribute)
  end;
  //ɾ��
  SDELNotEmpty = class(TCustomAttribute)
  end;
  //�޸�
  SMODNotEmpty = class(TCustomAttribute)
  end;
  TWorker=record
    CBH:string;
    CGH:TDictionary<Integer,string>;
    CMZYS:string;
    CZYYS:string;
    CZYHS:string;
    CYJYS:string;
    IMZKS:string;
    CMZKS:string;
    IZYKS:string;
    CZYKS:string;
    IYJKS:string;
    CYJKS:string;
    IZYBQ:string;
    CZYBQ:string;
  end;
  TEvent = record
    CBRH: string;    //���˺�
    CCZLXBM: string; //��������
    CWSLX: string;    //��������
    CSJID: string;    //�¼�ID
    CCZYGH: string;   //����Ա����
    CNR: string;
    XNR: string;
  end;

  TPubMod = class(TPersistent)
  private
    { Private declarations }
    QryXTCS: TFDQuery;       //�Ӻ����ڲ�ʹ��-�Ͻ���ҵ������ʹ��
    QryYXCS: TFDQuery;       //��ȡҽԺ����
    FRedis: IRedisClient;
    FRedisStream: TStringStream;
  public
    { Public declarations }
    PValue:TValue;    //��μ�����
    PCZLX:Integer;    //0ɾ��1����2�޸�
    PWorker:TWorker;
    TBEvent: string;  //Event�¼�ȫ�ֱ����
    FEvent: TEvent;    //Event�¼�ȫ�ֱ���
    FCSQL: string;           //ȫ��SQL����
    FCode: Integer;          //���ش������
    FResultData: string;    //����ֵ
    FError: string;         //������Ϣ
    SYXHIS: string;         //�������ݿ�--YXHIS
    SYXYKT: string;         //�������ݿ�--YXYKT
    SDBLX: string;           //��������
    Rdata: TDateTime;       //���ݿ������ʱ��
    FRdata: string;         //���ݿ������ʱ��--yyyy-MM-dd HH:mm:ss
    FRegDate: string;        //����ʱ��
    FIID: Int64;             //ѩ��ID
    FJson: TQJson;           //ȫ��Qjson����
    FIJson: TQJson;          //ȫ��Qjson-Item����
    DATABASE: TFDConnection; //MSSQL���ݿ�����
    SQLiteDB: TFDConnection; //SQLite���ݿ�����
    //Queryʹ������ѭע�͹��򣬱���Query����ʹ��
    QryExec: TFDQuery;       //ִ��Insert��Update,Delete���
    QryPUB: TFDQuery;       //ҵ���л�ȡ������Ϣ���������κ��߼�����
    QryZD: TFDQuery;         //�ֵ��
    QryCX: TFDQuery;         //ҵ������Select����ʹ��
    Qry1: TFDQuery;          //ҵ������Selectѭ��ʹ��
    Qry2: TFDQuery;          //ҵ������Selectѭ��ʹ��
    Qry3: TFDQuery;          //ҵ������Selectѭ��ʹ��
    SQLiteQry: TFDQuery;     //SQLiteQuery
    FCBQ: string;            //סԺ���˲�������
//------------------------------------------------------------------------------
// TSQD
   ///ҵ��ʹ��ȫ�ֱ���

    FIBRLX: Integer;        //�������� 0�����1��סԺ 2�����
    FCmode: string;         //���뵥���� JC,JY  TY,TC
    Flag: Integer;          //�������� 1��0��
    FCYLH: string;          //���ſ�����NYLKH
    FCICID: string;         //����CICID
    FCBH: string;           //���뵥��
    FCBRH: string;          //����/סԺ��
    FCSFD: string;          //�����շѵ���/סԺ���˵���
    FCYZH: string;          //ҽ����
//==============================================================================
// �����
//==============================================================================
    TBXXWZX: string;      //���뵥��Ϣδִ�б�
    TBXMWZX: string;      //���뵥��Ŀδִ�б�
    TBMXWZX: string;      //���뵥��ϸδִ�б�
    TBXXWGD: string;      //���뵥��Ϣδ�鵵��
    TBXMWGD: string;      //���뵥��Ŀδ�鵵��
    TBMXWGD: string;      //���뵥��ϸδ�鵵��
    TBBGXX: string;       //���浥��Ϣ��
    TBBGMX: string;       //���浥��ϸ��
    TBBGBGMX: string;     //���浥�����ϸ��
    TBYZYJWZX: string;    //ҽ��ҽ����Ϣ��
    TBYZBYZYLBQ: string;  //ҽ����ҽ��ҽ�Ʋ�����
    TBSQDJQJL: string;    //���뵥��ǩ��¼
    TBZTMX: string;       //������ϸ
    TBZTHZ: string;       //���׻���
    TBSFXM: string;     //�շ���Ŀ
    TBCWTJ: string;     // ����ͳ��
    TBFYTJ: string;    //����ͳ��
//==============================================================================
// ȫ�ֱ���
//==============================================================================
    FMRZXKSBM: string;    //�շ�Ĭ��ִ�п��ұ���
    FMRZXKSMC: string;    //�շ�Ĭ��ִ�п�������
    FSQDZXKSCLFS: string; //���뵥ִ�п��Ҵ���ʽ
    FCZYGH: string;       //����Ա����
    FCZYMC: string;       //����Ա����
    FCZYBH: string;       //����Ա����
    FIKS: string;         //����Ա���ұ���
    FCKS: string;         //����Ա��������
    FIZXKS: string;       //����Աִ�п��ұ���
    FCZXKS: string;       //����Աִ�п�������
    FIKDKS: string;       //�������ұ���
    FCKDKS: string;       //������������
    FBBQYLYZ: Boolean;     //���뵥�Ƿ�д��ҽ��ҽ����
    FBSFKZ: Boolean;      //δ�շ��Ƿ���ִ�У�����
    FZXKSKZ: Integer;     //���ӷ�ִ�п��ҿ���0����δ��룬1��ȡ�������ڿ��ң�2������Ա��������
    FMZHZE, FMZHZF, FMJZJE, FMZHYE, FJZJE: Currency; //�˻��ܶ�˻�֧���������ܶ�˻����
    FMZHZEJM, FMZHZFJM, FMJZJEJM: string;  //�˻��ܶ���ܣ��˻�֧�����ܣ����˽�����
//------------------------------------------------------------------------------

    /// <summary>�ⲿ����-����ֵ</summary>
    property AResultData: string read FResultData;
    /// <summary>�ⲿ����-������Ϣ</summary>
    property AERROR: string read FError;
    //��ʼ��--
    constructor Create;
    destructor Destroy; override;
    /// <summary>��ȡ����</summary>
    function GetTBName(MBTableName: string; Invalue: string = ''; DefType:
      Integer = 7; InDate: TDateTime = 0): string;
    /// <summary>��ȡ�� BeginDate-endDate�����б�����ֵΪTstrings�������ֶ��ͷ�</summary>
    function GetNkTables(MBTableName: string; BeginDate, endDate: TDateTime): Tstrings;
    /// <summary>������ݿ�</summary>
    function DataBaseCheck(DbName: string): boolean;
    /// <summary>����</summary>
    function TableCheck(Tablename: string): boolean;
    /// <summary>��ȡTBUSERPARAM/TBYXXTCSI����</summary>
    function GetXTCS(CMC: string; DefValue: string = ''): string; overload;
    function GetXTCS(CMC: string; DefValue: Integer): Integer; overload;
    /// <summary>��ȡ��ˮ��</summary>
    function GetSysNumber2(CBH: string; Diff: Integer; TJ: string): string;
    /// <summary>ִ��SQL���</summary>
    /// <param name="ExecFlag">True:ִ��,False:��ѯ</param>
    /// <param name="UseCache">True: ʹ�û���,False:Ĭ�ϲ�ʹ��</param>
    function ExeSql(AQuery: TFDQuery; CSQL: string; ExecFlag: Boolean; UseCache:
      Boolean = False): Boolean; overload;
    function ExeSql(AQuery: TFDQuery; CSQL: string): Integer; overload;
    /// <summary>ִ��SQL���-������</summary>
    function DoExeSQL(CSQL: string): Boolean;
    /// <summary>����ַ���</summary>
    function Addstr(Ostr: string; Astr: string; Lnum: integer): string;
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
    function QuotedStr(const S: string): string; overload;
    ///<summary>ȡURL�����������ֵ</summary>
    //����:url := http://127.0.0.1/GetActivityinformation?language=Chinese&name=westwind
    //�÷�:
    //    sLang := GetParamValue(url,'language'); //��ȡlanguage
    //    sName := GetParamValue(url,'name');    //��ȡname
    function GetParamValue(UrlStr, ParamName: string; Pos: string = '='): string;
    /// <summary>���ڵ�</summary>
    function CheckNode(aJson: TQJson; Value: string): string;
    /// <summary>��ȡ����</summary>
    function GetBQ(CZYH: string): Boolean;
    /// <summary>��ⲡ�˹��ڳ�Ժ</summary>
    function CheckBRXX(IBRLX: Integer; CBRH: string): Boolean;
    /// <summary>�������뵥��ţ�JC,JY</summary>
    procedure GetMode(CSQDH: string; out BH, CLX: string);
    /// <summary>��ʼ�������</summary>
    procedure SetTBInfo;
    /// <summary>��ȡ���뵥����</summary>
    function CheckSQD(AQry: TFDQuery): Boolean;
    /// <summary>��ȡ�����</summary>
    function GetMZHYE: Boolean;
    /// <summary>������</summary>
    function EncryptString(Value, Key: AnsiString): string;
    /// <summary>��ȡ����Ա��Ϣ</summary>
    function GetCZY(CZY: string; sno: Integer = 40): boolean;
     /// <summary>��ȡ����Ա��Ϣ</summary>
    function GetCZYBySNO(CYSBM: string; SNO: integer = 18): boolean;
    /// <summary>��ȡjson�е�Arr���ݣ���,����</summary>
    /// <param name="BSQL">�Ƿ����""����sql�е�in</param>
    function JsonArrToStr(aJson: TQJson; Name: string; BSQL: Boolean = False): string;
    /// <summary>��ȡArr���ݣ���,����</summary>
    /// <param name="BSQL">�Ƿ����""����sql�е�in</param>
    function ArrToStr(Arr: Tarray<string>; BSQL: Boolean = False): string;
    /// <summary>string����������Ϊ��</summary>
    procedure StrRequired(InStr: Tarray<string>);
    /// <summary>�������EVENT�¼�����</summary>
    /// <param name="Event">˵���鿴TEvent�ṹ</param>
    function EventProcessB(Event: TEvent): string;
    /// <summary>��ʱ��ת����yyyy-mm-dd hh:nn:ss��ʽ���ַ���</summary>
    function GetString(time: TDateTime): string;
    /// <summary>ҵ����� 0:������1������</summary>
    function DoLock(CBH: string; ITYPE: Integer = 1): Boolean;
    /// <summary>���ñ���λ���Լ�ȡ�᷽ʽ</summary>
    function SetRes(A: Extended; dig, cs1: integer): Extended;
    /// <summary>�������Ƿ�Ϊ��</summary>
    /// <param name="Rec">��Ҫ���ļ�¼</param>
    /// <param name="ILX">0ɾ��1����2�޸�</param>
    procedure CheckEmpty(const Rec: TValue; ILX: Integer);
    /// <summary>д��־</summary>
    procedure Log(Msg: string);
    //ҵ��ʵ�ʴ����麯��
    function Execute(Invalue, Method: string): Boolean; virtual; abstract;
  end;

var
  FMethodName: TDictionary<string, string>;

function AMethodName: TDictionary<string, string>;

implementation

function AMethodName: TDictionary<string, string>;
begin
  if not Assigned(FMethodName) then
    FMethodName := TDictionary<string, string>.Create;
  Result := FMethodName;
end;

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
    PutObj(QryXTCS);
    PutObj(QryPUB);
    PutObj(QryExec);
    PutObj(QryYXCS);
    PutObj(QryCX);
    PutObj(Qry1);
    PutObj(Qry2);
    PutObj(Qry3);
    PutObj(QryZD);
    PutObj(SQLiteQry);
  end;
  DBPool.PutObj(DATABASE);
  SQLiteDBPool.PutObj(SQLiteDB);
  if Assigned(FRedis) then
    FRedis := nil;
  StreamPool.PutObj(FRedisStream);
  inherited;
end;

function TPubMod.DoLock(CBH: string; ITYPE: Integer): Boolean;
var
  CSQL: string;
  CurOutTime: Integer;
begin
  Result := False;
  if ITYPE = 0 then
  begin
    CSQL := 'DELETE FROM ' + SYXHIS + '.DBO.TBSQDLockInfo where CBH=' + QuotedStr(CBH);
    if not ExeSql(QryExec, CSQL, True) then
      Exit;
    Exit(True);
  end;
  CurOutTime := 0;
  while True do
  begin
    CSQL := 'SELECT CBH FROM ' + SYXHIS + '.DBO.TBSQDLockInfo where CBH=' +
      QuotedStr(CBH);
    if not ExeSql(QryPUB, CSQL, False) then
      Exit;
    if QryPUB.IsEmpty then
    begin
      CSQL := 'Insert into ' + SYXHIS + '.DBO.TBSQDLockInfo (CBH,DJLRQ) values('
        + Quotedstr(CBH) + ',' + Quotedstr(FRdata) + ')';
      if ExeSql(QryExec, CSQL, True) then
        Exit(True);
      FError := '';
    end;
  //����鵽�������ڴ�������뵥 �� һֱ�ȵ���ʱ
    if CurOutTime >= 30000 then //30����
    begin
      FError := '��ǰ���뵥���ڴ������Ժ����ԣ�';
      Exit;
    end;
    Sleep(100); //0.1����
    CurOutTime := CurOutTime + 100; //��ʱ���ó�30��
  end; //end while
end;

function TPubMod.QuotedStr(const S: string): string;
var
  I: Integer;
begin
  Result := S;
  for I := Result.Length - 1 downto 0 do
    if Result.Chars[I] = '''' then
      Result := Result.Insert(I, '''');
  Result := 'N''' + Result + '''';
  //if Ini.Tib then
  //Result := 'N'+Result;
end;

function TPubMod.DoExeSQL(CSQL: string): Boolean;
begin
  Result := False;
  if Trim(CSQL) = '' then
  begin
    FError := 'SQL����Ϊ�գ�';
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
    if not ExeSql(QryXTCS, CSQL, False) then
      Exit;
    Result := QryXTCS.T['Rdata'];
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
  PostLog(llDebug, CSQL);
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
        FError := '���ݿ������Ϣ:' + E.Message;
        Exit;
      end;
    end;
  end;
end;

function TPubMod.ExeSql(AQuery: TFDQuery; CSQL: string; ExecFlag, UseCache:
  Boolean): Boolean;
var
  RedisData: TRedisString;
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
  PostLog(llDebug, CSQL);
  AQuery.Connection := DATABASE;
  if UseCache and (FRedis <> nil) and (not ExecFlag) then
  begin
    RedisData := FRedis.GET(CSQL);
    if RedisData.HasValue then
    begin
      FRedisStream.Clear;
      FRedisStream.WriteString(RedisData);
      FRedisStream.Position := 0;
      AQuery.LoadFromStream(FRedisStream, sfJson);
      Exit(True);
    end;
  end;
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
        FError := '���ݿ������Ϣ:' + E.Message;
        Exit;
      end;
    end;
    if UseCache and (FRedis <> nil) and (not ExecFlag) then
    begin
      FRedisStream.Clear;
      AQuery.SaveToStream(FRedisStream, sfJSON);
      FRedisStream.Position := 0;
      FRedis.&SET(CSQL, FRedisStream.DataString, 5);
    end;
  end;
  Result := True;
end;

function TPubMod.GetXTCS(CMC: string; DefValue: Integer): Integer;
var
  CSQL: string;
begin
  Result := DefValue;
  try
    if not QryYXCS.Active then
    begin
      CSQL := 'select CCSMC CMC, Cvalue from ' + SYXHIS +
        '.DBO.TBYXXTCSI with (nolock) WHERE CSTATUS=''1'' ' + #13#10 +
        ' UNION ALL ' + #13#10 + 'select CNBMC CMC,Cvalue From ' + SYXHIS +
        '.DBO.TBUSERPARAM with (nolock) WHERE CSTATUS=''1'' ';
      if not ExeSql(QryYXCS, CSQL, FALSE, True) then
        Exit;
      if QryYXCS.IsEmpty then
        Exit;
    end;
    try
      if QryYXCS.Locate('CMC', CMC) then
        Result := StrToIntDef(QryYXCS.S['Cvalue'], 0);
    except
    end;
  finally
    if FError <> '' then
      raise Exception.Create('��ȡ��������' + FError);
  end;
end;

function TPubMod.GetXTCS(CMC, DefValue: string): string;
var
  CSQL: string;
begin
  Result := DefValue;
  try
    if not QryYXCS.Active then
    begin
      CSQL := 'select CCSMC CMC, Cvalue from ' + SYXHIS +
        '.DBO.TBYXXTCSI with (nolock) WHERE CSTATUS=''1'' ' + #13#10 +
        ' UNION ALL ' + #13#10 + 'select CNBMC CMC,Cvalue From ' + SYXHIS +
        '.DBO.TBUSERPARAM with (nolock) WHERE CSTATUS=''1'' ';
      if not ExeSql(QryYXCS, CSQL, FALSE, True) then
        Exit;
      if QryYXCS.IsEmpty then
        exit;
    end;
    if QryYXCS.Locate('CMC', CMC) then
      Result := QryYXCS.S['Cvalue'];
  finally
    if FError <> '' then
      raise Exception.Create('��ȡ��������' + FError);
  end;
end;

function TPubMod.GetNkTables(MBTableName: string; BeginDate, endDate: TDateTime):
  Tstrings;
var
  BEGINYEAR, ENDYEAR: INTEGER;
  i, j: integer;
  DbName: string; //���ݿ�����
  CSQL: string;
  TbName: string;
begin
  Result := ListPool.GetObj;
  try
    BEGINYEAR := strtoint(formatdatetime('YYYY', BeginDate));
    ENDYEAR := strtoint(formatdatetime('YYYY', endDate));
    CSQL := 'select CDATABASE from ' + SYXHIS +
      '.DBO.tbsystables with (nolock) where cmc=' + Quotedstr(MBTableName);
    if not ExeSql(QryXTCS, CSQL, False) then
      Exit;
    DbName := '';
    if QryXTCS.IsEmpty then
    begin
      FError := 'δ�ҵ���صı����ã�';
      Exit;
    end;
    DbName := QryXTCS.FieldByName('CDATABASE').AsString;
    for i := BEGINYEAR to ENDYEAR do
    begin
      for j := 1 to 12 do
      begin
        if (i.ToString + addstr(j.ToString, '0', 2) >= formatdatetime('YYYYMM',
          BeginDate)) and (i.ToString + addstr(j.ToString, '0', 2) <=
          formatdatetime('YYYYMM', endDate)) then
        begin
          if not DataBaseCheck(DbName + i.ToString) then
            Exit;
          TbName := DbName + i.ToString + '..' + MBTableName + i.ToString +
            addstr(j.ToString, '0', 2);

          if not TableCheck(TbName) then
            Exit;
          Result.Add(TbName);
        end;
      end;
    end;
  finally
    if FError <> '' then
      raise Exception.Create('��ȡ�����' + FError);
  end;
end;

function TPubMod.GetTBName(MBTableName, Invalue: string; DefType: Integer;
  InDate: TDateTime): string;
var
  DbName: string;
  CSQL: string;
  ITYPE: Integer;
  KeyValue: string;
  YY, MM: string;
  RedisData: TRedisString;
  Rediskey: string;
begin
  try
    Result := '';
    ITYPE := DefType;
    KeyValue := trim(Invalue);
    if InDate <> 0 then
      KeyValue := FormatDateTime('YYYYMM', InDate)
    else if ((KeyValue <> '') and (ITYPE in [1, 2, 3, 4, 5, 6, 8])) then
      KeyValue := FormatDateTime(('YYYY'), rdata).Substring(0, 2) + KeyValue;

    if (KeyValue = '') and (not (ITYPE in [0, 11])) then
    begin
      FError := 'GetTbName("' + MBTableName + '"): ����ؼ��ֵ�ֵΪ�գ�';
      Exit;
    end;
    Rediskey := MBTableName + ':' + KeyValue + ':' + ITYPE.ToString;
    if FRedis <> nil then
    begin
      RedisData := FRedis.GET(Rediskey);
      if RedisData.HasValue then
        Exit(RedisData);
    end;
    YY := KeyValue.Substring(0, 4);
    MM := KeyValue.Substring(4, 2);
    CSQL := 'SELECT CDATABASE,ITYPE FROM ' + SYXHIS +
      '.DBO.TBSYSTABLES WITH(NOLOCK) WHERE CMC=' + Quotedstr(MBTableName);
    if not ExeSql(QryXTCS, CSQL, FALSE) then
      Exit;
    DbName := '';
    if QryXTCS.IsEmpty then
    begin
      FError := 'δ�ҵ�[' + MBTableName + ']��صı����ã�';
      Exit;
    end;
    DbName := QryXTCS.FieldByName('CDATABASE').AsString;
    if DbName = '' then
      Exit;
    ITYPE := QryXTCS.FieldByName('ITYPE').asinteger;
    /////�ж����ݿ���Ϣ
    case ITYPE of
      0:
        begin ///��ͨ��
          if not DataBaseCheck(DbName) then
            EXIT;
          if RightStr(MBTableName, 1) = '+' then
            MBTableName := MBTableName.Substring(0, Length(MBTableName) - 1);
          if not TableCheck(DbName + '..' + MBTableName) then
            EXIT;
          if DbName.ToUpper <> SYXHIS then
            Result := DbName + '..' + MBTableName
          else
            Result := MBTableName;
        end;
      1:
        begin ///���
          if not DataBaseCheck(DbName) then
            EXIT;
          if TableCheck(DbName + '..' + MBTableName + YY) then
          begin
            if DbName.ToUpper <> SYXHIS then
              Result := DbName + '..' + MBTableName + YY
            else
              Result := MBTableName + YY;
          end;
        end;
      2:
        begin ////�±�
          if not DataBaseCheck(DbName) then
            EXIT;
          if TableCheck(DbName + '..' + MBTableName + YY + MM) then
          begin
            if DbName.ToUpper <> SYXHIS then
              Result := DbName + '..' + MBTableName + YY + MM
            else
              Result := MBTableName + YY + MM;
          end;
        end;
      3:
        begin ///�ձ�
        end;
      4:
        begin ///����±�
          if not DataBaseCheck(DbName + YY) then
            Exit;
          if TableCheck(DbName + YY + '..' + MBTableName + YY + MM) then
          begin
            Result := DbName + YY + '..' + MBTableName + YY + MM;
          end;
        end;
      5:
        begin ///������
          if not DataBaseCheck(DbName + YY) then
            Exit;
          if TableCheck(DbName + YY + '..' + MBTableName + YY) then
          begin
            Result := DbName + YY + '..' + MBTableName + YY;
          end;
        end;
      6:
        begin ///����ձ�
        end;
      7:
        begin ///������
          if not DataBaseCheck(DbName) then
            Exit;
          if TableCheck(DbName + '..' + MBTableName + '_0' + RightStr(KeyValue, 1)) then
          begin
            Result := DbName + '..' + MBTableName + '_0' + RightStr(KeyValue, 1);
          end;
        end;
      8:   //��������
        begin
          if not DataBaseCheck(DbName + YY) then
            Exit;
          if TableCheck(DbName + YY + '..' + MBTableName + '_0' + RightStr(KeyValue,
            1)) then
          begin
            Result := DbName + YY + '..' + MBTableName + '_0' + RightStr(KeyValue, 1);
          end;
         // ������(�����������)
        end;
      10:
        begin //������
          if not DataBaseCheck(DbName) then
            Exit;
          if TableCheck(DbName + '..' + MBTableName + KeyValue) then
            Result := DbName + '..' + MBTableName + KeyValue
          else if TableCheck(DbName + '..' + MBTableName + 'BQ' + KeyValue) then
            Result := DbName + '..' + MBTableName + 'BQ' + KeyValue;
        end;
    end;
  finally
    if (FRedis <> nil) and (Result <> '') then
      FRedis.&SET(Rediskey, Result, 10);
    if Result = '' then
      raise Exception.Create('��ȡ��������' + FError);
  end;
end;

function TPubMod.DataBaseCheck(DbName: string): boolean;
var
  CSQL: string;
begin
  Result := false;
  try
    CSQL := 'SELECT DBID NUM FROM MASTER..SYSDATABASES WHERE NAME=''' + DbName + '''';
    if not ExeSql(QryXTCS, CSQL, false) then
    begin
      FError := '��ѯ[' + DbName + ']��������飡' + FError;
      Exit;
    end;
    if QryXTCS.IsEmpty then
    begin
      FError := 'δ�ҵ�[' + DbName + ']��ؿ⣡';
      Exit;
    end;
  finally
  end;
  Result := True;
end;

function TPubMod.TableCheck(Tablename: string): boolean;
var
  FDataBaseName, FTableName: string;
  Index: integer;
  CSQL: string;
begin
  Result := false;
  try
    FDataBaseName := 'dbo.';
    FTableName := '';
    Index := pos('..', Tablename);
    if Index > 0 then
    begin
      FDataBaseName := Tablename.Substring(0, Index + 1);
      FTableName := Tablename.Substring(Index + 1, (Length(Tablename) - (Index + 1)));
    end
    else
    begin
      Index := pos('.dbo.', Tablename);
      if Index > 0 then
      begin
        FDataBaseName := Tablename.Substring(0, Index + 4);
        FTableName := Tablename.Substring(Index + 4, (Length(Tablename) - (Index + 1)));
      end
      else
        FTableName := Tablename;
    end;
    CSQL := 'SELECT ID FROM ' + FDataBaseName +
      'SYSOBJECTS WHERE ID = object_id(''' + FDataBaseName + FTableName + ''') ';
    if not ExeSql(QryXTCS, CSQL, False) then
      Exit;

    if QryXTCS.IsEmpty then
    begin
      FError := 'δ��ѯ��' + FDataBaseName + FTableName + '��ر����ݣ�';
      if (Pos('#', FTableName) > 0) then
      begin
        CSQL :=
          'select ID from tempdb.dbo.sysobjects where id = object_id(''tempdb.dbo.' +
          FTableName + ''') ';
        if not ExeSql(QryXTCS, CSQL, False) then
          Exit;
        Result := not QryXTCS.IsEmpty;
      end;
      Exit;
    end;
    Result := true;
  finally
  end;
end;

function TPubMod.Addstr(Ostr: string; Astr: string; Lnum: integer): string;
//�ַ������  ���� Addstr ( '1','0',4);  Result = '0001'
var
  i: integer;
begin
  Result := Ostr;
  for i := 1 to Lnum - Length(Ostr) do
  begin
    Result := Astr + Result;
  end;
end;

function TPubMod.GetString(time: TDateTime): string;
begin
  Result := FormatDateTime('yyyy-mm-dd hh:nn:ss', time);
end;

function TPubMod.GetSysNumber2(CBH: string; Diff: Integer; TJ: string): string;
var
  CSQL: string;
begin
  Result := '0';
  if Diff < 1 then
  begin
    raise Exception.Create('��ˮ�����ɴ��󣡴����������(С��1)��CBH=' + CBH);
  end;
  try
    CSQL := 'DECLARE @Value VARCHAR(200)' + #13#10 + 'SET @Value = ' + QuotedStr
      (CBH) + #13#10 + 'EXEC ' + SYXHIS + '.DBO.GetSysNumber2 ' + Diff.ToString
      + ',' + QuotedStr(TJ) + ',@Value OUT' + #13#10 + 'SELECT @Value Value ';
    if not ExeSql(QryXTCS, CSQL, False) then
      Exit;
    if QryXTCS.IsEmpty then
    begin
      FError := 'δ��ѯ��[' + CBH + ']��ص���ˮ����Ϣ��';
      exit;
    end;
    Result := QryXTCS.FieldByName('Value').AsString;
  finally
    if Result = '0' then
      raise Exception.Create('[' + CBH + ']��ˮ�����ɴ���');
  end;
end;

function TPubMod.InTransaction: Boolean;
begin
  Result := False;
  if Assigned(DATABASE) then
  begin
    Result := Result or DATABASE.InTransaction;
  end;
end;

function TPubMod.JsonArrToStr(aJson: TQJson; Name: string; BSQL: Boolean): string;
begin
  Result := '';
  if aJson.ItemByPath(Name) <> nil then
  begin
    for var IJson in aJson.ItemByPath(Name) do
    begin
      if Result <> '' then
        Result := Result + ',';
      Result := Result + iif(BSQL, QuotedStr(IJson.Value), IJson.Value);
    end;
  end;
end;

procedure TPubMod.Log(Msg: string);
begin
  PostLog(llError, Msg);
end;

function TPubMod.ArrToStr(Arr: Tarray<string>; BSQL: Boolean): string;
begin
  Result := '';
  for var str in Arr do
  begin
    if Result <> '' then
      Result := Result + ',';
    Result := Result + iif(BSQL, QuotedStr(str), str);
  end;
end;

procedure TPubMod.StrRequired(InStr: Tarray<string>);
begin
  for var str in InStr do
  begin
    if str.Length = 0 then
      raise Exception.Create('��������string������Ϊ�գ�');
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
      on e: Exception do
      begin
        FError := '���ݿ�������ʧ�ܣ������ԣ�' + e.Message;
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
    QryXTCS := GetObj;
    QryExec := GetObj;
    QryYXCS := GetObj;
    QryPUB := GetObj;
    QryCX := GetObj;
    Qry1 := GetObj;
    Qry2 := GetObj;
    Qry3 := GetObj;
    QryZD := GetObj;
    SQLiteQry := GetObj;
  end;
  SQLiteQry.Connection := SQLiteDB;
  FJson := TQjson.create;
  if Ini.UseCache then
    FRedis := NewRedisClient;
  FRedisStream := StreamPool.GetObj;
  DATABASE := DBPool.GetObj;
  Rdata := GetRdata;
  FRdata := GetString(Rdata);
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
  try
    Match := Reg.Match(UrlStr, '(?<=' + ParamName + Pos + ')[^&]*');
    if Match.Success then
    begin
      Result := Match.Value;
    end;
  finally
    if (Result <> '') and (Ini.Aes) then
      Result := AESDecode(Result)
  end;
end;

procedure TPubMod.CheckEmpty(const Rec: TValue; ILX: Integer);
var
  AContext: TRttiContext;
  AField: TRttiField;
  ARttiType: TRttiType;
  Attr: TCustomAttribute;
  err: string;
begin
  err := '';
  try
    AContext := TRttiContext.Create;
    ARttiType := AContext.GetType(Rec.TypeInfo);
    for AField in ARttiType.GetFields do
    begin
      case ILX of
    //ɾ��
          0:
          Attr := AField.GetAttribute<SDELNotEmpty>;
    //����
          1:
          Attr := AField.GetAttribute<SADDNotEmpty>;

    //�޸�
          2:
          Attr := AField.GetAttribute<SMODNotEmpty>;
      end;
      if Attr <> nil then
      begin
        if AField.GetValue(Rec.GetReferenceToRawData).IsEmpty then
          err := AField.Name
        else if AField.FieldType.name = 'string' then
        begin
          if AField.GetValue(Rec.GetReferenceToRawData).AsString = '' then
            err := AField.Name;
        end
        else if AField.FieldType.name = 'Integer' then
        begin
          if AField.GetValue(Rec.GetReferenceToRawData).AsInteger = 0 then
            err := AField.Name;
        end
        else if AField.FieldType.name = 'Currency' then
        begin
          if AField.GetValue(Rec.GetReferenceToRawData).AsCurrency = 0 then
            err := AField.Name;
        end;
      end;
    end;
  finally
    if err <> '' then
      raise Exception.Create(err + 'Ϊ�����ֶΣ�');
  end;
end;

function TPubMod.CheckNode(aJson: TQJson; Value: string): string;
begin
  Result := aJson.S[Value];
  if Result = '' then
    raise Exception.Create('δ����' + Value + '�ڵ㣡');
end;

function TPubMod.CheckBRXX(IBRLX: Integer; CBRH: string): Boolean;
var
  CSQL, TBName: string;
  IYXTS: Integer;
begin
  Result := False;
  if IBRLX = 0 then
  begin
    if GetXTCS('IMZGHMXMID', 0) = 1 then
      TBName := SYXHIS + '.DBO.TBMZGHMX_MID'
    else
      TBName := GetTbName('TBMZGHMX', CBRH, 4);
    CSQL := 'Select BTH,IYXTS,DGH,DYY,BLG from ' + TBName + ' Where CMZH=' +
      QuotedStr(CBRH);
    if not ExeSql(QryCX, CSQL, False, True) then
      Exit;
    if QryCX.IsEmpty then
    begin
      FError := 'δ��ѯ�������ﲡ�˵ĹҺ���Ϣ��';
      Exit;
    end;
    if QryCX.B['BTH'] then
    begin
      FError := '�����ﲡ�����˺ţ�';
      Exit;
    end;
    if GetXTCS('IYJJKMZYXQXZ', 0) = 0 then Exit(True);
    //���۲�����Ч��
    if QryCX.B['BLG'] then
      Exit(True);
    IYXTS := GetXTCS('IMZSFXZYXTS', 0);
    if IYXTS = 0 then
      IYXTS := QryCX.I['IYXTS'];
    if IYXTS = 0 then
      IYXTS := 7;
    if (QryCX.T['DGH'] + IYXTS < Rdata) and (QryCX.T['DYY'] + IYXTS < Rdata) then
    begin
      FError := '�����ﲡ���ѹ��ڣ��Һ�ʱ��:[' + QryCX.S['DGH'] + '],ԤԼʱ��:[' + QryCX.S['DYY']
        + '],������:[' + IYXTS.ToString + '],��ǰʱ��:[' + FRdata + ']';
      Exit;
    end;
  end
  else
  begin
    if not GetBQ(CBRH) then
      Exit;
    CSQL := 'SELECT TOP 1 BDD FROM ' + SYXHIS + '.DBO.TBZYBRBQ' + FCBQ +
      ' WITH(NOLOCK) WHERE CZYH=' + QuotedStr(CBRH);
    if not ExeSql(QryCX, CSQL, False, True) then
      Exit;
    if QryCX.IsEmpty then
    begin
      FError := 'δ��ѯ����סԺ���˵���Ϣ��';
      Exit;
    end;
    if QryCX.B['BDD'] then
    begin
      FError := '�����Ѿ���Ժ��';
      Exit;
    end;
  end;
  Result := True;
end;

function TPubMod.GetBQ(CZYH: string): Boolean;
var
  CSQL: string;
begin
  Result := False;
  if FCBQ = '' then
  begin
    CSQL := 'SELECT TOP 1 CPOSTFIX FROM ' + GetTbName('TBZYBRINDEX+', '', 0) +
      ' WHERE CZYH=' + Quotedstr(CZYH);
    if not ExeSql(QryXTCS, CSQL, False, True) then
      Exit;
    if QryXTCS.IsEmpty then
    begin
      FError := 'δ��ѯ�����˲�����Ϣ��';
      Exit;
    end;
    FCBQ := QryXTCS.S['CPOSTFIX'].Replace('BQ', '');
  end;
  Result := True;
end;

procedure TPubMod.GetMode(CSQDH: string; out BH, CLX: string);
var
  CBH, CJCJY, PACSLX: string;
begin
  CJCJY := 'JY';
  CBH := CSQDH;
  PACSLX := UpperCase((GetXTCS('PACS_FQLX', '')));
  var Len := Length(PACSLX);
  if UpperCase(LeftStr(CSQDH, 2)) = 'JC' then
  begin
    System.Delete(CSQDH, 1, 2);
    CBH := CSQDH;
    CJCJY := 'JC';
  end
  else if Pos(UpperCase(LeftStr(CSQDH, Len)), PACSLX) > 0 then
  begin
    System.Delete(CSQDH, 1, Len);
    CBH := CSQDH;
    CJCJY := 'JC';
  end;
  if UpperCase(LeftStr(CSQDH, 2)) = 'JY' then
  begin
    System.Delete(CSQDH, 1, 2);
    CBH := CSQDH;
    CJCJY := 'JY';
  end;
  BH := CBH;
  CLX := CJCJY;
end;

procedure TPubMod.SetTBInfo;
begin
  TBZTMX := SYXHIS + '.DBO.VTBZDZTMX_M';
  TBZTHZ := SYXHIS + '.DBO.VTBZDZTHZ_M';
  TBSFXM := SYXHIS + '.DBO.TBZDSFXMMZ';
  TBCWTJ := SYXHIS + '.DBO.TBZDCWTJMZ';
  TBFYTJ := SYXHIS + '.DBO.TBZDFYTJMZ';
  if FIBRLX = 0 then    //����
  begin
    if FCmode = 'JC' then
    begin
      TBXXWZX := GetTbName('TBMZJCSQDXXWZX', FCBRH);
      TBXXWGD := GetTbName('TBMZJCSQDXX', FCBRH, 4);
    end
    else if FCmode = 'JY' then
    begin
      TBXXWZX := GetTbName('TBMZJYSQDXXWZX', FCBRH);
      TBXXWGD := GetTbName('TBMZJYSQDXX', FCBRH, 4);
    end;
  end
  else if FIBRLX = 1 then   //סԺ
  begin
    if FCmode = 'JC' then
      TBXXWZX := GetTbName('TBZYJCSQDXXWZX', FCBRH)
    else if FCmode = 'JY' then
      TBXXWZX := GetTbName('TBZYJYSQDXXWZX', FCBRH);
    TBXXWGD := TBXXWZX.Replace('WZX', 'WGD');
    if FBBQYLYZ then
      TBYZYJWZX := GetTbName('TBZYYZYJXXWZX', FCBRH);
    try
      if not GetBQ(FCBRH) then
        Exit;
      TBYZBYZYLBQ := GetTbName('TBYZBYZYLBQ', FCBQ);
    finally
      if FError <> '' then
        raise Exception.Create(FError);
    end;

    TBZTMX := SYXHIS + '.DBO.VTBZDZTMX_Z';
    TBZTHZ := SYXHIS + '.DBO.VTBZDZTHZ_Z';
    TBSFXM := SYXHIS + '.DBO.TBZDSFXM';
    TBCWTJ := SYXHIS + '.DBO.TBZDCWTJ';
    TBFYTJ := SYXHIS + '.DBO.TBZDFYTJ';
  end
  else if FIBRLX = 2 then   //���
  begin
    //TBXXWZX := 'JKJC..'+ GetTbName('TBJKJCYJWZX', '');
  end;
  TBMXWZX := TBXXWZX.Replace('XX', 'MX');
  TBMXWGD := TBXXWGD.Replace('XX', 'MX');
  TBXMWZX := TBXXWZX.Replace('XX', 'XM');
  TBXMWGD := TBXXWGD.Replace('XX', 'XM');
  TBBGXX := TBXXWGD.Replace('SQD', 'BGD');
  TBBGMX := TBMXWGD.Replace('SQD', 'BGD');
  TBBGBGMX := TBMXWGD.Replace('SQD', 'BGDBG');
end;

function TPubMod.CheckSQD(AQry: TFDQuery): Boolean;
var
  CSQL: string;
  CSSTR, CWSTR: string;
begin
  Result := False;
  CSSTR := 'select CBH,CBRH,CBRID,CBRXM,CBRXB,CBRNL,DSJSJ,CJLRBM,CJLRMC,CYZXXM,CBGDBH,'
    + 'CMBBH,ISFZT,IZXZT,IBGZT,CSQZXDWBM,CSQZXDWMC,BQZ,DQZ,XMLNR  ';
  CWSTR := ' WITH(NOLOCK) WHERE CBH=' + quotedstr(FCBH) + ' and CBRH=' + quotedstr(FCBRH);
  CSQL := CSSTR + ',''false'' WGD FROM ' + TBXXWZX + CWSTR;
  CSQL := CSQL + #13#10 + 'UNION ALL' + #13#10 + CSSTR + ',''true'' WGD FROM ' +
    TBXXWGD + CWSTR;
  if not ExeSql(AQry, CSQL, False) then
    Exit;
  if AQry.IsEmpty then
  begin
    FError := 'δ�ҵ����뵥��Ϣ��';
    Exit;
  end;
  Result := True;
end;

function TPubMod.GetMZHYE: Boolean;
var
  CSQL: string;
begin
  Result := False;
  try
    CSQL := 'select MZHZE,MZHZF,MJZJE,CMJEJM,CMZHZFJM,CMJZJM,IICZT from ' +
      SYXHIS + '.DBO.TBICXX  where CNYLH=' + QuotedStr(FCICID) + ' or CICID=' +
      QuotedStr(FCICID);
    if not ExeSql(QryXTCS, CSQL, False) then
      Exit;
    if QryXTCS.IsEmpty then
    begin
      FError := 'δ��ѯ�����һ��ͨ������ݣ�';
      Exit;
    end;
    //��Ҫ������ȡһ��,Ϊ��Ч�ʴ˴���ʹ��ReadOnlyOne��ȡ --����With(nolock)
    with QryXTCS do
    begin
      case I['IICZT'] of
        2:
          FError := '�ÿ��ѹ�ʧ�����ܽ����κβ�����';
        3:
          FError := '�ÿ���ע�������ܽ����κβ�����';
        4, 5:
          FError := '�ÿ����˿������ܽ����κβ�����';
      end;
      if FError <> '' then
        Exit;
      FMZHZE := Fields[0].AsCurrency;
      FMZHZF := Fields[1].AsCurrency;
      FMJZJE := Fields[2].AsCurrency;
      FMZHYE := FMZHZE - FMZHZF - FMJZJE;
      FMZHZEJM := S['CMJEJM'];
      FMZHZFJM := S['CMZHZFJM'];
      FMJZJEJM := S['CMJZJM'];
      if EncryptString(CurrToStrF(FMZHZE, ffFixed, 3), 'YX' + FCICID) <> FMZHZEJM then
      begin
        FError := '����[' + FCICID + ']�ܽ��������֤��ʹ�ã�';
        Exit;
      end;
      if EncryptString(CurrToStrF(FMZHZF, ffFixed, 3), 'YX' + FCICID) <> FMZHZFJM then
      begin
        FError := '����[' + FCICID + ']֧�����������֤��ʹ�ã�';
        Exit;
      end;

      if EncryptString(CurrToStrF(FMJZJE, ffFixed, 3), 'YX' + FCICID) <>
        FMJZJEJM then //4λС��
      begin
        if EncryptString(CurrToStrF(FMJZJE, ffFixed, 2), 'YX' + FCICID) <>
          FMJZJEJM then //��λС��  ��ǰ�汾��������λС�����ܴ���
        begin
          FError := '����[' + FCICID + ']���˽��������֤��ʹ�ã�';
          Exit;
        end;
      end;
    end;
  finally
  end;
  Result := True;
end;

function TPubMod.EncryptString(Value: AnsiString; Key: AnsiString): string;

  function StrToHex(Value: AnsiString): string;
  var
    I: Integer;
  begin
    Result := '';
    for I := 1 to Length(Value) do
      Result := Result + IntToHex(Ord(Value[I]), 2);
  end;

var
  SS, DS: TStringStream;
  Size: Int64;
  AESKey128: TAESKey128;
begin
  Result := '';
  SS := TStringStream.Create(Value);
  DS := TStringStream.Create('');
  try
    Size := SS.Size;
    DS.WriteBuffer(Size, SizeOf(Size));
      {  --  128 λ�ܳ���󳤶�Ϊ 16 ���ַ� --  }
    FillChar(AESKey128, SizeOf(AESKey128), 0);
    Move(PAnsiChar(Key)^, AESKey128, Min(SizeOf(AESKey128), Length(Key)));
    EncryptAESStreamECB(SS, 0, AESKey128, DS);
    Result := StrToHex(Copy(AnsiString(DS.Bytes), 1, DS.Size));
  finally
    FreeAndNil(SS);
    FreeAndNil(DS);
  end;
end;

function TPubMod.GetCZY(CZY: string; sno: Integer): Boolean;
var
  CSQL, CKSSQl: string;
  TBYSName: string;
  CBM: string;
begin
  Result := False;
  FCZYGH := '';
  FCZYMC := '';
  case sno of
    40:  //ҽ��ҽ��
      begin
        TBYSName := SYXHIS + '.DBO.TBZDYJYS';
        CBM := 'IBM';
      end;
    54: //���ﻤʿ
      begin
        TBYSName := SYXHIS + '.DBO.TBZDJZHS';
//      CKSSQl := 'SELECT CBM,CMC FROM ' + SYXHIS +
//        '.DBO.tbzdzxks WITH(NOLOCK) WHERE IMZKSBM=' +
//        '(SELECT top 1 IKSBM FROM ' + SYXHIS +
//        '.DBO.TBZDJZHS with(nolock) WHERE CCZYGH=' + Quotedstr(FCZYBH) + ')';
        CBM := 'CBM';
      end;
    18:  //����ҽ��
      begin
        TBYSName := SYXHIS + '.DBO.TBZDMZYS';
        CBM := 'IBM';
      end;
  end;
  try
    //if StrToIntDef(CZY,0) = 0 then
    CSQL := 'SELECT G.CGH,G.CMC,S.CBH FROM ' + SYXHIS + '.DBO.TBSYSCZY S WITH(NOLOCK)'
      + ' INNER JOIN ' + SYXHIS + '.DBO.TBCZY G WITH(NOLOCK) ON S.CUID=G.CSRM AND G.CCXBH='
      + Quotedstr(sno.ToString) + ' AND S.CBH=' + Quotedstr(CZY);
    if StrToIntDef(CZY, 0) <> 0 then
      CSQL := CSQL + #13#10 + 'union' + #13#10 + 'SELECT G.CGH,G.CMC,S.CBH FROM '
        + SYXHIS + '.DBO.TBSYSCZY S WITH(NOLOCK) INNER JOIN ' + SYXHIS + '.DBO.TBCZY G WITH(NOLOCK) ON S.CUID=G.CSRM AND G.CCXBH='
        + Quotedstr(sno.ToString) + ' INNER JOIN ' + TBYSName + ' Y WITH(NOLOCK)'
        + ' ON S.CBH=Y.CCZYGH AND Y.' + CBM + '=' + QuotedStr(CZY);
    if not ExeSql(QryXTCS, CSQL, false, True) then
      Exit;
    if QryXTCS.IsEmpty then
    begin
      FError := 'δ�ҵ���Ӧ�Ĳ���Ա���������Ա�Ƿ����' + sno.ToString + 'ϵͳ����ʹ��Ȩ�ޣ�';
      Exit;
    end;
    FCZYGH := QryXTCS.S['CGH'];
    FCZYMC := QryXTCS.S['CMC'];
    FCZYBH := QryXTCS.S['CBH'];
    if FMRZXKSBM <> '' then
      CSQL := 'SELECT CBM,CMC FROM ' + SYXHIS +
        '.DBO.tbzdzxks WITH(NOLOCK) WHERE CBM=' + Quotedstr(FMRZXKSBM)
    else
      CSQL := 'SELECT CBM,CMC FROM ' + SYXHIS +
        '.DBO.tbzdzxks WITH(NOLOCK) WHERE CYJKSBM=' +
        '(SELECT top 1 CKSBM FROM ' + SYXHIS +
        '.DBO.TBZDYJYS with(nolock) WHERE CCZYGH=' + Quotedstr(FCZYBH) + ')';
    if sno in [40] then
    begin
      if not ExeSql(QryXTCS, CSQL, false, True) then
        Exit;
      if QryXTCS.IsEmpty then
      begin
        FError := 'δ�ҵ���Ӧ��ִ�п��ң��������Ա�Ƿ����' + sno.ToString + 'ϵͳ����ʹ��Ȩ�ޣ�';
        Exit;
      end;
      FIZXKS := QryXTCS.S['CBM'];
      FCZXKS := QryXTCS.S['CMC'];
    end;
  finally
  end;
  Result := True;
end;

function TPubMod.GetCZYBySNO(CYSBM: string; SNO: integer): boolean;
Var
  CSQL,TBYSName : String;
begin
  Result := false;
  case SNO of
    18:TBYSName :=  SYXHIS + '.DBO.'+ 'TBZDMZYS';
    21:TBYSName :=  SYXHIS + '.DBO.'+ 'TBZDZYYS';
  end;
  if StrToIntDef(CYSBM,0) <> 0 then
    CSQL := '	SELECT TOP 1 d.cgh,b.IBM,b.CMC,b.CCZYGH FROM '
        + TBYSName +' b with(nolock), '
        + SYXHIS + '.DBO.TBSYSCZY c with(nolock),'
        + SYXHIS + '.DBO.TBCZY d with(nolock) where '
        + 'b.CCZYGH=c.cbh and c.cuid=d.CSRM and b.BENABLE=1 and c.BENABLE=1 and d.BENABLE=1 and d.CCXBH = '
        + QuotedStr(SNO.ToString) +' and (b.ibm=' + CYSBM + ' OR c.cuid=' + QuotedStr(CYSBM) + ')'
  else
    CSQL := '	SELECT TOP 1 d.cgh,b.IBM,b.CMC,b.CCZYGH FROM '
        + TBYSName +' b with(nolock), '
        + SYXHIS + '.DBO.TBSYSCZY c with(nolock),'
        + SYXHIS + '.DBO.TBCZY d with(nolock) where '
        + 'b.CCZYGH=c.cbh and c.cuid=d.CSRM and b.BENABLE=1 and c.BENABLE=1 and d.BENABLE=1 and d.CCXBH = '
        + QuotedStr(SNO.ToString) +' and ( c.cuid=' + QuotedStr(CYSBM) + ')' ;
  if not ExeSql(Qrycx, CSQL, False) then
    Exit;
  if Qrycx.IsEmpty then
  begin
    FError := '��ȡ����Ա��' + CYSBM + '������ʧ�ܣ�';
    Exit;
  end;
  Result := true;
end;

function TPubMod.EventProcessB(Event: TEvent): string;
var
  CSQL: string;
begin
  Result := '';
  if GetXTCS('YJJKBEvent', '0') = '0' then
    Exit;
  try
//    case IBRLX of
//      0:Tablename := GetTBName('TBEVENTMZ',CBRH,8);
//      1:Tablename := GetTBName('TBEVENTZY',CBRH,8);
//    end;
    with Event do

    begin
      CSQL := CSQL + #13#10 + 'insert into ' + TBEvent
        + '(CWSLX,CCZLXBM,CSJID,CBRH,CCZYGH,DJSJSJ,DCZSJ,CNR,CIP)'
        + ' Values(' + QuotedStr(CWSLX) + ',' + QuotedStr(CCZLXBM) + ','
        + QuotedStr(CSJID) + ',' + QuotedStr(CBRH) + ','
        + QuotedStr(CCZYGH) + ',' + QuotedStr(FRdata) + ','
        + QuotedStr(FRdata) + ',' + QuotedStr(CNR) + ',' + QuotedStr(Ini.IP) + ')';
    end;
  finally
    if FError <> '' then
      raise Exception.Create('Event�¼��������' + FError);
  end;
  Result := CSQL;
end;

function TPubMod.SetRes(A: Extended; dig: integer; cs1: integer): Extended;
var
  i: integer;
  Temp: Extended;
begin
  Temp := 0;
  Result := A;

    // ����С��
  case cs1 of
      // ���ݱ���ģʽ����С��
    0:
      begin
        for i := 1 to dig do
          Result := Result * 10;
        if abs(frac(Result)) + 0.00000001 >= 0.5 then
            // ����ת��Ϊ�ַ��������ж�,��Ϊ�������жϴ��ھ���ƫ��
        begin
          if result > 0 then
            Result := Result + 0.1
                // ע��Round������0.5����Ľ��Ϊ�㣬����Ҫ��0.1
          else
            Result := Result - 0.1
                // ע��Round������0.5����Ľ��Ϊ�㣬����Ҫ��0.1
        end;
        Result := Round(result); // �������� rmRound
        if (Result = 0) and (A > 0) then
          Result := 1; //����ֻ�������0��
        for i := 1 to dig do
          Result := Result / 10;
      end;
    1:
      begin
        for i := 1 to dig do
          Result := Result * 10;
        Result := result + 0.00000001; //���������⣬��1.14*100,trunc��Ϊ113
        Result := trunc(Result); // ȡ�� rmMin
        for i := 1 to dig do
          Result := Result / 10;
      end;
    2:
      begin
        for i := 1 to dig do
          Result := Result * 10;
        if result + 0.00000001 > 0 then
        begin
          if Result > trunc(Result) + 0.000000009 then
            Result := trunc(Result) + 1
          else
            Result := trunc(Result); // ȡ����һ rmMax
        end
        else
        begin
          if Result < trunc(Result) - 0.000000009 then
            Result := trunc(Result) - 1
          else
            Result := trunc(Result); // ȡ����һ rmMax
        end;
        for i := 1 to dig do
          Result := Result / 10;
      end;
    3:
      begin ////       ��������
        for i := 1 to dig - 1 do
          Result := Result * 10;
        Temp := Result - trunc(result);
        if result > 0 then
        begin
          if Temp > 0.7 + 0.00000001 then
          begin
            result := trunc(result) + 1;
          end
          else if Temp < 0.3 then
          begin
            result := trunc(result);
          end
          else
          begin
            result := trunc(result) + 0.5;
          end;
        end
        else
        begin
          if Temp + 0.00000001 < -0.7 then
          begin
            result := trunc(result) - 1;
          end
          else if Temp + 0.00000001 > -0.3 then
          begin
            result := trunc(result);
          end
          else
          begin
            result := trunc(result) - 0.5;
          end;
        end;
        for i := 1 to dig - 1 do
          Result := Result / 10;
      end;
    4:
      begin
        for i := 1 to dig - 1 do
          Result := Result * 10;
        Temp := Result - trunc(result);
        if result + 0.00000001 > 0 then
        begin
          if Temp + 0.00000001 >= 0.75 then
          begin
            result := trunc(result) + 1;
          end
          else if Temp < 0.25 then
          begin
            result := trunc(result);
          end
          else
          begin
            result := trunc(result) + 0.5;
          end;
        end
        else
        begin
          if Temp + 0.00000001 <= -0.75 then
          begin
            result := trunc(result) - 1;
          end
          else if Temp > -0.25 then
          begin
            result := trunc(result);
          end
          else
          begin
            result := trunc(result) - 0.5;
          end;
        end;

        for i := 1 to dig - 1 do
          Result := Result / 10;
      end;
    5:
      begin //1.2.3.4�ǽ���5�� ;6.7.8.9�ǽ���1Ԫ
        for i := 1 to dig - 1 do
          Result := Result * 10;
        Temp := Result - trunc(result);
        if result > 0 then
        begin
          if Temp > 0.5 then
          begin
            result := trunc(result) + 1;
          end
          else if (Temp < 0.5) and (Temp > 0) then
          begin
            result := trunc(result) + 0.5;
          end
          else
          begin
            result := trunc(result * 10) / 10;
          end;
        end
        else
        begin
          if Temp < -0.5 then
          begin
            result := trunc(result) - 1;
          end
          else if (Temp > -0.5) and (Temp < 0) then
          begin
            result := trunc(result) - 0.5;
          end
          else
          begin
            result := trunc(result * 10) / 10;
          end;
        end;

        for i := 1 to dig - 1 do
          Result := Result / 10;
      end;
    6: // ��������
      begin
        for i := 1 to dig do
          Result := Result * 10;
        if abs(frac(Result)) + 0.00000001 >= 0.4 then
            // ����ת��Ϊ�ַ��������ж�,��Ϊ�������жϴ��ھ���ƫ��
        begin
          if result > 0 then
            Result := Result + 0.2
                // ע��Round������0.4����Ľ��Ϊ�㣬����Ҫ��0.1
          else
            Result := Result - 0.2
                // ע��Round������0.4����Ľ��Ϊ�㣬����Ҫ��0.1
        end;
        Result := Round(result); //�������� rmRound
        for i := 1 to dig do
          Result := Result / 10;
      end;
  end;
  //ԭ�����ݲ�Ϊ0������������0��Ҫ������0.0001��Ҫ����2λС����Ӧ�ñ��0.01
  if (A <> 0) and (Result = 0) then
  begin
    Result := 1;
    for i := 1 to dig do
      Result := Result / 10;
  end;
end;

initialization

finalization
  if Assigned(FMethodName) then
    FMethodName.Free;

end.

