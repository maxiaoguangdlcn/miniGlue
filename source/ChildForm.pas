unit ChildForm;

(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1 or LGPL 2.1 with linking exception
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * Alternatively, the contents of this file may be used under the terms of the
 * Free Pascal modified version of the GNU Lesser General Public License
 * Version 2.1 (the "FPC modified LGPL License"), in which case the provisions
 * of this license are applicable instead of those above.
 * Please see the file LICENSE.txt for additional information concerning this
 * license.
 *
 *
 * The Initial Developer of this unit are
 *   Ma Xiaoguang and Ma Xiaoming < gmbros[at]hotmail[dot]com >
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
{ Delphi }
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
{ Graphics32 }
  GR32_Image, GR32, GR32_Layers,
{ miniGlue lib }
  igLayers,
  igBrightContrastLayer;

type
  TfrmChild = class(TForm)
    imgWorkArea: TImgView32;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure imgWorkAreaPaintStage(Sender: TObject; Buffer: TBitmap32;
      StageNum: Cardinal);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure imgWorkAreaMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure imgWorkAreaMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer; Layer: TCustomLayer);
    procedure imgWorkAreaMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
  private
    FLayerPanelList : TigLayerPanelList;
    FLeftButtonDown : Boolean;

    // callback functions
    procedure AfterLayerCombined(ASender: TObject; const ARect: TRect);
    procedure AfterSelectedLayerPanelChanged(ASender: TObject);
    procedure AfterLayerPanelChanged(ASender: TObject);
    procedure AfterLayerMerged(AResultPanel: TigCustomLayerPanel);
    procedure BCLayerThumbDblClick(ASender: TObject);
    procedure LayerThumbDblClick(ASender: TObject); // for testing
  public
    function CreateNormalLayer(const ABackColor: TColor32 = $00000000;
      const AsBackLayer: Boolean = False): TigCustomLayerPanel;

    function CreateBrightContrastLayer(const ABrightAmount: Integer = 0;
      const AContrastAmount: Integer = 0): TigCustomLayerPanel;

    procedure DeleteCurrentLayer;
    procedure SetCallbacksForLayerPanelsInList;

    property LayerPanelList : TigLayerPanelList read FLayerPanelList;
  end;

var
  frmChild: TfrmChild;

implementation

uses
{ miniGlue lib}
  igPaintFuncs,
{ miniGlue }
  MainDataModule,
  LayerForm,
  LayerBrightContrastForm;

{$R *.dfm}

// callback functions 
procedure TfrmChild.AfterLayerCombined(ASender: TObject; const ARect: TRect);
begin
  if Assigned(FLayerPanelList) then
  begin
    imgWorkArea.Bitmap.FillRectS(ARect, $00FFFFFF);  // must be transparent white
    imgWorkArea.Bitmap.Draw(ARect, ARect, FLayerPanelList.CombineResult);
    imgWorkArea.Bitmap.Changed(ARect);
  end;
end;

procedure TfrmChild.AfterSelectedLayerPanelChanged(ASender: TObject);
begin
  if Assigned(frmLayers) then
  begin
    frmLayers.LayerPanelManager.Invalidate;

    frmLayers.cmbbxBlendModes.ItemIndex := Ord(FLayerPanelList.SelectedPanel.LayerBlendMode);
    frmLayers.ggbrLayerOpacity.Position := MulDiv(FLayerPanelList.SelectedPanel.LayerOpacity, 100, 255);
  end;
end;

procedure TfrmChild.AfterLayerPanelChanged(ASender: TObject);
begin
  if Assigned(frmLayers) then
  begin
    frmLayers.LayerPanelManager.Invalidate;
  end;
end;

procedure TfrmChild.AfterLayerMerged(AResultPanel: TigCustomLayerPanel);
begin
  // setting callback functions for the result layer panel
  if Assigned(AResultPanel) and (AResultPanel is TigNormalLayerPanel) then
  begin
    with AResultPanel do
    begin
      OnChange             := Self.AfterLayerPanelChanged;
      OnThumbnailUpdate    := Self.AfterLayerPanelChanged;
      OnPanelDblClick      := nil;
      OnLayerThumbDblClick := Self.LayerThumbDblClick;
      OnMaskThumbDblClick  := nil;
    end;
  end;
end;

