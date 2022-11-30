unit uEncry;

interface



uses
  SysUtils, Classes, Winapi.Windows,CnSM4,CnBase64,CnAES;


function EnCode(Value: AnsiString; key: AnsiString =
  'AbCd1EFG2h3I4j5kLm9no4PQr8Stu6Vw5X7yz'): AnsiString;

function DeCode(Value: AnsiString; key: AnsiString =
  'AbCd1EFG2h3I4j5kLm9no4PQr8Stu6Vw5X7yz'): AnsiString;

//国密SM4
function Sm4Encode(Value:AnsiString;key:Ansistring = 'AC1hI4j5kLmPQr8S'):AnsiString;
function Sm4Decode(Value:AnsiString;key:Ansistring = 'AC1hI4j5kLmPQr8S'):AnsiString;

implementation

function HexToInt(const Hex: AnsiString): Integer;
var
  I, Res: Integer;
  ch: AnsiChar;
begin
  Res := 0;
  for I := 0 to Length(Hex) - 1 do
  begin
    ch := Hex[I + 1];
    if (ch >= '0') and (ch <= '9') then
      Res := Res * 16 + Ord(ch) - Ord('0')
    else if (ch >= 'A') and (ch <= 'F') then
      Res := Res * 16 + Ord(ch) - Ord('A') + 10
    else if (ch >= 'a') and (ch <= 'f') then
      Res := Res * 16 + Ord(ch) - Ord('a') + 10
    else
      raise Exception.Create('Error: not a Hex String');
  end;
  Result := Res;
end;

function BytesToHex(Data: TBytes): AnsiString;
const
  Digits: array[0..15] of AnsiChar = ('0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', 'A', 'B', 'C', 'D', 'E', 'F');
var
  I, Len: Integer;
  B: Byte;
  Buffer: PAnsiChar;
begin
  Result := '';
  Len := Length(Data);
  if Len = 0 then
    Exit;

  Buffer := @Data[0];
  for I := 0 to Len - 1 do
  begin
    B := PByte(Integer(Buffer) + I)^;
    Result := Result + {$IFDEF UNICODE}string{$ENDIF}
      (Digits[(B shr 4) and $0F] + Digits[B and $0F]);
  end;
end;

function HexToBytes(const Hex: string): TBytes;
var
  S: string;
  I: Integer;
begin
  if Hex = '' then
  begin
    Result := nil;
    Exit;
  end;

  SetLength(Result, (Length(Hex) + 1) div 2);
  for I := 0 to Length(Hex) div 2 - 1 do
  begin
    S := Copy(Hex, I * 2 + 1, 2);
    Result[I] := HexToInt(S);
  end;
end;

function EnCode(Value, key: AnsiString): AnsiString;
begin
  Result := '';
  if Value = '' then Exit;
  try
    Result := BytesToHex(
      AESEncryptCbcBytes(TEncoding.Default.UTF8.GetBytes(Value),
      TEncoding.Default.UTF8.GetBytes(key),
      TEncoding.Default.UTF8.GetBytes(key)));
  except
    raise Exception.Create('DeCode ERROR');
  end;

end;

function DeCode(Value,key: AnsiString): AnsiString;
begin
  Result := '';
  if Value = '' then Exit;
  try
    Result := TEncoding.UTF8.GetString(AESDecryptcbcBytes(
      HexToBytes(Value),
      TEncoding.Default.UTF8.GetBytes(key),
      TEncoding.Default.UTF8.GetBytes(key)));
  except
    raise Exception.Create('DeCode ERROR');
  end;
end;

//SM4加密解密-------------------------

{* 给字符串末尾加上 PKCS7 规定的填充“几个几”的填充数据}
function StrAddPKCS7Padding(const Str: AnsiString; BlockSize: Byte): AnsiString;
var
  R: Byte;
begin
  R := Length(Str) mod BlockSize;
  R := BlockSize - R;
  if R = 0 then
    R := R + BlockSize;

  Result := Str + AnsiString(StringOfChar(Chr(R), R));
end;
{* 去除 PKCS7 规定的字符串末尾填充“几个几”的填充数据}
function StrRemovePKCS7Padding(const Str: AnsiString): AnsiString;
var
  L: Integer;
  V: Byte;
begin
  Result := Str;
  if Result = '' then
    Exit;
  L := Length(Result);
  V := Ord(Result[L]);  // 末是几表示加了几

  if V <= L then
    Delete(Result, L - V + 1, V);
end;

function Sm4Encode(Value,key:Ansistring):AnsiString;
var
  Output: AnsiString;
  Len: Integer;
  s: string;
  BaseByte:Byte;
begin
  Result := '';
  BaseByte := 200;
  try
    if Value = '' then Exit;
    Len := Length(UTF8Encode(Value));
    if Len < 16 then
      Len := 16
    else
      Len := (((Len - 1) div 16) + 1) * 16;
    SetLength(Output, Len);
    ZeroMemory(@(Output[1]), Len);
    SM4EncryptEcbStr(UTF8Encode(key), StrAddPKCS7Padding(UTF8Encode(Value),SM4_BLOCKSIZE), @(Output[1]));
    BaseByte := Base64Encode(Output,s);
    if BaseByte <> 0 then Exit;
    Result := s;
  finally
    if Result = '' then
      raise Exception.Create('SM4Encode Error！Base64:'+inttostr(BaseByte));
  end;
end;

function Sm4Decode(Value,key:Ansistring):AnsiString;
var
  S: AnsiString;
  Output: AnsiString;
  Len: Integer;
  BaseByte :Byte;
begin
  Result := '';
  BaseByte := 200;
  try
    if Value = '' then Exit;
    BaseByte := Base64Decode(AnsiString(Value),s);
    if BaseByte <> 0  then Exit;
    Len := Length(S);
    if Len < 16 then
      Len := 16
    else
      Len := (((Len - 1) div 16) + 1) * 16;
    SetLength(Output, Len);
    ZeroMemory(@(Output[1]), Len);
    SM4DecryptEcbStr(UTF8Encode(key), S, @(Output[1]));
    Output := StrRemovePKCS7Padding(Output);
    Result := UTF8Decode(Output);
  finally
    if Result = '' then
      raise Exception.Create('SM4Decode Error！Base64:'+inttostr(BaseByte));
  end;
end;


end.

