//YXSOFT软件加解密单元 for D11
unit uCrypt;

interface

uses Windows, Variants, SysUtils, Classes;

const
  PassKey = 5728;
  RightKey = 35762;
  RightStrKey = 8762;

//
function Decrypt(const S,Key: AnsiString): AnsiString;
function Encrypt(const S,Key: AnsiString): AnsiString;

implementation

const
  Codes64 = '0A1B2C3D4E5F6G7H89IjKlMnOPqRsTuVWXyZabcdefghijkLmNopQrStUvwxYz+/';
  C1 = 28853;
  C2 = 31836;

function Decode(const S: AnsiString): AnsiString;
const
  Map: array[ansiChar] of Byte = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 62, 0, 0, 0, 63, 52, 53,
    54, 55, 56, 57, 58, 59, 60, 61, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2,
    3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
    20, 21, 22, 23, 24, 25, 0, 0, 0, 0, 0, 0, 26, 27, 28, 29, 30,
    31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45,
    46, 47, 48, 49, 50, 51, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0);
var
  I: Int64;
begin
  case Length(S) of
    2:
      begin
        I := Map[S[1]] + (Map[S[2]] shl 6);
        SetLength(Result, 1);
        Move(I, Result[1], Length(Result))
      end;
    3:
      begin
        I := Map[S[1]] + (Map[S[2]] shl 6) + (Map[S[3]] shl 12);
        SetLength(Result, 2);
        Move(I, Result[1], Length(Result))
      end;
    4:
      begin
        I := Map[S[1]] + (Map[S[2]] shl 6) + (Map[S[3]] shl 12) +
          (Map[S[4]] shl 18);
        SetLength(Result, 3);
        Move(I, Result[1], Length(Result))
      end
  end
end;

function PreProcess(const S: AnsiString): AnsiString;
var
  SS: AnsiString;
begin
  SS := S;
  Result := '';
  while SS <> '' do
  begin
    Result := Result + Decode(Copy(SS, 1, 4));
    Delete(SS, 1, 4)
  end
end;

function InternalDecrypt(const S: AnsiString; Key: Word): AnsiString;
var
  I: Word;
  Seed: Int64;
begin
  Result := S;
  Seed := Key;
  {$UNDEF SaveQ} {$IFOPT Q+} {$Q-} {$DEFINE SaveQ} {$ENDIF}
  for I := 1 to Length(Result) do
  begin
    Result[I] := ansiChar(Byte(Result[I]) xor (Seed shr 8));
    Seed := (Byte(S[I]) + Seed) * Word(C1) + Word(C2)
  end
  {$IFDEF SaveQ} {$Q+} {$UNDEF SaveQ} {$ENDIF}
end;

function Encode(const S: AnsiString): AnsiString;
const
  Map: array[0..63] of ansiChar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
    'abcdefghijklmnopqrstuvwxyz0123456789+/';
var
  I: Int64;
begin
  I := 0;
  Move(S[1], I, Length(S));
  case Length(S) of
    1:
      Result := Map[I mod 64] + Map[(I shr 6) mod 64];
    2:
      Result := Map[I mod 64] + Map[(I shr 6) mod 64] +
        Map[(I shr 12) mod 64];
    3:
      Result := Map[I mod 64] + Map[(I shr 6) mod 64] +
        Map[(I shr 12) mod 64] + Map[(I shr 18) mod 64]
  end
end;

function PostProcess(const S: AnsiString): AnsiString;
var
  SS: AnsiString;
begin
  SS := S;
  Result := '';
  while SS <> '' do
  begin
    Result := Result + Encode(Copy(SS, 1, 3));
    Delete(SS, 1, 3)
  end
end;

function InternalEncrypt(const S: AnsiString; Key: Word): AnsiString;
var
  I: Word;
  Seed: Int64;
begin
  Result := S;
  Seed := Key;
  {$UNDEF SaveQ} {$IFOPT Q+} {$Q-} {$DEFINE SaveQ} {$ENDIF}
  for I := 1 to Length(Result) do
  begin
    Result[I] := ansiChar(Byte(Result[I]) xor (Seed shr 8));
    Seed :=  (Byte(Result[I]) + Seed)*Word(C1) +Word(C2);
  end
  {$IFDEF SaveQ} {$Q+} {$UNDEF SaveQ} {$ENDIF}
end;

function Decrypt(const S,Key: AnsiString): AnsiString;
var i,a,m: Word;
 c: AnsiString;
begin
 Result := '';
 A := PassKey;
 for i:=1 to Length(Key) do
   A := A + Ord(Key[i]);
  c := InternalDecrypt(PreProcess(S), A);
 for i:=1 to Length(c) do
   Result:=Result+ansichar(Ord(c[i]) XOR $A5);
 Result := Trim(Result);
end;

function Encrypt(const S,Key: AnsiString): AnsiString;
var i,a: Word;
 c: AnsiString;
begin
 Result := '';
 A := PassKey;
 for i:=1 to Length(Key) do
   A := A + Ord(Key[i]);
 c:='';
 for i:=1 to Length(s) do
   c:=c+ansichar(Ord(s[i]) XOR $A5);
 Result := PostProcess(InternalEncrypt(c, A));
end;

end.
