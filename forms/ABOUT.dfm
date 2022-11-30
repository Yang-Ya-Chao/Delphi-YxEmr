object AboutBox: TAboutBox
  Left = 200
  Top = 108
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #20851#20110
  ClientHeight = 165
  ClientWidth = 275
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -17
  Font.Name = #23435#20307
  Font.Style = []
  GlassFrame.Enabled = True
  GlassFrame.SheetOfGlass = True
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 17
  object lbl1: TLabel
    Left = 20
    Top = 94
    Width = 234
    Height = 17
    Caption = 'Provider:2405414352@qq.com'
    IsControl = True
  end
  object lblProductName: TLabel
    Left = 56
    Top = 15
    Width = 197
    Height = 17
    Caption = #21307#26143'HIS'#30005#23376#30149#21382#26631#20934#25509#21475
    IsControl = True
  end
  object lblVersion: TLabel
    Left = 108
    Top = 38
    Width = 36
    Height = 17
    Caption = 'V3.1'
    IsControl = True
  end
  object lblCopyright: TLabel
    Left = 20
    Top = 68
    Width = 225
    Height = 17
    Caption = 'Copyright '#169' 2021 YYC_CDYX'
    IsControl = True
  end
  object img1: TImage
    Left = 1
    Top = 1
    Width = 55
    Height = 54
  end
  object OKButton: TButton
    Left = 95
    Top = 129
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
end
