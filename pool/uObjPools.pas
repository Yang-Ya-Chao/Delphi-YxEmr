// 标准模板
unit uObjPools;

interface

uses
  Classes, SysUtils, UntThreadTimer, Vcl.Forms, IniFiles,
  FireDAC.Comp.Client, FireDAC.Phys.MSSQL, FireDAC.Moni.FlatFile,
  FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  Data.DB, FireDAC.DApt,uConfig,QWorker,QLog,
  FireDAC.Phys.SQLite,System.Generics.Collections,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat,IdHTTP;

type
  TDBConfig = class
  private
    //数据库配置
    Driver:string;        //驱动类型
    DBServer: string; //数据源 --数据库服务器IP
    DataBase: string; //数据库名字 //sql server连接时需要数据库名参数--数据库实例名称
    UserName: string; //数据库用户
    PassWord: string; //密码
    PoolNum: Integer;    //池大小
  public
    constructor Create(aDriver: string); overload;
    destructor Destroy; override;
  end;
  { 这是一个对像池, 可以池化所有 TObject 对像 }
  { 用法:
       在一个全局的地方定义
    var
       Pooler: TObjectPool;

    用到的地方
       obj := Pooler.GetObj as Txxx;
       try
       finally
         Pooler.PutObj;
       end;

    初始化
    initialization
       Pooler := TObjectPool.Create(要收集的类名)
    finallization
       Pooler.Free;
    end;
  }
  //池中对象 状态
  TPoolItem = class
  private
    FInstance: TObject; //对象
    FLocked: Boolean; //是否被使用
    FLastTime: TDateTime; //最近活跃时间
  public
    constructor Create(AInstance: TObject; const IsLocked: Boolean = True);
    destructor Destroy; override;
  end;
  //对象池

  TObjectPool = class
  private
    FConfig:TDBConfig;
    FCachedList: TThreadList; //对象池 中 对象 列表
    FMaxCacheSize, FMinCacheSize: Integer; //对象池最大值，最小值  如不设置系统默认为 20
    FCacheHit: Cardinal; //调用对象池 中 对象的 次数
    FCreationCount: Cardinal; //创建对象次数
    FObjectClass: TClass;
    FRequestCount: Cardinal; //调用对象池次数
    FAutoReleased: Boolean; //自动释放空闲的对象
    FTimer: TThreadedTimer; //多线程计时器
    FHourInterval: Integer;  //设置间隔时间（小时）
    function GetCurObjCount: Integer;
    function GetLockObjCount: Integer;
    procedure IniMinPools; //初始化最小池对象
    procedure SetFHourInterval(iValue: Integer);
  protected
    function CreateObject: TObject; // 创建对象
    procedure OnMyTimer(Sender: TObject);
  public
    constructor Create(AClass: TClass; MaxPools, MinPools: Integer; Config:TDBConfig);
    destructor Destroy; override;

    function GetObj: TObject; //获取对象
    procedure PutObj(Instance: TObject); //释放对象


    property ObjectClass: TClass read FObjectClass;
    property MaxCacheSize: Integer read FMaxCacheSize; //池子大小
    property CacheHit: Cardinal read FCacheHit; //调用池子中对象次数
    property CreationCount: Cardinal read FCreationCount; //创建对象次数
    property RequestCount: Cardinal read FRequestCount; //请求池次数
    property RealCount: Integer read GetCurObjCount; //池中对象数量
    property LockObjCount: Integer read GetLockObjCount; //池子繁忙的对象数量
    property HourInterval: Integer read FHourInterval write SetFHourInterval;
    procedure StartAutoFree; //开启自动回收
    procedure StopAutoFree; //关闭自动回收
  end;


  { TObjectPool<T> }
  { 同样是对像池, 但支持模板 }
  { 用法:
       在一个全局的地方定义
    var
       Pooler: TObjectPool<要收集的类名>;

    用到的地方
       obj := Pooler.GetObj;
       try

       finally

         Pooler.PutObj;
       end;

    初始化

    initialization
       Pooler := TObjectPool<要收集的类名>.Create;
    finallization
       Pooler.Free;
    end;
  }
  TObjectPool<T: class> = class(TObjectPool)
  public
    constructor Create(const MaxPools: Integer = 0; const MinPools: Integer = 0;const Config:TDBConfig = nil);

    function GetObj: T;
  end;


