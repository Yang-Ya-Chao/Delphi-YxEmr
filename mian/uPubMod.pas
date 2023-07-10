//基类单元--所有的业务类应该继承此单元
unit uPubMod;

interface

uses
  System.SysUtils, System.StrUtils, System.Classes, FireDAC.Comp.Client, DB,
  Qlog, System.Math, FireDAC.DApt, uConfig, Qjson, uObjPools, FireDAC.Stan.Intf,
  uQueryHelper, Generics.Collections, System.RegularExpressions,
  FireDAC.Stan.StorageJSON, CnAES, uEncry, Redis.Commons, Redis.Client,
  redis.NetLib.INDY, Redis.Values, rtti;

type
  //不允许为空
  //新增
  SADDNotEmpty = class(TCustomAttribute)
  end;
  //删除
  SDELNotEmpty = class(TCustomAttribute)
  end;
  //修改
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
    CBRH: string;    //病人号
    CCZLXBM: string; //操作类型
    CWSLX: string;    //文书类型
    CSJID: string;    //事件ID
    CCZYGH: string;   //操作员工号
    CNR: string;
    XNR: string;
  end;

  TPubMod = class(TPersistent)
  private
    { Private declarations }
    QryXTCS: TFDQuery;       //子函数内部使用-严禁在业务函数中使用
    QryYXCS: TFDQuery;       //获取医院参数
    FRedis: IRedisClient;
    FRedisStream: TStringStream;
  public
    { Public declarations }
    PValue:TValue;    //入参检测变量
    PCZLX:Integer;    //0删除1新增2修改
    PWorker:TWorker;
    TBEvent: string;  //Event事件全局表变量
    FEvent: TEvent;    //Event事件全局变量
    FCSQL: string;           //全局SQL变量
    FCode: Integer;          //返回错误代码
    FResultData: string;    //返回值
    FError: string;         //错误消息
    SYXHIS: string;         //区域数据库--YXHIS
    SYXYKT: string;         //区域数据库--YXYKT
    SDBLX: string;           //区域类型
    Rdata: TDateTime;       //数据库服务器时间
    FRdata: string;         //数据库服务器时间--yyyy-MM-dd HH:mm:ss
    FRegDate: string;        //服务时限
    FIID: Int64;             //雪花ID
    FJson: TQJson;           //全局Qjson对象
    FIJson: TQJson;          //全局Qjson-Item对象
    DATABASE: TFDConnection; //MSSQL数据库链接
    SQLiteDB: TFDConnection; //SQLite数据库链接
    //Query使用请遵循注释规则，避免Query交叉使用
    QryExec: TFDQuery;       //执行Insert，Update,Delete语句
    QryPUB: TFDQuery;       //业务中获取数据信息，不参与任何逻辑代码
    QryZD: TFDQuery;         //字典表
    QryCX: TFDQuery;         //业务函数中Select单独使用
    Qry1: TFDQuery;          //业务函数中Select循环使用
    Qry2: TFDQuery;          //业务函数中Select循环使用
    Qry3: TFDQuery;          //业务函数中Select循环使用
    SQLiteQry: TFDQuery;     //SQLiteQuery
    FCBQ: string;            //住院病人病区编码
//------------------------------------------------------------------------------
// TSQD
   ///业务使用全局变量

    FIBRLX: Integer;        //病人类型 0：门诊，1：住院 2：体检
    FCmode: string;         //申请单类型 JC,JY  TY,TC
    Flag: Integer;          //操作类型 1收0退
    FCYLH: string;          //卡号可能是NYLKH
    FCICID: string;         //卡号CICID
    FCBH: string;           //申请单号
    FCBRH: string;          //门诊/住院号
    FCSFD: string;          //门诊收费单号/住院记账单号
    FCYZH: string;          //医嘱号
