unit uFrmAuthManage;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls,Data.DB, Vcl.DBGrids,Snowflake,
  uEncry, Vcl.Clipbrd,UpubFun,Vcl.Menus,Rtti,SynCrypto,
  FireDAC.Comp.Client,FireDAC.DApt,uConfig,uObjPools,uQueryHelper, Vcl.Grids;
const
  InputBoxMessage = WM_USER + 200;
{type
  TAuth=(ReadCard,WriteRegInfo,DoCharge,DoPerForm,WriteReport,DontTransact,
    CancelBarCode,MakeSQD,DelSQD,ExecCharge,ManageOpe,ManageDoc,ManageDep,
    GetPatData,GetMBMX,SaveEMR,GetEMR);}

type
  TFrmAuthManage = class(TForm)
    pnl1: TPanel;
    pnl3: TPanel;
    pnl2: TPanel;
    btnAdd: TBitBtn;
    btnMof: TBitBtn;
    btnDel: TBitBtn;
    btnSave: TBitBtn;
    lblUser: TLabel;
    edtUser: TEdit;
    grp1: TGroupBox;
    btnCanl: TBitBtn;
    Grid1: TDBGrid;
    ds1: TDataSource;
    GB1: TRadioGroup;
    pm1: TPopupMenu;
    N1: TMenuItem;
    oken1: TMenuItem;
    btnrefresh: TButton;
    edtTime: TEdit;
    lblUser1: TLabel;
    procedure btnAddClick(Sender: TObject);
    procedure btnMofClick(Sender: TObject);
    procedure btnCanlClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure CheckClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Grid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GB1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure oken1Click(Sender: TObject);
    procedure btnrefreshClick(Sender: TObject);
  private
    { Private declarations }
    FCSQL:string;//刷新时sql语句
    ILX:Integer; //0:新增，1:修改，2:刷新
    CID:string;
    //Auth :TAuth;
    //AuthList:TStringList;
    DB:TFDConnection;
    Qry:TFDQuery;
    procedure Enable(B:Boolean);
    procedure InputBoxSetPasswordChar(var Msg: TMessage); message InputBoxMessage;//声明
    function CheckGLY:Boolean;
    procedure GetAuthGrid;
    procedure AfterScroll(DataSet: TDataSet);
    procedure Reset;
  public
    { Public declarations }
    iPerLine : integer;//每行个数
    Checkboxs:array of TCheckBox;
    MethodList:TStringlist;
  end;

var
  FrmAuthManage: TFrmAuthManage;

implementation

{$R *.dfm}


procedure TFrmAuthManage.btnAddClick(Sender: TObject);
begin
  if not CheckGLY then Exit;
  ILX := 0;
  var IID := IdGenerator.NextId();
  CID := IntToStr(IID);
  Enable(True);
  Reset;
end;

procedure TFrmAuthManage.btnCanlClick(Sender: TObject);
begin
  Enable(False);
  GetAuthGrid ;
end;

procedure TFrmAuthManage.btnDelClick(Sender: TObject);
begin
  if Qry.IsEmpty then Exit;
  if not CheckGLY then Exit;
  try
    if MessageBox(Handle, Pchar('确认删除授权码['+CID+']？'), '提示', MB_YESNO+MB_ICONQUESTION) = IDYES then
    begin
      var CSQL := 'Delete From TBYxEmrAuthManage where iid='+CID;
      Qry.SQL.Text := CSQL;
      try
        Qry.ExecSQL;
      except
        on e:Exception do
        begin
          MessageBox(Handle, PChar(e.message+'SQL='+CSQL), '错误', MB_ICONERROR);
          Exit;
        end;
      end;
    end;
  finally
    Enable(False);
    GetAuthGrid ;
  end;
end;

procedure TFrmAuthManage.btnMofClick(Sender: TObject);
begin
  if not CheckGLY then Exit;
  ILX := 1;
  Enable(True);
end;

procedure TFrmAuthManage.btnrefreshClick(Sender: TObject);
var
  i:Integer;
