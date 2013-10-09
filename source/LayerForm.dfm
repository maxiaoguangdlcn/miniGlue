object frmLayers: TfrmLayers
  Left = 193
  Top = 133
  Width = 240
  Height = 502
  BorderStyle = bsSizeToolWin
  Caption = 'Layers'
  Color = clBtnFace
  Constraints.MinHeight = 170
  Constraints.MinWidth = 240
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object tlbrLayers: TToolBar
    Left = 0
    Top = 434
    Width = 232
    Height = 24
    Align = alBottom
    AutoSize = True
    Caption = 'tlbrLayers'
    Ctl3D = False
    Flat = True
    Images = dmMain.imglstLLayerForm
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object tlbnSeparator1: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'tlbnSeparator1'
      ImageIndex = 1
      Style = tbsSeparator
    end
    object tlbrAddMask: TToolButton
      Left = 8
      Top = 0
      Action = dmMain.actnAddMask
    end
    object tlbnNewLayer: TToolButton
      Left = 31
      Top = 0
      Cursor = crHandPoint
      Action = dmMain.actnNewLayer
    end
    object tlbtnDeleteLayer: TToolButton
      Left = 54
      Top = 0
      Action = dmMain.actnDeleteLayer
    end
  end
  object tlbrBlendModes: TToolBar
    Left = 0
    Top = 0
    Width = 232
    Height = 23
    AutoSize = True
    ButtonHeight = 21
    Caption = 'tlbrBlendModes'
    Ctl3D = False
    Flat = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    object tlbnSeparator2: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'tlbnSeparator2'
      Style = tbsSeparator
    end
    object cmbbxBlendModes: TComboBox
      Left = 8
      Top = 0
      Width = 145
      Height = 21
      Cursor = crHandPoint
      DropDownCount = 40
      ItemHeight = 13
      TabOrder = 0
      OnChange = ChangeLayerBlendMode
    end
  end
  object tlbrLayerOpacity: TToolBar
    Left = 0
    Top = 23
    Width = 232
    Height = 21
    AutoSize = True
    ButtonHeight = 19
    Caption = 'tlbrLayerOpacity'
    Ctl3D = False
    Flat = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Style = tbsSeparator
    end
    object ggbrLayerOpacity: TGaugeBar
      Left = 8
      Top = 0
      Width = 145
      Height = 19
      Cursor = crHandPoint
      Constraints.MinWidth = 120
      Backgnd = bgPattern
      ShowHandleGrip = True
      Style = rbsMac
      Position = 0
      OnChange = ggbrLayerOpacityChange
    end
    object edtLayerOpacity: TEdit
      Left = 153
      Top = 0
      Width = 40
      Height = 19
      TabOrder = 1
    end
    object lblLayerOpacity: TLabel
      Left = 193
      Top = 0
      Width = 24
      Height = 19
      AutoSize = False
      Caption = '%'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
  end
end
