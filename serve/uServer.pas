{ *************************************************************************** }
{  SynWebServer.pas is the 3rd file of SynBroker Project                      }
{  by c5soft@189.cn  Version 0.9.0.0  2018-5-27                               }
{ *************************************************************************** }
{
mORMot服务请求接收处理单元
-WEBSERVICE call Process
-HTTP call DoCommandGet
-实际业务在函数Execute中处理
}

unit uServer;

interface

uses
  SysUtils, Classes,  HTTPApp, WebReq, SynCommons, SynCrtSock,
  SynWebEnv,  Vcl.ExtCtrls,System.Types,SYSTEM.NetEncoding;

type
  TSynWebRequestHandler = class(TWebRequestHandler);

  TSynWebServer = class
  private
    StartTime, StopTime: Int64;
    FOwner: TObject;
    FActive: Boolean;
    {$IFDEF Socket}
    FHttpServer: THttpApiWebSocketServer;
    {$ELSE}
    FHttpServer: THttpApiServer;
    {$ENDIF}
    FReqHandler: TWebRequestHandler;
    FPath: string;   //文件保存位置
    function Process(AContext: THttpServerRequest): cardinal;
    function DoCommandGet(AContext: THttpServerRequest): cardinal;
    function WebBrokerDispatch(const AEnv: TSynWebEnv): Boolean;
    function GetActiveCount: Integer;
    function onAccept(AContext: THttpServerRequest;var Conn: THttpApiWebSocketConnection): Boolean;
    procedure onConnect(const Conn: THttpApiWebSocketConnection );
    procedure onMessage(const Conn: THttpApiWebSocketConnection;
      aBufferType: WEB_SOCKET_BUFFER_TYPE; aBuffer: Pointer; aBufferSize: Cardinal);
    procedure onDisconnect(const Conn: THttpApiWebSocketConnection ;
      aStatus: WEB_SOCKET_CLOSE_STATUS; aBuffer: Pointer; aBufferSize: Cardinal);
  public
    property Active: Boolean read FActive;
    property ActiveCount: Integer read GetActiveCount;
    constructor Create(AOwner: TComponent = nil);
    destructor Destroy; override;
    function Execute(Header,InValue: string; out OutValue: string): Boolean;
  end;

  TSynHTTPWebBrokerBridge = TSynWebServer;

implementation

uses
  SynZip, SynWebReqRes, uRouter, System.Variants, Winapi.Windows,
  Forms, Winapi.Messages, uHtml, QLog, UpubFun,QWorker,Qjson,QXML,
  uConfig,uEncry;

var
  RequestHandler: TWebRequestHandler = nil;

function GetRequestHandler: TWebRequestHandler;
begin
  if RequestHandler = nil then
    RequestHandler := TSynWebRequestHandler.Create(nil);
  Result := RequestHandler;
end;

{ TSynWebServer }

constructor TSynWebServer.Create(AOwner: TComponent);
begin
  inherited Create;
  FActive := False;
  FOwner := AOwner;
  if (FOwner <> nil) and (FOwner.InheritsFrom(TWebRequestHandler)) then
    FReqHandler := TWebRequestHandler(FOwner)
  else
    FReqHandler := GetRequestHandler;
  FReqHandler.MaxConnections := Ini.Pools;
  {$IFDEF Socket}
  FHttpServer := THttpApiWebSocketServer.Create(False,8,10000);
  {$ELSE}
  FHttpServer := THttpApiServer.Create(False);
  {$ENDIF}
  if FHttpServer <> nil then
  begin
    FHttpServer.AddUrl(StringTOUTF8(ini.Root), StringTOUTF8(ini.Port), Ini.Https, '+', true);
    {$IFDEF Socket}
    if Ini.Socket then
    begin
      FHttpServer.AddUrlWebSocket('WSYXHIS', StringTOUTF8(ini.Port), Ini.Https, '+');
      FHttpServer.RegisterProtocol('WSYXHIS', False, onAccept, onMessage, onConnect, onDisconnect);
    end;
    {$ENDIF}
  end;
  FHttpServer.RegisterCompress(CompressDeflate);
  // our server will deflate html :)
  if Ini.HttpType then
    FHttpServer.OnRequest := DoCommandGet
  else
    FHttpServer.OnRequest := Process;
  //处理请求队列，太大了并没有意义，业务上根本处理不了
  FHttpServer.HTTPQueueLength := 1000;
  FHttpServer.Clone(Ini.Pools - 1); // will use a thread pool of 32 threads in total
  FActive := true;
  FPATH := ExtractFilePath(ParamStr(0)) + 'File';
  if not DirectoryExists(FPATH) then
    CreateDir(FPATH);
