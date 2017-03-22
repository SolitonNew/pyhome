object AlertForm: TAlertForm
  Left = 1091
  Top = 353
  AlphaBlend = True
  AlphaBlendValue = 220
  BorderStyle = bsNone
  ClientHeight = 151
  ClientWidth = 184
  Color = clFuchsia
  TransparentColor = True
  TransparentColorValue = clFuchsia
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClick = FormClick
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 24
    Top = 24
  end
  object Timer2: TTimer
    Interval = 50
    OnTimer = Timer2Timer
    Left = 56
    Top = 24
  end
end