procedure TfrmChild.BCLayerThumbDblClick(ASender: TObject);
var
  LOldBright   : Integer;
  LOldContrast : Integer;
  LBCPanel     : TigBrightContrastLayerPanel;
  LModalResult : TModalResult;
begin
  if ASender is TigBrightContrastLayerPanel then
  begin
    LBCPanel := TigBrightContrastLayerPanel(ASender);

    LOldBright   := LBCPanel.BrightAmount;
    LOldContrast := LBCPanel.ContrastAmount;

    frmLayerBrightContrast := TfrmLayerBrightContrast.Create(nil);
    try
      frmLayerBrightContrast.AssociateToBCLayerPanel(LBCPanel);

      LModalResult := frmLayerBrightContrast.ShowModal;
    finally
      FreeAndNil(frmLayerBrightContrast);
    end;

    case LModalResult of
      mrOK:
        begin

        end;

      mrCancel:
        begin
          LBCPanel.BrightAmount   := LOldBright;
          LBCPanel.ContrastAmount := LOldContrast;
        end;
    end;

    LBCPanel.Changed;
  end;
end;

// for testing ...
procedure TfrmChild.LayerThumbDblClick(ASender: TObject);
var
  LColor : TColor32; 
begin
  if ASender is TigNormalLayerPanel then
  begin
    Randomize;
    LColor := $FF000000 or Cardinal( Random($FFFFFF) );

    with TigNormalLayerPanel(ASender) do
    begin
      LayerBitmap.Clear(LColor);
      Changed;

      UpdateLayerThumbnail;
    end;
  end;
end;

function TfrmChild.CreateNormalLayer(
  const ABackColor: TColor32 = $00000000;
  const AsBackLayer: Boolean = False): TigCustomLayerPanel;
begin
  Result := TigNormalLayerPanel.Create(FLayerPanelList,
    imgWorkArea.Bitmap.Width, imgWorkArea.Bitmap.Height,
    ABackColor, AsBackLayer);

  with Result do
  begin
    OnChange             := Self.AfterLayerPanelChanged;
    OnThumbnailUpdate    := Self.AfterLayerPanelChanged;
    OnLayerThumbDblClick := Self.LayerThumbDblClick;
  end;
end;

function TfrmChild.CreateBrightContrastLayer(const ABrightAmount: Integer = 0;
  const AContrastAmount: Integer = 0): TigCustomLayerPanel;
var
  LBCPanel : TigBrightContrastLayerPanel;
begin
  LBCPanel := TigBrightContrastLayerPanel.Create(FLayerPanelList,
    imgWorkArea.Bitmap.Width, imgWorkArea.Bitmap.Height);

  with LBCPanel do
  begin
    BrightAmount         := ABrightAmount;
    ContrastAmount       := AContrastAmount;
    OnChange             := Self.AfterLayerPanelChanged;
    OnThumbnailUpdate    := Self.AfterLayerPanelChanged;
    OnLayerThumbDblClick := Self.BCLayerThumbDblClick;
  end;

  Result := LBCPanel;
end;

procedure TfrmChild.DeleteCurrentLayer;
var
  LLayerName : string;
begin
  if FLayerPanelList.Count > 1 then
  begin
    LLayerName := '"' + FLayerPanelList.SelectedPanel.LayerName + '"';

    if MessageDlg('Delete the layer ' + LLayerName + '?',
                  mtConfirmation, [mbOK, mbCancel], 0) = mrOK then
    begin
      // delete the layer
      FLayerPanelList.DeleteSelectedLayerPanel;
    end;
  end;
end;

procedure TfrmChild.SetCallbacksForLayerPanelsInList;
var
  i           : Integer;
  LLayerPanel : TigCustomLayerPanel;
begin
  if FLayerPanelList.Count > 0 then
  begin
    for i := 0 to (FLayerPanelList.Count - 1) do
    begin
      LLayerPanel := FLayerPanelList.LayerPanels[i];

      with LLayerPanel do
      begin
        OnChange            := Self.AfterLayerPanelChanged;
        OnPanelDblClick     := nil;
        OnMaskThumbDblClick := nil;

        if LLayerPanel is TigNormalLayerPanel then
        begin
          OnThumbnailUpdate    := Self.AfterLayerPanelChanged;
          OnLayerThumbDblClick := Self.LayerThumbDblClick;
        end
        else if LLayerPanel is TigBrightContrastLayerPanel then
        begin
          OnLayerThumbDblClick := Self.BCLayerThumbDblClick;
        end;
      end;
    end;
  end;
