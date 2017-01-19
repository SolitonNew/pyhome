object SchedDialog: TSchedDialog
  Left = 729
  Top = 361
  BorderStyle = bsDialog
  Caption = #1047#1072#1087#1080#1089#1100' '#1088#1072#1089#1087#1080#1089#1072#1085#1080#1103
  ClientHeight = 344
  ClientWidth = 480
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 19
    Width = 53
    Height = 13
    Caption = #1054#1087#1080#1089#1072#1085#1080#1077':'
  end
  object Label2: TLabel
    Left = 16
    Top = 83
    Width = 53
    Height = 13
    Caption = #1044#1077#1081#1089#1090#1074#1080#1077':'
  end
  object Label3: TLabel
    Left = 16
    Top = 147
    Width = 57
    Height = 13
    Caption = #1055#1086#1074#1090#1086#1088#1103#1090#1100':'
  end
  object Label4: TLabel
    Left = 16
    Top = 179
    Width = 68
    Height = 13
    Caption = #1042#1088#1077#1084#1103' '#1076#1085#1103':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
    Left = 16
    Top = 243
    Width = 75
    Height = 13
    Caption = #1044#1085#1080' '#1085#1077#1076#1077#1083#1080':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object SpeedButton1: TSpeedButton
    Left = 360
    Top = 144
    Width = 105
    Height = 22
    Caption = #1058#1077#1089#1090' '#1076#1077#1081#1089#1090#1074#1080#1103
    OnClick = SpeedButton1Click
  end
  object Memo1: TMemo
    Left = 96
    Top = 16
    Width = 369
    Height = 57
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Memo2: TMemo
    Left = 96
    Top = 80
    Width = 369
    Height = 57
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object ComboBox1: TComboBox
    Left = 96
    Top = 144
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 2
    OnChange = ComboBox1Change
    Items.Strings = (
      #1050#1072#1078#1076#1099#1081' '#1076#1077#1085#1100
      #1050#1072#1078#1076#1091#1102' '#1085#1077#1076#1077#1083#1102
      #1050#1072#1078#1076#1099#1081' '#1084#1077#1089#1103#1094
      #1050#1072#1078#1076#1099#1081' '#1075#1086#1076
      #1058#1086#1083#1100#1082#1086' '#1086#1076#1080#1085' '#1088#1072#1079)
  end
  object Memo3: TMemo
    Left = 96
    Top = 176
    Width = 369
    Height = 57
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object Memo4: TMemo
    Left = 96
    Top = 240
    Width = 369
    Height = 57
    ScrollBars = ssVertical
    TabOrder = 4
  end
  object Button1: TButton
    Left = 8
    Top = 312
    Width = 73
    Height = 25
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 5
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 320
    Top = 312
    Width = 73
    Height = 25
    Caption = #1043#1086#1090#1086#1074#1086
    Default = True
    TabOrder = 6
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 400
    Top = 312
    Width = 73
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 7
  end
end
