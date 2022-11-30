unit uMapSoap;

interface

implementation

uses HTTPApp, SOAPHTTPPasInv, WebBrokerSOAP, WSDLPub, SynWebEnv,SynWebReqRes, uServer;

function DoDispatch(const Env: TSynWebEnv; const ADispatcher: IWebDispatch): Boolean;
var
  Request: TSynWebRequest;
  Response: TSynWebResponse;
begin
  Request := TSynWebRequest.Create(Env);
  try
    Response := TSynWebResponse.Create(Request);
    try
      Result := ADispatcher.DispatchRequest(nil, Request, Response);
    finally
      Response.Free;
    end;
  finally
    Request.Free;
  end;
end;

function RouteMapSoapWSDL(const Env: TSynWebEnv): Boolean;
var
  WSDLPublisher: TWSDLHTMLPublish;
begin
  WSDLPublisher := TWSDLHTMLPublish.Create(nil);
  try
    Result:=DoDispatch(Env, WSDLPublisher);
  finally
    WSDLPublisher.Free;
  end;
end;

function RouteMapSoapPost(const Env: TSynWebEnv): Boolean;
var
  SoapDispatcher: THTTPSoapDispatcher;
  PascalInvoker: THTTPSoapPascalInvoker;
begin
  PascalInvoker := THTTPSoapPascalInvoker.Create(nil);
  SoapDispatcher := THTTPSoapDispatcher.Create(nil);
  SoapDispatcher.Dispatcher := PascalInvoker;
  try
    Result:=DoDispatch(Env, SoapDispatcher);
  finally
    SoapDispatcher.Free;
    PascalInvoker.Free;
  end;
end;

initialization
  RouteMap('GET', '/wsdl', RouteMapSoapWSDL);
  RouteMap('POST', '/soap', RouteMapSoapPost);

end.
