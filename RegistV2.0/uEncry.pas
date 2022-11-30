unit uEncry;

interface



uses
  SysUtils, Classes, System.NetEncoding,Winapi.Windows,CnAES;


function EnCode(Value: AnsiString; key: AnsiString =
  'AbCd1EFG2h3I4j5kLm9no4PQr8Stu6Vw5X7yz'): AnsiString;

function DeCode(Value: AnsiString; key: AnsiString =
  'AbCd1EFG2h3I4j5kLm9no4PQr8Stu6Vw5X7yz'): AnsiString;

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
  Result := BytesToHex(
  AESEncryptCbcBytes(TEncoding.Default.UTF8.GetBytes(Value),
    TEncoding.Default.UTF8.GetBytes(key),
    TEncoding.Default.UTF8.GetBytes(key)));

end;

function DeCode(Value,key: AnsiString): AnsiString;
begin
  Result := TEncoding.UTF8.GetString(AESDecryptcbcBytes(
    HexToBytes(Value),
    TEncoding.Default.UTF8.GetBytes(key),
    TEncoding.Default.UTF8.GetBytes(key)));
end;



end.

