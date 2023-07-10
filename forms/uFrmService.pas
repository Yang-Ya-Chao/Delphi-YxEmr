unit uFrmService;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Data.DB, Vcl.DBGrids;

type
  TfrmService = class(TForm)
    Grid1: TStringGrid;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmService: TfrmService;

implementation

{$R *.dfm}

end.
