unit JsonHelp;

interface
uses
  JsonDataObjects, System.Generics.Collections, System.TypInfo, system.classes,
  System.SysUtils, System.Variants;
type
  TJsonObjectHelper = class helper for TJsonObject
  public
    procedure FromSimpleObjectList(QArrName:string;QList:TList<TObject>; ALowerCamelCase: Boolean = False);
    procedure ToSimpleObjectList(QArrName:string;QClass:TClass;QList:TList<TObject>;ACaseSensitive: Boolean = True);
  end;
implementation
procedure AnsiLowerCamelCaseString(var S: string);
begin
  S := AnsiLowerCase(PChar(S)^) + Copy(S, 2);
end;
procedure TJsonObjectHelper.FromSimpleObjectList(QArrName:string;QList:TList<TObject>; ALowerCamelCase: Boolean);
var
  Index, Count: Integer;
  PropList: PPropList;
  PropType: PTypeInfo;
  PropName: string;
  V: Variant;
  D: Double;
  Ch: Char;
  lTempJson:TJsonObject;
  lJsonArr:TJsonArray;
  lTempObject:TObject;
  iList:Integer;
begin
  Clear;
  lJsonArr := self.A[QArrName];
  if QList = nil then
    Exit;
  if QList.Count=0 then
    exit;
  lTempObject := QList[0];
  if lTempObject.ClassInfo = nil then
   Exit;

  Count := GetPropList(lTempObject, PropList);
  if Count=0 then
    exit;
  try
    for iList := 0 to QList.Count-1 do
    begin
      lTempObject :=  QList[iList];
      lTempJson := lJsonArr.AddObject;
      for Index := 0 to Count - 1 do
      begin
        if (PropList[Index].StoredProc = Pointer($1)) or IsStoredProp(lTempObject, PropList[Index]) then
        begin
          PropName := UTF8ToString(PropList[Index].Name);
          if ALowerCamelCase and (PropName <> '') then
          begin
            Ch := PChar(Pointer(PropName))^;
            if Ord(Ch) < 128 then
            begin
              case Ch of
                'A'..'Z':
                  PChar(Pointer(PropName))^ := Char(Ord(Ch) xor $20);
              end;
            end
            else // Delphi 2005+ compilers allow unicode identifiers, even if that is a very bad idea
              AnsiLowerCamelCaseString(PropName);
          end;

          case PropList[Index].PropType^.Kind of
            tkInteger, tkChar, tkWChar:
              lTempJson.InternAdd(PropName, GetOrdProp(lTempObject, PropList[Index]));

            tkEnumeration:
              begin
                PropType := PropList[Index].PropType^;
                if (PropType = TypeInfo(Boolean)) or (PropType = TypeInfo(ByteBool)) or
                   (PropType = TypeInfo(WordBool)) or (PropType = TypeInfo(LongBool)) then
                  lTempJson.InternAdd(PropName, GetOrdProp(lTempObject, PropList[Index]) <> 0)
                else
                  lTempJson.InternAdd(PropName, GetOrdProp(lTempObject, PropList[Index]));
              end;

            tkFloat:
              begin
                PropType := PropList[Index].PropType^;
                D := GetFloatProp(lTempObject, PropList[Index]);
                if (PropType = TypeInfo(TDateTime)) or (PropType = TypeInfo(TDate)) or (PropType = TypeInfo(TTime)) then
                  lTempJson.InternAdd(PropName, TDateTime(D))
                else
                  lTempJson.InternAdd(PropName, D);
              end;

            tkInt64:
              lTempJson.InternAdd(PropName, GetInt64Prop(lTempObject, PropList[Index]));

            tkString, tkLString, tkWString, tkUString:
              lTempJson.InternAdd(PropName, GetStrProp(lTempObject, PropList[Index]));

            tkSet:
              lTempJson.InternAdd(PropName, GetSetProp(lTempObject, PropList[Index]));

            tkVariant:
              begin
                V := GetVariantProp(lTempObject, PropList[Index]);
                if VarIsNull(V) or VarIsEmpty(V) then
                  lTempJson.InternAdd(PropName, TJsonObject(nil))
                else
                begin
                  case VarType(V) and varTypeMask of
                    varSingle, varDouble, varCurrency:
                      lTempJson.InternAdd(PropName, Double(V));
                    varShortInt, varSmallint, varInteger, varByte, varWord:
                      lTempJson.InternAdd(PropName, Integer(V));
                    varLongWord:
                      lTempJson.InternAdd(PropName, Int64(LongWord(V)));
                    {$IF CompilerVersion >= 23.0} // XE2+
                    varInt64:
                      lTempJson.InternAdd(PropName, Int64(V));
                    {$IFEND}
                    varBoolean:
                      lTempJson.InternAdd(PropName, Boolean(V));
                  else
                    lTempJson.InternAdd(PropName, VarToStr(V));
                  end;
                end;
              end;
          end;
        end;
      end;
    end;
  finally
    FreeMem(PropList);
  end;
