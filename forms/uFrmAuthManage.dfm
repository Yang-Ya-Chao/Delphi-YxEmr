object FrmAuthManage: TFrmAuthManage
  Left = 0
  Top = 0
  Caption = #26435#38480#31649#29702
  ClientHeight = 575
  ClientWidth = 634
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object spl1: TSplitter
    Left = 0
    Top = 417
    Width = 634
    Height = 3
    Cursor = crVSplit
    Align = alTop
    AutoSnap = False
    ExplicitTop = 337
    ExplicitWidth = 194
  end
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 634
    Height = 417
    Align = alTop
    TabOrder = 0
    object grp1: TGroupBox
      Left = 1
      Top = 51
      Width = 632
      Height = 365
      Align = alClient
      Caption = #21151#33021#21015#34920
      TabOrder = 0
    end
    object pnl4: TPanel
      Left = 1
      Top = 1
      Width = 632
      Height = 50
      Align = alTop
      TabOrder = 1
      object lblUser: TLabel
        Left = 216
        Top = 24
        Width = 26
        Height = 15
        Caption = #29992#25143
      end
      object lblUser1: TLabel
        Left = 401
        Top = 24
        Width = 73
        Height = 15
        Caption = #26377#25928#26399'('#20998#38047')'
      end
      object GB1: TRadioGroup
        Left = 5
        Top = 1
        Width = 192
        Height = 44
        Caption = #31579#36873
        Columns = 3
        Items.Strings = (
          #20840#36873
          #21453#36873
          #20840#19981#36873)
        TabOrder = 0
        OnClick = GB1Click
      end
      object edtUser: TEdit
        Left = 258
        Top = 21
        Width = 137
        Height = 23
        TabOrder = 1
      end
      object edtTime: TEdit
        Left = 484
        Top = 21
        Width = 137
        Height = 23
        ImeMode = imClose
        NumbersOnly = True
        TabOrder = 2
      end
    end
  end
  object pnl3: TPanel
    Left = 0
    Top = 531
    Width = 634
    Height = 44
    Align = alBottom
    TabOrder = 1
    object btnAdd: TBitBtn
      Left = 16
      Top = 6
      Width = 75
      Height = 25
      Caption = #26032#22686
      TabOrder = 0
      OnClick = btnAddClick
    end
    object btnMof: TBitBtn
      Left = 123
      Top = 6
      Width = 75
      Height = 25
      Caption = #20462#25913
      TabOrder = 1
      OnClick = btnMofClick
    end
    object btnDel: TBitBtn
      Left = 230
      Top = 6
      Width = 75
      Height = 25
      Caption = #21024#38500
      TabOrder = 2
      OnClick = btnDelClick
    end
    object btnSave: TBitBtn
      Left = 443
      Top = 6
      Width = 75
      Height = 25
      Caption = #20445#23384
      TabOrder = 3
      OnClick = btnSaveClick
    end
    object btnCanl: TBitBtn
      Left = 336
      Top = 6
      Width = 75
      Height = 25
      Caption = #21462#28040
      TabOrder = 4
      OnClick = btnCanlClick
    end
    object btnrefresh: TButton
      Left = 550
      Top = 6
      Width = 75
      Height = 25
      Caption = #21047#26032
      TabOrder = 5
      OnClick = btnrefreshClick
    end
  end
  object pnl2: TPanel
    Left = 0
    Top = 420
    Width = 634
    Height = 111
    Align = alClient
    TabOrder = 2
    object Grid1: TDBGrid
      Left = 1
      Top = 1
      Width = 632
      Height = 109
      Align = alClient
      DataSource = ds1
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      PopupMenu = pm1
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -12
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      OnKeyDown = Grid1KeyDown
      Columns = <
        item
          Alignment = taCenter
          Expanded = False
          FieldName = 'IID'
          Title.Alignment = taCenter
          Title.Caption = #25480#26435#30721
          Width = 300
          Visible = True
        end
        item
          Alignment = taCenter
          Expanded = False
          FieldName = 'UserName'
          Title.Alignment = taCenter
          Title.Caption = #29992#25143
          Width = 200
          Visible = True
        end
        item
          Alignment = taCenter
          Expanded = False
          FieldName = 'TimeOut'
          Title.Alignment = taCenter
          Title.Caption = #26377#25928#26399'('#20998#38047')'
          Width = 100
          Visible = True
        end>
    end
  end
  object ds1: TDataSource
    Left = 328
    Top = 329
  end
  object pm1: TPopupMenu
    Left = 448
    Top = 321
    object N1: TMenuItem
      Caption = #33719#21462#25480#26435#30721
      OnClick = N1Click
    end
    object oken1: TMenuItem
      Caption = #33719#21462#27704#20037#25480#26435#20196#29260
      OnClick = oken1Click
    end
  end
end
