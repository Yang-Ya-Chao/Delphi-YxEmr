{ Invokable implementation File for TTest which implements ITest }

unit SoapImpl;

interface

uses
  InvokeRegistry, Types, SoapIntf,uRouter, System.SysUtils;

type

  TWSYXHIS = class(TInvokableClass, IWSYXHIS)
  public
    function DoExcute(InValue: string): string;  stdcall;
  end;

implementation



function TWSYXHIS.DoExcute(InValue: string): string;
var
  Af: Router;
  outValue: string;
begin
  Result := SetResultInfo;
  try
    Af := Router.Create;
    try
      if not Af.DoExcute('Socket',InValue, outValue) then
      begin
        Result := SetResultInfo(0,outValue);
        Exit;
      end;
      Result := SetResultInfo(0,outValue);
    finally
      freeandnil(Af);
    end;
  except
    on e: exception do
    begin
      Result := SetResultInfo(0,e.message);
      Exit;
    end;
  end;
end;

initialization

{ Invokable classes must be registered }
  InvRegistry.RegisterInvokableClass(TWSYXHIS);

end.

