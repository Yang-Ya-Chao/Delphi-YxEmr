unit uRedisClientClass;

interface

uses
  System.Variants, IdTCPClient, Winapi.Windows, Vcl.Dialogs,
  Vcl.Forms, IdTCPConnection, Vcl.Controls, System.Classes, System.SysUtils,
  IdComponent, Winapi.Messages, IdBaseComponent, Vcl.Graphics, Vcl.StdCtrls,
  Redis.Client, Redis.Commons, Redis.Values,
  TestFramework;

const
  // REDIS_SERVER_ADDRESS = '192.168.1.102';
  KEY_GEODATA = 'geodata';
  REDIS_SERVER_ADDRESS = '127.0.0.1';
  REDIS_SERVER_PORT = 6379;

type
   /// <summary>Redis读取类</summary>
   TRedisClientClass = class(TTestCase)
   strict private
    FRedis: IRedisClient;
   private
    /// <summary>REDIS 地址</summary>
    FRedisUrl:String;
    /// <summary>REDIS 端口</summary>
    FRedisPort:Word;
   public
     /// <summary>创建类;参数：RedisUrl：地址，RedisPort：端口 </summary>
     constructor Create; overload;
     destructor Destroy; override;
     /// <summary>连接REDIS</summary>
     function Connect:TRedisClientClass;


     //****字符串****
     /// <summary>设置key value</summary>
     function SetKeyValue(aKey,Value:String):TRedisClientClass; overload;
     /// <summary>设置key value 过期时间(秒)</summary>
     function SetKeyValue(aKey,Value:string;ASecsExpire: UInt64):TRedisClientClass; overload;
     /// <summary>设置多个key value</summary>
     function MSET(const AKeysValues: array of string): boolean;

     /// <summary>如果KEY不存在则设置KEY value;存在则不做任何操作</summary>
     function SETNX(const aKey, aValue: string): boolean; overload;

     /// <summary>设置key过期时间(秒)</summary>
     function EXPIRE(const aKey: string; AExpireInSecond: UInt32): boolean;
     /// <summary>获取KEY value</summary>
     function GetKeyValue(aKey:string):String;
     /// <summary>删除多个key</summary>
     function DelKey(const aKeys: array of string): Integer;overload;
     /// <summary>删除单个key</summary>
     function DelKey(const aKeys: string): Boolean;overload;
     /// <summary>获取 所有参数的 keys</summary>
     function KEYS_T(const AKeyPattern: string): TArray<string>;
     function KEYS(const AKeyPattern: string): TRedisArray;
     /// <summary>获取keys的剩余时间</summary>
     /// <code>
     ///      -1:表示未设置过期时间
     ///      -2:表示没有这个KEY值
     ///      >0:表示剩余过期时间
     /// </code>
     function TTL(const aKey: string): Integer;
     /// <summary>判断KEY是否存在</summary>
     function EXISTS(const aKey: string): boolean;


     ///<summary>****hash(哈希)****
     ///Redis hash 是一个 string 类型的 field（字段） 和 value（值） 的映射表，
     ///hash 特别适合用于存储对象。
     ///Redis 中每个 hash 可以存储 232 - 1 键值对（40多亿）
     ///</summary>
     /// <summary>哈希设置 KEY  filed  avlaue</summary>
     function HSET(const aKey, aField: string; aValue: string): Integer;overload;
     /// <summary>哈希设置 KEY  多个filed  多个avlaue；fiels的个数=values个数</summary>
     function HMSET(const aKey: string; aFields: TArray<string>;aValues: TArray<string>):Boolean; overload;
     /// <summary>哈希获取 KEY  filed的值</summary>
     function HGET(const aKey, aField: string): String; overload;
     /// <summary>哈希获取 多个key Files 的值</summary>
     function HMGET(const aKey: string; aFields: TArray<string>): TRedisArray;
     /// <summary>哈希获取 多个key Files 的值</summary>
     function HMGET_T(const aKey: string; aFields: TArray<string>): TArray<string>;
     /// <summary>哈希删除 一个key files</summary>
     function HDEL(const aKey,aField:string): Integer; overload;
     /// <summary>哈希删除 一个或者多个key files</summary>
     function HDEL(const aKey: string; aFields: TArray<string>): Integer; overload;


     ///<summary>***lists(链表)****
     ///   Redis列表是简单的字符串列表，按照插入顺序排序。
     ///   你可以添加一个元素到列表的头部（左边）或者尾部（右边）
     ///   一个列表最多可以包含 232 - 1 个元素 (4294967295, 每个列表不超过40亿个元素)。
     ///</summary>
     ///<summary>往aListKey链表中放入一个或多个 value </summary>
     function RPUSH(const aListKey: string; aValue:string): Integer;overload;
     function RPUSH(const aListKey: string; aValues: array of string): Integer;overload;
     /// <summary>Redis Rpushx 命令用于将一个值插入到已存在的列表尾部(最右边)。如果列表不存在，操作无效。</summary>
     function RPUSHX(const aListKey: string; aValue:string): Integer;overload;
     function RPUSHX(const aListKey: string; aValues: array of string): Integer;overload;
     ///<summary>Lpushx 将一个值插入到已存在的列表头部，列表不存在时操作无效。</summary>
     function LPUSHX(const aListKey: string; aValue:string): Integer;overload;
     function LPUSHX(const aListKey: string; aValues: array of string): Integer;overload;
     ///<summary>RPOP 取aListKey链表中最后一个放入的value</summary>
     function RPOP(const aListKey: string):string; overload;
     ///<summary>LPOP 取aListKey链表中最先一个放入的value</summary>
     function LPOP(const aListKey: string):string; overload;
     ///<summary>获取aListKey的长度</summary>
     function LLEN(const aListKey: string): Integer;
     /// <summary>
     /// Lrange 返回列表中指定区间内的元素，区间以偏移量 START 和 END 指定。
     ///其中 0 表示列表的第一个元素， 1 表示列表的第二个元素，以此类推。
     ///你也可以使用负数下标，以 -1 表示列表的最后一个元素， -2 表示列表的倒数第二个元素，以此类推。
     /// </summary>
     function LRANGE(const aListKey: string; aIndexStart, aIndexStop: Integer): TRedisArray;
     function LRANGE_T(const aListKey: string; aIndexStart, aIndexStop: Integer): TArray<string>;


     /// <summary>
     /// ****无序集合sets***
     ///  Redis 的 Set 是 String 类型的无序集合。集合成员是唯一的，这就意味着集合中不能出现重复的数据。
     ///  Redis 中集合是通过哈希表实现的，所以添加，删除，查找的复杂度都是 O(1)。
     ///  集合中最大的成员数为 232 - 1 (4294967295, 每个集合可存储40多亿个成员)。
     /// </summary>
     /// <summary> 放入一个值，如值不存在就放入，存在则不放入</summary>
     function SADD(const aKey, aValue: string): Integer; overload;
     /// <summary>Srem 命令用于移除集合中的一个或多个成员元素，不存在的成员元素会被忽略。</summary>
     function SREM(const aKey, aValue: string): Integer; overload;
     /// <summary> 返回akey中的元素个数</summary>
     function SCARD(const aKey: string): Integer;
     /// <summary> 返回akey集合中的差集</summary>
     function SDIFF(const aKeys: array of string): TRedisArray;
     /// <summary> Redis Sunion 命令返回给定集合的并集。不存在的集合 key 被视为空集。 </summary>
     function SUNION(const aKeys: array of string): TRedisArray;
     /// <summary>
     /// ****有序集合sets***
     /// </summary>
     ///<summary>其它REDISTcaoz</summary>
     property Redis:IRedisClient  read FRedis ;

   end;

