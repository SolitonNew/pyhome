object RegForm: TRegForm
  Left = 654
  Top = 352
  BorderStyle = bsDialog
  Caption = #1056#1077#1075#1080#1089#1090#1088#1072#1094#1080#1103
  ClientHeight = 201
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 48
    Width = 377
    Height = 49
    AutoSize = False
    Caption = 
      #1069#1089#1083#1080' '#1082#1083#1080#1077#1085#1090' '#1088#1072#1085#1077#1077' '#1091#1078#1077' '#1073#1099#1083' '#1079#1072#1088#1077#1075#1080#1089#1090#1088#1080#1088#1086#1074#1072#1085', '#1090#1086' '#1080#1079' '#1074#1099#1087#1072#1076#1072#1102#1097#1077#1075#1086' '#1089#1087#1080 +
      #1089#1082#1072' '#1074#1099#1073#1077#1088#1080#1090#1077' '#1086#1087#1080#1089#1072#1085#1080#1077' '#1088#1072#1085#1077#1077' '#1079#1072#1088#1077#1075#1080#1089#1090#1088#1080#1088#1086#1074#1072#1085#1086#1075#1086' '#1082#1083#1080#1077#1085#1090#1072' '#1080#1083#1080' '#1074#1074#1077#1076#1080 +
      #1090#1077' '#1086#1087#1080#1089#1072#1085#1080#1077' '#1085#1086#1074#1086#1075#1086' '#1082#1083#1080#1077#1085#1090#1072'.'
    WordWrap = True
  end
  object Label2: TLabel
    Left = 16
    Top = 32
    Width = 287
    Height = 13
    Caption = #1069#1090#1086#1090' '#1082#1083#1080#1077#1085#1090' '#1079#1072#1087#1091#1089#1082#1072#1077#1090#1089#1103' '#1085#1072' '#1101#1090#1086#1084' '#1082#1086#1084#1087#1100#1102#1090#1077#1088#1077' '#1074#1087#1077#1088#1074#1099#1077'.'
  end
  object Label3: TLabel
    Left = 16
    Top = 16
    Width = 64
    Height = 13
    Caption = #1042#1085#1080#1084#1072#1085#1080#1077'!'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object ComboBox1: TComboBox
    Left = 16
    Top = 112
    Width = 385
    Height = 21
    ItemHeight = 13
    TabOrder = 0
  end
  object Button1: TButton
    Left = 248
    Top = 160
    Width = 73
    Height = 25
    Caption = #1043#1086#1090#1086#1074#1086
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 328
    Top = 160
    Width = 73
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 2
    OnClick = Button2Click
  end
end
