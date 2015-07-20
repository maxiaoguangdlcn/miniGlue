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

// Update Date: 2015/04/18

interface

uses
{ Delphi }
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
{ Graphics32 }
  GR32_Image, GR32, GR32_Layers,
{ miniGlue lib }
  igLayers,
  igBrightContrastLayer,
  igChannels,
  igChannelManager,
  igCustomBrush,
  igPaintBrush;

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
    procedure FormDestroy(Sender: TObject);
  private
    FLayerList       : TigLayerList;
    FChannelManager  : TigCustomChannelManager;
    FLeftButtonDown  : Boolean;
    FCheckerboardBmp : TBitmap32;   // holding checkerboard pattern for background rendering

    //** BEGIN TEST CODE *****************************
    FBrushTool      : TigCustomBrush;
    //** END TEST CODE ****************************
    
    // layer callback functions
    procedure AfterBrushPaint(ASender: TObject; const APaintRect: TRect);
    procedure AfterLayerCombined(ASender: TObject; const ARect: TRect);
    procedure AfterSelectedLayerPanelChanged(ASender: TObject);
    procedure AfterLayerPanelChanged(ASender: TObject);
    procedure AfterLayerMerged(AResultLayer: TigCustomLayer);
    procedure AfterLayerMaskApplied(ASender: TObject);
    procedure AfterLayerMaskEnabled(ASender: TObject);
    procedure AfterLayerMaskDisabled(ASender: TObject);
    procedure AfterLayerProcessStageChanged(ASender: TObject; const AStage: TigLayerProcessStage);
    procedure OnLayerPanelEnabled(ASender: TObject);
    procedure OnLayerPanelDisabled(ASender: TObject);

    procedure BCLogoThumbDblClick(ASender: TObject);
    procedure LayerThumbDblClick(ASender: TObject); // for testing

    // channel callback functions
    procedure OnAlphaChannelDelete(ASender: TObject);
    procedure OnChannelDblClick(AChannel: TigCustomChannel; const AChannelType: TigChannelType);
    procedure OnChannelVisibleChange(const AChannelType: TigChannelType);
    procedure OnChannelThumbnailUpdate(ASender: TObject);
    procedure OnInsertAlphaChannel(AList: TigAlphaChannelList; const AIndex: Integer);
    procedure OnLayerMaskChannelDelete(ASender: TObject);
    procedure OnQuickMaskChannelCreate(ASender: TObject);
    procedure OnQuickMaskChannelDelete(ASender: TObject);
    procedure OnSelectedChannelChanged(const ACurrentChannelType: TigChannelType);

    // other callback functions
    procedure ImageViewerScaleChange(ASender: TObject);
  public
    function CreateNormalLayer(const ABackColor: TColor32 = $00000000;
      const AsBackLayer: Boolean = False): TigCustomLayer;

    function CreateBrightContrastLayer(const ABrightAmount: Integer = 0;
      const AContrastAmount: Integer = 0): TigCustomLayer;

    procedure DeleteCurrentLayer;
    procedure SetCallbacksForLayersInList;

    property CheckerboardBmp : TBitmap32               read FCheckerboardBmp;
    property ChannelManager  : TigCustomChannelManager read FChannelManager;
    property LayerList       : TigLayerList            read FLayerList;
  end;

var
  frmChild: TfrmChild;

implementation

uses
  Math,
{ miniGlue lib}
  igRGBChannelManager,
  igPaintFuncs,
{ miniGlue }
  MainDataModule,
  LayerForm,
  LayerBrightContrastForm,
  ChannelForm,
  ChannelOptionsForm;

{$R *.dfm}

function AddRects(const ARect1, ARect2: TRect): TRect;
begin
  Result.Left   := Min(ARect1.Left,   ARect2.Left);
  Result.Top    := Min(ARect1.Top,    ARect2.Top);
  Result.Right  := Max(ARect1.Right,  ARect2.Right);
  Result.Bottom := Max(ARect1.Bottom, ARect2.Bottom);
end;

