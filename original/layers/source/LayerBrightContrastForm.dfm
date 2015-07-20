object frmLayerBrightContrast: TfrmLayerBrightContrast
  Left = 189
  Top = 129
  BorderStyle = bsDialog
  Caption = 'Brightness/Contrast'
  ClientHeight = 127
  ClientWidth = 321
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
  object lblBrightness: TLabel
    Left = 16
    Top = 20
    Width = 52
    Height = 13
    Caption = 'Brightness:'
  end
  object lblContrast: TLabel
    Left = 16
    Top = 76
    Width = 42
    Height = 13
    Caption = 'Contrast:'
  end
  object edtBrightness: TEdit
    Left = 140
    Top = 16
    Width = 61
    Height = 21
    ReadOnly = True
    TabOrder = 1
  end
  object ggbrBrightness: TGaugeBar
    Left = 16
    Top = 40
    Width = 185
    Height = 16
    Cursor = crHandPoint
    Backgnd = bgPattern
    Max = 200
    ShowHandleGrip = True
    Position = 100
    OnChange = ggbrBrightnessChange
    OnMouseUp = ggbrBrightnessMouseUp
  end
  object edtContrast: TEdit
    Left = 140
    Top = 72
    Width = 61
    Height = 21
    ReadOnly = True
    TabOrder = 2
  end
  object ggbrContrast: TGaugeBar
    Left = 16
    Top = 96
    Width = 185
    Height = 16
    Cursor = crHandPoint
    Backgnd = bgPattern
    Max = 200
    ShowHandleGrip = True
    Position = 100
    OnChange = ggbrContrastChange
    OnMouseUp = ggbrContrastMouseUp
  end
  object btbtnOK: TBitBtn
    Left = 224
    Top = 16
    Width = 75
    Height = 25
    Cursor = crHandPoint
    TabOrder = 0
    Kind = bkOK
  end
  object btbtnCancel: TBitBtn
    Left = 224
    Top = 48
    Width = 75
    Height = 25
    Cursor = crHandPoint
    TabOrder = 4
    Kind = bkCancel
  end
end