var
  DBConfig,SQLiteConfig: TDBConfig;
  // 基于泛型模板定义的具体模板
  FQryPool: TObjectPool<TFDQuery>; //Query池子
  FDBPool,FSQLiteDBPool: TObjectPool<TFDConnection>; //Database池子
  FListPool:TObjectPool<TStringList>; //List池子
  FDicPool:TObjectPool<TDictionary<string,string>>; //Dic池子
  FHTTPPool:TObjectPool<TIdHTTP>; //HTTP池子
  {FProcMgr: TObjectPool<TFDStoredProc>; //Database池子
  FDspMgr:TObjectPool<TDataSetProvider>;//DSP池子
  FCDSMgr:TObjectPool<TClientDataSet>;//cds池子
  FDSMgr :TObjectPool<TDataSource>;//ds池子
  FUniSQLMgr:TObjectPool<TUniSQL>;//执行SQL池子
  FUniSPMgr :TObjectPool<TUniStoredProc>;//存储过程池子 }

  function QryPool: TObjectPool<TFDQuery>;
  function DBPool: TObjectPool<TFDConnection>;
  function SQLiteDBPool: TObjectPool<TFDConnection>;
  function ListPool: TObjectPool<TStringList>;
  function DicPool: TObjectPool<TDictionary<string,string>>;
  function HTTPPool: TObjectPool<TIdHTTP>;
  procedure DoPoolStatus(AJob: PQJob);

implementation

// 创建Qry池
function QryPool: TObjectPool<TFDQuery>;
begin
  if not Assigned(FQryPool) then
    FQryPool := TObjectPool<TFDQuery>.Create(DBConfig.PoolNum * 10, DBConfig.PoolNum);
  Result := FQryPool;
end;
// 创建SQLiteDB池
function SQLiteDBPool: TObjectPool<TFDConnection>;
begin
  if not Assigned(FSQLiteDBPool) then
    FSQLiteDBPool := TObjectPool<TFDConnection>.Create(SQLiteConfig.PoolNum, 1,SQLiteConfig);
  Result := FSQLiteDBPool;
end;
// 创建MSSQLDB池
function DBPool: TObjectPool<TFDConnection>;
begin
  try
    if not Assigned(FDBPool) then
      FDBPool := TObjectPool<TFDConnection>.Create(DBConfig.PoolNum, 1,DBConfig);
    Result := FDBPool;
  except
    raise Exception.Create('数据库连接失败！请检查数据库配置或者网络链接！');
  end;
end;
// 创建List池
function ListPool: TObjectPool<TStringList>;
begin
  if not Assigned(FListPool) then
    FListPool := TObjectPool<TStringList>.Create(DBConfig.PoolNum * 10, DBConfig.PoolNum);
  Result := FListPool;
end;
// 创建字典池
function DicPool: TObjectPool<TDictionary<string,string>>;
begin
  if not Assigned(FDicPool) then
    FDicPool := TObjectPool<TDictionary<string,string>>.Create(DBConfig.PoolNum * 10, DBConfig.PoolNum);
  Result := FDicPool;
end;
// 创建http池
function HTTPPool: TObjectPool<TIdHTTP>;
begin
  if not Assigned(FHTTPPool) then
    FHTTPPool := TObjectPool<TIdHTTP>.Create(DBConfig.PoolNum * 10, DBConfig.PoolNum);
  Result := FHTTPPool;
end;

// 记录池数据
procedure DoPoolStatus(AJob: PQJob);
var
  Str:string;
begin
  if Assigned(FQryPool) then
  begin
    Str := Str+#13#10+'Query池:'
      +'池容量:'+IntToStr(FQryPool.MaxCacheSize)
      +';池大小:'+IntToStr(FQryPool.RealCount)
      +';繁忙量:'+IntToStr(FQryPool.LockObjCount)
      +';创建量:'+IntToStr(FQryPool.CreationCount)
      +';请求量:'+IntToStr(FQryPool.RequestCount)
      +';调用量:'+IntToStr(FQryPool.CacheHit);
  end;
  if Assigned(FDBPool) then
  begin
    Str := Str+#13#10+'MSSQLDB池:'
      +'池容量:'+IntToStr(FDBPool.MaxCacheSize)
      +';池大小:'+IntToStr(FDBPool.RealCount)
      +';繁忙量:'+IntToStr(FDBPool.LockObjCount)
      +';创建量:'+IntToStr(FDBPool.CreationCount)
      +';请求量:'+IntToStr(FDBPool.RequestCount)
      +';调用量:'+IntToStr(FDBPool.CacheHit);
  end;
  if Assigned(FSQLiteDBPool) then
  begin
    Str := Str+#13#10+'SQLiteDB池:'
      +'池容量:'+IntToStr(FSQLiteDBPool.MaxCacheSize)
      +';池大小:'+IntToStr(FSQLiteDBPool.RealCount)
      +';繁忙量:'+IntToStr(FSQLiteDBPool.LockObjCount)
      +';创建量:'+IntToStr(FSQLiteDBPool.CreationCount)
      +';请求量:'+IntToStr(FSQLiteDBPool.RequestCount)
      +';调用量:'+IntToStr(FSQLiteDBPool.CacheHit);
  end;
  if Assigned(FListPool) then
  begin
    Str := Str+#13#10+'List池:'
      +'池容量:'+IntToStr(FListPool.MaxCacheSize)
      +';池大小:'+IntToStr(FListPool.RealCount)
      +';繁忙量:'+IntToStr(FListPool.LockObjCount)
      +';创建量:'+IntToStr(FListPool.CreationCount)
      +';请求量:'+IntToStr(FListPool.RequestCount)
      +';调用量:'+IntToStr(FListPool.CacheHit);
  end;
  if Str <> '' then
    Logs.Post(llHint,Str);
end;




const
  MSecsPerMins = SecsPerMin * MSecsPerSec;
  //返回相差的分钟

function MyMinutesBetWeen(const ANow, AThen: TDateTime): Integer;
var
  tmpDay: Double;
begin
  tmpDay := 0;
  if ANow < AThen then
    tmpDay := AThen - ANow
  else
    tmpDay := ANow - AThen;
  Result := Round(MinsPerDay * tmpDay);
end;

constructor TPoolItem.Create(AInstance: TObject; const IsLocked: Boolean);
begin
  inherited Create;
  FInstance := AInstance;
  FLocked := IsLocked;
  FLastTime := Now;
end;

destructor TPoolItem.Destroy;
begin
  if Assigned(FInstance) then
    FreeAndNil(FInstance);
  inherited;
end;

{ TObjectPool }
constructor TObjectPool.Create(AClass: TClass; MaxPools, MinPools: Integer;Config:TDBConfig);
begin
  inherited Create;
  FConfig := Config;
  if FConfig = nil then
    FConfig := DBConfig;
  FObjectClass := AClass;
  FCachedList := TThreadList.Create;
  FMaxCacheSize := MaxPools;
  FMinCacheSize := MinPools;
  if FMaxCacheSize = 0 then
    FMaxCacheSize := 20;  //系统默认为20个并发
  if FMinCacheSize > FMaxCacheSize then
    FMinCacheSize := FMaxCacheSize; //系统默认最小值为0
  FCacheHit := 0;
  FCreationCount := 0;
  FRequestCount := 0;
  IniMinPools; //初始化最小池对象
  //计时销毁
  FTimer := TThreadedTimer.Create(Application.Handle, nil); //计时
  FHourInterval := 1; //默认空闲1小时则回收
  FTimer.Interval := SecsPerMin * MinsPerHour * FHourInterval;
  FTimer.OnTimer := OnMyTimer;
  FTimer.Enabled := True;
end;

function TObjectPool.CreateObject: TObject;
begin
  Result := FObjectClass.NewInstance;
  if Result is TStringList then
    TStringList(Result).Create
  else if Result is TDataModule then
    TDataModule(Result).Create(nil)
  else if Result is TComponent then
    TComponent(Result).Create(nil)
  else if Result is TPersistent then
    TPersistent(Result).Create
  else if Result is TDictionary<string,string> then
    TDictionary<string,string>(Result).Create
  else
    Result.Create;
  if (Result is TFDConnection)  then
  begin
    var str := 'DriverID='+FConfig.Driver+';Database=' + FConfig.DataBase
      + ';Password=' + FConfig.PassWord;
    if FConfig.Driver = 'MSSQL' then
      str := str+';User_name=' + FConfig.UserName+';Server=' + FConfig.DBServer;
    with TFDConnection(Result) do
    begin
      //ConnectionTimeout:=18000;
      ConnectionString := str;
      //解决执行sql过程断线，等待时间过程 ,加上之后，数据量过大写入会超时！屏蔽！
      //Params.add('ResourceOptions.CmdExecTimeout=3');
      //解决查询只返回50条数据问题
      Params.add('FetchOptions.Mode=fmAll');
      //解决！，&等字符插入数据库时丢失
      Params.add('ResourceOptions.MacroCreate=False');
      Params.add('ResourceOptions.MacroExpand=False');
      //try
        Connected := True;
      //except
      //  raise Exception.Create('数据库连接失败！请检查数据库配置或者网络链接！');
      //end;
    end;
  end;
end;

destructor TObjectPool.Destroy;
var
  I: Integer;
  LockedList: TList;
begin
  FTimer.Enabled := False;
  if Assigned(FCachedList) then
  begin
    LockedList := FCachedList.LockList;
    try
      for I := 0 to LockedList.Count - 1 do
        TPoolItem(LockedList[I]).Free;
    finally
      FCachedList.UnlockList;
      FCachedList.Free;
    end;
  end;
  FTimer.Free;
  inherited;
end;

function TObjectPool.GetCurObjCount: Integer;
var
  LockedList: TList;
begin
  Result := 0;
  LockedList := FCachedList.LockList;
  try
    Result := LockedList.Count;
  finally
    FCachedList.UnlockList;
  end;
end;

function TObjectPool.GetLockObjCount: Integer;
var
  LockedList: TList;
  i: Integer;
begin
  Result := 0;
  LockedList := FCachedList.LockList;
  try
    for i := 0 to LockedList.Count - 1 do
    begin
      if TPoolItem(LockedList[i]).FLocked then
        Result := Result + 1;
    end;
  finally
    FCachedList.UnlockList;
  end;
end;

procedure TObjectPool.IniMinPools;
var
  PoolsObject: TObject;
  LockedList: TList;
  I: Integer;
begin
  LockedList := FCachedList.LockList;
  try
    for I := 0 to FMinCacheSize - 1 do
    begin
      PoolsObject := CreateObject;
      if Assigned(PoolsObject) then
        LockedList.Add(TPoolItem.Create(PoolsObject, False));
    end;
  finally
    FCachedList.UnlockList;
  end;
end;

function TObjectPool.GetObj: TObject;
var
  LockedList: TList;
  I: Integer;
  CurOutTime: Integer;
begin
  Result := nil;
  CurOutTime := 0;
  LockedList := FCachedList.LockList;
  try
    Inc(FRequestCount);
    //从池中取未使用的对象
    for I := 0 to LockedList.Count - 1 do
    begin
      if not TPoolItem(LockedList.Items[I]).FLocked then
      begin
        Result := TPoolItem(LockedList.Items[I]).FInstance;
        TPoolItem(LockedList.Items[I]).FLocked := True;
        TPoolItem(LockedList.Items[I]).FLastTime := Now;
        Inc(FCacheHit); //从池中取的次数
        Break;
      end;
    end;
    //如果池中对象全在使用，则看下是否需要新建或者等待
    if not Assigned(Result) then
    begin
      //池未满，新建对象
      if LockedList.Count < FMaxCacheSize then //池子容量
      begin
        Result := CreateObject;
        Inc(FCreationCount);
        LockedList.Add(TPoolItem.Create(Result, True));
      end
      //池满 等待对象释放 超时设置成30秒
      else
      begin
        while True do
        begin
          for I := 0 to LockedList.Count - 1 do
          begin
            if not TPoolItem(LockedList.Items[I]).FLocked then
            begin
              Result := TPoolItem(LockedList.Items[I]).FInstance;
              TPoolItem(LockedList.Items[I]).FLocked := True;
              TPoolItem(LockedList.Items[I]).FLastTime := Now;
              Inc(FCacheHit); //从池中取的次数
              Break;
            end;
          end;
          //如果不存在这种对象 则 一直等到超时
          if CurOutTime >= 5000 * 6 then //30s
          begin
            raise Exception.Create('池中寻找可用对象超时！请重新提交业务！');
            Break;
          end;
          Sleep(500); //0.5秒钟
          CurOutTime := CurOutTime + 500; //超时设置成30秒
        end; //end while
      end;
    end;

  finally
    if Result is TFDQuery then
      TFDQuery(Result).Close;
    FCachedList.UnlockList;
  end;
end;

procedure TObjectPool.OnMyTimer(Sender: TObject);
var
  i: Integer;
  LockedList: TList;
begin
  LockedList := FCachedList.LockList;
  try
    for i := LockedList.Count - 1 downto 0 do
    begin
      //保留最小池对象
      if RealCount <= FMinCacheSize then Exit;
      //释放池子许久不用的对象
      if MyMinutesBetween(Now, TPoolItem(LockedList.Items[i]).FLastTime) >= FHourInterval * MinsPerHour then
      begin
        TPoolItem(LockedList.Items[i]).Free;
        LockedList.Delete(i);
      end;
    end;
  finally
    FCachedList.UnlockList;
  end;
end;

procedure TObjectPool.SetFHourInterval(iValue: Integer);
begin
  if iValue <= 1 then
    Exit;
  if FHourInterval = iValue then
    Exit;
  FTimer.Enabled := False;
  try
    FHourInterval := iValue;
    FTimer.Interval := MSecsPerMins * MinsPerHour * FHourInterval;
  finally
    FTimer.Enabled := True;
  end;
end;

procedure TObjectPool.StartAutoFree;
begin
  if not FTimer.Enabled then
    FTimer.Enabled := True;
end;

procedure TObjectPool.StopAutoFree;
begin
  if FTimer.Enabled then
    FTimer.Enabled := False;
end;

procedure TObjectPool.PutObj(Instance: TObject);
var
  LockedList: TList;
  I: Integer;
  Item: TPoolItem;
  CurOutTime: Integer;
begin
  LockedList := FCachedList.LockList;
  try
    Item := nil;
    CurOutTime := 0;
    for I := 0 to LockedList.Count - 1 do
    begin
      Item := TPoolItem(LockedList.Items[I]);
      if Item.FInstance = Instance then
      begin
        if Instance is TFDQuery then
          TFDQuery(Instance).Connection := nil;
        if Instance is TStringList then
          TStringList(Instance).Clear;
        if Instance is TDictionary<string,string> then
          TDictionary<string,string>(Instance).Clear;
        Item.FLocked := False;
        Item.FLastTime := Now;
        Break;
      end;
    end;
    if not Assigned(Item) then
      Instance.Free;
  finally
    FCachedList.UnlockList;
  end;
end;

// 基于标准模板定义的泛型模板
{ TObjectPool<T> }
constructor TObjectPool<T>.Create(const MaxPools, MinPools: Integer;const Config:TDBConfig);
begin
  inherited Create(T, MaxPools, MinPools,Config);
end;

function TObjectPool<T>.GetObj: T;
begin
  Result := T(inherited GetObj);
end;

{ TDBConfig }

constructor TDBConfig.Create(aDriver: string);
begin
  if aDriver = 'MSSQL' then
  begin
    Driver := 'MSSQL';
    DBServer := Ini.DBServer;
    DataBase := Ini.DBDataBase;
    UserName := Ini.DBUserName;
    PassWord := Ini.DBPassWord;
  end
  else if aDriver = 'SQLite' then
  begin
    Driver := 'SQLite';
    DataBase := ChangeFileExt(ParamStr(0), '.db');
    PassWord := admin;
  end;
  PoolNum := Ini.Pools;
end;

destructor TDBConfig.Destroy;
begin

  inherited;
end;

initialization
  DBConfig := TDBConfig.Create('MSSQL');
  SQLiteConfig := TDBConfig.Create('SQLite');
  Workers.Post(DoPoolStatus, 3*Q1Second, nil,False);

finalization
  if Assigned(DBConfig) then
    DBConfig.Free;
  if Assigned(SQLiteConfig) then
    SQLiteConfig.Free;
  if Assigned(FQryPool) then
    FQryPool.Free;
  if Assigned(FDBPool) then
    FDBPool.Free;
  if Assigned(FSQLiteDBPool) then
    FSQLiteDBPool.Free;
  if Assigned(FListPool) then
    FListPool.Free;
  if Assigned(FDicPool) then
    FDicPool.Free;
   if Assigned(FHTTPPool) then
    FHTTPPool.Free;
end.

