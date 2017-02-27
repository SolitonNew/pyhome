object AlertForm: TAlertForm
  Left = 1091
  Top = 414
  AlphaBlend = True
  AlphaBlendValue = 220
  BorderStyle = bsNone
  ClientHeight = 90
  ClientWidth = 308
  Color = clPurple
  TransparentColor = True
  TransparentColorValue = clPurple
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Shape1: TShape
    Left = 0
    Top = 0
    Width = 308
    Height = 90
    Align = alClient
    Pen.Color = clOlive
    Pen.Width = 2
  end
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 213
    Height = 19
    Caption = '050-123-45-67'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 128
    Top = 48
  end
end