//==============================================================================
// 表变量
//==============================================================================
    TBXXWZX: string;      //申请单信息未执行表
    TBXMWZX: string;      //申请单项目未执行表
    TBMXWZX: string;      //申请单明细未执行表
    TBXXWGD: string;      //申请单信息未归档表
    TBXMWGD: string;      //申请单项目未归档表
    TBMXWGD: string;      //申请单明细未归档表
    TBBGXX: string;       //报告单信息表
    TBBGMX: string;       //报告单明细表
    TBBGBGMX: string;     //报告单表格明细表
    TBYZYJWZX: string;    //医嘱医技信息表
    TBYZBYZYLBQ: string;  //医嘱本医嘱医疗病区表
    TBSQDJQJL: string;    //申请单拒签记录
    TBZTMX: string;       //组套明细
    TBZTHZ: string;       //组套汇总
    TBSFXM: string;     //收费项目
    TBCWTJ: string;     // 财务统计
    TBFYTJ: string;    //费用统计
//==============================================================================
// 全局变量
//==============================================================================
    FMRZXKSBM: string;    //收费默认执行科室编码
    FMRZXKSMC: string;    //收费默认执行科室名称
    FSQDZXKSCLFS: string; //申请单执行科室处理方式
    FCZYGH: string;       //操作员工号
    FCZYMC: string;       //操作员名称
    FCZYBH: string;       //操作员名称
    FIKS: string;         //操作员科室编码
    FCKS: string;         //操作员科室名称
    FIZXKS: string;       //操作员执行科室编码
    FCZXKS: string;       //操作员执行科室名称
    FIKDKS: string;       //开单科室编码
    FCKDKS: string;       //开单科室名称
    FBBQYLYZ: Boolean;     //申请单是否写到医疗医嘱中
    FBSFKZ: Boolean;      //未收费是否能执行，报告
    FZXKSKZ: Integer;     //附加费执行科室控制0：入参传入，1：取病人所在科室，2：操作员所属科室
    FMZHZE, FMZHZF, FMJZJE, FMZHYE, FJZJE: Currency; //账户总额，账户支付，记账总额，账户余额
    FMZHZEJM, FMZHZFJM, FMJZJEJM: string;  //账户总额加密，账户支付加密，记账金额加密