implementation




{ TRedisClientClass }

function TRedisClientClass.Connect:TRedisClientClass;
begin
  //
  result:=Self;
end;

constructor TRedisClientClass.Create;
begin
  FRedisUrl:=REDIS_SERVER_ADDRESS;
  FRedisPort:=REDIS_SERVER_PORT;
  if Assigned(FRedis) then
    FRedis:=nil;
  try
    FRedis := TRedisClient.Create(FRedisUrl, FRedisPort,'indy');
  except

  end;
  //FRedis.Connect;
end;

function TRedisClientClass.DelKey(const aKeys: array of string): Integer;
begin
  Result:=FRedis.DEL(aKeys)
end;

function TRedisClientClass.DelKey(const aKeys: string): Boolean;
var
  Arraystr:array of string;
//  iRe:integer;
begin
  SetLength(Arraystr,1);
  Arraystr[0]:=aKeys;
  Result:=FRedis.DEL(Arraystr)>0;
end;

destructor TRedisClientClass.Destroy;
begin
  FRedis.Disconnect;
  FRedis:=nil;
  inherited;
end;

function TRedisClientClass.EXISTS(const aKey: string): boolean;
begin
  Exit(FRedis.EXISTS(aKey));
end;

function TRedisClientClass.EXPIRE(const aKey: string;
  AExpireInSecond: UInt32): boolean;