{$RANGECHECKS OFF}
//This method is written by Zoltan Komaromy.
//Ezt csak a prevjúra használjuk!!, mert a végso intensityt majd nem itt, hanem a layer intensitynél szabályozzuk!!!
procedure MyFeatheredCircle(Bitmap32: TBitmap32; CenterX, CenterY, Radius, Feather: single; intensity:byte);
//modified by zoltan!
// Draw a disk on Bitmap. Bitmap must be a 256 color (pf8bit) palette bitmap,
// and parts outside the disk will get palette index 0, parts inside will get
// palette index 255, and in the antialiased area (feather), the pixels will
// get values inbetween.
// ***Parameters***
// Bitmap:
//   The bitmap to draw on
// CenterX, CenterY:
//   The center of the disk (float precision). Note that [0, 0] would be the
//   center of the first pixel. To draw in the exact middle of a 100x100 bitmap,
//   use CenterX = 49.5 and CenterY = 49.5
// Radius:
//   The radius of the drawn disk in pixels (float precision)
// Feather:
//   The feather area. Use 1 pixel for a 1-pixel antialiased area. Pixel centers
//   outside 'Radius + Feather / 2' become 0, pixel centers inside 'Radius - Feather/2'
//   become 255. Using a value of 0 will yield a bilevel image.
// Copyright (c) 2003 Nils Haeck M.Sc. www.simdesign.nl
var
  x, y: integer;
  LX, RX, LY, RY: integer;
  Fact: integer;
  RPF2, RMF2: single;
//  P: PByteArray;  //zoltan
  P: PColor32Array;
  SqY, SqDist: single;
  sqX: array of single;
  b:byte;
begin
  // Determine some helpful values (singles)
  RPF2 := sqr(Radius + Feather/2);
  RMF2 := sqr(Radius - Feather/2);

  // Determine bounds:
  LX := Max(floor(CenterX - RPF2), 0);
  RX := Min(ceil (CenterX + RPF2), Bitmap32.Width - 1);
  LY := Max(floor(CenterY - RPF2), 0);
  RY := Min(ceil (CenterY + RPF2), Bitmap32.Height - 1);

  if intensity=0 then
  begin
    //elméletileg elozoleg clearezve lett a kép, úgyhogy nem kéne csinálunk semmit se, de azért így tuti!
    for y := LY to RY do
    begin
      P := Bitmap32.Scanline[y];
      for x := LX to RX do
      begin
        P[x] := color32(255,255,255,255);
      end
    end;
  end
  else
  begin
    // Optimization run: find squares of X first
    SetLength(SqX, RX - LX + 1);
    for x := LX to RX do
      SqX[x - LX] := sqr(x - CenterX);

    // Loop through Y values
    for y := LY to RY do
    begin
      P := Bitmap32.Scanline[y];    //zoltan!!!
//       p :=  bitmap32.pixelptr[x,y];
      SqY := Sqr(y - CenterY);
      // Loop through X values
      for x := LX to RX do
      begin

        // determine squared distance from center for this pixel
        SqDist := SqY + SqX[x - LX];

        // inside inner circle? Most often..
        if sqdist < RMF2 then
        begin
        // inside the inner circle.. just give the scanline the new color
//        P[x] := 255;                       //orig
          P[x] := color32(255-intensity,255-intensity,255-intensity,255); //works ok!
//        P[x]:=SetAlpha(P[x], 255);
        end
        else
        begin
          // inside outer circle?
          if sqdist < RPF2 then
          begin
            // We are inbetween the inner and outer bound, now mix the color
            Fact := round(((Radius - sqrt(sqdist)) * 2 / Feather) * 127.5 + 127.5);
//          P[x] := Max(0, Min(Fact, 255)); // just in case limit to [0, 255]   //orig
            b:=Max(0, Min(Fact, 255)); // just in case limit to [0, 255]
            b:=255-round(b/(255/intensity));
            P[x] := color32(b,b,b,255);  //works ok!
//          P[x]:=SetAlpha(P[x], b);
          end
          else
          begin
            //P[x] := 0;
            P[x] := color32(255,255,255,255);   //works ok!           külso fehér
//          P[x]:=SetAlpha(P[x], 0);
          end;
        end;
      end;
    end;
  end;
end;
{$RANGECHECKS ON}

procedure InvertBitamp(ABitmap: TBitmap32);
var
  i       : Integer;
  p       : PColor32;
  r, g, b : Cardinal;
begin
  p := @ABitmap.Bits[0];

  for i := 1 to (ABitmap.Width * ABitmap.Height) do
  begin
    r := 255 - (p^ shr 16 and $FF);
    g := 255 - (p^ shr 8 and $FF);
    b := 255 - (P^ and $FF);

    p^ := (p^ and $FF000000) or (r shl 16) or (g shl 8) or b;
    
    Inc(p);
  end;
end;

procedure TfrmChild.AfterBrushPaint(ASender: TObject; const APaintRect: TRect);
begin
  if FChannelManager.CurrentChannelType in [ctColorChannel, ctLayerMaskChannel] then
  begin
    FLayerList.SelectedLayer.Changed(APaintRect);

    if FChannelManager.CurrentChannelType = ctLayerMaskChannel then
    begin
      if Assigned(FChannelManager.LayerMaskChannel) then
      begin
        FChannelManager.LayerMaskChannel.ChannelLayer.Bitmap.Draw(
          APaintRect, APaintRect, FLayerList.SelectedLayer.MaskBitmap);
      end;
    end;
  end
  else
  begin
    imgWorkArea.Bitmap.Changed(APaintRect);
  end;