//------------------------------------------------------------------------------

    /// <summary>外部调用-返回值</summary>
    property AResultData: string read FResultData;
    /// <summary>外部调用-错误信息</summary>
    property AERROR: string read FError;
    //初始化--
    constructor Create;
    destructor Destroy; override;
    /// <summary>获取表名</summary>
    function GetTBName(MBTableName: string; Invalue: string = ''; DefType:
      Integer = 7; InDate: TDateTime = 0): string;
    /// <summary>获取从 BeginDate-endDate的所有表，返回值为Tstrings对象，需手动释放</summary>
    function GetNkTables(MBTableName: string; BeginDate, endDate: TDateTime): Tstrings;
    /// <summary>检查数据库</summary>
    function DataBaseCheck(DbName: string): boolean;
    /// <summary>检查表</summary>
    function TableCheck(Tablename: string): boolean;
    /// <summary>获取TBUSERPARAM/TBYXXTCSI参数</summary>
    function GetXTCS(CMC: string; DefValue: string = ''): string; overload;
    function GetXTCS(CMC: string; DefValue: Integer): Integer; overload;
    /// <summary>获取流水号</summary>
    function GetSysNumber2(CBH: string; Diff: Integer; TJ: string): string;
    /// <summary>执行SQL语句</summary>
    /// <param name="ExecFlag">True:执行,False:查询</param>
    /// <param name="UseCache">True: 使用缓存,False:默认不使用</param>
    function ExeSql(AQuery: TFDQuery; CSQL: string; ExecFlag: Boolean; UseCache:
      Boolean = False): Boolean; overload;
    function ExeSql(AQuery: TFDQuery; CSQL: string): Integer; overload;
    /// <summary>执行SQL语句-带事务</summary>
    function DoExeSQL(CSQL: string): Boolean;
    /// <summary>添加字符串</summary>
    function Addstr(Ostr: string; Astr: string; Lnum: integer): string;
    /// <summary>获取数据库服务器时间</summary>
    function GetRdata: Tdatetime;
    /// <summary>if True Result 1 else Result 0</summary>
    function BoolToStr(B: Boolean): string;
    /// <summary>iif函数</summary>
    function iif(Expr: Boolean; vTrue, vFalse: string): string; overload;
    function iif(Expr: Boolean; vTrue, vFalse: integer): integer; overload;
    function iif(Expr: Boolean; vTrue, vFalse: TDateTime): TDateTime; overload;
    function iif(Expr: Boolean; vTrue, vFalse: Boolean): Boolean; overload;
    /// <summary>是否在事务中</summary>
    function InTransaction: Boolean;
    /// <summary>开始事务</summary>
    function StartTransaction(AutoRollBack: Boolean = True): IInterface;
    /// <summary>提交事务</summary>
    procedure Commit;
    /// <summary>回滚事务</summary>
    procedure Rollback;
    ///  <summary>对字符串前后加''</summary>
    function QuotedStr(const S: string): string; overload;
    ///<summary>取URL参数相关属性值</summary>
    //例如:url := http://127.0.0.1/GetActivityinformation?language=Chinese&name=westwind
    //用法:
    //    sLang := GetParamValue(url,'language'); //获取language
    //    sName := GetParamValue(url,'name');    //获取name
    function GetParamValue(UrlStr, ParamName: string; Pos: string = '='): string;
    /// <summary>检查节点</summary>
    function CheckNode(aJson: TQJson; Value: string): string;
    /// <summary>获取病区</summary>
    function GetBQ(CZYH: string): Boolean;
    /// <summary>检测病人过期出院</summary>
    function CheckBRXX(IBRLX: Integer; CBRH: string): Boolean;
    /// <summary>解析申请单编号，JC,JY</summary>
    procedure GetMode(CSQDH: string; out BH, CLX: string);
    /// <summary>初始化表变量</summary>
    procedure SetTBInfo;
    /// <summary>获取申请单数据</summary>
    function CheckSQD(AQry: TFDQuery): Boolean;
    /// <summary>获取卡余额</summary>
    function GetMZHYE: Boolean;
    /// <summary>金额加密</summary>
    function EncryptString(Value, Key: AnsiString): string;
    /// <summary>获取操作员信息</summary>
    function GetCZY(CZY: string; sno: Integer = 40): boolean;
     /// <summary>获取操作员信息</summary>
    function GetCZYBySNO(CYSBM: string; SNO: integer = 18): boolean;
    /// <summary>获取json中的Arr数据，以,隔开</summary>
    /// <param name="BSQL">是否添加""用于sql中的in</param>
    function JsonArrToStr(aJson: TQJson; Name: string; BSQL: Boolean = False): string;
    /// <summary>获取Arr数据，以,隔开</summary>
    /// <param name="BSQL">是否添加""用于sql中的in</param>
    function ArrToStr(Arr: Tarray<string>; BSQL: Boolean = False): string;
    /// <summary>string变量不允许为空</summary>
    procedure StrRequired(InStr: Tarray<string>);
    /// <summary>主程序的EVENT事件处理</summary>
    /// <param name="Event">说明查看TEvent结构</param>
    function EventProcessB(Event: TEvent): string;
    /// <summary>将时间转换成yyyy-mm-dd hh:nn:ss格式的字符串</summary>
    function GetString(time: TDateTime): string;
    /// <summary>业务加锁 0:解锁，1：加锁</summary>
    function DoLock(CBH: string; ITYPE: Integer = 1): Boolean;
    /// <summary>费用保留位数以及取舍方式</summary>
    function SetRes(A: Extended; dig, cs1: integer): Extended;
    /// <summary>检查参数是否为空</summary>
    /// <param name="Rec">需要检查的记录</param>
    /// <param name="ILX">0删除1新增2修改</param>
    procedure CheckEmpty(const Rec: TValue; ILX: Integer);
    /// <summary>写日志</summary>
    procedure Log(Msg: string);
    //业务实际处理虚函数
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
    //回滚
    uMod.Rollback;
    //日志
    uMod.FError := '自动回滚事务处理:' + uMod.FError;
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
  //如果查到表中有在处理的申请单 则 一直等到超时
    if CurOutTime >= 30000 then //30秒钟
    begin
      FError := '当前申请单正在处理！请稍后在试！';
      Exit;
    end;
    Sleep(100); //0.1秒钟
    CurOutTime := CurOutTime + 100; //超时设置成30秒
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
    FError := 'SQL参数为空！';
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
        FError := 'SQL执行失败:' + E.Message;
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
    FError := '无数据库连接！';
    Exit;
  end;
  if CSQL = '' then
  begin
    FError := '无SQL语句！';
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
        FError := '数据库错误信息:' + E.Message;
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
    FError := '无数据库连接！';
    Exit;
  end;
  if CSQL = '' then
  begin
    FError := '无SQL语句！';
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
        FError := '数据库错误信息:' + E.Message;
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
      raise Exception.Create('获取参数出错！' + FError);
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
      raise Exception.Create('获取参数出错！' + FError);
  end;
