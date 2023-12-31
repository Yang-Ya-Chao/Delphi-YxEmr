{ Invokable interface ITest }

unit SoapIntf;

interface

uses
  InvokeRegistry, Types;

type

  { Invokable interfaces must derive from IInvokable }
  IWSYXHIS = interface(IInvokable)
    ['{2FEFD041-C424-4673-8B86-42106004CCE4}']
    function DoExcute(InValue: string): string;stdcall;
    { Methods of Invokable interface must not use the default }
    { calling convention; stdcall is recommended }
  end;

implementation

initialization
  { Invokable interfaces must be registered }
  InvRegistry.RegisterInterface(TypeInfo(IWSYXHIS));

end.

