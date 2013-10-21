object frmMain: TfrmMain
  Left = 214
  Top = 134
  Width = 870
  Height = 640
  Caption = 'Paint Brush Demo'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pntbxDrawingArea: TigPaintBox
    Left = 0
    Top = 211
    Width = 862
    Height = 402
    Align = alClient
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 862
    Height = 211
    Align = alTop
    TabOrder = 1
    object lblBrushSize: TLabel
      Left = 212
      Top = 10
      Width = 79
      Height = 13
      Caption = 'Brush Size: 50px'
    end
    object lblBrushOpacity: TLabel
      Left = 211
      Top = 66
      Width = 98
      Height = 13
      Caption = 'Brush Opacity: 100%'
    end
    object lblBrushColor: TLabel
      Left = 379
      Top = 10
      Width = 57
      Height = 13
      Caption = 'Brush Color:'
    end
    object shpBrushColor: TShape
      Left = 379
      Top = 32
      Width = 134
      Height = 21
      Cursor = crHandPoint
      Brush.Color = clBlack
      OnMouseDown = shpBrushColorMouseDown
    end
    object lblBlendMode: TLabel
      Left = 379
      Top = 66
      Width = 60
      Height = 13
      Caption = 'Blend Mode:'
    end
    object imgStrokePreview: TImage32
      Left = 8
      Top = 8
      Width = 192
      Height = 192
      Bitmap.ResamplerClassName = 'TNearestResampler'
      BitmapAlign = baCenter
      Color = clWhite
      ParentColor = False
      Scale = 1.000000000000000000
      ScaleMode = smNormal
      TabOrder = 0
    end
    object scrlbrBrushSize: TScrollBar
      Left = 211
      Top = 32
      Width = 133
      Height = 21
      Cursor = crHandPoint
      Min = 1
      PageSize = 0
      Position = 20
      TabOrder = 1
      OnChange = scrlbrBrushSizeChange
    end
    object btnResetBackground: TButton
      Left = 208
      Top = 135
      Width = 137
      Height = 25
      Cursor = crHandPoint
      Caption = 'Reset Background'
      TabOrder = 2
      OnClick = btnResetBackgroundClick
    end
    object scrlbrBrushOpacity: TScrollBar
      Left = 211
      Top = 88
      Width = 133
      Height = 21
      Cursor = crHandPoint
      Max = 255
      PageSize = 0
      Position = 255
      TabOrder = 3
      OnChange = scrlbrBrushOpacityChange
    end
    object cmbbxBlendMode: TComboBox
      Left = 376
      Top = 88
      Width = 145
      Height = 21
      Cursor = crHandPoint
      DropDownCount = 40
      ItemHeight = 13
      TabOrder = 4
      OnChange = cmbbxBlendModeChange
    end
  end
  object ColorDialog: TColorDialog
    Left = 8
    Top = 224
  end
end
