{
  将TFDquery.FieldByName('').AsString等操作
  转换成将TFDquery.S['']操作
}
unit uQueryHelper;

interface
  uses FireDAC.Comp.Client;
type
  TFDQueryHelper = class helper for TFDQuery
  private
    function GetF(Name: string): Double;
    function GetI(Name: string): Int64;
    function GetS(Name: string): string;
    function GetT(Name: string): TDateTime;
    function GetC(Name: string): Currency;
    function GetB(Name: string): Boolean;
    { Private declarations }
  public
    { Public declarations }
    property S[Name : string] : string      read GetS  ;
    property I[Name : string] : Int64     read GetI   ;
    property T[Name : string] : TDateTime   read GetT  ;
    property F[Name : string] : Double      read GetF  ;
    property C[Name : string] : Currency    read GetC  ;
    property B[Name : string] : Boolean     read GetB  ;
  end;
implementation

{ TFDQueryHelper }

function TFDQueryHelper.GetB(Name: string): Boolean;
begin
  Result := self.FieldByName(Name).AsBoolean;
end;

function TFDQueryHelper.GetC(Name: string): Currency;
begin
  Result := self.FieldByName(Name).AsCurrency;
end;

function TFDQueryHelper.GetF(Name: string): Double;
begin
  Result := self.FieldByName(Name).AsFloat;
end;

function TFDQueryHelper.GetI(Name: string): Int64;
begin
  Result := self.FieldByName(Name).AsLargeInt;
end;

function TFDQueryHelper.GetS(Name: string): string;
begin
  Result := self.FieldByName(Name).AsString;
end;

function TFDQueryHelper.GetT(Name: string): TDateTime;
begin
  Result := self.FieldByName(Name).AsDateTime;
end;

end.


