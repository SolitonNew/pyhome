object PropertysForm: TPropertysForm
  Left = 577
  Top = 465
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsDialog
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  ClientHeight = 337
  ClientWidth = 538
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 521
    Height = 281
    ActivePage = TabSheet4
    TabOrder = 0
    object TabSheet3: TTabSheet
      Caption = #1054#1073#1097#1080#1077
      ImageIndex = 2
      object GroupBox3: TGroupBox
        Left = 8
        Top = 8
        Width = 497
        Height = 65
        Caption = ' '#1054#1087#1080#1089#1072#1085#1080#1077' '#1082#1083#1080#1077#1085#1090#1072': '
        TabOrder = 0
        object SpeedButton2: TSpeedButton
          Left = 392
          Top = 24
          Width = 89
          Height = 22
          Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
          OnClick = SpeedButton2Click
        end
        object Edit2: TEdit
          Left = 16
          Top = 24
          Width = 369
          Height = 21
          TabOrder = 0
        end
      end
      object GroupBox4: TGroupBox
        Left = 8
        Top = 80
        Width = 497
        Height = 65
        Caption = ' IP '#1089#1077#1088#1074#1077#1088#1072': '
        TabOrder = 1
        object SpeedButton3: TSpeedButton
          Left = 392
          Top = 24
          Width = 89
          Height = 22
          Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
          OnClick = SpeedButton3Click
        end
        object Edit3: TEdit
          Left = 16
          Top = 24
          Width = 369
          Height = 21
          TabOrder = 0
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = #1041#1080#1073#1083#1080#1086#1090#1077#1082#1072
      ImageIndex = 1
      object SpeedButton6: TSpeedButton
        Left = 8
        Top = 216
        Width = 161
        Height = 25
        Caption = #1054#1073#1085#1086#1074#1080#1090#1100' '#1073#1080#1073#1083#1080#1086#1090#1077#1082#1091
        OnClick = SpeedButton6Click
      end
      object Label1: TLabel
        Left = 184
        Top = 216
        Width = 321
        Height = 33
        AutoSize = False
        Caption = 'Label1'
        WordWrap = True
      end
      object GroupBox1: TGroupBox
        Left = 8
        Top = 8
        Width = 497
        Height = 193
        Caption = ' '#1055#1072#1087#1082#1080' '#1084#1077#1076#1080#1080': '
        TabOrder = 0
        object SpeedButton4: TSpeedButton
          Left = 408
          Top = 24
          Width = 73
          Height = 25
          Caption = #1044#1086#1073#1072#1074#1080#1090#1100'...'
          OnClick = SpeedButton4Click
        end
        object SpeedButton5: TSpeedButton
          Left = 408
          Top = 56
          Width = 73
          Height = 25
          Caption = #1059#1076#1072#1083#1080#1090#1100
          OnClick = SpeedButton5Click
        end
        object ListBox1: TListBox
          Left = 16
          Top = 24
          Width = 385
          Height = 153
          ItemHeight = 13
          TabOrder = 0
        end
      end
    end
    object TabSheet4: TTabSheet
      Caption = #1051#1086#1075' '#1084#1077#1090#1072#1076#1072#1085#1085#1099#1093
      ImageIndex = 3
      object SpeedButton7: TSpeedButton
        Left = 8
        Top = 216
        Width = 73
        Height = 25
        Caption = #1054#1095#1080#1089#1090#1080#1090#1100
        OnClick = SpeedButton7Click
      end
      object ListBox2: TListBox
        Left = 8
        Top = 8
        Width = 497
        Height = 201
        ItemHeight = 13
        TabOrder = 0
      end
    end
  end
  object Button1: TButton
    Left = 456
    Top = 304
    Width = 73
    Height = 25
    Cancel = True
    Caption = #1047#1072#1082#1088#1099#1090#1100
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = Button1Click
  end
  object OpenDialog1: TOpenDialog
    Filter = '*.exe|*.exe'
    Left = 12
    Top = 296
  end
end