end;

// callback functions 
procedure TfrmChild.AfterLayerCombined(ASender: TObject; const ARect: TRect);
begin
  if Assigned(FLayerList) then
  begin
    // rendering the checkerboard pattern as background first
    imgWorkArea.Bitmap.Draw(ARect, ARect, FCheckerboardBmp);

    // then rendering the combined result of layers on the background
//    imgWorkArea.Bitmap.Draw(ARect, ARect, FLayerList.CombineResult);

    // here, we don't draw layer combined result onto the background,
    // instead, we tweak the combined result with color channel settings,
    // and then merge the new result with the background ...
    FChannelManager.BlendByColorChannelSettings(FLayerList.CombineResult,
                                                imgWorkArea.Bitmap, ARect);

    imgWorkArea.Bitmap.Changed(ARect);
  end;
end;

procedure TfrmChild.AfterSelectedLayerPanelChanged(ASender: TObject);
begin
  if Assigned(frmLayers) then
  begin
    frmLayers.LayerPanelManager.Invalidate();

    frmLayers.cmbbxBlendModes.ItemIndex := Ord(FLayerList.SelectedLayer.LayerBlendMode);
    frmLayers.ggbrLayerOpacity.Position := MulDiv(FLayerList.SelectedLayer.LayerOpacity, 100, 255);

    if FLayerList.SelectedLayer.IsMaskEnabled then
    begin
      if Assigned(FChannelManager.LayerMaskChannel) then
      begin
        // replace the mask channel data with the mask settings on current layer

        FChannelManager.LayerMaskChannel.ChannelName := FLayerList.SelectedLayer.LayerName + ' Mask';

        // Note that, at here, we should always update the bitmap of
        // layer mask channel with Draw(), other than Assign(),
        // otherwise, the DrawMode of the layer mask bitmap will be
        // changed from dmCustom to dmOpaque.
        FChannelManager.LayerMaskChannel.ChannelLayer.Bitmap.Draw(0, 0,
          FLayerList.SelectedLayer.MaskBitmap);

        FChannelManager.LayerMaskChannel.UpdateChannelThumbnail();
      end
      else
      begin
        FChannelManager.CreateLayerMaskChannel(
          FLayerlist.SelectedLayer.MaskBitmap,
          FLayerList.SelectedLayer.LayerName + ' Mask');
      end;

      case FLayerList.SelectedLayer.LayerProcessStage of
        lpsLayer:
          begin
            FChannelManager.SelectColorChannel(0, True);
          end;

        lpsMask:
          begin
            FChannelManager.SelectLayerMaskChannel();
          end;
      end;
    end
    else
    begin
      if Assigned(FChannelManager.LayerMaskChannel) then
      begin
        FChannelManager.DeleteLayerMaskChannel();
      end;
    end;

    frmChannels.ChannelViewer.Invalidate();
  end;
end;

procedure TfrmChild.AfterLayerPanelChanged(ASender: TObject);
begin
  if Assigned(frmLayers) then
  begin
    frmLayers.LayerPanelManager.Invalidate;
  end;

  FChannelManager.UpdateColorChannelThumbnails(FLayerList.CombineResult);
end;

procedure TfrmChild.AfterLayerMerged(AResultLayer: TigCustomLayer);
begin
  // setting callback functions for the result layer
  if Assigned(AResultLayer) and (AResultLayer is TigNormalLayer) then
  begin
    with TigNormalLayer(AResultLayer) do
    begin
      OnChange              := Self.AfterLayerPanelChanged;
      OnMaskApplied         := Self.AfterLayerMaskApplied;
      OnMaskDisabled        := Self.AfterLayerMaskDisabled;
      OnMaskEnabled         := Self.AfterLayerMaskEnabled;
      OnMaskThumbDblClick   := nil;
      OnLayerDisabled       := Self.OnLayerPanelDisabled;
      OnLayerEnabled        := Self.OnLayerPanelEnabled;
      OnLayerThumbDblClick  := Self.LayerThumbDblClick;
      OnPanelDblClick       := nil;
      OnProcessStageChanged := Self.AfterLayerProcessStageChanged;
      OnThumbnailUpdate     := Self.AfterLayerPanelChanged;
    end;
  end;
end;

procedure TfrmChild.AfterLayerMaskApplied(ASender: TObject);
begin
  FChannelManager.DeleteLayerMaskChannel;
          
  if Assigned(frmChannels) then
  begin
    frmChannels.ChannelViewer.Invalidate;
  end;
end;

