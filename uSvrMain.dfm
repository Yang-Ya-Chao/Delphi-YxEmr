object MainService: TMainService
  OnDestroy = ServiceDestroy
  DisplayName = 'YxEmr'
  BeforeInstall = ServiceBeforeInstall
  AfterInstall = ServiceAfterInstall
  OnContinue = ServiceContinue
  OnPause = ServicePause
  OnShutdown = ServiceShutdown
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 201
  Width = 389
  PixelsPerInch = 96
end
