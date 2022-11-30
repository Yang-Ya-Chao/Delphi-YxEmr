object FrmMonitor: TFrmMonitor
  Left = 0
  Top = 0
  Caption = #26381#21153#30417#25511
  ClientHeight = 514
  ClientWidth = 598
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 598
    Height = 73
    Align = alTop
    TabOrder = 0
    object lbl1: TLabel
      Left = 5
      Top = 36
      Width = 52
      Height = 15
      Caption = #26174#31034#34892#25968
    end
    object se1: TSpinEdit
      Left = 61
      Top = 31
      Width = 87
      Height = 24
      MaxValue = 0
      MinValue = 0
      TabOrder = 0
      Value = 100
      OnChange = se1Change
    end
    object btnClear: TBitBtn
      Left = 154
      Top = 31
      Width = 75
      Height = 25
      Caption = #28165#31354
      TabOrder = 1
      OnClick = btnClearClick
    end
    object ck1: TCheckBox
      Left = 5
      Top = 8
      Width = 97
      Height = 17
      Caption = #24320#21551#36319#36394
      TabOrder = 2
      OnClick = ck1Click
    end
  end
  object pnl2: TPanel
    Left = 0
    Top = 73
    Width = 598
    Height = 441
    Align = alClient
    TabOrder = 1
    object pgc1: TPageControl
      Left = 1
      Top = 1
      Width = 596
      Height = 439
      ActivePage = ts1
      Align = alClient
      TabOrder = 0
      object ts1: TTabSheet
        Caption = #35831#27714#28040#24687
        object mmo1: TMemo
          Left = 0
          Top = 0
          Width = 588
          Height = 409
          Align = alClient
          TabOrder = 0
        end
      end
      object ts2: TTabSheet
        Caption = #38169#35823#28040#24687
        ImageIndex = 1
        object mmo2: TMemo
          Left = 0
          Top = 0
          Width = 588
          Height = 409
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 144
          ExplicitTop = 96
          ExplicitWidth = 185
          ExplicitHeight = 89
        end
      end
      object ts3: TTabSheet
        Caption = 'SQL'#35821#21477
        ImageIndex = 2
        object mmo3: TMemo
          Left = 0
          Top = 0
          Width = 588
          Height = 409
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 144
          ExplicitTop = 96
          ExplicitWidth = 185
          ExplicitHeight = 89
        end
      end
      object ts4: TTabSheet
        Caption = #23545#35937#27744
        ImageIndex = 3
        object mmo4: TMemo
          Left = 0
          Top = 0
          Width = 588
          Height = 409
          Align = alClient
          TabOrder = 0
        end
      end
    end
  end
end