procedure TfrmChild.AfterLayerMaskEnabled(ASender: TObject);
begin
  if Assigned(frmLayers) then
  begin
    frmLayers.LayerPanelManager.Invalidate;
  end;

  FChannelManager.CreateLayerMaskChannel(
    FLayerList.SelectedLayer.MaskBitmap,
    FLayerList.SelectedLayer.LayerName + ' Mask');

  if Assigned(FChannelManager.LayerMaskChannel) then
  begin
    FChannelManager.SelectLayerMaskChannel;
  end;
      
  if Assigned(frmChannels) then
  begin
    frmChannels.ChannelViewer.Invalidate;
  end;
end;

procedure TfrmChild.AfterLayerMaskDisabled(ASender: TObject);
begin
  if Assigned(frmLayers) then
  begin
    frmLayers.LayerPanelManager.Invalidate;
  end;

  FChannelManager.DeleteLayerMaskChannel;
          
  if Assigned(frmChannels) then
  begin
    frmChannels.ChannelViewer.Invalidate;
  end;
end;

procedure TfrmChild.AfterLayerProcessStageChanged(ASender: TObject;
  const AStage: TigLayerProcessStage);
begin
  case AStage of
    lpsLayer:
      begin
        FChannelManager.SelectColorChannel(0, True);
      end;

    lpsMask:
      begin
        FChannelManager.SelectLayerMaskChannel;
      end;
  end;

  if Assigned(frmLayers) then
  begin
    frmLayers.LayerPanelManager.Invalidate;
  end;

  if Assigned(frmChannels) then
  begin
    frmChannels.ChannelViewer.Invalidate;
  end;
end;

procedure TfrmChild.OnLayerPanelEnabled(ASender: TObject);
begin
  case FLayerList.SelectedLayer.LayerProcessStage of
    lpsLayer:
      begin
        FChannelManager.SelectColorChannel(0, False);
      end;

    lpsMask:
      begin
        FChannelManager.SelectLayerMaskChannel;
      end;
  end;

  if Assigned(frmLayers) then
  begin
    frmLayers.LayerPanelManager.Invalidate;
  end;
end;

procedure TfrmChild.OnLayerPanelDisabled(ASender: TObject);
begin
  if Assigned(frmLayers) then
  begin
    frmLayers.LayerPanelManager.Invalidate;
  end;
end;

procedure TfrmChild.BCLogoThumbDblClick(ASender: TObject);
var
  LOldBright   : Integer;
  LOldContrast : Integer;
  LBCLayer     : TigBrightContrastLayer;
  LModalResult : TModalResult;
begin
  if ASender is TigBrightContrastLayer then
  begin
    LBCLayer := TigBrightContrastLayer(ASender);

    LOldBright   := LBCLayer.BrightAmount;
    LOldContrast := LBCLayer.ContrastAmount;

    frmLayerBrightContrast := TfrmLayerBrightContrast.Create(nil);
    try
      frmLayerBrightContrast.AssociateToBCLayer(LBCLayer);

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
          LBCLayer.BrightAmount   := LOldBright;
          LBCLayer.ContrastAmount := LOldContrast;
        end;
    end;

    LBCLayer.Changed;
  end;
end;

procedure TfrmChild.ImageViewerScaleChange(ASender: TObject);
begin
  // Update the background checkerboard pattern first.
  // Note that, we divide the size of checkerboard pattern by the
  // scale of the image viewer. This way, no matter how the scale was,
  // the displayed checkerboard's cells on the background will be remained
  // to a fixed size.
  DrawCheckerboardPattern( gActiveChildForm.CheckerboardBmp,
    Round(DEFAULT_CHECKERBOARD_SIZE / gActiveChildForm.imgWorkArea.Scale) );

  // We must invoke the Changed() of the selected layer to actually
  // refresh the view.
  gActiveChildForm.LayerList.SelectedLayer.Changed;
end;

// for testing ...
procedure TfrmChild.LayerThumbDblClick(ASender: TObject);
var
  LColor : TColor32; 
begin
  if ASender is TigNormalLayer then
  begin
    Randomize;
    LColor := $FF000000 or Cardinal( Random($FFFFFF) );

    with TigNormalLayer(ASender) do
    begin
      LayerBitmap.Clear(LColor);
      Changed;

      UpdateLayerThumbnail;
    end;
  end;
end;

procedure TfrmChild.OnAlphaChannelDelete(ASender: TObject);
begin
  FChannelManager.SelectColorChannel(0, True);
end;