end;
procedure TJsonObjectHelper.ToSimpleObjectList(QArrName:string;QClass:TClass;QList:TList<TObject>;ACaseSensitive: Boolean = True);
var
  Index, Count: Integer;
  PropList: PPropList;
//  PropInfo:PPropInfo;
  PropType: PTypeInfo;
  PropName: string;
  Item: PJsonDataValue;
  V: Variant;
  lTempObject:TObject;
  lTempJson:TJsonObject;
  lJsonArr:TJsonArray;
  iArr:Integer;
begin
  if QList=nil then
    exit;
  if QClass = nil then
    Exit;
  lJsonArr := self.A[QArrName];
  if lJsonArr.Count=0 then
    exit;
//  Count := 0;
  lTempObject := QClass.Create;
  try
    Count := GetPropList(lTempObject, PropList);
  finally
    lTempObject.Free;
  end;
  if Count=0 then
    exit;
  try
    for iArr := 0 to lJsonArr.Count-1 do
    begin
      lTempObject := QClass.Create;
      QList.Add(lTempObject);
      lTempJson := lJsonArr.O[iArr];
      for Index := 0 to Count - 1 do
      begin
        if (PropList[Index].StoredProc = Pointer($1)) or IsStoredProp(lTempObject, PropList[Index]) then
        begin
          PropName := UTF8ToString(PropList[Index].Name);
          if not ACaseSensitive then
            Item := lTempJson.FindCaseInsensitiveItem(PropName)
          else if not lTempJson.FindItem(PropName, Item) then
            Item := nil;

          if Item <> nil then
          begin
            case PropList[Index].PropType^.Kind of
              tkInteger, tkChar, tkWChar:
                SetOrdProp(lTempObject, PropList[Index], Item.IntValue);

              tkEnumeration:
                SetOrdProp(lTempObject, PropList[Index], Item.IntValue);

              tkFloat:
                begin
                  PropType := PropList[Index].PropType^;
                  if (PropType = TypeInfo(TDateTime)) or (PropType = TypeInfo(TDate)) or (PropType = TypeInfo(TTime)) then
                    SetFloatProp(lTempObject, PropList[Index], Item.DateTimeValue)
                  else
                    SetFloatProp(lTempObject, PropList[Index], Item.FloatValue);
                end;

              tkInt64:
                SetInt64Prop(lTempObject, PropList[Index], Item.LongValue);

              tkString, tkLString, tkWString, tkUString:
                SetStrProp(lTempObject, PropList[Index], Item.Value);

              tkSet:
                SetSetProp(lTempObject, PropList[Index], Item.Value);

              tkVariant:
                begin
                  case Types[PropName] of
                    jdtObject, jdtArray:
                      V := Null;
                    jdtInt:
                      V := Item.IntValue;
                    jdtLong:
                      V := Item.LongValue;
                    jdtULong:
                      V := Item.ULongValue;
                    jdtFloat:
                      V := Item.FloatValue;
                    jdtDateTime:
                      V := Item.DateTimeValue;
                    jdtUtcDateTime:
                      V := Item.UtcDateTimeValue;
                    jdtBool:
                      V := Item.BoolValue;
                  else
                    V := Item.Value;
                  end;
                  SetVariantProp(lTempObject, PropList[Index], V);
                end;
            end;
          end;
        end;
      end;
    end;
  finally
    FreeMem(PropList);
  end;
end;
end.
