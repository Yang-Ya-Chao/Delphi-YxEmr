unit uFrmMonitor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Samples.Spin,
  Vcl.Buttons, Vcl.ComCtrls, Vcl.ExtCtrls,QWorker,Qlog;

type
  TFrmMonitor = class(TForm)
    pnl1: TPanel;
    pnl2: TPanel;
    pgc1: TPageControl;
    ts1: TTabSheet;
    ts2: TTabSheet;
    ts3: TTabSheet;
    se1: TSpinEdit;
    lbl1: TLabel;
    btnClear: TBitBtn;
    mmo1: TMemo;
    mmo2: TMemo;
    mmo3: TMemo;
    ts4: TTabSheet;
    mmo4: TMemo;
    ck1: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure se1Change(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure ck1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ErrWriter,MsgWriter,SQLWriter,ObjPoolWriter:TQLogStringsWriter;
  end;

var
  FrmMonitor: TFrmMonitor;

implementation

{$R *.dfm}

procedure TFrmMonitor.btnClearClick(Sender: TObject);
begin
  mmo1.Clear;
  mmo2.Clear;
  mmo3.Clear;
  mmo4.Clear;
end;



procedure TFrmMonitor.ck1Click(Sender: TObject);
begin
  MsgWriter.Enabled := ck1.checked;
  ErrWriter.Enabled := ck1.checked;
  SQLWriter.Enabled := ck1.checked;
  ObjPoolWriter.Enabled := ck1.checked;
end;

procedure TFrmMonitor.FormCreate(Sender: TObject);
begin
  //ÇëÇó¼à¿Ø
  MsgWriter := TQLogStringsWriter.Create;
  MsgWriter.MaxItems := 1;
  MsgWriter.Enabled := False;
  MsgWriter.Items := mmo1.lines;
  MsgWriter.AcceptLevels := [llMessage];
  Logs.Castor.AddWriter(MsgWriter);
  //´íÎó¼à¿Ø
  ErrWriter := TQLogStringsWriter.Create;
  ErrWriter.MaxItems := 1;
  ErrWriter.Enabled := False;
  ErrWriter.Items := mmo2.lines;
  ErrWriter.AcceptLevels := [llError];
  Logs.Castor.AddWriter(ErrWriter);
  //sql¼à¿Ø
  SQLWriter := TQLogStringsWriter.Create;
  SQLWriter.MaxItems := se1.Value;
  SQLWriter.Enabled := False;
  SQLWriter.Items := mmo3.lines;
  SQLWriter.AcceptLevels := [llDebug];
  Logs.Castor.AddWriter(SQLWriter);
  //¶ÔÏó³Ø¼à¿Ø
  //Workers.Wait(DoSignalJobMsgPools, SignalPools,false);
  ObjPoolWriter := TQLogStringsWriter.Create;
  ObjPoolWriter.MaxItems := 1;
  ObjPoolWriter.Enabled := False;
  ObjPoolWriter.Items := mmo4.lines;
  ObjPoolWriter.AcceptLevels := [llHint];
  Logs.Castor.AddWriter(ObjPoolWriter);
end;

procedure TFrmMonitor.FormDestroy(Sender: TObject);
begin
  Logs.Castor.RemoveWriter(MsgWriter);
  Logs.Castor.RemoveWriter(ErrWriter);
  Logs.Castor.RemoveWriter(SQLWriter);
  Logs.Castor.RemoveWriter(ObjPoolWriter);
  MsgWriter.Free;
  ErrWriter.Free;
  SQLWriter.Free;
  ObjPoolWriter.Free;
end;

procedure TFrmMonitor.se1Change(Sender: TObject);
begin
  SQLWriter.MaxItems := se1.Value;
end;

end.
