object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Hint = #26102#38480'('#26376')'
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #27880#20876#26426'V2.0'
  ClientHeight = 89
  ClientWidth = 478
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -17
  Font.Name = #23435#20307
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poScreenCenter
  TextHeight = 17
  object lbl2: TLabel
    Left = 12
    Top = 56
    Width = 68
    Height = 17
    Caption = #27880#20876#30721#65306
  end
  object lbl1: TLabel
    Left = 12
    Top = 13
    Width = 68
    Height = 17
    Caption = #26426#22120#30721#65306
  end
  object EdtCode: TEdit
    Left = 76
    Top = 10
    Width = 189
    Height = 25
    TabOrder = 0
  end
  object EdtRegist: TEdit
    Left = 76
    Top = 54
    Width = 189
    Height = 25
    ReadOnly = True
    TabOrder = 1
  end
  object BtnSET: TBitBtn
    Left = 395
    Top = 10
    Width = 75
    Height = 25
    Caption = #27880#20876
    TabOrder = 2
    OnClick = BtnSETClick
  end
  object BtnGet: TBitBtn
    Left = 395
    Top = 54
    Width = 75
    Height = 25
    Caption = #22797#21046
    TabOrder = 3
    OnClick = BtnGetClick
  end
  object EdtDATA: TEdit
    Left = 271
    Top = 10
    Width = 50
    Height = 25
    NumbersOnly = True
    ParentShowHint = False
    ShowHint = False
    TabOrder = 4
  end
  object cbb1: TComboBox
    Left = 327
    Top = 10
    Width = 42
    Height = 25
    ItemIndex = 2
    TabOrder = 5
    Text = #24180
    Items.Strings = (
      #22825
      #26376
      #24180)
  end
end
