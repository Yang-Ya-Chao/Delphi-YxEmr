unit uFrmMQTTClient;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,  UpubFun, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, QMqttClient, QLog,
  qdac_ssl_ics, Vcl.Mask,uRouter,QWorker,uConfig,System.Types;

type
  TFrmMQClient = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    leServerHost: TLabeledEdit;
    leServerPort: TLabeledEdit;
    leUserName: TLabeledEdit;
    lePassword: TLabeledEdit;
    Button1: TButton;
    Panel5: TPanel;
    btnSubscribe: TButton;
    Panel6: TPanel;
    Panel7: TPanel;
    btnPublish: TButton;
    Splitter1: TSplitter;
    Label1: TLabel;
    edtSubscribeTopic: TEdit;
    Label2: TLabel;
    edtPublishTopic: TEdit;
    Label3: TLabel;
    edtMessage: TEdit;
    Memo1: TMemo;
    Memo2: TMemo;
    Panel8: TPanel;
    Label4: TLabel;
    cbxQoSLevel: TComboBox;
    Panel9: TPanel;
    Label5: TLabel;
    cbxRecvQoSLevel: TComboBox;
    tmSend: TTimer;
    chkAutoSend: TCheckBox;
    chkAutoClearLog: TCheckBox;
    Label6: TLabel;
    edtClientId: TEdit;
    tmStatics: TTimer;
    pnlStatus: TPanel;
    chkSSL: TCheckBox;
    cbxVersion: TComboBox;
    btnUnsubscribe: TButton;
    Panel10: TPanel;
    btnSAVE: TButton;
    ckBMQ: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure btnSubscribeClick(Sender: TObject);
    procedure btnPublishClick(Sender: TObject);
    procedure tmSendTimer(Sender: TObject);
    procedure chkAutoSendClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmStaticsTimer(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure chkSSLClick(Sender: TObject);
    procedure btnUnsubscribeClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSAVEClick(Sender: TObject);
  private
    { Private declarations }
    FClient: TQMQTTMessageClient;
    procedure DoClientConnecting(ASender: TQMQTTMessageClient);
    procedure DoClientConnected(ASender: TQMQTTMessageClient);
    procedure DoClientDisconnected(ASender: TQMQTTMessageClient);
    procedure DoClientError(ASender: TQMQTTMessageClient; const AErrorCode:
      Integer; const AErrorMsg: string);
    procedure DoSubscribeDone(ASender: TQMQTTMessageClient; const AResults:
      TQMQTTSubscribeResults);
    procedure DoBeforePublish(ASender: TQMQTTMessageClient; const ATopic: string;
      const AReq: PQMQTTMessage);
    procedure DoAfterPublished(ASender: TQMQTTMessageClient; const ATopic:
      string; const AReq: PQMQTTMessage);
    procedure DoRecvTopic(ASender: TQMQTTMessageClient; const ATopic: string;
      const AReq: PQMQTTMessage);
    procedure DoStdTopicTest(ASender: TQMQTTMessageClient; const ATopic: string;
      const AReq: PQMQTTMessage);
    procedure DoPatternTopicTest(ASender: TQMQTTMessageClient; const ATopic:
      string; const AReq: PQMQTTMessage);
    procedure DoRegexTopicTest(ASender: TQMQTTMessageClient; const ATopic:
      string; const AReq: PQMQTTMessage);
    procedure DoMultiDispatch1(ASender: TQMQTTMessageClient; const ATopic:
      string; const AReq: PQMQTTMessage);
    procedure DoMultiDispatch2(ASender: TQMQTTMessageClient; const ATopic:
      string; const AReq: PQMQTTMessage);
    procedure DoBeforeUnsubscribe(ASender: TQMQTTMessageClient; const ATopic:
      string; const AReq: PQMQTTMessage);
    procedure DoAfterUnsubscribe(ASender: TQMQTTMessageClient; const ATopic: string);
    procedure SaveSettings;
    procedure LoadSettings;
  public
    { Public declarations }
  end;

var
  FrmMQClient: TFrmMQClient;
  PubTop:string;
  procedure StartMQTT;
  procedure StopMQTT;
  procedure Execute(aHeader,InValue: string; out OutValue: string);
  procedure OnExecTop(ASender: TQMQTTMessageClient; const ATopic: string;
      const AReq: PQMQTTMessage);

implementation

uses
  qstring;
{$R *.dfm}

//*****************************MQ外部调用实现*****************************//

procedure StopMQTT;
begin
  if DefaultMQTTClient.Connected then
    DefaultMQTTClient.Stop;
end;
procedure StartMQTT;
begin
  try
    // ClientId 如果不指定，则会自动生成一个随机的ClientId，建议指定
    with DefaultMQTTClient do
    begin
      ClientId := Ini.MQClientID;
      ServerHost := Ini.MQHost;
      ServerPort := ini.MQPort;
      UserName := Ini.MQUser;
      Password := Ini.MQPass;
      UseSSL := Ini.MQSSL;
      QosLevel := TQMQTTQoSLevel(Ini.MQRecQos);
      PubTop := Ini.MQPubTop;
      WillTopic := 'YxEmr_willmessage';
      WillMessage := bytesof(format('ClientId[%s] off line(WILL MESSAGE)', [ClientID]));
      // if FClient.UseSSL then
      // FClient.SSLManager.LoadCAFiles('root.pem');
      if Ini.MQVerSion = 1 then
      begin
        ProtocolVersion := pv5_0;
        ConnectProps.AsInt[MP_NEED_PROBLEM_INFO] := 1;
      end
      else
        ProtocolVersion := pv3_1_1;
      PeekInterval := 15;
      // 5.0 test
      //
      // 如果不关心中间的连接过程，这些事件不需要管
      {BeforeConnect := DoClientConnecting;
      AfterConnected := DoClientConnected;
      AfterDisconnected := DoClientDisconnected;
      AfterSubscribed := DoSubscribeDone;
      BeforePublish := DoBeforePublish;
      AfterPublished := DoAfterPublished;
      BeforeUnsubscribe := DoBeforeUnsubscribe;
      AfterUnsubscribed := DoAfterUnsubscribe;
      OnError := DoClientError;
      OnRecvTopic := DoRecvTopic;}
      // 在这里添加自己的订阅，由于这个是要发送到服务器端的，所以不支持正则，但可以使用主题过滤表达式匹配
      // 请参考：http://itindex.net/detail/58722-mqtt-topic-%E9%80%9A%E9%85%8D%E7%AC%A6
      Subscribe([Ini.MQSubTop], QosLevel);
      // 主题的派发处理，支持完全匹配（默认）、主题过滤表达式和正则表达式，当收到相应的主题时会调用相应的处理函数
      RegisterDispatch(Ini.MQSubTop, OnExecTop);
      // 启动后台工作
      Start;
    end;
  except
  end;
end;

procedure OnExecTop(ASender: TQMQTTMessageClient; const ATopic: string;
      const AReq: PQMQTTMessage);
const
  Result_Info = '<Result><MsgID>@MsgID@</MsgID><Code>@Code@</Code><Info>@Info@</Info></Result>';
var
  Text,MsgID,Msg: string;
  OutValue: string;
  Log: string;
  StartTime, StopTime: Int64;
begin
  StartTime := GetTickCount64;
  //收到请求发送信号到主线程
  Workers.Signal(SignalAllID);
  Text := '通过主题词派发:' + ATopic + SLineBreak + '  ID:' + IntToStr(AReq.TopicId)
    + SLineBreak + '  内容(' + RollupSize(AReq.TopicContentSize) + '):' + AReq.TopicText;
  Msg := AReq.TopicText;
  MsgID := Copy(Msg,Pos('<MsgID>', Msg)+7, Pos('</MsgID>',Msg)-Pos('<MsgID>', Msg)-7);
  try
    try
      Execute('',Msg, OutValue);
    except
      on e: Exception do
      begin
        OutValue := '服务器运行出错:' + e.Message;
      end;
    end;
  finally
    StopTime := GetTickCount64;
    outvalue := OutValue.Replace('<Code>','<MsgID>'+MsgID+'</MsgID><Code>');
    ASender.Publish(PubTop, outvalue, ASender.QosLevel);
    Log := '[Tick:' + IntToStr(StopTime - StartTime) + 'ms]'
      + #13#10 + Text + #13#10 + OutValue;
    if  Pos('</BGD.20>', Log) > 0 then
    Log := Log.Replace(Copy(Log, Pos('<BGD.20', Log) , Pos('</BGD.20>', Log) - Pos('<BGD.20', Log) + 9),'');
    if  Pos('</BGD.21>', Log) > 0 then
    Log := Log.Replace(Copy(Log, Pos('<BGD.21', Log) , Pos('</BGD.21>', Log) - Pos('<BGD.21', Log) + 9),'');
    if  Pos('</BGD.22>', Log) > 0 then
    Log := Log.Replace(Copy(Log, Pos('<BGD.22', Log) , Pos('</BGD.22>', Log) - Pos('<BGD.22', Log) + 9),'');
    if  Pos('</BGD.23>', Log) > 0 then
    Log := Log.Replace(Copy(Log, Pos('<BGD.23', Log) , Pos('</BGD.23>', Log) - Pos('<BGD.23', Log) + 9),'');
    if  Pos('</BGD.24>', Log) > 0 then
    Log := Log.Replace(Copy(Log, Pos('<BGD.24', Log) , Pos('</BGD.24>', Log) - Pos('<BGD.24', Log) + 9),'');
    if POS('<Code>0</Code>', OutValue) > 0 then
    begin
      PostLog(llError,Log);
      //发送失败信号到主线程
      Workers.Signal(SignalFalseID);
    end
    else
      PostLog(llmessage,Log)
  end;
end;

procedure Execute(aHeader,InValue: string; out OutValue: string);
var
  R: Router;
begin
  OutValue := '';
  try
    R := Router.Create;
    try
      if not R.DoExcute('Soctet',InValue, OutValue) then
      begin
        OutValue := SetResultInfo(0,OutValue);
        Exit;
      end;
      OutValue := SetResultInfo(1,OutValue);
    finally
      R.Free;
    end;
  except
    on e: exception do
    begin
      OutValue := SetResultInfo(0,e.message);
      Exit;
    end;
  end;
end;

//*****************************MQ外部调用实现*****************************//

procedure TFrmMQClient.btnPublishClick(Sender: TObject);
begin
  if Assigned(FClient) then
    FClient.Publish(edtPublishTopic.Text, edtMessage.Text, TQMQTTQoSLevel(cbxQoSLevel.ItemIndex));
end;

procedure TFrmMQClient.btnSAVEClick(Sender: TObject);
begin
  SaveSettings;
  MessageBox(Handle, '配置保存成功！请重启程序生效！', '提示', MB_ICONASTERISK and MB_ICONINFORMATION);
end;

procedure TFrmMQClient.btnSubscribeClick(Sender: TObject);
var
  ATopics: TArray<string>;
  S: string;
  p: PChar;
  C: Integer;
begin
  if Assigned(FClient) then
  begin
    SetLength(ATopics, 4);
    S := edtSubscribeTopic.Text;
    p := PChar(S);
    C := 0;
    while p^ <> #0 do
    begin
      ATopics[C] := DecodeTokenW(p, ',', #0, true);
      Inc(C);
    end;
    SetLength(ATopics, C);
    FClient.Subscribe(ATopics, TQMQTTQoSLevel(cbxRecvQoSLevel.ItemIndex));
  end;
end;

procedure TFrmMQClient.btnUnsubscribeClick(Sender: TObject);
var
  ATopics: TArray<string>;
  S: string;
  p: PChar;
  C: Integer;
begin
  if Assigned(FClient) then
  begin
    SetLength(ATopics, 4);
    S := edtSubscribeTopic.Text;
    p := PChar(S);
    C := 0;
    while p^ <> #0 do
    begin
      ATopics[C] := DecodeTokenW(p, ',', #0, true);
      Inc(C);
    end;
    SetLength(ATopics, C);
    FClient.Unsubscribe(ATopics);
  end;
end;

procedure TFrmMQClient.Button1Click(Sender: TObject);
begin
  if Button1.Caption = '连接测试' then
  begin
    if not Assigned(FClient) then
      FClient := TQMQTTMessageClient.Create(Self);
    FClient.Stop;
    // ClientId 如果不指定，则会自动生成一个随机的ClientId，建议指定
    FClient.ClientId := edtClientId.Text;
    FClient.ServerHost := leServerHost.Text;
    FClient.ServerPort := StrToIntDef(leServerPort.Text, 1883);
    FClient.UserName := leUserName.Text;
    FClient.Password := lePassword.Text;
    FClient.UseSSL := chkSSL.Checked;
    FClient.WillTopic := 'YxEmr_willmessage';
    FClient.WillMessage := bytesof(format('ClientId[%s] off line(WILL MESSAGE)', [FClient.ClientID]));
    // if FClient.UseSSL then
    // FClient.SSLManager.LoadCAFiles('root.pem');
    if cbxVersion.ItemIndex = 1 then
    begin
      FClient.ProtocolVersion := pv5_0;
      FClient.ConnectProps.AsInt[MP_NEED_PROBLEM_INFO] := 1;
    end
    else
      FClient.ProtocolVersion := pv3_1_1;
    FClient.PeekInterval := 15;
    // 5.0 test
    //
    // 如果不关心中间的连接过程，这些事件不需要管
    FClient.BeforeConnect := DoClientConnecting;
    FClient.AfterConnected := DoClientConnected;
    FClient.AfterDisconnected := DoClientDisconnected;
    FClient.AfterSubscribed := DoSubscribeDone;
    FClient.BeforePublish := DoBeforePublish;
    FClient.AfterPublished := DoAfterPublished;
    FClient.BeforeUnsubscribe := DoBeforeUnsubscribe;
    FClient.AfterUnsubscribed := DoAfterUnsubscribe;
    FClient.OnError := DoClientError;
    FClient.OnRecvTopic := DoRecvTopic;
    // 在这里添加自己的订阅，由于这个是要发送到服务器端的，所以不支持正则，但可以使用主题过滤表达式匹配
    // 请参考：http://itindex.net/detail/58722-mqtt-topic-%E9%80%9A%E9%85%8D%E7%AC%A6
    FClient.Subscribe(['/Topic/Dispatch'], qlMax1);
    // 主题的派发处理，支持完全匹配（默认）、主题过滤表达式和正则表达式，当收到相应的主题时会调用相应的处理函数
    FClient.RegisterDispatch('/Topic/Dispatch', DoStdTopicTest);
    FClient.RegisterDispatch('/+/Dispatch', DoPatternTopicTest, mtPattern);
    FClient.RegisterDispatch('/Topic\d', DoRegexTopicTest, mtRegex);
    FClient.RegisterDispatch('/Topic1', DoMultiDispatch1, mtFull);
    FClient.RegisterDispatch('/Topic1', DoMultiDispatch2, mtFull);
    // 启动后台工作
    FClient.Start;
  end
  else
  begin
    FClient.Stop;
    Button1.Caption := '连接测试';
  end;
end;

procedure TFrmMQClient.chkAutoSendClick(Sender: TObject);
begin
  tmSend.Enabled := chkAutoSend.Checked;
end;

procedure TFrmMQClient.chkSSLClick(Sender: TObject);
begin
  if chkSSL.Checked then
    leServerPort.Text := '8883'
  else
    leServerPort.Text := '1883';
end;

procedure TFrmMQClient.DoAfterPublished(ASender: TQMQTTMessageClient; const
  ATopic: string; const AReq: PQMQTTMessage);
begin
  Memo2.Lines.Add('发布 ' + ATopic + ' ID=' + IntToStr(AReq.TopicId) + ',大小:' +
    IntToStr(AReq.Size) + ' 完成');
end;

procedure TFrmMQClient.DoAfterUnsubscribe(ASender: TQMQTTMessageClient; const
  ATopic: string);
begin
  Memo1.Lines.Add('订阅 ' + ATopic + ' 已取消');
end;

procedure TFrmMQClient.DoBeforePublish(ASender: TQMQTTMessageClient; const
  ATopic: string; const AReq: PQMQTTMessage);
begin
  Memo2.Lines.Add('正在发布 ' + ATopic + ' ID=' + IntToStr(AReq.TopicId) + ',大小:' +
    IntToStr(AReq.Size) + ' ...');
end;

procedure TFrmMQClient.DoBeforeUnsubscribe(ASender: TQMQTTMessageClient; const
  ATopic: string; const AReq: PQMQTTMessage);
begin
  Memo1.Lines.Add('正在取消订阅 ' + ATopic + '...');
end;

procedure TFrmMQClient.DoClientConnected(ASender: TQMQTTMessageClient);
begin
  Memo1.Lines.Add(ASender.ServerHost + ':' + IntToStr(ASender.ServerPort) + ' 连接成功.');
  Button1.Caption := '断开';
end;

procedure TFrmMQClient.DoClientConnecting(ASender: TQMQTTMessageClient);
begin
  Memo1.Lines.Add('正在连接 ' + ASender.ServerHost + ':' + IntToStr(ASender.ServerPort));
end;

procedure TFrmMQClient.DoClientDisconnected(ASender: TQMQTTMessageClient);
begin
  Memo1.Lines.Add('连接 ' + ASender.ServerHost + ':' + IntToStr(ASender.ServerPort)
    + '已断开');
end;

procedure TFrmMQClient.DoClientError(ASender: TQMQTTMessageClient; const
  AErrorCode: Integer; const AErrorMsg: string);
begin
  Memo1.Lines.Add('错误:' + AErrorMsg + ',代码:' + IntToStr(AErrorCode));
end;

procedure TFrmMQClient.DoMultiDispatch1(ASender: TQMQTTMessageClient; const
  ATopic: string; const AReq: PQMQTTMessage);
begin
  Memo1.Lines.Add('Dispatch1 接收到Topic:' + ATopic + SLineBreak + '  ID:' +
    IntToStr(AReq.TopicId) + SLineBreak + '  内容(' + RollupSize(AReq.TopicContentSize)
    + '):' + AReq.TopicText);
end;

procedure TFrmMQClient.DoMultiDispatch2(ASender: TQMQTTMessageClient; const
  ATopic: string; const AReq: PQMQTTMessage);
begin
  Memo1.Lines.Add('Dispatch2 接收到Topic:' + ATopic + SLineBreak + '  ID:' +
    IntToStr(AReq.TopicId) + SLineBreak + '  内容(' + RollupSize(AReq.TopicContentSize)
    + '):' + AReq.TopicText);
end;

procedure TFrmMQClient.DoPatternTopicTest(ASender: TQMQTTMessageClient; const
  ATopic: string; const AReq: PQMQTTMessage);
begin
  Memo1.Lines.Add('通过主题词模式匹配派发:' + ATopic + SLineBreak + '  ID:' + IntToStr(AReq.TopicId)
    + SLineBreak + '  内容(' + RollupSize(AReq.TopicContentSize) + '):' + AReq.TopicText);
end;

procedure TFrmMQClient.DoRecvTopic(ASender: TQMQTTMessageClient; const ATopic:
  string; const AReq: PQMQTTMessage);
begin
  Memo1.Lines.Add('接收到Topic:' + ATopic + SLineBreak + '  ID:' + IntToStr(AReq.TopicId)
    + SLineBreak + '  内容(' + RollupSize(AReq.TopicContentSize) + '):' + AReq.TopicText);
end;

procedure TFrmMQClient.DoRegexTopicTest(ASender: TQMQTTMessageClient; const
  ATopic: string; const AReq: PQMQTTMessage);
begin
  Memo1.Lines.Add('通过主题词正则匹配派发:' + ATopic + SLineBreak + '  ID:' + IntToStr(AReq.TopicId)
    + SLineBreak + '  内容(' + RollupSize(AReq.TopicContentSize) + '):' + AReq.TopicText);
end;

procedure TFrmMQClient.DoStdTopicTest(ASender: TQMQTTMessageClient; const ATopic:
  string; const AReq: PQMQTTMessage);
begin
  Memo1.Lines.Add('通过主题词派发:' + ATopic + SLineBreak + '  ID:' + IntToStr(AReq.TopicId)
    + SLineBreak + '  内容(' + RollupSize(AReq.TopicContentSize) + '):' + AReq.TopicText);
end;

procedure TFrmMQClient.DoSubscribeDone(ASender: TQMQTTMessageClient; const
  AResults: TQMQTTSubscribeResults);
var
  I: Integer;
begin
  for I := 0 to High(AResults) do
  begin
    if AResults[I].Success then
      Memo1.Lines.Add(AResults[I].Topic + ' -> QoS ' + IntToStr(Ord(AResults[I].Qos))
        + ' 订阅完成')
    else
      Memo1.Lines.Add(AResults[I].Topic + ' -> QoS ' + IntToStr(Ord(AResults[I].Qos))
        + ' 订阅失败');
  end;
end;

procedure TFrmMQClient.FormCreate(Sender: TObject);
begin
  SetDefaultLogFile('', 2097152, false);
  LoadSettings;
end;

procedure TFrmMQClient.FormDestroy(Sender: TObject);
begin
  if Assigned(FClient) then
    FClient.AfterDisconnected := nil;
end;

procedure TFrmMQClient.LoadSettings;
begin
  CKBMQ.Checked := Ini.MQEnable;
  leServerHost.Text := Ini.MQHost;
  leServerPort.Text := IntToStr(Ini.MQPort);
  leUserName.Text := Ini.MQUser;
  lePassword.Text := Ini.MQPass;
  edtclientid.Text := Ini.MQClientID;
  edtsubscribeTopic.Text := Ini.MQSubTop;
  edtPublishTopic.Text := Ini.MQPubTop;
  cbxVersion.ItemIndex := Ini.MQVerSion;
  cbxRecvQoSLevel.ItemIndex := Ini.MQRecQos;
  cbxQoSLevel.ItemIndex := Ini.MQPubQos;
  chkSSL.Checked := Ini.MQSSL;
end;

procedure TFrmMQClient.Panel1Click(Sender: TObject);
begin
  if Assigned(FClient) then
    FClient.Publish('/Topic1', StringReplicateW('0', 16848), qlMax1);
end;

procedure TFrmMQClient.SaveSettings;
begin
  Ini.MQEnable := CKBMQ.Checked;
  Ini.MQHost := leServerHost.Text;
  Ini.MQPort := StrToInt(leServerPort.Text);
  Ini.MQUser := leUserName.Text;
  Ini.MQPass := lePassword.Text;
  Ini.MQClientID := edtclientid.Text;
  Ini.MQVerSion := cbxVersion.ItemIndex;
  Ini.MQSubTop := edtsubscribeTopic.Text;
  Ini.MQRecQos := cbxRecvQoSLevel.ItemIndex;
  Ini.MQPubTop := edtPublishTopic.Text;
  Ini.MQPubQos := cbxQoSLevel.ItemIndex;
  Ini.MQSSL := chkSSL.Checked;
  SaveToFile;
end;

procedure TFrmMQClient.tmSendTimer(Sender: TObject);
begin
  btnPublishClick(Sender);
  if chkAutoClearLog.Checked then
  begin
    if tmSend.Tag = 0 then
      tmSend.Tag := GetTickCount
    else if GetTickCount - Cardinal(tmSend.Tag) > 15000 then
    begin
      tmSend.Tag := GetTickCount;
      Memo1.Text := '';
      Memo2.Text := '';
    end;
  end;
end;

procedure TFrmMQClient.tmStaticsTimer(Sender: TObject);
begin
  if Assigned(FClient) then
    pnlStatus.Caption := '收到主题:' + IntToStr(FClient.RecvTopics) + ' 发布主题:' +
      IntToStr(FClient.SentTopics);
end;

end.