procedure TfrmChild.OnChannelVisibleChange(const AChannelType: TigChannelType);
begin
//  case AChannelType of
//    ctColorChannel:
//      begin
        if Assigned(FLayerList) then
        begin
          // rendering the checkerboard pattern as background first
          imgWorkArea.Bitmap.Draw(imgWorkArea.Bitmap.BoundsRect,
                                  FCheckerboardBmp.BoundsRect,
                                  FCheckerboardBmp);

          // here, we don't draw layer combined result onto the background,
          // instead, we tweak the combined result with color channel settings,
          // and then merge the new result with the background ...
          FChannelManager.BlendByColorChannelSettings(
            FLayerList.CombineResult, imgWorkArea.Bitmap,
            imgWorkArea.Bitmap.BoundsRect);

          imgWorkArea.Bitmap.Changed(imgWorkArea.Bitmap.BoundsRect);
        end;
//      end;
//  end;

  if Assigned(frmChannels) then
  begin
    frmChannels.ChannelViewer.Invalidate;
  end;
end;

procedure TfrmChild.OnChannelDblClick(AChannel: TigCustomChannel;
  const AChannelType: TigChannelType);
var
  LChannel : TigAlphaChannel;
begin
  if Assigned(AChannel) then
  begin
    case AChannelType of
      ctAlphaChannel,
      ctLayerMaskChannel,
      ctQuickMaskChannel:
        begin
          LChannel := TigAlphaChannel(AChannel);

          frmChannelOptions := TfrmChannelOptions.Create(Application);
          try
            frmChannelOptions.FormSetup(LChannel, AChannelType);

            if frmChannelOptions.ShowModal = mrOK then
            begin
              LChannel.ChannelName        := frmChannelOptions.edtChannelName.Text;
              LChannel.MaskColor          := Color32(frmChannelOptions.shpMaskColor.Brush.Color);
              LChannel.MaskColorIndicator := TigMaskColorIndicator(frmChannelOptions.rdgrpColorIndicator.ItemIndex);
              LChannel.MaskOpacity        := Round( StrToInt(frmChannelOptions.edtMaskOpacity.Text) * 255 / 100 );

              LChannel.ChannelLayer.Changed;

              FChannelManager.DefaultMaskColor := LChannel.MaskColor;
            end;
          finally
            FreeAndNil(frmChannelOptions);
          end;
        end;
    end;
  end;
end;

procedure TfrmChild.OnChannelThumbnailUpdate(ASender: TObject);
begin
  if Assigned(frmChannels) then
  begin
    frmChannels.ChannelViewer.Invalidate;
  end;
end;

procedure TfrmChild.OnInsertAlphaChannel(AList: TigAlphaChannelList;
  const AIndex: Integer);
begin
  FChannelManager.SelectAlphaChannel(AIndex, False);
end;

procedure TfrmChild.OnLayerMaskChannelDelete(ASender: TObject);
begin
  FChannelManager.SelectColorChannel(0, True);
end;

procedure TfrmChild.OnQuickMaskChannelCreate(ASender: TObject);
begin
  if Assigned(FChannelManager.QuickMaskChannel) then
  begin
    FChannelManager.SelectQuickMaskChannel;
  end;
end;

procedure TfrmChild.OnQuickMaskChannelDelete(ASender: TObject);
begin
  FChannelManager.SelectColorChannel(0, True);

  if Assigned(frmChannels) then
  begin
    frmChannels.spdbtnStandardMode.Down  := True;
    frmChannels.spdbtnQuickMaskMode.Down := False;
  end;
end;

procedure TfrmChild.OnSelectedChannelChanged(
  const ACurrentChannelType: TigChannelType);
begin
  case ACurrentChannelType of
    ctColorChannel:
      begin
        if Assigned(FLayerList) then
        begin
          // rendering the checkerboard pattern as background first
          imgWorkArea.Bitmap.Draw(imgWorkArea.Bitmap.BoundsRect,
                                  imgWorkArea.Bitmap.BoundsRect,
                                  FCheckerboardBmp);

          // here, we don't draw layer combined result onto the background,
          // instead, we tweak the combined result with color channel settings,
          // and then merge the new result with the background ...
          FChannelManager.BlendByColorChannelSettings(FLayerList.CombineResult,
                                                      imgWorkArea.Bitmap,
                                                      imgWorkArea.Bitmap.BoundsRect);

          imgWorkArea.Bitmap.Changed(imgWorkArea.Bitmap.BoundsRect);

          FLayerList.SelectedLayer.LayerProcessStage := lpsLayer;
          FLayerList.SelectedLayer.IsLayerEnabled    := True;
        end;
      end;

    ctLayerMaskChannel:
      begin
        FLayerList.SelectedLayer.LayerProcessStage := lpsMask;
        FLayerList.SelectedLayer.IsLayerEnabled    := True;
      end;

    ctAlphaChannel,
    ctQuickMaskChannel:
      begin
        FLayerList.SelectedLayer.IsLayerEnabled := False;
      end;
  end;

  if Assigned(frmChannels) then
  begin
    // If we need to scroll the selected channel panel in to the
    // viewport of the channel viewer, the functioin
    // ScrollSelectedChannelPanelInViewport() will help us refresh the
    // viewer. If no need to scroll, we have to refresh the viewer
    // by ourselves.
    if not frmChannels.ChannelViewer.ScrollSelectedChannelPanelInViewport then
    begin
      frmChannels.ChannelViewer.Invalidate;
    end;
  end;
