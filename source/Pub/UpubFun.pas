/////本单元仅提供主线程调用，保证线程完全
unit UpubFun;

interface

uses
  System.SysUtils, uEncry, System.Classes, System.Win.ComObj, Windows, Messages,
  System.DateUtils, System.Variants, Registry, Vcl.Forms, TLhelp32, PsAPI,
  SyncObjs, WinSock, uConfig, Vcl.Controls, QWorker, Qjson,
  System.Net.HttpClientComponent;

type
  TCPUID = array[1..4] of LongInt;

  TQSystemTimes = record
    IdleTime, UserTime, KernelTime: UInt64;
  end;

    //自注册Win自启动
procedure SelfAutoRun(R: Boolean);
    //是否64位系统

function IsWoW64: Boolean;

    //检测CPU序列号
function CheckCPUID: Boolean;

    //获取注册天数
function GetRegisTime: Int64;

    //注册CPU序列号
function RegisterCPUID(CDATA: string): Boolean;

    //获取网络时间
function GetTime: TDateTime;

    //获取CPU使用率
function GetCpuUsage: Double;

    //获取内存使用
function CurrentMemoryUsage: Cardinal;

    //获取线程数
function GetProcessThreadCount: integer;

    //获取程序运行时间
function GetRunTimeInfo: string;

    //请求数格式化
function SetHTTPCount(x: integer): string;

    //获取机器码
function GetCPUIDStr: string;

   //获取本机IP
function GetLocalIP(InternetIP: Boolean = False): string;

   //获取IP列表
function GetIPList: string;

   //获取操作系统版本号
function GetVersion: integer;

 //获取程序版本号
function GetBuildInfo: string;

var
  FLastTimes: TQSystemTimes;
  //信号量ID
  SignalAllID, SignalFalseID, SignalPools: Integer;
  //服务开始时间
  StartRunTime: Int64 = 0;

const
  BatAdmin = '@echo off' + #13#10 + 'echo 获取Administrator权限' + #13#10 + 'cacls.exe "%SystemDrive%\System Volume Information" >nul 2>nul' + #13#10 + 'if %errorlevel%==0 goto Admin' + #13#10 + 'if exist "%temp%\getadmin.vbs" del /f /q "%temp%\getadmin.vbs"' + #13#10 + 'echo Set RequestUAC = CreateObject^("Shell.Application"^)>"%temp%\getadmin.vbs"' + #13#10 + 'echo RequestUAC.ShellExecute "%~s0","","","runas",1 >>"%temp%\getadmin.vbs"' + #13#10 + 'echo WScript.Quit >>"%temp%\getadmin.vbs"' + #13#10 + '"%temp%\getadmin.vbs" /f' + #13#10 + 'if exist "%temp%\getadmin.vbs" del /f /q "%temp%\getadmin.vbs"' + #13#10 + 'exit' + #13#10 + ':Admin' + #13#10 + 'echo 成功取得Administrator权限' + #13#10;

implementation

function GetBuildInfo: string; //获取版本号
var
  verinfosize: DWORD;
  verinfo: pointer;
  vervaluesize: dword;
  vervalue: pvsfixedfileinfo;
  dummy: dword;
  v1, v2, v3, v4: word;
