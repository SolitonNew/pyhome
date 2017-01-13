object VlcForm: TVlcForm
  Left = 1223
  Top = 404
  Width = 383
  Height = 473
  Caption = 'VLC Player'
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
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 57
    Width = 367
    Height = 378
    Align = alClient
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 367
    Height = 57
    Align = alTop
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 5
      Width = 32
      Height = 13
      Caption = 'Label1'
    end
    object Label2: TLabel
      Left = 48
      Top = 5
      Width = 32
      Height = 13
      Caption = 'Label2'
    end
    object SpeedButton1: TSpeedButton
      Left = 280
      Top = 32
      Width = 81
      Height = 22
      Caption = #1054#1090#1087#1088#1072#1074#1080#1090#1100
      OnClick = SpeedButton1Click
    end
    object Edit1: TEdit
      Left = 8
      Top = 32
      Width = 265
      Height = 21
      TabOrder = 0
      Text = 'help'
      OnKeyPress = Edit1KeyPress
    end
  end
  object ClientSocket1: TClientSocket
    Active = False
    ClientType = ctNonBlocking
    Host = '127.0.0.1'
    Port = 4444
    OnConnect = ClientSocket1Connect
    OnDisconnect = ClientSocket1Disconnect
    OnRead = ClientSocket1Read
    OnError = ClientSocket1Error
    Left = 8
    Top = 64
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 40
    Top = 64
  end
end