begin
  try
    ILX := 2;
    while not Qry.Eof do
    begin
      btnSaveClick(Self);
      Qry.Next;
    end;
    if FCSQL <> '' then
    begin
      Qry.SQL.Text := FCSQL;
      try
        Qry.ExecSQL;
      except
        on e:Exception do
        begin
          MessageBox(Handle, PChar(e.message+'SQL='+FCSQL), '错误', MB_ICONERROR);
          Exit;
        end;
      end;
      GetAuthGrid ;
    end;
  finally
    FCSQL := ''
  end;
end;

procedure TFrmAuthManage.btnSaveClick(Sender: TObject);
var
  CSQL:String;
  Invalue:string;
  Token:string;
  //LToken: TJWT;
  SAuth:string;
  LJWT:TJWTAbstract;
  i:Integer;
begin
  if Trim(edtuser.Text) = '' then
  begin
    MessageBox(Handle, '请填写用户！', '错误', MB_ICONERROR);
    edtuser.SetFocus;
    Exit;
  end;
  if edtTime.Text = '' then
    edtTime.Text := '30';
  for I := 0 to Length(Checkboxs)-1 do
  begin
    if SAuth <> '' then
      SAuth := SAuth+'|';
    if Checkboxs[i].Checked then
      SAuth := SAuth+Checkboxs[i].Caption;
  end;
  //SAuth := AuthList.Text.Replace(#13#10,'|').Replace(#0,'');
  Invalue := EnCode(CID+'=|'+SAuth+'|');
  LJWT := TJWTHS256.Create(UTF8Encode(HS256Key), 1,
    [jrcIssuer, jrcSubject, jrcAudience, jrcIssuedAt,jrcJwtID],
    [], GetRegisTime*24*60);
  try
    Token := UTF8Decode(LJWT.Compute(['id:',CID],
        'YxEmr Server', SAuth, Trim(edtuser.Text)));
  finally
    LJWT.Free;
  end;

  case ILX of
    0:CSQL := 'Insert Into TBYxEmrAuthManage (IID,UserName,AuthCode,TokenCode,TimeOut) values('
      + CID + ',' + Quotedstr(Trim(edtuser.Text)) + ',' + QuotedStr(Invalue)
      + ',' + Quotedstr(Token) + ',' + edtTime.Text +')';
    1:CSQL := 'Update TBYxEmrAuthManage Set UserName=' + Quotedstr(Trim(edtuser.Text))
      +',AuthCode=' + QuotedStr(Invalue) + ',TokenCode='+ Quotedstr(Token)
      +',TimeOut=' + edtTime.Text +' Where IID=' + CID;
    2:FCSQL := FCSQL +#13#10+ ' Update TBYxEmrAuthManage Set UserName=' + Quotedstr(Trim(edtuser.Text))
      +',AuthCode=' + QuotedStr(Invalue) + ',TokenCode='+ Quotedstr(Token)
      +',TimeOut=' + edtTime.Text +' Where IID=' + CID+';';
  end;
  if ILX <> 2 then
  begin
    Qry.SQL.Text := CSQL;
    try
      Qry.ExecSQL;
    except
      on e:Exception do
      begin
        MessageBox(Handle, PChar(e.message+'SQL='+CSQL), '错误', MB_ICONERROR);
        Exit;
      end;
    end;
    Enable(False);
    GetAuthGrid ;
  end;
end;

procedure TFrmAuthManage.Enable(B: Boolean);
begin
  pnl1.enabled := B;
  btnCanl.enabled :=  B;
  btnSave.enabled :=  B;
  pnl2.enabled := not B;
  btnadd.enabled := not B;
  btnMof.enabled := not B;
  btnDel.enabled := not B;
  GB1.ItemIndex := -1;
end;

procedure TFrmAuthManage.AfterScroll(DataSet: TDataSet);
var
  AuthCode,sTmp:string;
  AuthList:TStringList;
