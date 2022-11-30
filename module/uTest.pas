unit uTest;
//业务单元--test

interface
  //引用基础类
  uses uPubMod,System.Classes;


//创建TPubMod的子类业务类-Test
type
  Test = class(TPubMod)
  private
  public
   //实际业务处理函数，入参为请求提交的body数据
   function Execute(Invalue,Method:string):Boolean;override;
  end;
implementation


{ Test }
//实际业务处理函数，FResultData为返回值,FError为错误信息

function Test.Execute(Invalue,Method:string): Boolean;
begin
  Result := False;

  //返回失败信息--给FError赋值并退出即可返回错误信息
  FError := '';
  if FError <> '' then Exit;

  //返回成功数据
  FResultData := 'Invalue：'+Invalue+#13#10+'test:'+FRdata;
  Result := True;
end;

//注册这个子类Test,后一个参数为注册类别名，与请求的Method参数一致
initialization
  RegisterClassAlias(Test,'Test');
finalization
  System.Classes.UnRegisterClass(Test)
end.

