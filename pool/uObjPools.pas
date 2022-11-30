// ��׼ģ��
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
    //���ݿ�����
    Driver:string;        //��������
    DBServer: string; //����Դ --���ݿ������IP
    DataBase: string; //���ݿ����� //sql server����ʱ��Ҫ���ݿ�������--���ݿ�ʵ������
    UserName: string; //���ݿ��û�
    PassWord: string; //����
    PoolNum: Integer;    //�ش�С
  public
    constructor Create(aDriver: string); overload;
    destructor Destroy; override;
  end;
  { ����һ�������, ���Գػ����� TObject ���� }
  { �÷�:
       ��һ��ȫ�ֵĵط�����
    var
       Pooler: TObjectPool;

    �õ��ĵط�
       obj := Pooler.GetObj as Txxx;
       try
       finally
         Pooler.PutObj;
       end;

    ��ʼ��
    initialization
       Pooler := TObjectPool.Create(Ҫ�ռ�������)
    finallization
       Pooler.Free;
    end;
  }
  //���ж��� ״̬
  TPoolItem = class
  private
    FInstance: TObject; //����
    FLocked: Boolean; //�Ƿ�ʹ��
    FLastTime: TDateTime; //�����Ծʱ��
  public
    constructor Create(AInstance: TObject; const IsLocked: Boolean = True);
    destructor Destroy; override;
  end;
  //�����

  TObjectPool = class
  private
    FConfig:TDBConfig;
    FCachedList: TThreadList; //����� �� ���� �б�
    FMaxCacheSize, FMinCacheSize: Integer; //��������ֵ����Сֵ  �粻����ϵͳĬ��Ϊ 20
    FCacheHit: Cardinal; //���ö���� �� ����� ����
    FCreationCount: Cardinal; //�����������
    FObjectClass: TClass;
    FRequestCount: Cardinal; //���ö���ش���
    FAutoReleased: Boolean; //�Զ��ͷſ��еĶ���
    FTimer: TThreadedTimer; //���̼߳�ʱ��
    FHourInterval: Integer;  //���ü��ʱ�䣨Сʱ��
    function GetCurObjCount: Integer;
    function GetLockObjCount: Integer;
    procedure IniMinPools; //��ʼ����С�ض���
    procedure SetFHourInterval(iValue: Integer);
  protected
    function CreateObject: TObject; // ��������
    procedure OnMyTimer(Sender: TObject);
  public
    constructor Create(AClass: TClass; MaxPools, MinPools: Integer; Config:TDBConfig);
    destructor Destroy; override;

    function GetObj: TObject; //��ȡ����
    procedure PutObj(Instance: TObject); //�ͷŶ���


    property ObjectClass: TClass read FObjectClass;
    property MaxCacheSize: Integer read FMaxCacheSize; //���Ӵ�С
    property CacheHit: Cardinal read FCacheHit; //���ó����ж������
    property CreationCount: Cardinal read FCreationCount; //�����������
    property RequestCount: Cardinal read FRequestCount; //����ش���
    property RealCount: Integer read GetCurObjCount; //���ж�������
    property LockObjCount: Integer read GetLockObjCount; //���ӷ�æ�Ķ�������
    property HourInterval: Integer read FHourInterval write SetFHourInterval;
    procedure StartAutoFree; //�����Զ�����
    procedure StopAutoFree; //�ر��Զ�����
  end;


  { TObjectPool<T> }
  { ͬ���Ƕ����, ��֧��ģ�� }
  { �÷�:
       ��һ��ȫ�ֵĵط�����
    var
       Pooler: TObjectPool<Ҫ�ռ�������>;

    �õ��ĵط�
       obj := Pooler.GetObj;
       try

       finally

         Pooler.PutObj;
       end;

    ��ʼ��

    initialization
       Pooler := TObjectPool<Ҫ�ռ�������>.Create;
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
  // ���ڷ���ģ�嶨��ľ���ģ��
  FQryPool: TObjectPool<TFDQuery>; //Query����
  FDBPool,FSQLiteDBPool: TObjectPool<TFDConnection>; //Database����
  FListPool:TObjectPool<TStringList>; //List����
  FDicPool:TObjectPool<TDictionary<string,string>>; //Dic����
  FHTTPPool:TObjectPool<TIdHTTP>; //HTTP����
  {FProcMgr: TObjectPool<TFDStoredProc>; //Database����
  FDspMgr:TObjectPool<TDataSetProvider>;//DSP����
  FCDSMgr:TObjectPool<TClientDataSet>;//cds����
  FDSMgr :TObjectPool<TDataSource>;//ds����
  FUniSQLMgr:TObjectPool<TUniSQL>;//ִ��SQL����
  FUniSPMgr :TObjectPool<TUniStoredProc>;//�洢���̳��� }

  function QryPool: TObjectPool<TFDQuery>;
  function DBPool: TObjectPool<TFDConnection>;
  function SQLiteDBPool: TObjectPool<TFDConnection>;
  function ListPool: TObjectPool<TStringList>;
  function DicPool: TObjectPool<TDictionary<string,string>>;
  function HTTPPool: TObjectPool<TIdHTTP>;
  procedure DoPoolStatus(AJob: PQJob);

implementation

// ����Qry��
function QryPool: TObjectPool<TFDQuery>;
begin
  if not Assigned(FQryPool) then
    FQryPool := TObjectPool<TFDQuery>.Create(DBConfig.PoolNum * 10, DBConfig.PoolNum);
  Result := FQryPool;
end;
// ����SQLiteDB��
function SQLiteDBPool: TObjectPool<TFDConnection>;
begin
  if not Assigned(FSQLiteDBPool) then
    FSQLiteDBPool := TObjectPool<TFDConnection>.Create(SQLiteConfig.PoolNum, 1,SQLiteConfig);
  Result := FSQLiteDBPool;
end;
// ����MSSQLDB��
function DBPool: TObjectPool<TFDConnection>;
begin
  try
    if not Assigned(FDBPool) then
      FDBPool := TObjectPool<TFDConnection>.Create(DBConfig.PoolNum, 1,DBConfig);
    Result := FDBPool;
  except
    raise Exception.Create('���ݿ�����ʧ�ܣ��������ݿ����û����������ӣ�');
  end;
end;
// ����List��
function ListPool: TObjectPool<TStringList>;
begin
  if not Assigned(FListPool) then
    FListPool := TObjectPool<TStringList>.Create(DBConfig.PoolNum * 10, DBConfig.PoolNum);
  Result := FListPool;
end;
// �����ֵ��
function DicPool: TObjectPool<TDictionary<string,string>>;
begin
  if not Assigned(FDicPool) then
    FDicPool := TObjectPool<TDictionary<string,string>>.Create(DBConfig.PoolNum * 10, DBConfig.PoolNum);
  Result := FDicPool;
end;
// ����http��
function HTTPPool: TObjectPool<TIdHTTP>;
begin
  if not Assigned(FHTTPPool) then
    FHTTPPool := TObjectPool<TIdHTTP>.Create(DBConfig.PoolNum * 10, DBConfig.PoolNum);
  Result := FHTTPPool;
end;

// ��¼������
procedure DoPoolStatus(AJob: PQJob);
var
  Str:string;
begin
  if Assigned(FQryPool) then
  begin
    Str := Str+#13#10+'Query��:'
      +'������:'+IntToStr(FQryPool.MaxCacheSize)
      +';�ش�С:'+IntToStr(FQryPool.RealCount)
      +';��æ��:'+IntToStr(FQryPool.LockObjCount)
      +';������:'+IntToStr(FQryPool.CreationCount)
      +';������:'+IntToStr(FQryPool.RequestCount)
      +';������:'+IntToStr(FQryPool.CacheHit);
  end;
  if Assigned(FDBPool) then
  begin
    Str := Str+#13#10+'MSSQLDB��:'
      +'������:'+IntToStr(FDBPool.MaxCacheSize)
      +';�ش�С:'+IntToStr(FDBPool.RealCount)
      +';��æ��:'+IntToStr(FDBPool.LockObjCount)
      +';������:'+IntToStr(FDBPool.CreationCount)
      +';������:'+IntToStr(FDBPool.RequestCount)
      +';������:'+IntToStr(FDBPool.CacheHit);
  end;
  if Assigned(FSQLiteDBPool) then
  begin
    Str := Str+#13#10+'SQLiteDB��:'
      +'������:'+IntToStr(FSQLiteDBPool.MaxCacheSize)
      +';�ش�С:'+IntToStr(FSQLiteDBPool.RealCount)
      +';��æ��:'+IntToStr(FSQLiteDBPool.LockObjCount)
      +';������:'+IntToStr(FSQLiteDBPool.CreationCount)
      +';������:'+IntToStr(FSQLiteDBPool.RequestCount)
      +';������:'+IntToStr(FSQLiteDBPool.CacheHit);
  end;
  if Assigned(FListPool) then
  begin
    Str := Str+#13#10+'List��:'
      +'������:'+IntToStr(FListPool.MaxCacheSize)
      +';�ش�С:'+IntToStr(FListPool.RealCount)
      +';��æ��:'+IntToStr(FListPool.LockObjCount)
      +';������:'+IntToStr(FListPool.CreationCount)
      +';������:'+IntToStr(FListPool.RequestCount)
      +';������:'+IntToStr(FListPool.CacheHit);
  end;
  if Str <> '' then
    Logs.Post(llHint,Str);
end;




const
  MSecsPerMins = SecsPerMin * MSecsPerSec;
  //�������ķ���

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
    FMaxCacheSize := 20;  //ϵͳĬ��Ϊ20������
  if FMinCacheSize > FMaxCacheSize then
    FMinCacheSize := FMaxCacheSize; //ϵͳĬ����СֵΪ0
  FCacheHit := 0;
  FCreationCount := 0;
  FRequestCount := 0;
  IniMinPools; //��ʼ����С�ض���
  //��ʱ����
  FTimer := TThreadedTimer.Create(Application.Handle, nil); //��ʱ
  FHourInterval := 1; //Ĭ�Ͽ���1Сʱ�����
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
      //���ִ��sql���̶��ߣ��ȴ�ʱ����� ,����֮������������д��ᳬʱ�����Σ�
      //Params.add('ResourceOptions.CmdExecTimeout=3');
      //�����ѯֻ����50����������
      Params.add('FetchOptions.Mode=fmAll');
      //�������&���ַ��������ݿ�ʱ��ʧ
      Params.add('ResourceOptions.MacroCreate=False');
      Params.add('ResourceOptions.MacroExpand=False');
      //try
        Connected := True;
      //except
      //  raise Exception.Create('���ݿ�����ʧ�ܣ��������ݿ����û����������ӣ�');
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
    //�ӳ���ȡδʹ�õĶ���
    for I := 0 to LockedList.Count - 1 do
    begin
      if not TPoolItem(LockedList.Items[I]).FLocked then
      begin
        Result := TPoolItem(LockedList.Items[I]).FInstance;
        TPoolItem(LockedList.Items[I]).FLocked := True;
        TPoolItem(LockedList.Items[I]).FLastTime := Now;
        Inc(FCacheHit); //�ӳ���ȡ�Ĵ���
        Break;
      end;
    end;
    //������ж���ȫ��ʹ�ã������Ƿ���Ҫ�½����ߵȴ�
    if not Assigned(Result) then
    begin
      //��δ�����½�����
      if LockedList.Count < FMaxCacheSize then //��������
      begin
        Result := CreateObject;
        Inc(FCreationCount);
        LockedList.Add(TPoolItem.Create(Result, True));
      end
      //���� �ȴ������ͷ� ��ʱ���ó�30��
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
              Inc(FCacheHit); //�ӳ���ȡ�Ĵ���
              Break;
            end;
          end;
          //������������ֶ��� �� һֱ�ȵ���ʱ
          if CurOutTime >= 5000 * 6 then //30s
          begin
            raise Exception.Create('����Ѱ�ҿ��ö���ʱ���������ύҵ��');
            Break;
          end;
          Sleep(500); //0.5����
          CurOutTime := CurOutTime + 500; //��ʱ���ó�30��
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
      //������С�ض���
      if RealCount <= FMinCacheSize then Exit;
      //�ͷų�����ò��õĶ���
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

// ���ڱ�׼ģ�嶨��ķ���ģ��
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

