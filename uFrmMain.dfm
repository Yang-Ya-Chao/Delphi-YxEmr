object MainForm: TMainForm
  Left = 207
  Top = 87
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'YxEmr'#24212#29992#26381#21153#22120
  ClientHeight = 111
  ClientWidth = 294
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  GlassFrame.Enabled = True
  GlassFrame.SheetOfGlass = True
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  TextHeight = 13
  object lbl1: TLabel
    Left = 2
    Top = 40
    Width = 39
    Height = 13
    Hint = #21344#29992'CPU'#65307#21344#29992#20869#23384#65307#32447#31243#25968
    Caption = #29366#24577#65306
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
  end
  object lbl2: TLabel
    Left = 47
    Top = 39
    Width = 3
    Height = 13
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lbl3: TLabel
    Left = 47
    Top = 58
    Width = 3
    Height = 13
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lbl4: TLabel
    Left = 2
    Top = 58
    Width = 39
    Height = 13
    Hint = #24037#20316#22312#29992#32447#31243#25968'/'#24037#20316#24635#32447#31243#25968#65307#36816#34892#26102#38388
    Caption = #36816#34892#65306
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
  end
  object lbl5: TLabel
    Left = 2
    Top = 76
    Width = 39
    Height = 13
    Hint = 'All:'#35831#27714#24635#25968#65307'Err:'#35831#27714#22833#36133#25968
    Caption = #35831#27714#65306
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
  end
  object lbl6: TLabel
    Left = 47
    Top = 75
    Width = 3
    Height = 13
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lbl7: TLabel
    Left = 2
    Top = 93
    Width = 39
    Height = 13
    Hint = #25509#21475#35775#38382#22320#22336
    Caption = #22320#22336#65306
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
  end
  object lbl8: TLabel
    Left = 47
    Top = 93
    Width = 3
    Height = 13
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
    OnClick = lbl8Click
    OnMouseEnter = lbl8MouseEnter
    OnMouseLeave = lbl8MouseLeave
  end
  object btnStart: TBitBtn
    Left = 57
    Top = 5
    Width = 75
    Height = 25
    Caption = #24320#22987#26381#21153
    TabOrder = 0
    TabStop = False
    OnClick = btnStartClick
  end
  object btnStop: TBitBtn
    Left = 166
    Top = 5
    Width = 75
    Height = 25
    Caption = #20572#27490#26381#21153
    Enabled = False
    TabOrder = 1
    TabStop = False
    OnClick = btnStopClick
  end
  object pm1: TPopupMenu
    Left = 193
    Top = 40
    object N1: TMenuItem
      Caption = #24320#22987#26381#21153
      OnClick = N1Click
    end
    object N2: TMenuItem
      Caption = #20572#27490#26381#21153
      OnClick = N2Click
    end
    object N3: TMenuItem
      Caption = #36824#21407
      GroupIndex = 1
      OnClick = N3Click
    end
    object N4: TMenuItem
      Caption = #36864#20986
      GroupIndex = 1
      OnClick = N4Click
    end
  end
  object pm2: TPopupMenu
    Left = 224
    Top = 40
    object NA: TMenuItem
      AutoCheck = True
      Caption = #40657#33394
      Checked = True
      GroupIndex = 1
      RadioItem = True
    end
    object NB: TMenuItem
      AutoCheck = True
      Caption = #30333#33394
      GroupIndex = 1
      RadioItem = True
    end
    object NC: TMenuItem
      AutoCheck = True
      Caption = #28784#33394
      GroupIndex = 1
      RadioItem = True
    end
    object ND: TMenuItem
      AutoCheck = True
      Caption = #28145#33394
      GroupIndex = 1
      RadioItem = True
    end
  end
end
