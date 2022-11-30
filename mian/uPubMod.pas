//基类单元--所有的业务类应该继承此单元
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
    FCode:Integer;          //返回错误代码
    FResultData :string;    //返回值
    FError :string;         //错误消息
    Rdata: TDateTime;       //数据库服务器时间
    FRdata: string;         //数据库服务器时间--yyyy-MM-dd HH:mm:ss
    FRegDate:String;        //服务时限
    FIID:Int64;             //雪花ID
    FJson:TQJson;           //全局Qjson对象
    FIJson:TQJson;          //全局Qjson-Item对象
    DATABASE: TFDConnection;//MSSQL数据库链接
    SQLiteDB: TFDConnection;//SQLite数据库链接
    QryCX:TFDQuery;
    QryExec:TFDQuery;
    SQLiteQry:TFDQuery;     //SQLiteQuery

//------------------------------------------------------------------------------
    /// <summary>外部调用-返回值</summary>
    property AResultData: string read FResultData;
    /// <summary>外部调用-错误信息</summary>
    property AERROR: string read FError;
    //初始化--
    constructor Create;
    destructor Destroy; override;
    /// <summary>执行SQL语句</summary>
    /// <param name="ExecFlag">True:执行,False:查询</param>
    function ExeSql(AQuery: TFDQuery; CSQL: string; ExecFlag: Boolean): Boolean; overload;
    function ExeSql(AQuery: TFDQuery; CSQL: string): Integer; overload;
    /// <summary>执行SQL语句-带事务</summary>
    function DoExeSQL(CSQL: string): Boolean;
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
    function QuotedStr(const S: string): string;overload;
    ///<summary>取URL参数相关属性值</summary>
    //例如:url := http://127.0.0.1/GetActivityinformation?language=Chinese&name=westwind
    //用法:
    //    sLang := GetParamValue(url,'language'); //获取language
    //    sName := GetParamValue(url,'name');    //获取name
    function GetParamValue(UrlStr, ParamName: string;Pos:string='='): string;

    //业务实际处理虚函数
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
    FError:= 'SQL参数为空！';
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
    FError := '无数据库连接！';
    Exit;
  end;
  if CSQL = '' then
  begin
    FError := '无SQL语句！';
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
        FError := '错误信息:' + E.Message + ';SQL=' + CSQL;
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
    FError := '无数据库连接！';
    Exit;
  end;
  if CSQL = '' then
  begin
    FError := '无SQL语句！';
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
        FError := '错误信息:' + E.Message + #13#10 + ' SQL:' + CSQL;
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
      on e:Exception do
      begin
        FError := '数据库事务开启失败！请重试！'+e.Message;
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
