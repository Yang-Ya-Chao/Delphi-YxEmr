program Register;

uses
  Vcl.Forms,
  uFrmRegister in 'uFrmRegister.pas' {FrmMain},
  uEncry in 'uEncry.pas',
  Vcl.Themes,
  Vcl.Styles,
  CnAES in 'CnAES.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Glossy');
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
