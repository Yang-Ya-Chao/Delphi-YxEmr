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
   /// <summary>Redis��ȡ��</summary>
   TRedisClientClass = class(TTestCase)
   strict private
    FRedis: IRedisClient;
   private
    /// <summary>REDIS ��ַ</summary>
    FRedisUrl:String;
    /// <summary>REDIS �˿�</summary>
    FRedisPort:Word;
   public
     /// <summary>������;������RedisUrl����ַ��RedisPort���˿� </summary>
     constructor Create; overload;
     destructor Destroy; override;
     /// <summary>����REDIS</summary>
     function Connect:TRedisClientClass;


     //****�ַ���****
     /// <summary>����key value</summary>
     function SetKeyValue(aKey,Value:String):TRedisClientClass; overload;
     /// <summary>����key value ����ʱ��(��)</summary>
     function SetKeyValue(aKey,Value:string;ASecsExpire: UInt64):TRedisClientClass; overload;
     /// <summary>���ö��key value</summary>
     function MSET(const AKeysValues: array of string): boolean;

     /// <summary>���KEY������������KEY value;���������κβ���</summary>
     function SETNX(const aKey, aValue: string): boolean; overload;

     /// <summary>����key����ʱ��(��)</summary>
     function EXPIRE(const aKey: string; AExpireInSecond: UInt32): boolean;
     /// <summary>��ȡKEY value</summary>
     function GetKeyValue(aKey:string):String;
     /// <summary>ɾ�����key</summary>
     function DelKey(const aKeys: array of string): Integer;overload;
     /// <summary>ɾ������key</summary>
     function DelKey(const aKeys: string): Boolean;overload;
     /// <summary>��ȡ ���в����� keys</summary>
     function KEYS_T(const AKeyPattern: string): TArray<string>;
     function KEYS(const AKeyPattern: string): TRedisArray;
     /// <summary>��ȡkeys��ʣ��ʱ��</summary>
     /// <code>
     ///      -1:��ʾδ���ù���ʱ��
     ///      -2:��ʾû�����KEYֵ
     ///      >0:��ʾʣ�����ʱ��
     /// </code>
     function TTL(const aKey: string): Integer;
     /// <summary>�ж�KEY�Ƿ����</summary>
     function EXISTS(const aKey: string): boolean;


     ///<summary>****hash(��ϣ)****
     ///Redis hash ��һ�� string ���͵� field���ֶΣ� �� value��ֵ�� ��ӳ���
     ///hash �ر��ʺ����ڴ洢����
     ///Redis ��ÿ�� hash ���Դ洢 232 - 1 ��ֵ�ԣ�40���ڣ�
     ///</summary>
     /// <summary>��ϣ���� KEY  filed  avlaue</summary>
     function HSET(const aKey, aField: string; aValue: string): Integer;overload;
     /// <summary>��ϣ���� KEY  ���filed  ���avlaue��fiels�ĸ���=values����</summary>
     function HMSET(const aKey: string; aFields: TArray<string>;aValues: TArray<string>):Boolean; overload;
     /// <summary>��ϣ��ȡ KEY  filed��ֵ</summary>
     function HGET(const aKey, aField: string): String; overload;
     /// <summary>��ϣ��ȡ ���key Files ��ֵ</summary>
     function HMGET(const aKey: string; aFields: TArray<string>): TRedisArray;
     /// <summary>��ϣ��ȡ ���key Files ��ֵ</summary>
     function HMGET_T(const aKey: string; aFields: TArray<string>): TArray<string>;
     /// <summary>��ϣɾ�� һ��key files</summary>
     function HDEL(const aKey,aField:string): Integer; overload;
     /// <summary>��ϣɾ�� һ�����߶��key files</summary>
     function HDEL(const aKey: string; aFields: TArray<string>): Integer; overload;


     ///<summary>***lists(����)****
     ///   Redis�б��Ǽ򵥵��ַ����б����ղ���˳������
     ///   ��������һ��Ԫ�ص��б��ͷ������ߣ�����β�����ұߣ�
     ///   һ���б������԰��� 232 - 1 ��Ԫ�� (4294967295, ÿ���б�����40�ڸ�Ԫ��)��
     ///</summary>
     ///<summary>��aListKey�����з���һ������ value </summary>
     function RPUSH(const aListKey: string; aValue:string): Integer;overload;
     function RPUSH(const aListKey: string; aValues: array of string): Integer;overload;
     /// <summary>Redis Rpushx �������ڽ�һ��ֵ���뵽�Ѵ��ڵ��б�β��(���ұ�)������б����ڣ�������Ч��</summary>
     function RPUSHX(const aListKey: string; aValue:string): Integer;overload;
     function RPUSHX(const aListKey: string; aValues: array of string): Integer;overload;
     ///<summary>Lpushx ��һ��ֵ���뵽�Ѵ��ڵ��б�ͷ�����б�����ʱ������Ч��</summary>
     function LPUSHX(const aListKey: string; aValue:string): Integer;overload;
     function LPUSHX(const aListKey: string; aValues: array of string): Integer;overload;
     ///<summary>RPOP ȡaListKey���������һ�������value</summary>
     function RPOP(const aListKey: string):string; overload;
     ///<summary>LPOP ȡaListKey����������һ�������value</summary>
     function LPOP(const aListKey: string):string; overload;
     ///<summary>��ȡaListKey�ĳ���</summary>
     function LLEN(const aListKey: string): Integer;
     /// <summary>
     /// Lrange �����б���ָ�������ڵ�Ԫ�أ�������ƫ���� START �� END ָ����
     ///���� 0 ��ʾ�б�ĵ�һ��Ԫ�أ� 1 ��ʾ�б�ĵڶ���Ԫ�أ��Դ����ơ�
     ///��Ҳ����ʹ�ø����±꣬�� -1 ��ʾ�б�����һ��Ԫ�أ� -2 ��ʾ�б�ĵ����ڶ���Ԫ�أ��Դ����ơ�
     /// </summary>
     function LRANGE(const aListKey: string; aIndexStart, aIndexStop: Integer): TRedisArray;
     function LRANGE_T(const aListKey: string; aIndexStart, aIndexStop: Integer): TArray<string>;


     /// <summary>
     /// ****���򼯺�sets***
     ///  Redis �� Set �� String ���͵����򼯺ϡ����ϳ�Ա��Ψһ�ģ������ζ�ż����в��ܳ����ظ������ݡ�
     ///  Redis �м�����ͨ����ϣ��ʵ�ֵģ�������ӣ�ɾ�������ҵĸ��Ӷȶ��� O(1)��
     ///  ���������ĳ�Ա��Ϊ 232 - 1 (4294967295, ÿ�����Ͽɴ洢40���ڸ���Ա)��
     /// </summary>
     /// <summary> ����һ��ֵ����ֵ�����ھͷ��룬�����򲻷���</summary>
     function SADD(const aKey, aValue: string): Integer; overload;
     /// <summary>Srem ���������Ƴ������е�һ��������ԱԪ�أ������ڵĳ�ԱԪ�ػᱻ���ԡ�</summary>
     function SREM(const aKey, aValue: string): Integer; overload;
     /// <summary> ����akey�е�Ԫ�ظ���</summary>
     function SCARD(const aKey: string): Integer;
     /// <summary> ����akey�����еĲ</summary>
     function SDIFF(const aKeys: array of string): TRedisArray;
     /// <summary> Redis Sunion ����ظ������ϵĲ����������ڵļ��� key ����Ϊ�ռ��� </summary>
     function SUNION(const aKeys: array of string): TRedisArray;
     /// <summary>
     /// ****���򼯺�sets***
     /// </summary>
     ///<summary>����REDISTcaoz</summary>
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