end;

procedure TfrmChild.FormCreate(Sender: TObject);
begin
  FLayerPanelList := TigLayerPanelList.Create;
  with FLayerPanelList do
  begin
    OnLayerCombined      := Self.AfterLayerCombined;
    OnSelectionChanged   := Self.AfterSelectedLayerPanelChanged;
    OnLayerOrderChanged  := Self.AfterLayerPanelChanged;
    OnMergeVisibleLayers := Self.AfterLayerMerged;
    OnFlattenLayers      := Self.AfterLayerMerged;
  end;

  // by default, PST_CLEAR_BACKGND is executed at this stage,
  // which, in turn, calls ExecClearBackgnd method of ImgView.
  // Here I substitute PST_CLEAR_BACKGND with PST_CUSTOM, so force ImgView
  // to call the OnPaintStage event instead of performing default action. 
  with imgWorkArea.PaintStages[0]^ do
  begin
    if Stage = PST_CLEAR_BACKGND then
    begin
      Stage := PST_CUSTOM;
    end;
  end;

  imgWorkArea.RepaintMode     := rmOptimizer;
  imgWorkArea.Bitmap.DrawMode := dmBlend;

  FLeftButtonDown := False;            
end;

procedure TfrmChild.FormActivate(Sender: TObject);
begin
  gActiveChildForm := Self;

  frmLayers.LayerPanelManager.PanelList := FLayerPanelList;

  if Assigned(FLayerPanelList.SelectedPanel) then
  begin
    frmLayers.cmbbxBlendModes.ItemIndex := Ord(FLayerPanelList.SelectedPanel.LayerBlendMode);
    frmLayers.ggbrLayerOpacity.Position := MulDiv(FLayerPanelList.SelectedPanel.LayerOpacity, 100, 255);
  end;
end;

procedure TfrmChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmLayers.LayerPanelManager.PanelList := nil;
  gActiveChildForm := nil;

  Action := caFree;  // close the child form
end;

procedure TfrmChild.imgWorkAreaPaintStage(Sender: TObject;
  Buffer: TBitmap32; StageNum: Cardinal);
var
  LRect : TRect;
begin
  Buffer.Clear($FFC0C0C0);

  LRect := imgWorkArea.GetBitmapRect;
  DrawCheckerboardPattern(Buffer, LRect);

  LRect.Left   := LRect.Left   - 1;
  LRect.Top    := LRect.Top    - 1;
  LRect.Right  := LRect.Right  + 1;
  LRect.Bottom := LRect.Bottom + 1;

  // draw thin border, learned from Andre Felix Miertschink
  Buffer.FrameRectS(LRect, clBlack32);
end;

procedure TfrmChild.FormShow(Sender: TObject);
begin
  frmLayers.LayerPanelManager.PanelList := FLayerPanelList;
end;

procedure TfrmChild.imgWorkAreaMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  LRect  : TRect;
  LPoint : TPoint;
begin
  LPoint := imgWorkArea.ControlToBitmap( Point(X, Y) );

  LRect.Left   := LPoint.X - 10;
  LRect.Top    := LPoint.Y - 10;
  LRect.Right  := LPoint.X + 10;
  LRect.Bottom := LPoint.Y + 10;

  FLayerPanelList.SelectedPanel.LayerBitmap.FillRectS(LRect, $7F000000);
  FLayerPanelList.SelectedPanel.Changed(LRect);

  FLeftButtonDown := True;
end;

procedure TfrmChild.imgWorkAreaMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  LRect  : TRect;
  LPoint : TPoint;
begin
  LPoint := imgWorkArea.ControlToBitmap( Point(X, Y) );
  
  if FLeftButtonDown then
  begin
    LRect.Left   := LPoint.X - 10;
    LRect.Top    := LPoint.Y - 10;
    LRect.Right  := LPoint.X + 10;
    LRect.Bottom := LPoint.Y + 10;

    FLayerPanelList.SelectedPanel.LayerBitmap.FillRectS(LRect, $7F000000);
    FLayerPanelList.SelectedPanel.Changed(LRect);
  end;
end;

procedure TfrmChild.imgWorkAreaMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
  if FLeftButtonDown then
  begin
    FLeftButtonDown := False;

    FLayerPanelList.SelectedPanel.UpdateLayerThumbnail;
  end;
end;

end.