begin
  Exit(FRedis.EXPIRE(akey,AExpireInSecond))
end;

function TRedisClientClass.GetKeyValue(aKey: string): String;
//var
//  Res:String;
begin
  Result:= FRedis.Get(aKey);
//  FRedis.Get(aKey,Res);
//  Exit(Res)
end;

function TRedisClientClass.HDEL(const aKey: string;
  aFields: TArray<string>): Integer;
begin
  Exit(FRedis.HDEL(aKey,aFields));
end;

function TRedisClientClass.HDEL(const aKey, aField: string): Integer;
var
  AryFileds:TArray<string>;
begin
  SetLength(AryFileds,1);
  AryFileds[0]:=aField;
  Exit(FRedis.HDEL(aKey,AryFileds));
end;

function TRedisClientClass.HGET(const aKey, aField: string): string;
var
  aValue:String;
begin
  aValue:='';
  FRedis.HGET(aKey, aField,aValue);
  Exit(aValue);
end;

function TRedisClientClass.HMGET(const aKey: string;
  aFields: TArray<string>): TRedisArray;
begin
  Exit(FRedis.HMGET(aKey,aFields));
end;

function TRedisClientClass.HMGET_T(const aKey: string;
  aFields: TArray<string>): TArray<string>;
var
  ARedisArray:TRedisArray;
  aValue:TRedisString;
  i:integer;
begin
  ARedisArray:=FRedis.HMGET(aKey,aFields);
  SetLength(Result,High(ARedisArray.Value));
  i:=0;
  for aValue in ARedisArray.Value do
  begin
    Result[i]:=aValue.Value;
    Inc(i);
  end;
end;

function TRedisClientClass.HMSET(const aKey: string; aFields,
  aValues: TArray<string>):Boolean;
begin
  Result:=True;
  Try
    FRedis.HMSET(aKey,aFields,aValues);
  Except
    Exit(False)
  End;
end;

function TRedisClientClass.HSET(const aKey, aField: string;
  aValue: string): Integer;
begin
  Exit(FRedis.HSET(aKey,aField,aValue));
end;

function TRedisClientClass.KEYS(const AKeyPattern: string): TRedisArray;
begin
  Exit(FRedis.KEYS(AKeyPattern));
end;

function TRedisClientClass.KEYS_T(const AKeyPattern: string): TArray<string>;
var
  ARedisArray:TRedisArray;
  key:TRedisString;
  i:integer;
begin
  ARedisArray:=FRedis.KEYS(AKeyPattern);
  i:=0;
  SetLength(Result,High(ARedisArray.Value));
  for key in ARedisArray.Value do
  begin
    Result[i]:=key.Value;
    Inc(i);
  end;
end;

function TRedisClientClass.LLEN(const aListKey: string): Integer;
begin
  Exit(FRedis.LLEN(aListKey));
end;

