object FrmMQClient: TFrmMQClient
  Left = 0
  Top = 0
  Caption = 'MQTT Client '
  ClientHeight = 527
  ClientWidth = 918
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -17
  Font.Name = #23435#20307
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 17
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 918
    Height = 137
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alTop
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 0
    OnClick = Panel1Click
    object Label6: TLabel
      Left = 11
      Top = 77
      Width = 86
      Height = 17
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #23458#25143#31471'ID'#65306
    end
    object leServerHost: TLabeledEdit
      Left = 110
      Top = 11
      Width = 227
      Height = 25
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      EditLabel.Width = 94
      EditLabel.Height = 17
      EditLabel.Caption = #26381#21153#22120#22320#22336':'
      LabelPosition = lpLeft
      TabOrder = 0
      Text = '127.0.0.1'
    end
    object leServerPort: TLabeledEdit
      Left = 415
      Top = 11
      Width = 74
      Height = 25
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      EditLabel.Width = 60
      EditLabel.Height = 17
      EditLabel.Caption = #31471#21475#21495':'
      LabelPosition = lpLeft
      TabOrder = 1
      Text = '8883'
    end
    object leUserName: TLabeledEdit
      Left = 74
      Top = 41
      Width = 177
      Height = 25
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      EditLabel.Width = 60
      EditLabel.Height = 17
      EditLabel.Caption = #29992#25143#21517':'
      LabelPosition = lpLeft
      TabOrder = 2
      Text = 'admin'
    end
    object lePassword: TLabeledEdit
      Left = 312
      Top = 42
      Width = 178
      Height = 25
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      EditLabel.Width = 43
      EditLabel.Height = 17
      EditLabel.Caption = #23494#30721':'
      LabelPosition = lpLeft
      PasswordChar = '*'
      TabOrder = 3
      Text = '123456'
    end
    object Button1: TButton
      AlignWithMargins = True
      Left = 753
      Top = 6
      Width = 163
      Height = 125
      Margins.Left = 2
      Margins.Top = 6
      Margins.Right = 2
      Margins.Bottom = 6
      Align = alRight
      Caption = #36830#25509#27979#35797
      TabOrder = 4
      OnClick = Button1Click
    end
    object chkAutoSend: TCheckBox
      Left = 87
      Top = 103
      Width = 138
      Height = 22
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #33258#21160#21457#36865#27979#35797
      TabOrder = 5
      OnClick = chkAutoSendClick
    end
    object chkAutoClearLog: TCheckBox
      Left = 229
      Top = 103
      Width = 219
      Height = 22
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #27599#38548'15'#31186#28165#31354#19968#27425#26085#24535
      TabOrder = 6
    end
    object edtClientId: TEdit
      Left = 103
      Top = 74
      Width = 225
      Height = 25
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      TabOrder = 7
      Text = 'YxCisSvr'
    end
    object chkSSL: TCheckBox
      Left = 11
      Top = 103
      Width = 51
      Height = 22
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'SSL'
      TabOrder = 8
      OnClick = chkSSLClick
    end
    object cbxVersion: TComboBox
      Left = 358
      Top = 71
      Width = 59
      Height = 25
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 9
      Text = '3.1.1'
      Items.Strings = (
        '3.1.1'
        '5.0')
    end
    object btnSAVE: TButton
      Left = 432
      Top = 101
      Width = 129
      Height = 25
      Caption = #20445#23384#24403#21069#37197#32622
      TabOrder = 10
      OnClick = btnSAVEClick
    end
    object ckBMQ: TCheckBox
      Left = 432
      Top = 72
      Width = 97
      Height = 17
      Caption = #26159#21542#21551#29992
      TabOrder = 11
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 137
    Width = 918
    Height = 372
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 392
      Top = 0
      Width = 2
      Height = 372
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      ExplicitHeight = 338
    end
    object Panel3: TPanel
      Left = 0
      Top = 0
      Width = 392
      Height = 372
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alLeft
      BevelOuter = bvLowered
      ShowCaption = False
      TabOrder = 0
      object Panel5: TPanel
        Left = 1
        Top = 1
        Width = 390
        Height = 80
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Align = alTop
        TabOrder = 0
        object Panel9: TPanel
          Left = 1
          Top = 35
          Width = 388
          Height = 44
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 0
          object Label5: TLabel
            Left = 6
            Top = 12
            Width = 70
            Height = 17
            Margins.Left = 2
            Margins.Top = 2
            Margins.Right = 2
            Margins.Bottom = 2
            Caption = 'QoS'#32423#21035':'
          end
          object cbxRecvQoSLevel: TComboBox
            Left = 85
            Top = 5
            Width = 108
            Height = 26
            Margins.Left = 2
            Margins.Top = 2
            Margins.Right = 2
            Margins.Bottom = 2
            Style = csOwnerDrawFixed
            ItemHeight = 20
            ItemIndex = 0
            TabOrder = 0
            Text = #26368#22810#19968#27425
            Items.Strings = (
              #26368#22810#19968#27425
              #33267#23569#19968#27425
              #21482#21457#19968#27425)
          end
          object btnUnsubscribe: TButton
            AlignWithMargins = True
            Left = 288
            Top = 4
            Width = 86
            Height = 32
            Margins.Left = 2
            Margins.Top = 2
            Margins.Right = 2
            Margins.Bottom = 2
            Caption = #21462#28040#35746#38405
            TabOrder = 1
            OnClick = btnUnsubscribeClick
          end
          object btnSubscribe: TButton
            AlignWithMargins = True
            Left = 207
            Top = 4
            Width = 60
            Height = 32
            Margins.Left = 2
            Margins.Top = 2
            Margins.Right = 2
            Margins.Bottom = 2
            Caption = #35746#38405
            TabOrder = 2
            OnClick = btnSubscribeClick
          end
        end
        object Panel10: TPanel
          Left = 1
          Top = 1
          Width = 388
          Height = 34
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alTop
          BevelOuter = bvNone
          Caption = 'Panel10'
          TabOrder = 1
          object Label1: TLabel
            AlignWithMargins = True
            Left = 2
            Top = 2
            Width = 77
            Height = 30
            Margins.Left = 2
            Margins.Top = 2
            Margins.Right = 2
            Margins.Bottom = 2
            Align = alLeft
            Caption = #25509#25910#20027#39064':'
            Layout = tlCenter
            ExplicitHeight = 17
          end
          object edtSubscribeTopic: TEdit
            AlignWithMargins = True
            Left = 83
            Top = 2
            Width = 303
            Height = 30
            Margins.Left = 2
            Margins.Top = 2
            Margins.Right = 2
            Margins.Bottom = 2
            Align = alClient
            TabOrder = 0
            Text = 'YxCisSvr'
            ExplicitHeight = 25
          end
        end
      end
      object Memo1: TMemo
        Left = 1
        Top = 81
        Width = 390
        Height = 290
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Align = alClient
        TabOrder = 1
      end
    end
    object Panel4: TPanel
      Left = 394
      Top = 0
      Width = 524
      Height = 372
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Align = alClient
      BevelOuter = bvLowered
      ShowCaption = False
      TabOrder = 1
      object Panel6: TPanel
        Left = 1
        Top = 1
        Width = 522
        Height = 35
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Align = alTop
        TabOrder = 0
        object Label2: TLabel
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 77
          Height = 29
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alLeft
          Caption = #21457#24067#20027#39064':'
          Layout = tlCenter
          ExplicitHeight = 17
        end
        object edtPublishTopic: TEdit
          AlignWithMargins = True
          Left = 84
          Top = 3
          Width = 226
          Height = 29
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          TabOrder = 0
          Text = 'YxCisSvrRet'
          ExplicitHeight = 25
        end
        object Panel8: TPanel
          Left = 312
          Top = 1
          Width = 209
          Height = 33
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alRight
          BevelOuter = bvNone
          ShowCaption = False
          TabOrder = 1
          object Label4: TLabel
            Left = 6
            Top = 6
            Width = 70
            Height = 17
            Margins.Left = 2
            Margins.Top = 2
            Margins.Right = 2
            Margins.Bottom = 2
            Caption = 'QoS'#32423#21035':'
          end
          object cbxQoSLevel: TComboBox
            Left = 86
            Top = 2
            Width = 99
            Height = 26
            Margins.Left = 2
            Margins.Top = 2
            Margins.Right = 2
            Margins.Bottom = 2
            Style = csOwnerDrawFixed
            ItemHeight = 20
            ItemIndex = 0
            TabOrder = 0
            Text = #26368#22810#19968#27425
            Items.Strings = (
              #26368#22810#19968#27425
              #33267#23569#19968#27425
              #21482#21457#19968#27425)
          end
        end
      end
      object Panel7: TPanel
        Left = 1
        Top = 328
        Width = 522
        Height = 43
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Align = alBottom
        TabOrder = 1
        object Label3: TLabel
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 77
          Height = 37
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alLeft
          Caption = #21457#24067#20869#23481':'
          Layout = tlCenter
          ExplicitHeight = 17
        end
        object btnPublish: TButton
          AlignWithMargins = True
          Left = 459
          Top = 3
          Width = 60
          Height = 37
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alRight
          Caption = #21457#24067
          TabOrder = 0
          OnClick = btnPublishClick
        end
        object edtMessage: TEdit
          AlignWithMargins = True
          Left = 84
          Top = 3
          Width = 371
          Height = 37
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 2
          Margins.Bottom = 2
          Align = alClient
          TabOrder = 1
          Text = 'Hello,world'
          ExplicitHeight = 25
        end
      end
      object Memo2: TMemo
        Left = 1
        Top = 36
        Width = 522
        Height = 292
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Align = alClient
        TabOrder = 2
      end
    end
  end
  object pnlStatus: TPanel
    Left = 0
    Top = 509
    Width = 918
    Height = 18
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alBottom
    Alignment = taLeftJustify
    BevelOuter = bvLowered
    TabOrder = 2
  end
  object tmSend: TTimer
    Enabled = False
    Interval = 20
    OnTimer = tmSendTimer
    Left = 592
    Top = 304
  end
  object tmStatics: TTimer
    OnTimer = tmStaticsTimer
    Left = 680
    Top = 304
  end
end
