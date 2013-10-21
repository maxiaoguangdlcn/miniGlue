object MDIChild: TMDIChild
  Left = 286
  Top = 153
  Width = 512
  Height = 352
  ActiveControl = img1
  Caption = 'MDI Child'
  Color = clBtnFace
  ParentFont = True
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Visible = True
  OnActivate = FormActivate
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object img1: TigPaintBox
    Left = 0
    Top = 0
    Width = 504
    Height = 325
    Align = alClient
  end
end
