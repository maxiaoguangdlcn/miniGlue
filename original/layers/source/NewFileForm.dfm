object frmNewFile: TfrmNewFile
  Left = 187
  Top = 132
  BorderStyle = bsDialog
  Caption = 'New'
  ClientHeight = 106
  ClientWidth = 310
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object grpbxBitmapDimension: TGroupBox
    Left = 8
    Top = 8
    Width = 193
    Height = 89
    Caption = 'Bitmap Dimension:'
    TabOrder = 0
    object lblWidth: TLabel
      Left = 19
      Top = 28
      Width = 31
      Height = 13
      Caption = 'Width:'
    end
    object lblHeight: TLabel
      Left = 16
      Top = 52
      Width = 34
      Height = 13
      Caption = 'Height:'
    end
    object edtWidth: TEdit
      Left = 56
      Top = 24
      Width = 121
      Height = 21
      TabOrder = 0
      OnChange = edtWidthChange
    end
    object edtHeight: TEdit
      Left = 56
      Top = 48
      Width = 121
      Height = 21
      TabOrder = 1
      OnChange = edtHeightChange
    end
  end
  object btbtnOK: TBitBtn
    Left = 216
    Top = 16
    Width = 75
    Height = 25
    Cursor = crHandPoint
    TabOrder = 1
    Kind = bkOK
  end
  object btbtnCancel: TBitBtn
    Left = 216
    Top = 56
    Width = 75
    Height = 25
    Cursor = crHandPoint
    TabOrder = 2
    Kind = bkCancel
  end
end