function TRedisClientClass.LPOP(const aListKey: string): string;
var
  aValue: string;
begin
  FRedis.LPOP(aListKey,aValue);
  Exit(aValue);
end;

function TRedisClientClass.LPUSHX(const aListKey: string;
  aValues: array of string): Integer;
begin
  Exit(FRedis.LPUSHX(aListKey,aValues));
end;

function TRedisClientClass.LRANGE(const aListKey: string; aIndexStart,
  aIndexStop: Integer): TRedisArray;
begin
  Exit(FRedis.LRANGE(aListKey,aIndexStart,aIndexStop));
end;

function TRedisClientClass.LRANGE_T(const aListKey: string; aIndexStart,
  aIndexStop: Integer): TArray<string>;
var
  ARedisArray:TRedisArray;
  values:TRedisString;
  i:integer;
begin
  ARedisArray:=FRedis.LRANGE(aListKey,aIndexStart,aIndexStop);
  i:=0;
  SetLength(Result,High(ARedisArray.Value));
  for values in ARedisArray.Value do
  begin
    Result[i]:=values.Value;
    Inc(i);
  end;

end;

function TRedisClientClass.LPUSHX(const aListKey: string;
  aValue: string): Integer;
var
  values:array of string;
begin
  SetLength(values,1);
  values[0]:=aValue;
  Exit(FRedis.LPUSHX(aListKey,values));

end;

function TRedisClientClass.MSET(const AKeysValues: array of string): boolean;
begin
  Exit(FRedis.MSET(AKeysValues));
end;

function TRedisClientClass.RPOP(const aListKey: string): string;
var
  aValue: string;
begin
  FRedis.RPOP(aListKey,aValue);
  Exit(aValue);
end;

function TRedisClientClass.RPUSH(const aListKey: string;aValue: string): Integer;
var
  values:array of string;
begin
  SetLength(values,1);
  values[0]:=aValue;
  Exit(FRedis.RPUSH(aListKey,values));
end;

function TRedisClientClass.RPUSH(const aListKey: string;
  aValues: array of string): Integer;
begin
  Exit(FRedis.RPUSH(aListKey,aValues));
end;

function TRedisClientClass.RPUSHX(const aListKey: string;
  aValue: string): Integer;
var
  values:array of string;
begin
  SetLength(values,1);
  values[0]:=aValue;
  Exit(FRedis.RPUSHX(aListKey,values));

end;

function TRedisClientClass.RPUSHX(const aListKey: string;
  aValues: array of string): Integer;
begin
  Exit(FRedis.RPUSHX(aListKey,aValues));
end;

function TRedisClientClass.SADD(const aKey, aValue: string): Integer;
begin
  Exit(FRedis.SADD(aKey,aValue))
end;

function TRedisClientClass.SCARD(const aKey: string): Integer;
begin
  Exit(FRedis.SCARD(akey));
end;

function TRedisClientClass.SDIFF(const aKeys: array of string): TRedisArray;
begin
  Exit(FRedis.SDIFF(akeys));
end;

function TRedisClientClass.SetKeyValue(aKey, Value: string;
  ASecsExpire: UInt64): TRedisClientClass;
begin
  FRedis.&SET(aKey,Value,ASecsExpire);
  Exit(self);
end;

function TRedisClientClass.SETNX(const aKey, aValue: string): boolean;
begin
  Exit(FRedis.SETNX(aKey, aValue));
end;

function TRedisClientClass.SREM(const aKey, aValue: string): Integer;
begin
  Exit(FRedis.SREM(aKey,aValue));
end;

function TRedisClientClass.SUNION(const aKeys: array of string): TRedisArray;
begin
  Exit(FRedis.SUNION(aKeys));
end;

function TRedisClientClass.SetKeyValue(aKey, Value: String):TRedisClientClass;
begin
  FRedis.&SET(aKey,Value);
  Exit(self);
end;

function TRedisClientClass.TTL(const aKey: string): Integer;
begin
  Exit(FRedis.TTL(akey));
end;

end.
