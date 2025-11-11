object MediaInfoDialog: TMediaInfoDialog
  Left = 655
  Top = 298
  BorderStyle = bsDialog
  Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1079#1072#1087#1080#1089#1080
  ClientHeight = 186
  ClientWidth = 434
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
  object Button1: TButton
    Left = 272
    Top = 152
    Width = 73
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    Default = True
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 352
    Top = 152
    Width = 73
    Height = 25
    Cancel = True
    Caption = #1047#1072#1082#1088#1099#1090#1100
    ModalResult = 2
    TabOrder = 1
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 417
    Height = 57
    Caption = ' '#1053#1072#1079#1074#1072#1085#1080#1077': '
    TabOrder = 2
    object Edit1: TEdit
      Left = 16
      Top = 24
      Width = 385
      Height = 21
      TabOrder = 0
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 72
    Width = 417
    Height = 65
    Caption = ' '#1056#1072#1089#1087#1086#1083#1086#1078#1077#1085#1080#1077': '
    TabOrder = 3
    object Label3: TLabel
      Left = 16
      Top = 19
      Width = 385
      Height = 33
      AutoSize = False
      Caption = 'Label3'
      WordWrap = True
    end
  end
end
