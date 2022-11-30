object FrmRegist: TFrmRegist
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #27880#20876#30721#35831#32852#31995'QQ******'#33719#21462
  ClientHeight = 90
  ClientWidth = 416
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -17
  Font.Name = #23435#20307
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 17
  object lbl1: TLabel
    Left = 36
    Top = 13
    Width = 68
    Height = 17
    Caption = #26426#22120#30721#65306
  end
  object lbl2: TLabel
    Left = 36
    Top = 56
    Width = 68
    Height = 17
    Caption = #27880#20876#30721#65306
  end
  object EdtRegist: TEdit
    Left = 100
    Top = 54
    Width = 189
    Height = 25
    TabOrder = 0
  end
  object EdtCode: TEdit
    Left = 100
    Top = 10
    Width = 189
    Height = 25
    ReadOnly = True
    TabOrder = 1
  end
  object BtnGet: TBitBtn
    Left = 304
    Top = 10
    Width = 75
    Height = 25
    Caption = #22797#21046
    TabOrder = 2
    OnClick = BtnGetClick
  end
  object BtnSET: TBitBtn
    Left = 304
    Top = 54
    Width = 75
    Height = 25
    Caption = #27880#20876
    TabOrder = 3
    OnClick = BtnSETClick
  end
end