end;

function TfrmChild.CreateNormalLayer(
  const ABackColor: TColor32 = $00000000;
  const AsBackLayer: Boolean = False): TigCustomLayer;
begin
  Result := TigNormalLayer.Create(FLayerList,
    imgWorkArea.Bitmap.Width, imgWorkArea.Bitmap.Height,
    ABackColor, AsBackLayer);

  with TigNormalLayer(Result) do
  begin
    OnChange              := Self.AfterLayerPanelChanged;
    OnThumbnailUpdate     := Self.AfterLayerPanelChanged;
    OnMaskApplied         := Self.AfterLayerMaskApplied;
    OnMaskEnabled         := Self.AfterLayerMaskEnabled;
    OnMaskDisabled        := Self.AfterLayerMaskDisabled;
    OnLayerThumbDblClick  := Self.LayerThumbDblClick;
    OnLayerDisabled       := Self.OnLayerPanelDisabled;
    OnLayerEnabled        := Self.OnLayerPanelEnabled;
    OnProcessStageChanged := Self.AfterLayerProcessStageChanged;
  end;
end;

function TfrmChild.CreateBrightContrastLayer(const ABrightAmount: Integer = 0;
  const AContrastAmount: Integer = 0): TigCustomLayer;
var
  LBCLayer : TigBrightContrastLayer;
begin
  LBCLayer := TigBrightContrastLayer.Create(FLayerList,
    imgWorkArea.Bitmap.Width, imgWorkArea.Bitmap.Height);

  with LBCLayer do
  begin
    BrightAmount        := ABrightAmount;
    ContrastAmount      := AContrastAmount;
    OnChange            := Self.AfterLayerPanelChanged;
    OnThumbnailUpdate   := Self.AfterLayerPanelChanged;
    OnLayerDisabled     := Self.OnLayerPanelDisabled;
    OnLayerEnabled      := Self.OnLayerPanelEnabled;
    OnMaskEnabled       := Self.AfterLayerMaskEnabled;
    OnMaskDisabled      := Self.AfterLayerMaskDisabled;
    OnLogoThumbDblClick := Self.BCLogoThumbDblClick;
  end;

  Result := LBCLayer;
end;

procedure TfrmChild.DeleteCurrentLayer;
var
  LLayerName : string;
begin
  if FLayerList.Count > 1 then
  begin
    LLayerName := '"' + FLayerList.SelectedLayer.LayerName + '"';

    if MessageDlg('Delete the layer ' + LLayerName + '?',
                  mtConfirmation, [mbOK, mbCancel], 0) = mrOK then
    begin
      // delete the layer
      FLayerList.DeleteSelectedLayer();
      LayerList.SelectedLayer.Changed();
    end;
  end;
end;

procedure TfrmChild.SetCallbacksForLayersInList;
var
  i      : Integer;
  LLayer : TigCustomLayer;
begin
  if FLayerList.Count > 0 then
  begin
    for i := 0 to (FLayerList.Count - 1) do
    begin
      LLayer := FLayerList.Layers[i];

      with LLayer do
      begin
        OnChange            := Self.AfterLayerPanelChanged;
        OnLayerDisabled     := Self.OnLayerPanelDisabled;
        OnLayerEnabled      := Self.OnLayerPanelEnabled;
        OnMaskEnabled       := Self.AfterLayerMaskEnabled;
        OnMaskDisabled      := Self.AfterLayerMaskDisabled;
        OnPanelDblClick     := nil;
        OnMaskThumbDblClick := nil;
      
        if LLayer is TigNormalLayer then
        begin
          OnThumbnailUpdate     := Self.AfterLayerPanelChanged;
          OnLayerThumbDblClick  := Self.LayerThumbDblClick;
          OnProcessStageChanged := Self.AfterLayerProcessStageChanged;
          
          TigNormalLayer(LLayer).OnMaskApplied := Self.AfterLayerMaskApplied;
        end
        else if LLayer is TigBrightContrastLayer then
        begin
          OnLogoThumbDblClick := Self.BCLogoThumbDblClick;
        end;
      end;
    end;
  end;
end;

