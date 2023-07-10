object FrmConfig: TFrmConfig
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #25509#21475#37197#32622
  ClientHeight = 658
  ClientWidth = 682
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -17
  Font.Name = #23435#20307
  Font.Style = []
  FormStyle = fsStayOnTop
  Position = poScreenCenter
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object pnl2: TPanel
    Left = 0
    Top = 513
    Width = 682
    Height = 145
    Align = alClient
    TabOrder = 0
    ExplicitTop = 400
    ExplicitWidth = 592
    ExplicitHeight = 109
    object BtnCancel: TBitBtn
      Left = 294
      Top = 23
      Width = 75
      Height = 25
      Caption = #25918#24323
      ParentDoubleBuffered = True
      TabOrder = 2
      OnClick = BtnCancelClick
    end
    object BtnSave: TBitBtn
      Left = 383
      Top = 23
      Width = 75
      Height = 25
      Caption = #23384#30424
      ParentDoubleBuffered = True
      TabOrder = 1
      OnClick = BtnSaveClick
    end
    object BtnMod: TBitBtn
      Left = 203
      Top = 23
      Width = 75
      Height = 25
      Caption = #20462#25913
      ParentDoubleBuffered = True
      TabOrder = 0
      OnClick = BtnModClick
    end
    object btnrefresh: TButton
      Left = 383
      Top = 70
      Width = 75
      Height = 25
      Caption = #21047#26032
      TabOrder = 3
      OnClick = btnrefreshClick
    end
    object btnDel: TBitBtn
      Left = 294
      Top = 70
      Width = 75
      Height = 25
      Caption = #21024#38500
      TabOrder = 4
      OnClick = btnDelClick
    end
    object btnAdd: TBitBtn
      Left = 203
      Top = 70
      Width = 75
      Height = 25
      Caption = #26032#22686
      TabOrder = 5
      OnClick = btnAddClick
    end
    object btnCSLJ: TBitBtn
      Left = 479
      Top = 70
      Width = 75
      Height = 25
      Caption = #27979#35797#38142#25509
      ParentDoubleBuffered = True
      TabOrder = 6
      OnClick = btnCSLJClick
    end
  end
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 682
    Height = 513
    Align = alTop
    TabOrder = 1
    ExplicitWidth = 731
    object pgc1: TPageControl
      Left = 1
      Top = 1
      Width = 680
      Height = 511
      ActivePage = ts3
      Align = alClient
      TabOrder = 0
      OnChange = pgc1Change
      ExplicitWidth = 729
      object ts1: TTabSheet
        Caption = #22522#26412#37197#32622
        object pnl3: TPanel
          Left = 0
          Top = 0
          Width = 672
          Height = 478
          Align = alClient
          DoubleBuffered = True
          ParentDoubleBuffered = False
          TabOrder = 0
          ExplicitTop = -1
          ExplicitWidth = 721
          object lbl1: TLabel
            Left = 15
            Top = 216
            Width = 102
            Height = 17
            Caption = #24037#20316#32447#31243#24635#25968
          end
          object lbl2: TLabel
            Left = 15
            Top = 125
            Width = 34
            Height = 17
            Caption = #31471#21475
          end
          object lbl3: TLabel
            Left = 15
            Top = 187
            Width = 145
            Height = 17
            Caption = #26085#24535#20998#39029#22823#23567#65288'M'#65289
          end
          object lbl5: TLabel
            Left = 15
            Top = 245
            Width = 69
            Height = 17
            Caption = #26381#21153#22120'IP'
          end
          object edtWorkcount: TEdit
            Left = 132
            Top = 211
            Width = 93
            Height = 25
            NumbersOnly = True
            ParentShowHint = False
            ShowHint = False
            TabOrder = 13
            OnExit = edtWorkcountExit
          end
          object ckMsg: TCheckBox
            Left = 15
            Top = 96
            Width = 90
            Height = 17
            Caption = #35814#32454#26085#24535
            TabOrder = 6
          end
          object ckReBoot: TCheckBox
            Left = 15
            Top = 67
            Width = 126
            Height = 17
            Caption = #25509#21475#23450#26102#37325#21551
            TabOrder = 5
            OnClick = ckReBootClick
          end
          object ckAutoRun: TCheckBox
            Left = 15
            Top = 37
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
          object edtPort: TEdit
            Left = 55
            Top = 123
            Width = 102
            Height = 25
            NumbersOnly = True
            TabOrder = 0
          end
          object btnBtnCheckPort: TBitBtn
            Left = 163
            Top = 123
            Width = 42
            Height = 25
            Caption = #26816#27979
            TabOrder = 1
            OnClick = btnBtnCheckPortClick
          end
          object edtSize: TEdit
            Left = 166
            Top = 183
            Width = 42
            Height = 25
            NumbersOnly = True
            ParentShowHint = False
            ShowHint = False
            TabOrder = 11
            Text = '10'
            OnExit = edtSizeExit
          end
          object ckSQL: TCheckBox
            Left = 120
            Top = 96
            Width = 94
            Height = 17
            Caption = 'SQL'#26085#24535
            TabOrder = 7
          end
          object edtReBootT: TEdit
            Left = 147
            Top = 65
            Width = 141
            Height = 25
            NumbersOnly = True
            ParentShowHint = False
            ShowHint = False
            TabOrder = 4
            TextHint = #37325#21551#38388#38548#26102#38388'('#22825')'
            Visible = False
            OnExit = edtReBootTExit
          end
          object ckEMR: TCheckBox
            Left = 323
            Top = 96
            Width = 81
            Height = 17
            Caption = 'EMR'#25991#20214
            TabOrder = 12
            Visible = False
          end
          object ckSYSLOG: TCheckBox
            Left = 15
            Top = 154
            Width = 162
            Height = 20
            Caption = #36828#31243'syslog'#26381#21153#22120
            TabOrder = 10
            OnClick = ckSYSLOGClick
          end
          object edtIP: TEdit
            Left = 199
            Top = 152
            Width = 148
            Height = 25
            ImeMode = imClose
            ParentShowHint = False
            ShowHint = False
            TabOrder = 9
            TextHint = #36828#31243#26085#24535#26381#21153#22120'IP'
            Visible = False
          end
          object ckErr: TCheckBox
            Left = 220
            Top = 96
            Width = 97
            Height = 17
            Caption = #38169#35823#26085#24535
            Checked = True
            State = cbChecked
            TabOrder = 8
          end
          object ckAES: TCheckBox
            Left = 513
            Top = 96
            Width = 86
            Height = 17
            Caption = #21152#23494#20256#36755
            TabOrder = 14
            Visible = False
            OnClick = ckAESClick
          end
          object cbbip: TComboBox
            Left = 107
            Top = 242
            Width = 181
            Height = 25
            Style = csDropDownList
            ImeMode = imClose
            TabOrder = 15
          end
          object ckCache: TCheckBox
            Left = 421
            Top = 96
            Width = 86
            Height = 17
            Caption = #20351#29992#32531#23384
            TabOrder = 16
            Visible = False
            OnClick = ckCacheClick
          end
        end
      end
      object ts4: TTabSheet
        Caption = #25968#25454#24211#37197#32622
        ImageIndex = 3
        object pnl7: TPanel
          Left = 0
          Top = 0
          Width = 672
          Height = 478
          Align = alClient
          TabOrder = 0
          ExplicitLeft = 80
          ExplicitTop = 248
          ExplicitWidth = 577
          ExplicitHeight = 177
          object lbl4: TLabel
            Left = 176
            Top = 72
            Width = 69
            Height = 17
            Caption = #26381' '#21153' '#22120
          end
          object lbl6: TLabel
            Left = 176
            Top = 115
            Width = 69
            Height = 17
            Caption = #25968' '#25454' '#24211
          end
          object lbl7: TLabel
            Left = 176
            Top = 153
            Width = 69
            Height = 17
            Caption = #29992' '#25143' '#21517
          end
          object lbl8: TLabel
            Left = 176
            Top = 192
            Width = 70
            Height = 17
            Caption = #23494'    '#30721
          end
          object edtServer: TEdit
            Left = 296
            Top = 69
            Width = 177
            Height = 25
            Hint = #25968#25454#24211#30340#26381#21153#22120#22320#22336
            ImeMode = imClose
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
          end
          object edtDBName: TEdit
            Left = 296
            Top = 111
            Width = 177
            Height = 25
            Hint = #40664#35748#30331#24405#36830#25509#30340#25968#25454#24211#21517#31216'(YXHIS)'
            ImeMode = imClose
            ParentShowHint = False
            ShowHint = True
            TabOrder = 1
            Text = 'YXHIS'
          end
          object edtUserName: TEdit
            Left = 296
            Top = 148
            Width = 177
            Height = 25
            Hint = #25968#25454#24211#30331#24405#21517
            ImeMode = imClose
            ParentShowHint = False
            ShowHint = True
            TabOrder = 2
            Text = 'sa'
          end
          object edtPass: TEdit
            Left = 296
            Top = 186
            Width = 177
            Height = 25
            Hint = #25968#25454#24211#23494#30721
            ParentShowHint = False
            PasswordChar = '*'
            ShowHint = True
            TabOrder = 3
            Text = '123qwe,.'
          end
          object ck1: TCheckBox
            Left = 479
            Top = 191
            Width = 13
            Height = 13
            Hint = #26174#31034#23494#30721
            ParentShowHint = False
            ShowHint = True
            TabOrder = 4
            OnClick = ck1Click
          end
        end
      end
      object ts2: TTabSheet
        Caption = #38468#21152#25509#21475
        ImageIndex = 1
        object Grid2: TDBGrid
          Left = 0
          Top = 0
          Width = 672
          Height = 478
          Align = alClient
          DataSource = ds1
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
          PopupMenu = pm1
          TabOrder = 0
          TitleFont.Charset = ANSI_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -17
          TitleFont.Name = #23435#20307
          TitleFont.Style = []
          Columns = <
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'name'
              Title.Alignment = taCenter
              Title.Caption = #25509#21475
              Width = 200
              Visible = True
            end
            item
              Alignment = taCenter
              Expanded = False
              FieldName = 'url'
              Title.Alignment = taCenter
              Title.Caption = #22320#22336
              Width = 100
              Visible = True
            end>
        end
      end
      object ts3: TTabSheet
        Caption = #26435#38480#37197#32622
        ImageIndex = 2
        object pnl4: TPanel
          Left = 0
          Top = 0
          Width = 672
          Height = 337
          Align = alTop
          TabOrder = 0
          ExplicitTop = 8
          ExplicitWidth = 582
          object grp1: TGroupBox
            Left = 1
            Top = 49
            Width = 670
            Height = 287
            Align = alClient
            Caption = #21151#33021#21015#34920
            TabOrder = 0
            ExplicitLeft = 2
            ExplicitTop = 42
            ExplicitWidth = 719
            ExplicitHeight = 294
          end
          object pnl6: TPanel
            Left = 1
            Top = 1
            Width = 670
            Height = 48
            Align = alTop
            TabOrder = 1
            ExplicitTop = -5
            ExplicitWidth = 719
            object lblUser: TLabel
              Left = 229
              Top = 15
              Width = 34
              Height = 17
              Caption = #29992#25143
            end
            object lblUser1: TLabel
              Left = 412
              Top = 15
              Width = 103
              Height = 17
              Caption = #26377#25928#26399'('#20998#38047')'
            end
            object GB1: TRadioGroup
              Left = 1
              Top = 0
              Width = 220
              Height = 44
              Caption = #31579#36873
              Columns = 3
              Items.Strings = (
                #20840#36873
                #21453#36873
                #20840#19981#36873)
              TabOrder = 0
            end
            object edtTime: TEdit
              Left = 519
              Top = 10
              Width = 137
              Height = 25
              ImeMode = imClose
              NumbersOnly = True
              TabOrder = 1
            end
            object edtUser: TEdit
              Left = 269
              Top = 10
              Width = 137
              Height = 25
              TabOrder = 2
            end
          end
        end
        object pnl5: TPanel
          Left = 0
          Top = 337
          Width = 672
          Height = 141
          Align = alClient
          TabOrder = 1
          ExplicitTop = 340
          ExplicitWidth = 634
          ExplicitHeight = 191
          object Grid1: TDBGrid
            Left = 1
            Top = 1
            Width = 670
            Height = 139
            Align = alClient
            DataSource = ds1
            Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
            PopupMenu = pm1
            TabOrder = 0
            TitleFont.Charset = ANSI_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -17
            TitleFont.Name = #23435#20307
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
      end
    end
  end
  object ds1: TDataSource
    Left = 328
    Top = 329
  end
  object pm1: TPopupMenu
    Left = 448
    Top = 321
    object mniN1: TMenuItem
      Caption = #33719#21462#25480#26435#30721
      OnClick = mniN1Click
    end
    object mnioken1: TMenuItem
      Caption = #33719#21462'Token'
      OnClick = mnioken1Click
    end
  end
end