begin
  verinfosize := getfileversioninfosize(pchar(paramstr(0)), dummy);
  if verinfosize = 0 then
  begin
    dummy := getlasterror;
    result := '0.0.0.0';
  end;
  getmem(verinfo, verinfosize);
  getfileversioninfo(pchar(paramstr(0)), 0, verinfosize, verinfo);
  verqueryvalue(verinfo, '\', pointer(vervalue), vervaluesize);
  with vervalue^ do
  begin
    v1 := dwfileversionms shr 16;
    v2 := dwfileversionms and $ffff;
    v3 := dwfileversionls shr 16;
    v4 := dwfileversionls and $ffff;
  end;
  result := inttostr(v1) + '.' + inttostr(v2); //+ '.' + inttostr(v3) + '.' + inttostr(v4);
  freemem(verinfo, verinfosize);
end;

function GetVersion: integer;
var
  osVerInfo: TOSVersionInfo;
begin
  Result := 5; //默认是xp的主版本号
  osVerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  if GetVersionEx(osVerInfo) then
    Result := osVerInfo.dwMajorVersion + osVerInfo.dwMinorVersion;
end;

function GetIPList: string;
type
  TaPInAddr = array[0..10] of PInAddr;

  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  Buffer: array[0..63] of ansiChar;
  I: Integer;
  GInitData: TWSAData;
  IP: string;
begin
  Screen.Cursor := crHourGlass;
  try
    WSAStartup($101, GInitData);
    IP := '127.0.0.1';
    GetHostName(Buffer, SizeOf(Buffer));
    phe := GetHostByName(Buffer);
    if phe = nil then
    begin
         //ShowMessage(IP);
      Result := IP;
      Exit;
    end;
    pptr := PaPInAddr(phe^.h_addr_list);
    I := 0;
    while pptr^[I] <> nil do
    begin
      IP := inet_ntoa(pptr^[I]^);
      if IP = '0.0.0.0' then
        continue;
      if Result <> '' then
        Result := Result + #13#10;
      Result := Result + IP;
      Inc(I);
    end;
    WSACleanup;
  finally
    Screen.Cursor := crDefault;
  end;
end;

function GetLocalIP(InternetIP: Boolean): string;
type
  TaPInAddr = array[0..10] of PInAddr;

  PaPInAddr = ^TaPInAddr;
var
  phe: PHostEnt;
  pptr: PaPInAddr;
  Buffer: array[0..63] of ansiChar;
  I: Integer;
  GInitData: TWSAData;
  IP: string;
begin
  Screen.Cursor := crHourGlass;
  try
    WSAStartup($101, GInitData);
    IP := '127.0.0.1';
    GetHostName(Buffer, SizeOf(Buffer));
    phe := GetHostByName(Buffer);
    if phe = nil then
    begin
         //ShowMessage(IP);
      Result := IP;
      Exit;
    end;
    pptr := PaPInAddr(phe^.h_addr_list);
    if InternetIP then
    begin
      I := 0;
      while pptr^[I] <> nil do
      begin
        IP := inet_ntoa(pptr^[I]^);
        Inc(I);
      end;
    end
    else
      IP := inet_ntoa(pptr^[0]^);
    WSACleanup;
    Result := IP; //如果上网则为上网ip否则是网卡ip
  finally
    Screen.Cursor := crDefault;
  end;
end;

function GetCpuUsage: Double;
var
  Usage, Idle: UInt64;
  CreateTime, ExitTime, IdleTime, UserTime, KernelTime: TFileTime;
  CurTimes: TQSystemTimes;

  function FileTimeToI64(const ATime: TFileTime): Int64;
  begin
    Result := (Int64(ATime.dwHighDateTime) shl 32) + ATime.dwLowDateTime;
  end;

begin
  Result := 0;
  if GetProcessTimes(GetCurrentProcess, CreateTime, ExitTime, KernelTime, UserTime) then
  begin
    CurTimes.UserTime := FileTimeToI64(UserTime);
    CurTimes.KernelTime := FileTimeToI64(KernelTime);
    CurTimes.IdleTime := GetTimeStamp;
    Usage := (CurTimes.UserTime - FLastTimes.UserTime) + (CurTimes.KernelTime - FLastTimes.KernelTime);
    if FLastTimes.IdleTime <> 0 then
    begin
      Idle := CurTimes.IdleTime - FLastTimes.IdleTime;
      if Idle > 0 then
        Result := Usage / Idle / GetCpuCount / 10;
    end;
    FLastTimes := CurTimes;
  end;

end;

function SetHTTPCount(x: integer): string;
var
  a, b, c: Integer;
begin

  a := x div 10000;
  c := x mod 10000;
  b := a div 10000;
  if a > 0 then
  begin
    Result := a.ToString + 'W';
    if c > 0 then
      Result := Result + c.ToString;
  end
  else
    Result := c.ToString;
  if b > 0 then
  begin
    a := x div 100000000;
    c := x mod 100000000;
    b := c div 10000;
    if b > 0 then
      c := c mod 10000;
    Result := a.ToString + 'Y';
    if b > 0 then
      Result := Result + b.ToString + 'W';
    if c > 0 then
      Result := Result + c.ToString;
  end;
end;

function GetRunTimeInfo: string;
var
  lvMSec, lvRemain: Int64;
  lvDay, lvHour, lvMin, lvSec: Integer;
begin
  lvMSec := GetTickCount64 - StartRunTime;
  lvDay := Trunc(lvMSec / MSecsPerDay);
  lvRemain := lvMSec mod MSecsPerDay;

  lvHour := Trunc(lvRemain / (MSecsPerSec * 60 * 60));
  lvRemain := lvRemain mod (MSecsPerSec * 60 * 60);

  lvMin := Trunc(lvRemain / (MSecsPerSec * 60));
  lvRemain := lvRemain mod (MSecsPerSec * 60);

  lvSec := Trunc(lvRemain / (MSecsPerSec));

  Result := Result + IntToStr(lvDay) + '天';
  Result := Result + IntToStr(lvHour) + '小时';
  Result := Result + IntToStr(lvMin) + '分钟';
  Result := Result + IntToStr(lvSec) + '秒';
end;


// 取得当前进程占用内存
function CurrentMemoryUsage: Cardinal;
var
  pmc: TProcessMemoryCounters;
begin
  pmc.cb := SizeOf(pmc);
  if GetProcessMemoryInfo(GetCurrentProcess, @pmc, SizeOf(pmc)) then
    result := (pmc.WorkingSetSize div 1024) div 1024
  else
    RaiseLastOSError;

end;

// 取得当前进程的线程数
function GetProcessThreadCount: integer;
var
  SnapProcHandle: THandle;
  ThreadEntry: TThreadEntry32;
  Next: boolean;
begin
  result := 0;
  SnapProcHandle := CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
  try
    if SnapProcHandle <> THandle(-1) then
    begin
      ThreadEntry.dwSize := SizeOf(ThreadEntry);
      Next := Thread32First(SnapProcHandle, ThreadEntry);
      while Next do
      begin
        if (ThreadEntry.th32OwnerProcessID = GetCurrentProcessId) then
          result := result + 1;
        Next := Thread32Next(SnapProcHandle, ThreadEntry);
      end;
    end;
  finally
    CloseHandle(SnapProcHandle);
  end;
end;

function GetCPUID: TCPUID; assembler; register;
asm

  {$IF Defined(CPUX86)}
        push    ebx
        push    edi
        mov     edi, eax
        mov     eax, 1
        dw      $A20F
        stosd
        mov     eax, ebx
        stosd
        mov     eax, ecx
        stosd
        mov     eax, edx
        stosd
        pop     edi
        pop     ebx
  {$ELSEIF Defined(CPUX64)}
        PUSH    RBX
        PUSH    RDI
        MOV     RDI, RCX
        MOV     EAX, 1
        CPUID
        mov     [rdi], eax;
        mov     [rdi + 4], ebx;
        mov     [rdi + 8], ecx;
        mov     [rdi + 12], edx;
        POP     RDI
        POP     RBX
  {$IFEND}
end;

function GetCPUIDStr: string;
var
  CPUID: TCPUID;
begin
  CPUID := GetCPUID;
  Result := IntToHex(CPUID[4], 8) + IntToHex(CPUID[1], 8);
end;

function GetRegisTime: Int64;
var
  SDATE, CDate: string;
  IDATE: Int64;
  SID, CID: string;
  Time: TDateTime;
begin
  Result := 0;
  try
    SID := GetCPUIDStr;
    CDate := Ini.RegisterDate;
    //yxsoft为超级权限 100年 我人都死了
    if CDate = admin then
    begin
      Result := 36500;
      Exit;
    end;
    CDate := DeCode(CDate, SID);
    CID := Copy(CDate, 1, Pos('_', CDate) - 1);
    SDATE := Copy(CDate, Pos('_', CDate) + 1, Length(CDate));
    if CID <> SID then
      Exit;
    if SDATE = '' then
      Exit;
    IDATE := StrToIntDEF(SDATE, 0);
    if IDATE = 0 then
      Exit;
    //否则获取本地电脑时间
    Time := GetTime;
    var date := Format('%s-%s-%s',[Copy(SDATE,1,4),Copy(SDATE,5,2),Copy(SDATE,7,2)]);
    if True then

    if (Time <> 0) then
      Result := (DateTimeToMilliseconds(StrToDateTime(date)) - DateTimeToMilliseconds(Time))
         div Int64(MSecsPerSec * SecsPerMin * MinsPerHour * HoursPerDay)
    else
      Result := (DateTimeToMilliseconds(StrToDateTime(date)) - DateTimeToMilliseconds(now))
         div Int64(MSecsPerSec * SecsPerMin * MinsPerHour * HoursPerDay)
  except
    Exit;
  end;
end;

function CheckCPUID: Boolean;
var
  SDATE, CDate: string;
  IDATE: Integer;
  SID, CID: string;
  Time: TDateTime;
begin
  Result := False;
  try
    SID := GetCPUIDStr;
    CDate := Ini.RegisterDate;
    //yxsoft为超级权限
    if CDate = admin then
      Exit(True);
    CDate := DeCode(CDate, SID);
    CID := Copy(CDate, 1, Pos('_', CDate) - 1);
    SDATE := Copy(CDate, Pos('_', CDate) + 1, Length(CDate));
    if CID <> SID then
      Exit;
    if SDATE = '' then
      Exit;
    IDATE := StrToIntDEF(SDATE, 0);
    if IDATE = 0 then
      Exit;
    //能联网电脑从http://time.tianqi.com/网页拉取时间
    //否则获取本地电脑时间
    Time := GetTime;
    if (Time <> 0) then
    begin
      if IDATE < StrToInt(FormatDateTime('YYYYMMDD', Time)) then
        Exit;
    end
    else if IDATE < StrToInt(FormatDateTime('YYYYMMDD', Now)) then
      Exit;
    Result := True;
  except
  end;
end;

function RegisterCPUID(CDATA: string): Boolean;
var
  SDATE: string;
begin
  Result := False;
  try
    SDATE := CDATA;
    Ini.RegisterDate := SDATE;
    SaveToFile;
  except
    Exit;
  end;
  Result := True;
end;

//淘宝正常返回：{"api":"mtop.common.getTimestamp","v":"*","ret":["SUCCESS::接口调用成功"],"data":{"t":"1613698172343"}}
//苏宁正常返回：{"api":"mtop.common.getTimestamp","v":"*","ret":["SUCCESS::接口调用成功"],"data":{"t":"1613698172343"}}
//京东正常返回：{"api":"mtop.common.getTimestamp","v":"*","ret":["SUCCESS::接口调用成功"],"data":{"t":"1613698172343"}}

function GetTime: TDateTime;
const
  TB_HOST = 'http://api.m.taobao.com/rest/api3.do?api=mtop.common.getTimestamp';
  SN_HOST = 'http://quan.suning.com/getSysTime.do';
var
  HTTP: TNetHTTPClient;
  TM: TMemoryStream;
  B: TBytes;
  S: string;
  jo: tqjson;
  T: TDateTime;
  i: Int64;
begin
  Result := 0;
  TM := TMemoryStream.Create;
  HTTP := TNetHTTPClient.Create(nil);
  jo := tqjson.Create;
  try
    try
      HTTP.ConnectionTimeout := 1000;  //连接超时设置为 2秒
      HTTP.ResponseTimeout := 1000;     //读取超时设置为 2秒

      HTTP.Get(TB_HOST, TM);     //首先检查 淘宝网络
      SetLength(B, TM.Size);
      TM.Position := 0;
      TM.Read(B[0], TM.Size);
      S := TEncoding.UTF8.GetString(B);  //取得实际的时间字符串
    //解析字符串

      jo.Parse(S);
      if jo.ItemByPath('data.t') <> nil then
       //if jo.TryGetValue('t',jv) then
      begin
        i := jo.ItemByPath('data.t').AsInt64 div 1000;
            //相差8个小时
        T := IncHour(UnixToDateTime(i), 8);
        Exit(T);
      end;
      TM.Clear;
    //如果解析失败等，则尝试苏宁
      HTTP.Get(SN_HOST, TM);     //二次检查 苏宁网络
      SetLength(B, TM.Size);
      TM.Position := 0;
      TM.Read(B[0], TM.Size);
      S := '';
      S := TEncoding.UTF8.GetString(B);  //取得实际的时间字符串

    //解析字符串
      jo.Parse(S);

      if jo.ItemByPath('sysTime2') <> nil then
      begin
        try
          T := jo.ItemByPath('sysTime2').AsDateTime;
          Exit(T);
        except
          on E: Exception do
            Exit(0);
        end;
      end;
    except

    end;
  finally
    jo.Free;
    HTTP.Free;
    TM.Free;
  end;
end;

//function GetTime: TDateTime;
//var
//  XmlHttp: Variant;
//  datetxt: string;
//  DateLst: TStringList;
//  mon: string;
//  timeGMT, GetNetTime: TDateTime;
//begin
//  result := 0;
//  try
//    try
//      XmlHttp := createoleobject('Microsoft.XMLHTTP');
//      try
//        XmlHttp.Open('Get', 'http://time.tianqi.com/', False);
//        XmlHttp.send;
//        datetxt := XmlHttp.getResponseHeader('Date');
//      except
//        Exit;
//      end;
//      //if datetxt = '' then Exit;
//      datetxt := Copy(datetxt, Pos(',', datetxt) + 1, 100);
//      datetxt := StringReplace(datetxt, 'GMT', '', []);
//      datetxt := Trim(datetxt);
//      DateLst := TStringList.Create;
//      while Pos(' ', datetxt) > 0 do
//      begin
//        DateLst.Add(Copy(datetxt, 1, Pos(' ', datetxt) - 1));
//        datetxt := Copy(datetxt, Pos(' ', datetxt) + 1, 100);
//      end;
//      DateLst.Add(datetxt);
//      if DateLst.Count < 1 then
//        Exit;
//      if DateLst[1] = 'Jan' then
//        mon := '01'
//      else if DateLst[1] = 'Feb' then
//        mon := '02'
//      else if DateLst[1] = 'Mar' then
//        mon := '03'
//      else if DateLst[1] = 'Apr' then
//        mon := '04'
//      else if DateLst[1] = 'Mar' then
//        mon := '05'
//      else if DateLst[1] = 'Jun' then
//        mon := '06'
//      else if DateLst[1] = 'Jul' then
//        mon := '07'
//      else if DateLst[1] = 'Aug' then
//        mon := '08'
//      else if DateLst[1] = 'Sep' then
//        mon := '09'
//      else if DateLst[1] = 'Oct' then
//        mon := '10'
//      else if DateLst[1] = 'Nov' then
//        mon := '11'
//      else if DateLst[1] = 'Dec' then
//        mon := '12';
//      timeGMT := StrToDateTime(DateLst[2] + '-' + mon + '-' + DateLst[0] + ' ' + DateLst[3]);
//      GetNetTime := IncHour(timeGMT, 8);
//    finally
//      if Assigned(DateLst) then
//        FreeAndNil(DateLst);
//      XmlHttp := unassigned;
//    end;
//    Result := GetNetTime;
//  except
//
//  end;
//end;

function IsWoW64: Boolean;
var
  Kernel32Handle: THandle;
  IsWow64Process: function(Handle: THandle; var Res: BOOL): BOOL; stdcall;
  GetNativeSystemInfo: procedure(var lpSystemInfo: TSystemInfo); stdcall;
  isWoW64: Bool;
  SystemInfo: TSystemInfo;
begin
  Kernel32Handle := GetModuleHandle('KERNEL32.DLL');
  if Kernel32Handle = 0 then
    Kernel32Handle := LoadLibrary('KERNEL32.DLL');
  if Kernel32Handle <> 0 then
  begin
    try
      IsWow64Process := GetProcAddress(Kernel32Handle, 'IsWow64Process');
      //需要注意是GetNativeSystemInfo 函数从Windows XP 开始才有，
      //而 IsWow64Process 函数从 Windows XP with SP2 以及 Windows Server 2003 with SP1 开始才有。
      //所以使用该函数的时候最好用GetProcAddress 。
      GetNativeSystemInfo := GetProcAddress(Kernel32Handle, 'GetNativeSystemInfo');
      if Assigned(IsWow64Process) then
      begin
        IsWow64Process(GetCurrentProcess, isWoW64);
        Result := isWoW64 and Assigned(GetNativeSystemInfo);
        if Result then
        begin
          GetNativeSystemInfo(SystemInfo);
          Result := SystemInfo.wProcessorArchitecture in [6, 9];
        end;
      end
      else
        Result := False;
    finally
        //CloseHandle(Kernel32Handle);
    end;
  end
  else
    Result := False;
end;

procedure SelfAutoRun(R: Boolean);
const
  KEY_WOW64_64KEY = $0100;
  App_Key = 'YxEmr Service';
var
  RegF: TRegistry;
begin
  if isWoW64 then
    RegF := TRegistry.Create(KEY_WRITE or KEY_READ or KEY_WOW64_64KEY)
  else
    RegF := TRegistry.Create;
  RegF.RootKey := HKEY_LOCAL_MACHINE;
  try
    RegF.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run', True);
    try
      if R then
      begin
        if not RegF.KeyExists(App_Key) then
          RegF.WriteString(App_Key, application.ExeName);
      end
      else
      begin
        if RegF.KeyExists(App_Key) then
          RegF.DeleteValue(App_Key);
      end;
    finally
      RegF.CloseKey;
      FreeAndNil(RegF);
    end;
  except
    //nothing...
  end;
end;

end.

