object FrmSvrConfig: TFrmSvrConfig
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #25509#21475#37197#32622
  ClientHeight = 343
  ClientWidth = 344
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -17
  Font.Name = #23435#20307
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object pnl2: TPanel
    Left = 0
    Top = 305
    Width = 344
    Height = 38
    Align = alClient
    TabOrder = 1
    object BtnSQL: TBitBtn
      Left = 196
      Top = 7
      Width = 75
      Height = 25
      Caption = #25968#25454#24211
      ParentDoubleBuffered = True
      TabOrder = 3
      OnClick = BtnSQLClick
    end
    object BtnCancel: TBitBtn
      Left = 131
      Top = 7
      Width = 49
      Height = 25
      Caption = #25918#24323
      ParentDoubleBuffered = True
      TabOrder = 2
      OnClick = BtnCancelClick
    end
    object BtnSave: TBitBtn
      Left = 67
      Top = 7
      Width = 49
      Height = 25
      Caption = #23384#30424
      ParentDoubleBuffered = True
      TabOrder = 1
      OnClick = BtnSaveClick
    end
    object BtnMod: TBitBtn
      Left = 3
      Top = 7
      Width = 49
      Height = 25
      Caption = #20462#25913
      ParentDoubleBuffered = True
      TabOrder = 0
      OnClick = BtnModClick
    end
    object BitBtn1: TBitBtn
      Left = 286
      Top = 7
      Width = 55
      Height = 25
      Caption = 'MQTT'
      Enabled = False
      TabOrder = 4
      OnClick = BitBtn1Click
    end
  end
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 344
    Height = 305
    Align = alTop
    DoubleBuffered = True
    ParentDoubleBuffered = False
    TabOrder = 0
    ExplicitTop = 1
    object lbl1: TLabel
      Left = 15
      Top = 190
      Width = 102
      Height = 17
      Caption = #24037#20316#32447#31243#24635#25968
    end
    object lbl2: TLabel
      Left = 140
      Top = 9
      Width = 34
      Height = 17
      Caption = #31471#21475
    end
    object lbl3: TLabel
      Left = 15
      Top = 117
      Width = 145
      Height = 17
      Caption = #26085#24535#20998#39029#22823#23567#65288'M'#65289
    end
    object lbl4: TLabel
      Left = 15
      Top = 217
      Width = 61
      Height = 17
      Caption = #29289#36164'Url'
    end
    object lbl5: TLabel
      Left = 15
      Top = 245
      Width = 69
      Height = 17
      Caption = #26381#21153#22120'IP'
    end
    object lbl6: TLabel
      Left = 15
      Top = 275
      Width = 119
      Height = 17
      Caption = #21382#21490#26085#24535#25991#20214#25968
    end
    object EdtWorkcount: TEdit
      Left = 140
      Top = 187
      Width = 93
      Height = 25
      NumbersOnly = True
      ParentShowHint = False
      ShowHint = False
      TabOrder = 17
      OnExit = EdtWorkcountExit
    end
    object rbWEB: TRadioButton
      Left = 15
      Top = 139
      Width = 113
      Height = 17
      Caption = 'WEBSERVICE'
      Enabled = False
      TabOrder = 13
    end
    object ckMsg: TCheckBox
      Left = 15
      Top = 71
      Width = 90
      Height = 17
      Caption = #35814#32454#26085#24535
      TabOrder = 6
    end
    object ckReBoot: TCheckBox
      Left = 15
      Top = 50
      Width = 126
      Height = 17
      Caption = #25509#21475#23450#26102#37325#21551
      TabOrder = 5
      OnClick = ckReBootClick
    end
    object rbHTTP: TRadioButton
      Left = 131
      Top = 139
      Width = 57
      Height = 17
      Caption = 'HTTP'
      Checked = True
      TabOrder = 14
      TabStop = True
    end
    object ckAutoRun: TCheckBox
      Left = 15
      Top = 29
      Width = 126
      Height = 17
      Caption = #24320#26426#33258#21160#21551#21160
      TabOrder = 3
    end
    object ckRun: TCheckBox
      Left = 15
      Top = 8
      Width = 126
      Height = 17
      Caption = #33258#21160#24320#22987#26381#21153
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object EdtPort: TEdit
      Left = 179
      Top = 6
      Width = 102
      Height = 25
      NumbersOnly = True
      TabOrder = 0
    end
    object BtnCheckPort: TBitBtn
      Left = 288
      Top = 6
      Width = 42
      Height = 25
      Caption = #26816#27979
      TabOrder = 1
      OnClick = BtnCheckPortClick
    end
    object EdtSize: TEdit
      Left = 163
      Top = 116
      Width = 42
      Height = 25
      NumbersOnly = True
      ParentShowHint = False
      ShowHint = False
      TabOrder = 11
      Text = '10'
      OnExit = EdtSizeExit
    end
    object ckHTTPS: TCheckBox
      Left = 15
      Top = 162
      Width = 65
      Height = 17
      Caption = 'HTTPS'
      Enabled = False
      TabOrder = 15
      OnClick = ckHTTPSClick
    end
    object ckSQL: TCheckBox
      Left = 111
      Top = 71
      Width = 94
      Height = 17
      Caption = 'SQL'#26085#24535
      TabOrder = 7
    end
    object EdtReBootT: TEdit
      Left = 140
      Top = 46
      Width = 141
      Height = 25
      NumbersOnly = True
      ParentShowHint = False
      ShowHint = False
      TabOrder = 4
      TextHint = #37325#21551#38388#38548#26102#38388'('#22825')'
      Visible = False
      OnExit = EdtReBootTExit
    end
    object ckEMR: TCheckBox
      Left = 211
      Top = 120
      Width = 81
      Height = 17
      Caption = 'EMR'#25991#20214
      TabOrder = 12
    end
    object ckSYSLOG: TCheckBox
      Left = 15
      Top = 91
      Width = 162
      Height = 20
      Caption = #36828#31243'syslog'#26381#21153#22120
      TabOrder = 10
      OnClick = ckSYSLOGClick
    end
    object EdtIP: TEdit
      Left = 182
      Top = 90
      Width = 148
      Height = 25
      ImeMode = imClose
      ParentShowHint = False
      ShowHint = False
      TabOrder = 9
      TextHint = #36828#31243#26085#24535#26381#21153#22120'IP'
      Visible = False
    end
    object chkSocket: TCheckBox
      Left = 94
      Top = 163
      Width = 127
      Height = 17
      Caption = 'WEBSOCKET'
      Enabled = False
      TabOrder = 16
    end
    object ckErr: TCheckBox
      Left = 211
      Top = 71
      Width = 97
      Height = 17
      Caption = #38169#35823#26085#24535
      Checked = True
      State = cbChecked
      TabOrder = 8
    end
    object ckAES: TCheckBox
      Left = 244
      Top = 190
      Width = 86
      Height = 17
      Caption = #21152#23494#20256#36755
      TabOrder = 18
      Visible = False
      OnClick = ckAESClick
    end
    object edtWZUrl: TEdit
      Left = 81
      Top = 214
      Width = 249
      Height = 25
      TabOrder = 19
    end
    object cbbip: TComboBox
      Left = 111
      Top = 242
      Width = 181
      Height = 25
      Style = csDropDownList
      ImeMode = imClose
      TabOrder = 20
    end
    object ckCache: TCheckBox
      Left = 244
      Top = 163
      Width = 86
      Height = 17
      Caption = #20351#29992#32531#23384
      TabOrder = 21
      Visible = False
      OnClick = ckCacheClick
    end
    object se1: TSpinEdit
      Left = 140
      Top = 270
      Width = 81
      Height = 27
      MaxValue = 0
      MinValue = 0
      TabOrder = 22
      Value = 10
    end
  end
end