procedure TfrmChild.FormCreate(Sender: TObject);
var
  LBmp : TBitmap32;
begin
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
  imgWorkArea.OnScaleChange   := Self.ImageViewerScaleChange;

  FLayerList := TigLayerList.Create;
  with FLayerList do
  begin
    OnLayerCombined      := Self.AfterLayerCombined;
    OnSelectionChanged   := Self.AfterSelectedLayerPanelChanged;
    OnLayerOrderChanged  := Self.AfterLayerPanelChanged;
    OnMergeVisibleLayers := Self.AfterLayerMerged;
    OnFlattenLayers      := Self.AfterLayerMerged;
  end;

  FChannelManager := TigRGBChannelManager.Create;
  with FChannelManager do
  begin
    Layers                   := imgWorkArea.Layers;
    OnAlphaChannelDelete     := Self.OnAlphaChannelDelete;
    OnChannelDblClick        := Self.OnChannelDblClick;
    OnChannelVisibleChanged  := Self.OnChannelVisibleChange;
    OnChannelThumbnailUpdate := Self.OnChannelThumbnailUpdate;
    OnInsertAlphaChannel     := Self.OnInsertAlphaChannel;
    OnLayerMaskChannelDelete := Self.OnLayerMaskChannelDelete;
    OnQuickMaskChannelCreate := Self.OnQuickMaskChannelCreate;
    OnQuickMaskChannelDelete := Self.OnQuickMaskChannelDelete;
    OnSelectedChannelChanged := Self.OnSelectedChannelChanged;
  end;

  FLeftButtonDown := False;

  FCheckerboardBmp := TBitmap32.Create;

  FBrushTool := TigPaintBrush.Create;
  FBrushTool.OnBrushPaintEvent := AfterBrushPaint;

  LBmp := TBitmap32.Create;
  try
    LBmp.SetSize(50, 50);
    LBmp.Clear(clBlack32);
  
    MyFeatheredCircle(LBmp, LBmp.Width div 2 - 1, LBmp.Height div 2 - 1, 20, 12, 255);
    InvertBitamp(LBmp);
    FBrushTool.SetPaintingStroke(LBmp);
  finally
    LBmp.Free;
  end;
end;

procedure TfrmChild.FormDestroy(Sender: TObject);
begin
  FBrushTool.Free;
  FLayerList.Free;
  FChannelManager.Free;
  FCheckerboardBmp.Free;
end;

procedure TfrmChild.FormActivate(Sender: TObject);
begin
  gActiveChildForm := Self;

  frmLayers.LayerPanelManager.LayerList := FLayerList;

  if Assigned(FLayerList.SelectedLayer) then
  begin
    frmLayers.cmbbxBlendModes.ItemIndex := Ord(FLayerList.SelectedLayer.LayerBlendMode);
    frmLayers.ggbrLayerOpacity.Position := MulDiv(FLayerList.SelectedLayer.LayerOpacity, 100, 255);
  end;

  // link channel manager to channel manager viewer
  frmChannels.ChannelViewer.ChannelManager := FChannelManager;
  frmChannels.spdbtnStandardMode.Enabled   := True;
  frmChannels.spdbtnStandardMode.Down      := not Assigned(FChannelManager.QuickMaskChannel);
  frmChannels.spdbtnQuickMaskMode.Enabled  := True;
  frmChannels.spdbtnQuickMaskMode.Down     := Assigned(FChannelManager.QuickMaskChannel);
end;

procedure TfrmChild.FormShow(Sender: TObject);
begin
  frmLayers.LayerPanelManager.LayerList := FLayerList;
end;

procedure TfrmChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmLayers.LayerPanelManager.LayerList    := nil;
  frmChannels.ChannelViewer.ChannelManager := nil;
  frmChannels.spdbtnStandardMode.Enabled   := False;
  frmChannels.spdbtnStandardMode.Down      := True;
  frmChannels.spdbtnQuickMaskMode.Enabled  := False;
  frmChannels.spdbtnQuickMaskMode.Down     := False;

  gActiveChildForm := nil;
  Action           := caFree;  // close the child form
end;

procedure TfrmChild.imgWorkAreaPaintStage(Sender: TObject;
  Buffer: TBitmap32; StageNum: Cardinal);
var
  LRect : TRect;
begin
  Buffer.Clear($FFC0C0C0);

  LRect := imgWorkArea.GetBitmapRect;

  LRect.Left   := LRect.Left   - 1;
  LRect.Top    := LRect.Top    - 1;
  LRect.Right  := LRect.Right  + 1;
  LRect.Bottom := LRect.Bottom + 1;

  // draw thin border, learned from Andre Felix Miertschink
  Buffer.FrameRectS(LRect, clBlack32);
end;

