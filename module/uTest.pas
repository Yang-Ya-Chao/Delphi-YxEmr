unit uTest;
//ҵ��Ԫ--test

interface
  //���û�����
  uses uPubMod,System.Classes;


//����TPubMod������ҵ����-Test
type
  Test = class(TPubMod)
  private
  public
   //ʵ��ҵ�����������Ϊ�����ύ��body����
   function Execute(Invalue,Method:string):Boolean;override;
  end;
implementation


{ Test }
//ʵ��ҵ��������FResultDataΪ����ֵ,FErrorΪ������Ϣ

function Test.Execute(Invalue,Method:string): Boolean;
begin
  Result := False;

  //����ʧ����Ϣ--��FError��ֵ���˳����ɷ��ش�����Ϣ
  FError := '';
  if FError <> '' then Exit;

  //���سɹ�����
  FResultData := 'Invalue��'+Invalue+#13#10+'test:'+FRdata;
  Result := True;
end;

//ע���������Test,��һ������Ϊע����������������Method����һ��
initialization
  RegisterClassAlias(Test,'Test');
finalization
  System.Classes.UnRegisterClass(Test)
end.

