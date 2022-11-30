/////����Ԫ���ṩ���̵߳��ã���֤�߳���ȫ
unit UpubFun;

interface

uses
  System.SysUtils, uEncry, System.Classes, System.Win.ComObj,
  Windows, Messages, System.DateUtils, System.Variants, Registry, Vcl.Forms,
  TLhelp32, PsAPI, SyncObjs,IdIPWatch,uConfig;

type
  TCPUID = array[1..4] of LongInt;

type
  TProcessCpuUsage = record
  private
    FLastUsed, FLastTime: Int64;
    FCpuCount: Integer;
  public
    class function Create: TProcessCpuUsage; static;
    function Current: Single;
  end;

    //��ע��Win������
procedure SelfAutoRun(R: Boolean);

    //���CPU���к�
function CheckCPUID: Boolean;

    //��ȡע������
function GetRegisTime:Int64;

    //ע��CPU���к�
function RegisterCPUID(CDATA: string): Boolean;

    //��ȡ����ʱ��
function GetTime: TDateTime;

    //��ȡCPUʹ����
function GetCPURate: Single;

    //��ȡ�ڴ�ʹ��
function CurrentMemoryUsage: Cardinal;

    //��ȡ�߳���
function GetProcessThreadCount: integer;

    //��ȡ��������ʱ��
function GetRunTimeInfo: string;

    //��������ʽ��
function SetHTTPCount(x: integer): string;

    //��ȡ������
function GetCPUIDStr: string;

   //��ȡ����IP
function GetLocalIP: String;

   //��ȡ����ϵͳ�汾��
function GetVersion: integer;

var
  //�ź���ID
  SignalAllID,SignalFalseID,SignalPools:Integer;
  //����ʼʱ��
  StartRunTime: Int64 = 0;
  { TProcessCpuUsage }
  ProcessCpuUsage: TProcessCpuUsage = (
    FLastUsed: 0;
    FLastTime: 0;
    FCpuCount: 0
  );

implementation

function GetVersion: integer;
var  osVerInfo: TOSVersionInfo;
begin
  Result := 5; //Ĭ����xp�����汾��
  osVerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  if GetVersionEx(osVerInfo) then
    Result := osVerInfo.dwMajorVersion+osVerInfo.dwMinorVersion;
end;


function GetLocalIP: String;
var
  IdIPWatch: TIdIPWatch;
begin
  IdIPWatch := TIdIPWatch.Create(nil);
  try
    IdIPWatch.historyenabled := False;
    Result := IdIPWatch.LocalIP;
  finally
    IdIPWatch.Free;
  end;
end;

class function TProcessCpuUsage.Create: TProcessCpuUsage;
begin
  Result.FLastTime := 0;
  Result.FLastUsed := 0;
  Result.FCpuCount := 0;
end;

function TProcessCpuUsage.Current: Single;
var
  Usage, ACurTime: UInt64;
  CreateTime, ExitTime, IdleTime, UserTime, KernelTime: TFileTime;

  function FileTimeToI64(const ATime: TFileTime): Int64;
  begin
    Result := (Int64(ATime.dwHighDateTime) shl 32) + ATime.dwLowDateTime;
  end;

  function GetCPUCount: Integer;
  var
    SysInfo: TSystemInfo;
  begin
    GetSystemInfo(SysInfo);
    Result := SysInfo.dwNumberOfProcessors;
  end;

begin
  Result := 0;
  if GetProcessTimes(GetCurrentProcess, CreateTime, ExitTime, KernelTime, UserTime) then
  begin
    ACurTime := GetTickCount;
    Usage := FileTimeToI64(UserTime) + FileTimeToI64(KernelTime);
    if FLastTime <> 0 then
      Result := (Usage - FLastUsed) / (ACurTime - FLastTime) / FCpuCount / 100
    else
      FCpuCount := GetCpuCount;
    FLastUsed := Usage;
    FLastTime := ACurTime;
  end;
end;

function GetCPURate: Single;
begin
  result := ProcessCpuUsage.Current;
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
    Result := IntToStr(a) + 'W';
    if c > 0 then
      Result := Result + INTTOSTR(c);
  end
  else
    Result := IntToStr(c);
  if b > 0 then
  begin
    a := x div 100000000;
    c := x mod 100000000;
    b := c div 10000;
    if b > 0 then
      c := c mod 10000;
    Result := IntToStr(a) + 'Y';
    if b > 0 then
      Result := Result + INTTOSTR(b) + 'W';
    if c > 0 then
      Result := Result + INTTOSTR(c);
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


  Result := Result + IntToStr(lvDay) + '��';
  Result := Result + IntToStr(lvHour) + 'Сʱ';
  Result := Result + IntToStr(lvMin) + '����';
  Result := Result + IntToStr(lvSec) + '��';