end;

function TPubMod.GetNkTables(MBTableName: string; BeginDate, endDate: TDateTime):
  Tstrings;
var
  BEGINYEAR, ENDYEAR: INTEGER;
  i, j: integer;
  DbName: string; //数据库名称
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
      FError := '未找到相关的表配置！';
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
      raise Exception.Create('获取表出错！' + FError);
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
      FError := 'GetTbName("' + MBTableName + '"): 传入关键字的值为空！';
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
      FError := '未找到[' + MBTableName + ']相关的表配置！';
      Exit;
    end;
    DbName := QryXTCS.FieldByName('CDATABASE').AsString;
    if DbName = '' then
      Exit;
    ITYPE := QryXTCS.FieldByName('ITYPE').asinteger;
    /////判断数据库信息
    case ITYPE of
      0:
        begin ///普通表
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
        begin ///年表
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
        begin ////月表
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
        begin ///日表
        end;
      4:
        begin ///年库月表
          if not DataBaseCheck(DbName + YY) then
            Exit;
          if TableCheck(DbName + YY + '..' + MBTableName + YY + MM) then
          begin
            Result := DbName + YY + '..' + MBTableName + YY + MM;
          end;
        end;
      5:
        begin ///年库年表
          if not DataBaseCheck(DbName + YY) then
            Exit;
          if TableCheck(DbName + YY + '..' + MBTableName + YY) then
          begin
            Result := DbName + YY + '..' + MBTableName + YY;
          end;
        end;
      6:
        begin ///年库日表；
        end;
      7:
        begin ///分区表
          if not DataBaseCheck(DbName) then
            Exit;
          if TableCheck(DbName + '..' + MBTableName + '_0' + RightStr(KeyValue, 1)) then
          begin
            Result := DbName + '..' + MBTableName + '_0' + RightStr(KeyValue, 1);
          end;
        end;
      8:   //年库分区表
        begin
          if not DataBaseCheck(DbName + YY) then
            Exit;
          if TableCheck(DbName + YY + '..' + MBTableName + '_0' + RightStr(KeyValue,
            1)) then
          begin
            Result := DbName + YY + '..' + MBTableName + '_0' + RightStr(KeyValue, 1);
          end;
         // 分区表(但表在年库中)
        end;
      10:
        begin //病区表
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
      raise Exception.Create('获取表名出错！' + FError);
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
      FError := '查询[' + DbName + ']库错误！请检查！' + FError;
      Exit;
    end;
    if QryXTCS.IsEmpty then
    begin
      FError := '未找到[' + DbName + ']相关库！';
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
      FError := '未查询到' + FDataBaseName + FTableName + '相关表数据！';
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
//字符串添加  例如 Addstr ( '1','0',4);  Result = '0001'
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
    raise Exception.Create('流水号生成错误！传入参数错误(小于1)！CBH=' + CBH);
  end;
  try
    CSQL := 'DECLARE @Value VARCHAR(200)' + #13#10 + 'SET @Value = ' + QuotedStr
      (CBH) + #13#10 + 'EXEC ' + SYXHIS + '.DBO.GetSysNumber2 ' + Diff.ToString
      + ',' + QuotedStr(TJ) + ',@Value OUT' + #13#10 + 'SELECT @Value Value ';
    if not ExeSql(QryXTCS, CSQL, False) then
      Exit;
    if QryXTCS.IsEmpty then
    begin
      FError := '未查询到[' + CBH + ']相关的流水号信息！';
      exit;
    end;
    Result := QryXTCS.FieldByName('Value').AsString;
  finally
    if Result = '0' then
      raise Exception.Create('[' + CBH + ']流水号生成错误！');
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
      raise Exception.Create('参数错误！string不允许为空！');
  end;