procedure TfrmChild.imgWorkAreaMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  LPoint : TPoint;
begin
  LPoint := imgWorkArea.ControlToBitmap( Point(X, Y) );

  case FChannelManager.CurrentChannelType of
    ctColorChannel:
      begin
        TigPaintBrush(FBrushTool).Color := clRed32;

        if FLayerList.SelectedLayer is TigNormalLayer then
        begin
          FBrushTool.MouseDown(imgWorkArea, Button, Shift, LPoint.X, LPoint.Y,
            FLayerList.SelectedLayer.LayerBitmap);
        end;
      end;

    ctLayerMaskChannel:
      begin
        TigPaintBrush(FBrushTool).Color := clGray32;

        FBrushTool.MouseDown(imgWorkArea, Button, Shift, LPoint.X, LPoint.Y,
          FLayerList.SelectedLayer.MaskBitmap);
      end;

    ctAlphaChannel:
      begin
        TigPaintBrush(FBrushTool).Color := clGray32;

        FBrushTool.MouseDown(imgWorkArea, Button, Shift, LPoint.X, LPoint.Y,
          FChannelManager.SelectedAlphaChannel.ChannelLayer.Bitmap);
      end;

    ctQuickMaskChannel:
      begin
        TigPaintBrush(FBrushTool).Color := clGray32;

        FBrushTool.MouseDown(imgWorkArea, Button, Shift, LPoint.X, LPoint.Y,
          FChannelManager.QuickMaskChannel.ChannelLayer.Bitmap);
      end;
  end;
end;

procedure TfrmChild.imgWorkAreaMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
var
  LPoint : TPoint;
begin
  LPoint := imgWorkArea.ControlToBitmap( Point(X, Y) );

  case FChannelManager.CurrentChannelType of
    ctColorChannel:
      begin
        if FLayerList.SelectedLayer is TigNormalLayer then
        begin
          FBrushTool.MouseMove(imgWorkArea, Shift, LPoint.X, LPoint.Y,
            FLayerList.SelectedLayer.LayerBitmap);
        end;
      end;

    ctLayerMaskChannel:
      begin
        FBrushTool.MouseMove(imgWorkArea, Shift, LPoint.X, LPoint.Y,
          FLayerList.SelectedLayer.MaskBitmap);
      end;

    ctAlphaChannel:
      begin
        FBrushTool.MouseMove(imgWorkArea, Shift, LPoint.X, LPoint.Y,
          FChannelManager.SelectedAlphaChannel.ChannelLayer.Bitmap);
      end;

    ctQuickMaskChannel:
      begin
        FBrushTool.MouseMove(imgWorkArea, Shift, LPoint.X, LPoint.Y,
          FChannelManager.QuickMaskChannel.ChannelLayer.Bitmap);
      end;
  end;
end;

procedure TfrmChild.imgWorkAreaMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  LPoint : TPoint;
begin
  LPoint := imgWorkArea.ControlToBitmap( Point(X, Y) );

  case FChannelManager.CurrentChannelType of
    ctColorChannel:
      begin
        if FLayerList.SelectedLayer is TigNormalLayer then
        begin
          FBrushTool.MouseUp(imgWorkArea, Button, Shift, LPoint.X, LPoint.Y,
            FLayerList.SelectedLayer.LayerBitmap);

          FLayerList.SelectedLayer.UpdateLayerThumbnail;
          FChannelManager.UpdateColorChannelThumbnails(FLayerList.CombineResult);
        end;
      end;

    ctLayerMaskChannel:
      begin
        FBrushTool.MouseUp(imgWorkArea, Button, Shift, LPoint.X, LPoint.Y,
          FLayerList.SelectedLayer.MaskBitmap);

        FLayerList.SelectedLayer.UpdateMaskThumbnail;
        FChannelManager.UpdateColorChannelThumbnails(FLayerList.CombineResult);
        FChannelManager.LayerMaskChannel.UpdateChannelThumbnail;
      end;

    ctAlphaChannel:
      begin
        FBrushTool.MouseUp(imgWorkArea, Button, Shift, LPoint.X, LPoint.Y,
          FChannelManager.SelectedAlphaChannel.ChannelLayer.Bitmap);

        FChannelManager.SelectedAlphaChannel.UpdateChannelThumbnail;
      end;

    ctQuickMaskChannel:
      begin
        FBrushTool.MouseUp(imgWorkArea, Button, Shift, LPoint.X, LPoint.Y,
          FChannelManager.QuickMaskChannel.ChannelLayer.Bitmap);

        FChannelManager.QuickMaskChannel.UpdateChannelThumbnail;
      end;
  end;

  // need to refresh the whole work area ...
  FLayerList.SelectedLayer.Changed;
end;

end.