end;


// ȡ�õ�ǰ����ռ���ڴ�
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

// ȡ�õ�ǰ���̵��߳���
function GetProcessThreadCount: integer;
var
  SnapProcHandle: THandle;
  ThreadEntry: TThreadEntry32;
  Next: boolean;
begin
  result := 0;
  try
    SnapProcHandle := CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
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


function GetRegisTime:Int64;
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
    //yxsoftΪ����Ȩ�� 100�� ���˶�����
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
    //���������Դ�http://time.tianqi.com/��ҳ��ȡʱ��
    //�����ȡ���ص���ʱ��
    Time := GetTime;
    if (Time <> 0) then
      Result := IDATE - StrToInt(FormatDateTime('YYYYMMDD', Time))
    else
      Result := IDATE - StrToInt(FormatDateTime('YYYYMMDD', Now));
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
    //yxsoftΪ����Ȩ��
    if CDate = admin then Exit(True);
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
    //���������Դ�http://time.tianqi.com/��ҳ��ȡʱ��
    //�����ȡ���ص���ʱ��
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
    Ini.SaveToFile(ChangeFileExt(ParamStr(0), '.ini'));
  except
    Exit;
  end;
  Result := True;
end;

function GetTime: TDateTime;
var
  XmlHttp: Variant;
  datetxt: string;
  DateLst: TStringList;
  mon: string;
  timeGMT, GetNetTime: TDateTime;
begin
  result := 0;
  try
    try
      XmlHttp := createoleobject('Microsoft.XMLHTTP');
      try
        XmlHttp.Open('Get', 'http://time.tianqi.com/', False);
        XmlHttp.send;
        datetxt := XmlHttp.getResponseHeader('Date');
      except
        Exit;
      end;
      //if datetxt = '' then Exit;
      datetxt := Copy(datetxt, Pos(',', datetxt) + 1, 100);
      datetxt := StringReplace(datetxt, 'GMT', '', []);
      datetxt := Trim(datetxt);
      DateLst := TStringList.Create;
      while Pos(' ', datetxt) > 0 do
      begin
        DateLst.Add(Copy(datetxt, 1, Pos(' ', datetxt) - 1));
        datetxt := Copy(datetxt, Pos(' ', datetxt) + 1, 100);
      end;
      DateLst.Add(datetxt);
      if DateLst.Count < 1 then
        Exit;
      if DateLst[1] = 'Jan' then
        mon := '01'
      else if DateLst[1] = 'Feb' then
        mon := '02'
      else if DateLst[1] = 'Mar' then
        mon := '03'
      else if DateLst[1] = 'Apr' then
        mon := '04'
      else if DateLst[1] = 'Mar' then
        mon := '05'
      else if DateLst[1] = 'Jun' then
        mon := '06'
      else if DateLst[1] = 'Jul' then
        mon := '07'
      else if DateLst[1] = 'Aug' then
        mon := '08'
      else if DateLst[1] = 'Sep' then
        mon := '09'
      else if DateLst[1] = 'Oct' then
        mon := '10'
      else if DateLst[1] = 'Nov' then
        mon := '11'
      else if DateLst[1] = 'Dec' then
        mon := '12';
      timeGMT := StrToDateTime(DateLst[2] + '-' + mon + '-' + DateLst[0] + ' ' +
        DateLst[3]);
      GetNetTime := IncHour(timeGMT, 8);
    finally
      if Assigned(DateLst) then
        FreeAndNil(DateLst);
      XmlHttp := unassigned;
    end;
    Result := GetNetTime;
  except

  end;
end;

procedure SelfAutoRun(R: Boolean);
const
  KEY_WOW64_64KEY = $0100;
  App_Key = 'YxEmr Service';

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
      //��Ҫע����GetNativeSystemInfo ������Windows XP ��ʼ���У�
      //�� IsWow64Process ������ Windows XP with SP2 �Լ� Windows Server 2003 with SP1 ��ʼ���С�
      //����ʹ�øú�����ʱ�������GetProcAddress ��
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