begin
  if DataSet.IsEmpty then Exit;
  Reset;
  AuthList := TStringList.Create;
  try
    edtUser.Text := TFDQuery(DataSet).S['UserName'];
    edtTime.Text := TFDQuery(DataSet).S['TimeOut'];
    CID := TFDQuery(DataSet).S['IID'];
    AuthCode := DeCode(TFDQuery(DataSet).S['AuthCode']);
    sTmp := Copy(AuthCode,1,Pos('=',AuthCode)-1);
    if CID <> sTmp then
    begin
      MessageBox(Handle, PChar('授权码['+CID+']权限非法！请重置！'), '错误', MB_ICONERROR);
      Exit;
    end;
    AuthCode := Copy(AuthCode,Pos('=',AuthCode)+1,Length(AuthCode));
    AuthList.Text := AuthCode.Replace('|',#13#10).Replace(#0,'');
    for sTmp in AuthList do
    begin
      if Trim(sTmp) = '' then Continue;
      //Tag := Ord(TRttiEnumerationType.GetValue<TAuth>(sTmp));
      //TCheckBox(grp1.Controls[Tag]).Checked := True;
      Checkboxs[MethodList.IndexOf(sTmp)].Checked := True;
    end;
  finally
    AuthList.free;
  end;
end;
const
  iHtoH = 15; //行间距
  iWtoW = 20; //列间距
  iWidth = 100; //按钮宽度

procedure TFrmAuthManage.FormCreate(Sender: TObject);
var
  i:integer;
  Method:String;
begin

  DB := SQLiteDBPool.GetObj;
  Qry := TFDQuery.Create(nil);
  Qry.Connection := DB;
  MethodList := TStringList.Create;
  MethodList.Text := Ini.Method.Replace('|',#13#10);
  SetLength(Checkboxs,MethodList.Count);
  iPerLine := grp1.ClientWidth div (iWidth+iWtoW);
  for i := 0 to MethodList.Count-1 do
  begin
    Checkboxs[i]:=TCheckBox.Create(Self);
    Checkboxs[i].Parent:=grp1;        //组  GroupBox控件名
    Checkboxs[i].OnClick:=CheckClick;
    Checkboxs[i].Tag:=i;
    Checkboxs[i].Caption:=MethodList[i];
    Checkboxs[i].Top:= iHtoH + (30+iHtoH) * ((i+1) div iPerLine - integer(((i+1) mod iPerLine)=0));
    Checkboxs[i].Left:= iWtoW + (iWidth+iWtoW) * ((i) mod iPerLine);
  end;
end;

procedure TFrmAuthManage.FormDestroy(Sender: TObject);
begin
  Checkboxs := nil;
  Qry.Free;
  SQLiteDBPool.PutObj(DB);
  MethodList.Free;
  inherited;
end;

procedure TFrmAuthManage.FormShow(Sender: TObject);

begin
  if DB = nil then
  begin
    PostMessage(Self.Handle, WM_CLOSE, 0, 0);
    Exit;
  end;
  Enable(False);
  ILX := 0;
  var CSQL := 'SELECT * FROM sqlite_master where type=''table'' and name = ''TBYxEmrAuthManage'' ';
  Qry.Open(CSQL);
  if Qry.IsEmpty then
  begin
    CSQL := 'CREATE TABLE TBYxEmrAuthManage ('
    +#13#10+'IID BIGINT Primary key Not null,'
    +#13#10+'UserName VARCHAR(100) null,'
    +#13#10+'TokenCode VARCHAR(1000)  null,'
    +#13#10+'TimeOut BIGINT not null,'
    +#13#10+'AuthCode VARCHAR(1000) not null )';
    Qry.ExecSQL(CSQL);
  end;
  {CSQL := 'SELECT * FROM sqlite_master where type=''table'' and name = ''TBSysLog'' ';
  Qry.Open(CSQL);
  if Qry.IsEmpty then
  begin
    CSQL := 'CREATE TABLE TBSysLog ('
    +#13#10+'IID BIGINT Primary key Not null,'
    +#13#10+'InHeader TEXT null,'
    +#13#10+'InValue TEXT null,'
    +#13#10+'OutValue TEXT  null,'
    +#13#10+'StarTime DateTime null,'
    +#13#10+'StopTime DateTime null,'
    +#13#10+'Take BIGINT null)';
    Qry.ExecSQL(CSQL);
  end;    }
  GetAuthGrid ;
end;

procedure TFrmAuthManage.Reset;
var
  i:Integer;
begin
  edtUser.Text := '';
  edtTime.Text := '30';
  for I := 0 to grp1.ControlCount-1 do
    TCheckBox(grp1.Controls[i]).Checked := False;
end;

procedure TFrmAuthManage.GB1Click(Sender: TObject);
var
  i:Integer;
begin
  case GB1.ItemIndex of
    0:begin
      for I := 0 to grp1.ControlCount-1 do
       TCheckBox(grp1.Controls[i]).Checked := True;
    end;
    1:begin
      for I := 0 to grp1.ControlCount-1 do
       TCheckBox(grp1.Controls[i]).Checked := not TCheckBox(grp1.Controls[i]).Checked ;
    end;
    2:begin
      for I := 0 to grp1.ControlCount-1 do
       TCheckBox(grp1.Controls[i]).Checked := False;
    end;
  end;
end;

procedure TFrmAuthManage.GetAuthGrid;
begin
  Qry.AfterScroll := nil;
  var CSQL := 'Select IID ,UserName ,AuthCode ,TokenCode ,TimeOut from TBYxEmrAuthManage';
  Qry.SQL.Text := CSQL;
  try
    Qry.AfterScroll := AfterScroll;
    Qry.Open;
  except
    on e:Exception do
    begin
      MessageBox(Handle, PChar(e.message+'SQL='+CSQL), '错误', MB_ICONERROR);
      Exit;
    end;
  end;
  ds1.DataSet := Qry ;
  Grid1.columns[0].Title.alignment := taCenter;
  Grid1.columns[1].Title.alignment := taCenter;
  Grid1.columns[2].Title.alignment := taCenter;
  Grid1.columns[0].alignment := taCenter;
  Grid1.columns[1].alignment := taCenter;
  Grid1.columns[2].alignment := taCenter;
  Grid1.columns[0].Width := 300;
  Grid1.columns[1].Width := 200;
  Grid1.columns[2].Width := 100;
  if Qry.IsEmpty then
    Reset;
end;

procedure TFrmAuthManage.Grid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ssCtrl in Shift then
    case Key of
      Ord('C'):Clipboard.AsText := TFDQuery(Grid1.DataSource.DataSet).S['IID'];
    end;
end;

procedure TFrmAuthManage.InputBoxSetPasswordChar(var Msg: TMessage);//实现
var
  hInputForm, hEdit, hButton: HWND;
begin
  hInputForm := Screen.Forms[0].Handle;
  if (hInputForm <> 0) then
  begin
      hEdit := FindWindowEx(hInputForm, 0, 'TEdit', nil);
      SendMessage(hEdit, EM_SETPASSWORDCHAR, Ord('*'), 0);
        // Change button text:
      hButton := FindWindowEx(hInputForm, 0, 'TButton', 'Cancel');
      SendMessage(hButton, WM_SETTEXT,0, Integer(PChar('取消')));
      hButton := FindWindowEx(hInputForm, 0, 'TButton', 'OK');
      SendMessage(hButton, WM_SETTEXT,0, Integer(PChar('确定')));
  end;
end;

procedure TFrmAuthManage.N1Click(Sender: TObject);
begin
  Clipboard.AsText := TFDQuery(Grid1.DataSource.DataSet).S['IID'];
end;

procedure TFrmAuthManage.oken1Click(Sender: TObject);
begin
  Clipboard.AsText :=  TFDQuery(Grid1.DataSource.DataSet).S['TokenCode'];
end;

procedure TFrmAuthManage.CheckClick(Sender: TObject);
begin
  //Auth := TAuth(TCheckBox(Sender).tag);
  //var Sauth := TRttiEnumerationType.GetName<TAuth>(Auth) ;
  {AuthList.Sorted := True;
  AuthList.Duplicates := dupIgnore;
  if TCheckBox(Sender).Checked then
    AuthList.Add(TCheckBox(Sender).Caption)
  else
   AuthList.Delete(AuthList.IndexOf(TCheckBox(Sender).Caption)); }
end;

function TFrmAuthManage.CheckGLY: Boolean;
var
  S:string;
begin
  Result := False;
  PostMessage(Handle, InputBoxMessage, 0, 0);
  if not InputQuery('管理员验证','请输入管理员密码：',S) then Exit;
  if S <> admin then
  begin
    MessageBox(Handle, '密码错误！', '错误', MB_ICONERROR);
    Exit;
  end;
  Result := True;
end;



end.
