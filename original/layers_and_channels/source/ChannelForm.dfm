object frmChannels: TfrmChannels
  Left = 471
  Top = 136
  Width = 240
  Height = 400
  BorderStyle = bsSizeToolWin
  Caption = 'Channels'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object tlbrChannels: TToolBar
    Left = 0
    Top = 332
    Width = 232
    Height = 24
    Align = alBottom
    AutoSize = True
    Caption = 'tlbrChannels'
    Flat = True
    Images = dmMain.imglstLLayerForm
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Down = True
      Style = tbsSeparator
    end
    object tlbtnNewAlphaChannel: TToolButton
      Left = 8
      Top = 0
      Action = dmMain.actnNewAlphaChannel
    end
    object tlbtnDeleteAlphaChannel: TToolButton
      Left = 31
      Top = 0
      Action = dmMain.actnDeleteChannel
    end
    object ToolButton2: TToolButton
      Left = 54
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      Down = True
      ImageIndex = 1
      Style = tbsSeparator
    end
    object spdbtnStandardMode: TSpeedButton
      Left = 62
      Top = 0
      Width = 40
      Height = 22
      Hint = 'Edit in standard mode'
      GroupIndex = 1
      Down = True
      Enabled = False
      Flat = True
      Glyph.Data = {
        42010000424D4201000000000000760000002800000015000000110000000100
        040000000000CC00000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFFFF
        FFFFFFFFF000FFFFFFFFFFFFFFFFFFFFF0000000000000000000000FF0000FFF
        FFFFFFFFFFFFFF0FF0000FFFFFFF000FFFFFFF0FF0000FFFFF0FFFFF0FFFFF0F
        F0000FFFF0FFFFFFF0FFFF0FF0000FFFFFFFFFFFFFFFFF0FF0000FFF0FFFFFFF
        FF0FFF0FF0000FFF0FFFFFFFFF0FFF0FF0000FFF0FFFFFFFFF0FFF0FF0000FFF
        FFFFFFFFFFFFFF0FF0000FFFF0FFFFFFF0FFFF0FF0000FFFFF0FFFFF0FFFFF0F
        F0000FFFFFFF000FFFFFFF0FF0000FFFFFFFFFFFFFFFFF0FF000000000000000
        0000000FF000}
      OnClick = spdbtnStandardModeClick
    end
    object spdbtnQuickMaskMode: TSpeedButton
      Left = 102
      Top = 0
      Width = 40
      Height = 22
      Hint = 'Edit in quick mask mode'
      GroupIndex = 1
      Enabled = False
      Flat = True
      Glyph.Data = {
        42010000424D4201000000000000760000002800000015000000110000000100
        040000000000CC00000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFFFF
        FFFFFFFFF000FFFFFFFFFFFFFFFFFFFFF0000000000000000000000FF0000777
        777777777777770FF0000777777700077777770FF0000777770FFFFF0777770F
        F000077770FFFFFFF077770FF00007777FFFFFFFFF77770FF00007770FFFFFFF
        FF07770FF00007770FFFFFFFFF07770FF00007770FFFFFFFFF07770FF0000777
        7FFFFFFFFF77770FF000077770FFFFFFF077770FF0000777770FFFFF0777770F
        F0000777777700077777770FF0000777777777777777770FF000000000000000
        0000000FF000}
      OnClick = spdbtnQuickMaskModeClick
    end
  end
end