end;

function TPubMod.StartTransaction(AutoRollBack: Boolean): IInterface;
var
  aAutoObject: TAutoRollback;
begin
  if Assigned(DATABASE) then
  begin
    Rollback;
    //调用本StartTransaction函数或过程结束后将，若事务还在，将会自动回滚事务
    if AutoRollBack then
    begin
      aAutoObject := TAutoRollback.Create;
      aAutoObject.uMod := self;
      Result := aAutoObject as IInterface;
    end;
    //开始事务
    try
      DATABASE.StartTransaction;
      //Break;
    except
      on e: Exception do
      begin
        FError := '数据库事务开启失败！请重试！' + e.Message;
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
    //删除
          0:
          Attr := AField.GetAttribute<SDELNotEmpty>;
    //新增
          1:
          Attr := AField.GetAttribute<SADDNotEmpty>;

    //修改
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
      raise Exception.Create(err + '为必填字段！');
  end;
end;

function TPubMod.CheckNode(aJson: TQJson; Value: string): string;
begin
  Result := aJson.S[Value];
  if Result = '' then
    raise Exception.Create('未传入' + Value + '节点！');
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
      FError := '未查询到该门诊病人的挂号信息！';
      Exit;
    end;
    if QryCX.B['BTH'] then
    begin
      FError := '该门诊病人已退号！';
      Exit;
    end;
    if GetXTCS('IYJJKMZYXQXZ', 0) = 0 then Exit(True);
    //留观不管有效期
    if QryCX.B['BLG'] then
      Exit(True);
    IYXTS := GetXTCS('IMZSFXZYXTS', 0);
    if IYXTS = 0 then
      IYXTS := QryCX.I['IYXTS'];
    if IYXTS = 0 then
      IYXTS := 7;
    if (QryCX.T['DGH'] + IYXTS < Rdata) and (QryCX.T['DYY'] + IYXTS < Rdata) then
    begin
      FError := '该门诊病人已过期！挂号时间:[' + QryCX.S['DGH'] + '],预约时间:[' + QryCX.S['DYY']
        + '],有限期:[' + IYXTS.ToString + '],当前时间:[' + FRdata + ']';
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
      FError := '未查询到该住院病人的信息！';
      Exit;
    end;
    if QryCX.B['BDD'] then
    begin
      FError := '病人已经出院！';
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
      FError := '未查询到病人病区信息！';
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
  if FIBRLX = 0 then    //门诊
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
  else if FIBRLX = 1 then   //住院
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
  else if FIBRLX = 2 then   //体检
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
    FError := '未找到申请单信息！';
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
      FError := '未查询到相关一卡通余额数据！';
      Exit;
    end;
    //需要重新再取一次,为提效率此处不使用ReadOnlyOne读取 --不加With(nolock)
    with QryXTCS do
    begin
      case I['IICZT'] of
        2:
          FError := '该卡已挂失，不能进行任何操作！';
        3:
          FError := '该卡已注销，不能进行任何操作！';
        4, 5:
          FError := '该卡已退卡，不能进行任何操作！';
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
        FError := '卡号[' + FCICID + ']总金额错误！请查证后使用！';
        Exit;
      end;
      if EncryptString(CurrToStrF(FMZHZF, ffFixed, 3), 'YX' + FCICID) <> FMZHZFJM then
      begin
        FError := '卡号[' + FCICID + ']支付金额错误！请查证后使用！';
        Exit;
      end;

      if EncryptString(CurrToStrF(FMJZJE, ffFixed, 3), 'YX' + FCICID) <>
        FMJZJEJM then //4位小数
      begin
        if EncryptString(CurrToStrF(FMJZJE, ffFixed, 2), 'YX' + FCICID) <>
          FMJZJEJM then //两位小数  以前版本建卡以两位小数加密存盘
        begin
          FError := '卡号[' + FCICID + ']记账金额错误！请查证后使用！';
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
      {  --  128 位密匙最大长度为 16 个字符 --  }
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
    40:  //医技医生
      begin
        TBYSName := SYXHIS + '.DBO.TBZDYJYS';
        CBM := 'IBM';
      end;
    54: //急诊护士
      begin
        TBYSName := SYXHIS + '.DBO.TBZDJZHS';