end;

destructor TSynWebServer.Destroy;
begin
  FHttpServer.RemoveUrl(StringTOUTF8(Ini.Root), StringTOUTF8(Ini.Port), Ini.Https, '+');
  FreeAndNil(FHttpServer);
  inherited;
end;

function TSynWebServer.Execute(Header,InValue: string; out OutValue: string): Boolean;
var
  R: Router;
begin
  Result := False;
  OutValue := '';
  try
    R := Router.Create;
    try
      if not R.DoExcute(Header,InValue, OutValue) then
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
  Result := True;
end;

{$REGION 'Http'}
function TSynWebServer.DoCommandGet(AContext: THttpServerRequest): cardinal;
var
  aBuff,aHeader: string;
  OutValue: string;
  Log: string;
  W: TTextWriter;
  FileName: TFileName;
  FN, SRName, href: RawUTF8;
  i: integer;
  SR: TSearchRec;
  procedure hrefCompute;
  begin
    SRName := StringToUTF8(SR.Name);
    href := FN+StringReplaceChars(SRName,'\','/');
  end;
//文件目录
  procedure GetRoot(Url:string);
  begin
    FN := StringReplaceChars(UrlDecode(copy(AContext.URL,15,maxInt)),'/','\');
    if PosEx('..',FN)>0 then Exit;
    while (FN<>'') and (FN[1]='\') do
      delete(FN,1,1);
    while (FN<>'') and (FN[length(FN)]='\') do
      delete(FN,length(FN),1);
    FileName := ExtractFilePath(ParamStr(0))+UTF8ToString(FN);
    if DirectoryExists(FileName) then
    begin
      // reply directory listing as html
      W := TTextWriter.CreateOwnedStream;
      try
        W.Add('<html><body style="font-family: Arial">'+
          '<h3>%</h3><p><table>',[FN]);
        FN := StringReplaceChars(FN,'\','/');
        if FN<>'' then
          FN := FN+'/';
        if FindFirst(FileName+'\*.*',faDirectory,SR)=0 then
        begin
          repeat
            if (SR.Attr and faDirectory<>0) and (SR.Name<>'.') then begin
              hrefCompute;
              if SRName='..' then begin
                i := length(FN);
                while (i>0) and (FN[i]='/') do dec(i);
                while (i>0) and (FN[i]<>'/') do dec(i);
                href := copy(FN,1,i);
              end;
              W.Add('<tr><td><b><a href="'+Ini.Root+'/root/%">[%]</a></b></td></tr>',[href,SRName]);
            end;
          until FindNext(SR)<>0;
          SysUtils.FindClose(SR);
        end;
        if FindFirst(FileName+'\*.*',faAnyFile-faDirectory-faHidden,SR)=0 then
        begin
          repeat
            hrefCompute;
            if SR.Attr and faDirectory=0 then
              W.Add('<tr><td><b><a href="'+Ini.Root+'/root/%">%</a></b></td><td>%</td><td>%</td></td></tr>',
                [href,SRName,KB(SR.Size),DateTimeToStr(FileDateToDateTime(SR.Time))]);
          until FindNext(SR)<>0;
          SysUtils.FindClose(SR);
        end;
        W.AddShort('</table></p><p><i>Powered by 2405414352@qq.com');
        W.AddShort(' - <strong>YanHua Medical</strong></i></p></body></html>');
        //W.AddClassName(AContext.Server.ClassType);
        //W.AddShort('</strong></i> - '+'see <a href=https://synopse.info>https://synopse.info</a></p></body></html>');
        OutValue := W.Text;
        OutValue := OutValue.replace('[..]','[上一层]');
      finally
        W.Free;
      end;
    end
    else
    begin
      // http.sys will send the specified file from kernel mode
      OutValue := FileName;
      AContext.OutContentType := HTTP_RESP_STATICFILE;
    end;
  end;
//文件下载
  procedure Download(Url: string);
  var
    sFile, fileName: string;
  begin
    fileName := Copy(Url, pos('fileDown?file=', Url) + length('fileDown?file='), length(Url));
    sFile := FPATH + '\' + fileName;
    OutValue := sFile;
    AContext.OutCustomHeaders := AContext.OutCustomHeaders
      + #13#10 + 'Content-Disposition:filename=' + fileName;
    AContext.OutContentType := HTTP_RESP_STATICFILE;
  end;
//文件上传
  function Upload(mimetype, params: RawUTF8) : Boolean;
  var
    parts: TMultiPartDynArray;
    i: Integer;
    ss: TStringStream;
  begin
    Result := False;
    try
      MultiPartFormDataDecode(mimetype, params, parts);
      if Length(parts) =0 then
      begin
        OutValue := '无文件！请检查！';
        Exit;
      end;
      for i := 0 to high(parts) do
      begin
        if sametext(parts[i].Name, 'file') then
        begin
          ss := TStringStream.Create(parts[i].Content);
          try
            ss.SaveToFile(FPATH + '\' + parts[i].filename)
          finally
            ss.Free;
          end;
        end
        else
        begin
          OutValue := '上传文件格式错误！请指定文件参数key=file！';
          Exit
        end;
      end;
    except
      on e: Exception do
      begin
        OutValue := '文件保存出错！' + e.Message;
        Exit
      end;
    end;
    OutValue := '';
    Result := True;
  end;

begin
  StartTime := GetTickCount64;
  //收到请求发送信号到主线程
  Workers.Signal(SignalAllID);
  Result := 200;
  AContext.OutCustomHeaders := 'Developer:2405414352@qq.com' + #13#10 +
      'Development:YanHua Medical'+ #13#10 + 'Access-Control-Allow-Origin:*';
  AContext.OutContentType := JSON_CONTENT_TYPE;
  if not IdemPChar(pointer(AContext.URL),PansiChar(Ini.Root))  then begin
    Result := 404;
    Exit;
  end;
  try
    OutValue := '';
    try
      if AContext.Method = 'GET' then
      begin
        AContext.OutContentType := HTML_CONTENT_TYPE;
        if (Pos(Ini.Root+'/', AContext.URL) < 1) then
        begin
          OutValue := '404！ HTTP NOT FOUND！';
          if AContext.URL = Ini.Root then
            OutValue := (cstHTMLBegin
              {.$DEFINE Service}
              {$IFDEF Service}
              + '<P><a href="https://console-docs.apipost.cn/preview/bf3e99e5e7b1047d/7cbb247154d23f1c">'
              +'<span class="api_name"><font color="red">接口服务文档</font></span></P>'
              +'<P><a href="https://47q480p552.picp.vip/IWSYXHIS/fileDown?file=YxCisSvr2.0.exe">'
              +'<span class="api_name"><font color="red">V2.0接口程序下载</font></span></P>'
              +'<P><a href="https://47q480p552.picp.vip/IWSYXHIS/fileDown?file=YxEmr.exe">'
              +'<span class="api_name"><font color="red">V3.0接口程序下载</font></span></P>'
              {$ENDIF}
              +cstHTMLEnd).Replace('text-align:Left;',
              'text-align:Center;');
          Exit;
        end;
        //直接下载当前目录的file文件夹下的文件
        if (Pos('/fileDown?file=', AContext.URL) > 0) then
        begin
          Download(HTTPDecode(AContext.URL));
          Exit;
        end;
        //返回程序当前目录
        if (Pos('/root', AContext.URL) > 0 ) then
        begin
          GetRoot(AContext.URL);
          Exit;
        end;
        //上传文件
        {$IFDEF Service}
        if (Pos('/Upload',AContext.URL) > 0 ) then
        begin
          OutValue := cshtmlup;
          Exit;
        end;
        {$ENDIF}
        aBuff := '/'+UTF8Decode(AContext.URL);
        aHeader := UTF8ToString(AContext.InHeaders).Replace(#13#10,'&');
        if not Execute(aHeader,aBuff, OutValue) then
          Exit;
      end
      else
      begin
        if AContext.URL <> Ini.Root then
        begin
          OutValue := '404！ HTTP NOT FOUND！';
          Result := 404;
          Exit;
        end;
        //保存文件
        if Pos('multipart/form-data', AContext.InContentType) > 0 then
        begin
          if upload(AContext.InContentType, AContext.InContent) then
            OutValue := SetResultInfo(1,OutValue)
          else
            OutValue := SetResultInfo(0,OutValue);
          Exit;
        end;
        //调用其他post业务
        aBuff := UTF8ToString(AContext.InContent);
        aHeader := UTF8ToString(AContext.InHeaders).Replace(#13#10,'&');
        if aBuff = '' then
        begin
          OutValue := '无效入参！请检查！';
          OutValue := SetResultInfo(0,OutValue);
          Exit;
        end;
        AContext.OutContentType := JSON_CONTENT_TYPE;
        if not Execute(aHeader,aBuff, OutValue) then
          Exit;
      end;

    except
      on e: Exception do
      begin
        OutValue := '服务器运行出错:' + UTF8ToString(AContext.Method + ' ' + AContext.URL)
          + '：' + e.Message;
        OutValue := SetResultInfo(0,OutValue);
        Result := 500;
      end;
    end;
  finally
    AContext.OutContent := StringToUTF8(OutValue);
    StopTime := GetTickCount64;
    var aJson := TQjson.create;
    var Value := AESDecode(OutValue);
    try
      Log := #13#10 + '[请求方式]:' + 'HTTP/'+AContext.Method
           + #13#10 + '[请求地址]:' + AContext.URL
           + #13#10 + '[请求头]:' + aHeader
           + #13#10 + '[耗时]:' + (StopTime - StartTime).ToString + 'ms'
           + #13#10 + '[入参]:' + UTF8ToString(AContext.InContent)
           + #13#10 + '[出参]:' + Value + #13#10;
      if aJson.TryParse(Value) then
      begin
        if aJson.IntByPath('Result.Code',0) = 0 then
        begin
          PostLog(llError, Log);
          //发送失败信号到主线程
          Workers.Signal(SignalFalseID);
        end
        else
          PostLog(llMessage, Log);
      end
      else
        PostLog(llMessage, Log);
    finally
      aJson.Free;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'WebService'}

function TSynWebServer.Process(AContext: THttpServerRequest): cardinal;
var
  FEnv: TSynWebEnv;
  Log,Invalue,Outvalue: string;
begin
  try
    StartTime := GetTickCount64;
    try
      //收到请求发送信号到主线程
      Workers.Signal(SignalAllID);
      FEnv := TSynWebEnv.Create(AContext);
      try
        if WebBrokerDispatch(FEnv) then
          Result := 200
        else
          Result := 404;
      finally
        Freeandnil(FEnv);
      end;
    except
      on e: Exception do
      begin
        AContext.OutContent := StringTOUTF8(SetResultInfo(0,'服务器运行出错:'
          + UTF8ToString(AContext.Method + '-' + AContext.URL) + '：' + e.Message));
        Result := 500;
      end;
    end;
  finally
    StopTime := GetTickCount64;
    AContext.OutCustomHeaders := 'Developer:2405414352@qq.com' + #13#10 +
      'Development:YanHua Medical'+ #13#10 + 'Access-Control-Allow-Origin:*' ;
    Outvalue := UTF8ToString(AContext.OutContent);
    Invalue :=  UTF8ToString(AContext.InContent);
    var aJson := TQjson.create;
    var aXml := TQXML.Create;
    try
      //写入日志时简化入参，去掉soap层
      aXml.Parse(Invalue);
      if (aXml <> nil) and (aXml.ItemByPath('soapenv:Envelope/soapenv:Body/urn:DoExcute/InValue')<>nil) then
        Invalue := aXml.ItemByPath('soapenv:Envelope/soapenv:Body/urn:DoExcute/InValue').ToString;
      aXml.Parse(Outvalue);
      if (aXml <> nil) and (aXml.ItemByPath('SOAP-ENV:Envelope/SOAP-ENV:Body/NS1:DoExcuteResponse/return')<>nil) then
        Outvalue := aXml.ItemByPath('SOAP-ENV:Envelope/SOAP-ENV:Body/NS1:DoExcuteResponse/return').ToString;
      Log := #13#10 + '[请求方式]:' + 'WEBSERVICE/SOAP'
           + #13#10 + '[请求地址]:' + AContext.URL
           + #13#10 + '[请求头]:' + UTF8ToString(AContext.InHeaders).Replace(#13#10,'&')
           + #13#10 + '[耗时]:' + (StopTime - StartTime).ToString + 'ms'
           + #13#10 + '[入参]:' + Invalue
           + #13#10 + '[出参]:' + OutValue + #13#10;
      if aJson.TryParse(Outvalue) then
      begin
        if aJson.IntByPath('Result.Code',0) = 0 then
        begin
          PostLog(llError, Log);
          //发送失败信号到主线程
          Workers.Signal(SignalFalseID);
        end
        else
          PostLog(llMessage, Log);
      end
      else
        PostLog(llMessage, Log);
    finally
      aXml.Free;
      aJson.Free;
    end;
  end;
end;

function TSynWebServer.WebBrokerDispatch(const AEnv: TSynWebEnv): Boolean;
var
  HTTPRequest: TSynWebRequest;
  HTTPResponse: TSynWebResponse;
begin
  HTTPRequest := TSynWebRequest.Create(AEnv);
  try
    HTTPResponse := TSynWebResponse.Create(HTTPRequest);
    try
      Result := TSynWebRequestHandler(FReqHandler).HandleRequest(HTTPRequest,
        HTTPResponse);
    finally
      freeandnil(HTTPResponse);
    end;
  finally
    freeandnil(HTTPRequest);
  end;
end;
{$ENDREGION}

{$REGION 'WebSocket'}
function TSynWebServer.onAccept(AContext: THttpServerRequest;
  var Conn: THttpApiWebSocketConnection): Boolean;
begin
  Result := True;
end;

procedure TSynWebServer.onConnect(const Conn: THttpApiWebSocketConnection);
begin
  PostLog(llMessage,'New ConNecTionID='+Conn.index.ToString);
end;

procedure TSynWebServer.onDisconnect(const Conn: THttpApiWebSocketConnection;
  aStatus: WEB_SOCKET_CLOSE_STATUS; aBuffer: Pointer; aBufferSize: Cardinal);
var
  str: RawUTF8;
begin
  SetString(str, pUtf8Char(aBuffer), aBufferSize);
  PostLog(llMessage,'DisconnectedID='+Conn.index.ToString+';Msg:'+UTF8ToString(Str));
end;

procedure TSynWebServer.onMessage(const Conn: THttpApiWebSocketConnection;
  aBufferType: WEB_SOCKET_BUFFER_TYPE; aBuffer: Pointer; aBufferSize: Cardinal);
var
  aBuff,aHeader,aRst: RawUTF8;
  OutValue,Log:String;
begin
  StartTime := GetTickCount64;
  try
    Workers.Signal(SignalAllID);
    try
      SetString(aBuff, pUtf8Char(aBuffer), aBufferSize);
      //调用其他post业务
      if aBuff = '' then
      begin
        OutValue := '无效入参！请检查！';
        OutValue := SetResultInfo(0,OutValue);
        Exit;
      end;
      if not Execute('Socket',aBuff, OutValue) then
        Exit;
    except
      on e:Exception do
        OutValue := SetResultInfo(0,e.message);
    end;

  finally
    aRst := StringToUTF8(OutValue);
    //返回socket数据
    Conn.Send(aBufferType, Pointer(aRst), Length(aRst));
    StopTime := GetTickCount64;
    var aJson := TQjson.create;
    try
      Log := #13#10 + '[请求方式]:' + 'WebSocket'
           + #13#10 + '[请求地址]:/WSYXHIS'
           + #13#10 + '[请求头]:' //+ aHeader
           + #13#10 + '[客户端ID]:' + Conn.Index.ToString
           + #13#10 + '[耗时]:' + (StopTime - StartTime).ToString + 'ms'
           + #13#10 + '[入参]:' + aBuff
           + #13#10 + '[出参]:' + OutValue + #13#10;
      if aJson.TryParse(OutValue) then
      begin
        if aJson.IntByPath('Result.Code',0) = 0 then
        begin
          PostLog(llError, Log);
          //发送失败信号到主线程
          Workers.Signal(SignalFalseID);
        end
        else
          PostLog(llMessage, Log);
      end
      else
        PostLog(llMessage, Log);
    finally
      aJson.Free;
    end;
  end;
end;
{$ENDREGION}


function TSynWebServer.GetActiveCount: Integer;
begin
  Result := FReqHandler.ActiveCount;
end;

initialization
  WebReq.WebRequestHandlerProc := GetRequestHandler;


finalization
  if RequestHandler <> nil then
    FreeAndNil(RequestHandler);

end.