//      CKSSQl := 'SELECT CBM,CMC FROM ' + SYXHIS +
//        '.DBO.tbzdzxks WITH(NOLOCK) WHERE IMZKSBM=' +
//        '(SELECT top 1 IKSBM FROM ' + SYXHIS +
//        '.DBO.TBZDJZHS with(nolock) WHERE CCZYGH=' + Quotedstr(FCZYBH) + ')';
        CBM := 'CBM';
      end;
    18:  //门诊医生
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
      FError := '未找到对应的操作员！请检查操作员是否具有' + sno.ToString + '系统正常使用权限！';
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
        FError := '未找到对应的执行科室！请检查操作员是否具有' + sno.ToString + '系统正常使用权限！';
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
    FError := '获取操作员【' + CYSBM + '】工号失败！';
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
      raise Exception.Create('Event事件保存错误！' + FError);
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

    // 保留小数
  case cs1 of
      // 根据保留模式保留小数
    0:
      begin
        for i := 1 to dig do
          Result := Result * 10;
        if abs(frac(Result)) + 0.00000001 >= 0.5 then
            // 必须转换为字符串才能判断,因为用数字判断存在精度偏差
        begin
          if result > 0 then
            Result := Result + 0.1
                // 注意Round函数对0.5运算的结果为零，所以要加0.1
          else
            Result := Result - 0.1
                // 注意Round函数对0.5运算的结果为零，所以要加0.1
        end;
        Result := Round(result); // 四舍五入 rmRound
        if (Result = 0) and (A > 0) then
          Result := 1; //现在只处理大于0的
        for i := 1 to dig do
          Result := Result / 10;
      end;
    1:
      begin
        for i := 1 to dig do
          Result := Result * 10;
        Result := result + 0.00000001; //处理精度问题，如1.14*100,trunc后为113
        Result := trunc(Result); // 取整 rmMin
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
            Result := trunc(Result); // 取整加一 rmMax
        end
        else
        begin
          if Result < trunc(Result) - 0.000000009 then
            Result := trunc(Result) - 1
          else
            Result := trunc(Result); // 取整加一 rmMax
        end;
        for i := 1 to dig do
          Result := Result / 10;
      end;
    3:
      begin ////       二七作五
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
      begin //1.2.3.4角进到5角 ;6.7.8.9角进到1元
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
    6: // 三舍四入
      begin
        for i := 1 to dig do
          Result := Result * 10;
        if abs(frac(Result)) + 0.00000001 >= 0.4 then
            // 必须转换为字符串才能判断,因为用数字判断存在精度偏差
        begin
          if result > 0 then
            Result := Result + 0.2
                // 注意Round函数对0.4运算的结果为零，所以要加0.1
          else
            Result := Result - 0.2
                // 注意Round函数对0.4运算的结果为零，所以要加0.1
        end;
        Result := Round(result); //三舍四入 rmRound
        for i := 1 to dig do
          Result := Result / 10;
      end;
  end;
  //原本数据不为0进行舍入后成了0的要处理：如0.0001，要求保留2位小数，应该变成0.01
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

