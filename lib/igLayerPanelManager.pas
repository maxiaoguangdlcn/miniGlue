unit igLayerPanelManager;

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
  Types, Windows, Controls, Classes,
{ Graphics32 }
  GR32, GR32_Image, GR32_RangeBars,
{ miniGlue lib }
  igLayers;

type
  TigSelectedPanelArea = (spaUnknown,
                          spaVisibleMark,
                          spaStageMark,
                          spaLayerThumbnail,
                          spaMaskLinkageMark,
                          spaMaskThumbnail,
                          spaLayerCaption);

  { TigLayerPanelCustomTheme }

  TigLayerPanelCustomTheme = class(TObject)
  private
    procedure SetObjectSpan(AValue: Integer);
  protected
    FObjectSpan : Integer;

    function GetLayerVisibleIconRect(const APanelRect: TRect): TRect; virtual; abstract;

    function GetPanelAreaAtXY(APanel: TigCustomLayerPanel;
      const APanelRect: TRect; const AX, AY: Integer): TigSelectedPanelArea; virtual; abstract;
  public
    constructor Create;

    procedure Paint(ABuffer: TBitmap32; APanel: TigCustomLayerPanel;
      const ARect: TRect); virtual; abstract;

    function GetSnapshot(APanel: TigCustomLayerPanel;
      const AWidth, AHeight: Integer): TBitmap32; virtual; abstract;

    property ObjectSpan : Integer read FObjectSpan write SetObjectSpan;
  end;

  { TigLayerPanelStdTheme }

  TigLayerPanelStdTheme = class(TigLayerPanelCustomTheme)
  private
    FLayerVisibleIcon : TBitmap32;
    FLayerStageIcon   : TBitmap32;
    FMaskStageIcon    : TBitmap32;
    FMaskLinkedIcon   : TBitmap32;
    FMaskUnlinkedIcon : TBitmap32;
    FSpanColor        : TColor32;
    FSelectedColor    : TColor32;
    FDeselectedColor  : TColor32;
  protected
    function GetLayerVisibleIconRect(const APanelRect: TRect): TRect; override;

    function GetPanelAreaAtXY(APanel: TigCustomLayerPanel;
      const APanelRect: TRect; const AX, AY: Integer): TigSelectedPanelArea; override;

    procedure DrawLayerVisibleIcon(ABuffer: TBitmap32; const ARect: TRect; const AVisible: Boolean);
    procedure DrawProcessStageIcon(ABuffer: TBitmap32; const ARect: TRect; const AStage: TigLayerProcessStage);
    procedure DrawMaskLinkIcon(ABuffer: TBitmap32; const ARect: TRect; const ALinked: Boolean);
    procedure DrawPanelBorder(ABuffer: TBitmap32; const ARect: TRect);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Paint(ABuffer: TBitmap32; APanel: TigCustomLayerPanel;
      const ARect: TRect); override;

    function GetSnapshot(APanel: TigCustomLayerPanel;
      const AWidth, AHeight: Integer): TBitmap32; override;
  end;

  { TigLayerPanelManager }

  TigScrollPanelThread = class; // forward declaration
  
  TigLayerPanelManager = class(TCustomPaintBox32)
  private
    FScrollLocked   : Boolean;                 // lock execution of the scroll bars
    FVertScroll     : TRangeBar;
    FPanelTheme     : TigLayerPanelCustomTheme;
    FPanelList      : TigLayerPanelList;
    FViewportOffset : TPoint;                  // offset of the viewport
    FWorkSize       : TPoint;                  // maximum scrollable area
    FLeftButtonDown : Boolean;                 // if mouse left button is pressed
    FWheelDelta     : Integer;

    // for render snapshot of a moving panel by mouse move
    FMouseX, FMouseY  : Integer;
    FLastX, FLastY    : Integer;
    FMouseDownX       : Integer;
    FMouseDownY       : Integer;
    FSnapshotOffsetY  : Integer;
    FMovingPanelIndex : Integer;
    FIsPanelMoving    : Boolean;
    FSnapshotTopLeft  : TPoint;
    FPanelSnapshot    : TBitmap32;
    FScrollThread     : TigScrollPanelThread;


    procedure SetPanelList(const AValue: TigLayerPanelList);
    procedure ScrollThreadStop;

    function GetPanelRect(const APanelIndex: Integer): TRect;
    function GetPanelIndexAtXY(AX, AY: Integer): Integer;
    function CanScrollDown: Boolean;
    function CanScrollUp: Boolean;
    function IsRectInViewport(const ARect: TRect): Boolean; // dertermine if any part of a rect is in the viewport

    // callbacks
    procedure ScrollHandler(Sender: TObject);
  protected
    procedure PreparePanelSnapshotRendering(const AMouseX, AMouseY: Integer); virtual;
    procedure CheckLayout; virtual;
    procedure Scroll(Dy: Integer); virtual;
    procedure DoPaintBuffer; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;

    function ScrollPanelInViewport(const APanelIndex: Integer): Boolean; virtual;
    function ScrollSelectedPanelInViewport: Boolean;
    function GetPanelSnapshot(const APanelIndex: Integer): TBitmap32;
    function GetSelectedPanelSnapshot: TBitmap32;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Resize; override;

    property PanelList : TigLayerPanelList read FPanelList write SetPanelList;
  published
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

  { TigScrollPanelThread }

  TigScrollPanelThread = class(TThread)
  private
    FPanelManager : TigLayerPanelManager;
  protected
    procedure Execute; override;
  public
    constructor Create(APanelManager: TigLayerPanelManager);
  end;

implementation

uses
{ Delphi }
  SysUtils, Graphics, Forms, Math,
{ Graphics32 }
  GR32_LowLevel,
{ miniGlue lib }
  igMath;

{$R igIcons.res}

const
  MIN_OBJECT_SPAN    = 2;
  MAX_OBJECT_SPAN    = 20;
  LAYER_PANEL_HEIGHT = 40;

{ TigLayerPanelCustomTheme }

constructor TigLayerPanelCustomTheme.Create;
begin
  inherited;

  FObjectSpan := 5;
end;

procedure TigLayerPanelCustomTheme.SetObjectSpan(AValue: Integer);
begin
  FObjectSpan := Clamp(AValue, MIN_OBJECT_SPAN, MAX_OBJECT_SPAN);
end;

{ TigLayerPanelStdTheme }

constructor TigLayerPanelStdTheme.Create;
begin
  inherited;

  FLayerVisibleIcon := TBitmap32.Create;
  FLayerVisibleIcon.LoadFromResourceName(HInstance, 'EYEOPEN');

  FLayerStageIcon := TBitmap32.Create;
  FLayerStageIcon.LoadFromResourceName(HInstance, 'ONLAYER');
  
  FMaskStageIcon := TBitmap32.Create;
  FMaskStageIcon.LoadFromResourceName(HInstance, 'ONMASK');

  FMaskLinkedIcon   := TBitmap32.Create;
  FMaskLinkedIcon.LoadFromResourceName(HInstance, 'MASKLINKED');

  FMaskUnlinkedIcon := TBitmap32.Create;
  FMaskUnlinkedIcon.LoadFromResourceName(HInstance, 'MASKUNLINKED');

  FSpanColor       := clSilver32;
  FSelectedColor   := Color32(clHighlight);
  FDeselectedColor := Color32(clBtnFace);
end;

destructor TigLayerPanelStdTheme.Destroy;
begin
  FMaskLinkedIcon.Free;
  FMaskUnlinkedIcon.Free;
  FMaskStageIcon.Free;
  FLayerStageIcon.Free;
  FLayerVisibleIcon.Free;

  inherited;
end;

// calculate an area from ARect for drawing EYE icon
function TigLayerPanelStdTheme.GetLayerVisibleIconRect(
  const APanelRect: TRect): TRect;
begin
  Result.TopLeft := APanelRect.TopLeft;
  Result.Right   := APanelRect.Left + FLayerVisibleIcon.Width + FObjectSpan;
  Result.Bottom  := APanelRect.Bottom;
end;

function TigLayerPanelStdTheme.GetPanelAreaAtXY(APanel: TigCustomLayerPanel;
  const APanelRect: TRect; const AX, AY: Integer): TigSelectedPanelArea;
var
  LRect      : TRect;
  LSize      : TSize;
  LTestPoint : TPoint;
  LBmp       : TBitmap32;
  LSpan2     : Integer;
begin
  Result     := spaUnknown;
  LTestPoint := Point(AX, AY);
  LSize      := igMath.GetRectSize(APanelRect);
  LSpan2     := FObjectSpan * 2;
  LBmp       := nil;

  // if point on layer visible mark ...

  LRect := GetLayerVisibleIconRect(APanelRect);

  if Windows.PtInRect(LRect, LTestPoint) then
  begin
    Result := spaVisibleMark;
    Exit;
  end;

  // if point on stage mark ...

  case APanel.LayerProcessStage of
    lpsLayer:
      begin
        LBmp := FLayerStageIcon;
      end;

    lpsMask:
      begin
        LBmp := FMaskStageIcon;
      end;
  end;

  LRect.Left  := LRect.Right + 1;
  LRect.Right := LRect.Left + LBmp.Width + FObjectSpan - 1;
  
  if Windows.PtInRect(LRect, LTestPoint) then
  begin
    Result := spaStageMark;
    Exit;
  end;

  // if point on layer thumbnail ...

  LRect.Left  := LRect.Right + 1;
  LRect.Right := LRect.Left + APanel.LayerThumbnail.Width + LSpan2 - 1;

  if Windows.PtInRect(LRect, LTestPoint) then
  begin
    Result := spaLayerThumbnail;
    Exit;
  end;

  // if mask enabled ...

  if APanel.IsMaskEnabled then
  begin
    // if point on Mask-Link mark ...

    if APanel.IsMaskLinked then
    begin
      LBmp := FMaskLinkedIcon;
    end
    else
    begin
      LBmp := FMaskUnlinkedIcon;
    end;

    LRect.Left  := LRect.Right + 1;
    LRect.Right := LRect.Left + LBmp.Width + FObjectSpan - 1;

    if Windows.PtInRect(LRect, LTestPoint) then
    begin
      Result := spaMaskLinkageMark;
      Exit;
    end;

    // if point on Mask thumbnail ...

    LRect.Left  := LRect.Right + 1;
    LRect.Right := LRect.Left + APanel.MaskThumbnail.Width + LSpan2 - 1;

    if Windows.PtInRect(LRect, LTestPoint) then
    begin
      Result := spaMaskThumbnail;
      Exit;
    end;
  end;

  // if point on caption area ...

  LRect.Left   := LRect.Right + 1;
  LRect.Right  := APanelRect.Right;

  if Windows.PtInRect(LRect, LTestPoint) then
  begin
    Result := spaLayerCaption;
  end;
end;

procedure TigLayerPanelStdTheme.DrawLayerVisibleIcon(ABuffer: TBitmap32;
  const ARect: TRect; const AVisible: Boolean);
var
  LRectSize : TSize;
  LIconRect : TRect;
begin
  LRectSize := igMath.GetRectSize(ARect);

  LIconRect.Left   := ARect.Left + (LRectSize.cx - FLayerVisibleIcon.Width) div 2;
  LIconRect.Top    := ARect.Top  + (LRectSize.cy - FLayerVisibleIcon.Height) div 2;
  LIconRect.Right  := LIconRect.Left + FLayerVisibleIcon.Width;
  LIconRect.Bottom := LIconRect.Top  + FLayerVisibleIcon.Height;

  if AVisible then
  begin
    ABuffer.Draw(LIconRect, FLayerVisibleIcon.BoundsRect, FLayerVisibleIcon);
  end;
  
  ABuffer.FrameRectS(LIconRect, clGray32);
end;

procedure TigLayerPanelStdTheme.DrawProcessStageIcon(ABuffer: TBitmap32;
  const ARect: TRect; const AStage: TigLayerProcessStage);
var
  LRectSize : TSize;
  LIconRect : TRect;
  LBmp      : TBitmap32;
begin
  LRectSize := igMath.GetRectSize(ARect);
  LBmp      := nil;

  case AStage of
    lpsLayer:
      begin
        LBmp := FLayerStageIcon;
      end;

    lpsMask:
      begin
        LBmp := FMaskStageIcon;
      end;
  end;

  LIconRect.Left   := ARect.Left + (LRectSize.cx - LBmp.Width) div 2;
  LIconRect.Top    := ARect.Top + (LRectSize.cy - LBmp.Height) div 2;
  LIconRect.Right  := LIconRect.Left + LBmp.Width;
  LIconRect.Bottom := LIconRect.Top  + LBmp.Height;

  ABuffer.Draw(LIconRect, LBmp.BoundsRect, LBmp);
  ABuffer.FrameRectS(LIconRect, clGray32);
end;

procedure TigLayerPanelStdTheme.DrawMaskLinkIcon(ABuffer: TBitmap32;
  const ARect: TRect; const ALinked: Boolean);
var
  LRectSize : TSize;
  LIconRect : TRect;
  LBmp      : TBitmap32;
begin
  LRectSize := igMath.GetRectSize(ARect);

  if ALinked then
  begin
    LBmp := FMaskLinkedIcon;
  end
  else
  begin
    LBmp := FMaskUnlinkedIcon;
  end;

  LIconRect.Left   := ARect.Left + (LRectSize.cx - LBmp.Width) div 2;
  LIconRect.Top    := ARect.Top + (LRectSize.cy - LBmp.Height) div 2;
  LIconRect.Right  := LIconRect.Left + LBmp.Width;
  LIconRect.Bottom := LIconRect.Top  + LBmp.Height;

  ABuffer.Draw(LIconRect, LBmp.BoundsRect, LBmp);
end;

procedure TigLayerPanelStdTheme.DrawPanelBorder(ABuffer: TBitmap32;
  const ARect: TRect);
begin
  ABuffer.LineS(ARect.Left, ARect.Top, ARect.Left, ARect.Bottom, clWhite32);
  ABuffer.LineS(ARect.Left, ARect.Top, ARect.Right, ARect.Top, clWhite32);
  ABuffer.LineS(ARect.Right, ARect.Top, ARect.Right, ARect.Bottom, clGray32);
  ABuffer.LineS(ARect.Left, ARect.Bottom, ARect.Right, ARect.Bottom, clGray32);
end;

procedure TigLayerPanelStdTheme.Paint(ABuffer: TBitmap32;
  APanel: TigCustomLayerPanel; const ARect: TRect);
var
  LRect         : TRect;
  LSize         : TSize;
  LBmp          : TBitmap32;
  LCaptionColor : TColor32;
begin
  LSize := igMath.GetRectSize(ARect);
  LBmp  := nil;

  ABuffer.BeginUpdate;
  try
    // draw layer visible mark
    LRect := GetLayerVisibleIconRect(ARect);
    DrawLayerVisibleIcon(ABuffer, LRect, APanel.IsLayerVisible);
    ABuffer.LineS(LRect.Right, LRect.Top, LRect.Right, LRect.Bottom, FSpanColor);

    // draw process stage mark
    case APanel.LayerProcessStage of
      lpsLayer:
        begin
          LBmp := FLayerStageIcon;
        end;

      lpsMask:
        begin
          LBmp := FMaskStageIcon;
        end;
    end;

    LRect.Left  := LRect.Right;
    LRect.Right := LRect.Left + LBmp.Width + FObjectSpan;
    DrawProcessStageIcon(ABuffer, LRect, APanel.LayerProcessStage);
    ABuffer.LineS(LRect.Right, LRect.Top, LRect.Right, LRect.Bottom, FSpanColor);

    // draw layer thumbnail
    LRect.Left   := LRect.Right + FObjectSpan;
    LRect.Top    := LRect.Top + (LSize.cy - APanel.LayerThumbnail.Height) div 2;
    LRect.Right  := LRect.Left + APanel.LayerThumbnail.Width;
    LRect.Bottom := LRect.Top + APanel.LayerThumbnail.Height;
    ABuffer.Draw(LRect.Left, LRect.Top, APanel.LayerThumbnail);

    LRect.Top    := ARect.Top;
    LRect.Right  := LRect.Right + FObjectSpan;
    LRect.Bottom := ARect.Bottom;
    ABuffer.LineS(LRect.Right, LRect.Top, LRect.Right, LRect.Bottom, FSpanColor);

    // draw Mask-Link mark
    if APanel.IsMaskEnabled then
    begin
      if APanel.IsMaskLinked then
      begin
        LBmp := FMaskLinkedIcon;
      end
      else
      begin
        LBmp := FMaskUnlinkedIcon;
      end;

      LRect.Left  := LRect.Right;
      LRect.Right := LRect.Left + LBmp.Width + FObjectSpan;
      DrawMaskLinkIcon(ABuffer, LRect, APanel.IsMaskLinked);
      ABuffer.LineS(LRect.Right, LRect.Top, LRect.Right, LRect.Bottom, FSpanColor);

      // draw Mask thumbnail
      LRect.Left   := LRect.Right + FObjectSpan;
      LRect.Top    := ARect.Top + (LSize.cy - APanel.MaskThumbnail.Height) div 2;
      LRect.Right  := LRect.Left + APanel.MaskThumbnail.Width;
      LRect.Bottom := ARect.Top + APanel.MaskThumbnail.Height;
      ABuffer.Draw(LRect.Left, LRect.Top, APanel.MaskThumbnail);

      LRect.Top    := ARect.Top;
      LRect.Right  := LRect.Right + FObjectSpan;
      LRect.Bottom := ARect.Bottom;
      ABuffer.LineS(LRect.Right, LRect.Top, LRect.Right, LRect.Bottom, FSpanColor);
    end;

    // fill background color for the panel
    LRect.Left   := LRect.Right + 1;
    LRect.Top    := ARect.Top;
    LRect.Right  := ARect.Right;
    LRect.Bottom := ARect.Bottom;

    if APanel.IsSelected then
    begin
      ABuffer.FillRectS(LRect, FSelectedColor);
      LCaptionColor := clWhite32;
    end
    else
    begin
      ABuffer.FillRectS(LRect, FDeselectedColor);
      LCaptionColor := clBlack32;
    end;

    // draw panel caption
    LRect.Left := LRect.Left + FObjectSpan;
    LRect.Top  := LRect.Top + ( LSize.cy - ABuffer.TextHeight(APanel.LayerName) ) div 2;

    ABuffer.RenderText(LRect.Left, LRect.Top, APanel.LayerName, 0, LCaptionColor);

    // draw panel border
    DrawPanelBorder(ABuffer, ARect);
  finally
    ABuffer.EndUpdate;
  end;
end;

function TigLayerPanelStdTheme.GetSnapshot(APanel: TigCustomLayerPanel;
  const AWidth, AHeight: Integer): TBitmap32;
var
  LBackColor : TColor32;
begin
  Result := nil;

  if not Assigned(APanel) then
  begin
    Exit;
  end;

  if (AWidth <= 0) or (AHeight < LAYER_PANEL_HEIGHT) then
  begin
    Exit;
  end;

  LBackColor := Color32(clBtnFace);

  Result             := TBitmap32.Create;
  Result.DrawMode    := dmBlend;
  Result.CombineMode := cmMerge;
  
  Result.SetSize(AWidth, AHeight);
  Result.Clear(LBackColor);

  Self.Paint(Result, APanel, Result.BoundsRect);
  Result.FrameRectS(Result.BoundsRect, LBackColor); // clear border
end;

{ TigLayerManager }

constructor TigLayerPanelManager.Create(AOwner: TComponent);
begin
  inherited;

  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
                   csDoubleClicks, csReplicatable, csOpaque];
    
  Options := [pboAutoFocus, pboWantArrowKeys];
  TabStop := True; //to receive Tabkey and focusable as default 

  FScrollLocked   := False;
  FViewportOffset := Point(0, 0);
  FLeftButtonDown := False;
  FWheelDelta     := LAYER_PANEL_HEIGHT div 2;

  FPanelTheme := TigLayerPanelStdTheme.Create;

  FVertScroll := TRangeBar.Create(Self);
  with FVertScroll do
  begin
    Parent       := Self;
    BorderStyle  := bsNone;
    Kind         := sbVertical;
    Align        := alRight;
    Width        := GetSystemMetrics(SM_CYVSCROLL) div 2;
    OnUserChange := ScrollHandler;
  end;

  // for render snapshot of a moving panel by mouse move
  FPanelSnapshot := nil;
  FScrollThread  := nil;
  FIsPanelMoving := False;
end;

destructor TigLayerPanelManager.Destroy;
begin
  ScrollThreadStop;
  FPanelSnapshot.Free;
  FVertScroll.Free;
  FPanelTheme.Free;

  inherited;
end;

procedure TigLayerPanelManager.Resize;
var
  LHeight : Integer;
  LDelta  : Integer;
begin
  inherited;

  LHeight := FWorkSize.Y + Self.FViewportOffset.Y;

  if LHeight < Self.ClientHeight then
  begin
    LDelta := Self.ClientHeight - LHeight;

    Inc(FViewportOffset.Y, LDelta);

    if FViewportOffset.Y > 0 then
    begin
      FViewportOffset.Y := 0;
    end;

    FScrollLocked := True;
    try
      FVertScroll.Position := Abs(FViewportOffset.Y);
    finally
      FScrollLocked := False;
    end;
  end;
end;

procedure TigLayerPanelManager.SetPanelList(const AValue: TigLayerPanelList);
begin
  FPanelList := AValue;
  CheckLayout;
  
  // make the selected panel fully showing in the viewport ...
  FViewportOffset := Point(0, 0);
  ScrollSelectedPanelInViewport;
  
  Invalidate;
end;

procedure TigLayerPanelManager.ScrollThreadStop;
begin
  if Assigned(FScrollThread) then
  begin
    FScrollThread.Terminate;
    FScrollThread.WaitFor;
    FreeAndNil(FScrollThread);
  end;
end;

function TigLayerPanelManager.GetPanelRect(const APanelIndex: Integer): TRect;
begin
  Result.Left   := 0;
  Result.Top    := (FPanelList.MaxIndex - APanelIndex) * LAYER_PANEL_HEIGHT + FViewportOffset.Y;
  Result.Right  := Self.ClientWidth - 1;
  Result.Bottom := Result.Top + LAYER_PANEL_HEIGHT - 1;
end;

function TigLayerPanelManager.GetPanelIndexAtXY(AX, AY: Integer): Integer;
var
  LYActual: Integer;
begin
  Result := -1;

  if Assigned(FPanelList) and (FPanelList.Count > 0) then
  begin
    LYActual := AY + Abs(FViewportOffset.Y);

    if LYActual < FWorkSize.Y then
    begin
      Result := FPanelList.MaxIndex - LYActual div LAYER_PANEL_HEIGHT;
    end;
  end;
end;

function TigLayerPanelManager.CanScrollDown: Boolean;
begin
  Result := FViewportOffset.Y + FWorkSize.Y > Self.ClientHeight;
end;

function TigLayerPanelManager.CanScrollUp: Boolean;
begin
  Result := FViewportOffset.Y < 0;
end;

// dertermine if any part of a rect is in the viewport
function TigLayerPanelManager.IsRectInViewport(const ARect: TRect): Boolean;
begin
  Result := Windows.PtInRect(Self.ClientRect, ARect.TopLeft) or
            Windows.PtInRect(Self.ClientRect, ARect.BottomRight);
end;

procedure TigLayerPanelManager.ScrollHandler(Sender: TObject);
begin
  if Sender = FVertScroll then
  begin
    if not FScrollLocked then
    begin
      FViewportOffset.Y := 0 - Round(FVertScroll.Position);
      Invalidate;
    end;
  end;
end;

procedure TigLayerPanelManager.PreparePanelSnapshotRendering(
  const AMouseX, AMouseY: Integer);
var
  LPanelIndex : Integer;
  LPanelRect  : TRect;
  LPanel      : TigCustomLayerPanel;
begin
  FMovingPanelIndex := -1;

  if Assigned(FPanelList) and (FPanelList.Count > 0) then
  begin
    LPanelIndex := GetPanelIndexAtXY(AMouseX, AMouseY);
    LPanel      := FPanelList.LayerPanels[LPanelIndex];

    if Assigned(LPanel) then
    begin
      FMovingPanelIndex := LPanelIndex;
      LPanelRect        := Self.GetPanelRect(LPanelIndex);
      FSnapshotOffsetY  := LPanelRect.Top - AMouseY;

      if Assigned(FPanelSnapshot) then
      begin
        FreeAndNil(FPanelSnapshot);
      end;

      FPanelSnapshot := GetPanelSnapshot(LPanelIndex);
      FPanelSnapshot.MasterAlpha := $7F;
    end;
  end;
end;

procedure TigLayerPanelManager.CheckLayout;
begin
  if Assigned(FPanelList) then
  begin
    // update WorkSize
    FWorkSize         := Point(Self.ClientWidth, FPanelList.Count * LAYER_PANEL_HEIGHT);
    FVertScroll.Range := FWorkSize.Y;
  end;
end;

procedure TigLayerPanelManager.Scroll(Dy: Integer);
var
  LHeight : Integer;
begin
  FViewportOffset.Y := FViewportOffset.Y + Dy;

  // limit the scrolling amount
  LHeight := FViewportOffset.Y + FWorkSize.Y;
  if LHeight < Self.ClientHeight then
  begin
    Inc(FViewportOffset.Y, Self.ClientHeight - LHeight);
  end;

  if FViewportOffset.Y > 0 then
  begin
    FViewportOffset.Y := 0;
  end;

  // update scroll bar
  FScrollLocked := True;
  try
    FVertScroll.Position := Abs(FViewportOffset.Y);
  finally
    FScrollLocked := False;
  end;
end;

procedure TigLayerPanelManager.DoPaintBuffer;
var
  i, y, LMaxY : Integer;
  LLayerPanel : TigCustomLayerPanel;
  LRect       : TRect;
begin
  CheckLayout;
  Buffer.Clear( Color32(clBtnFace) );

  if Assigned(FPanelList) then
  begin
    if FPanelList.Count > 0 then
    begin
      for i := FPanelList.MaxIndex downto 0 do
      begin
        LLayerPanel := FPanelList.LayerPanels[i];
        LRect       := GetPanelRect(i);

        // only render the panel that in the viewport area...
        if IsRectInViewport(LRect) then
        begin
          FPanelTheme.Paint(Buffer, LLayerPanel, LRect);
        end;
      end;

      // render panel snapshot, if any ...
      if FIsPanelMoving then
      begin
        LMaxY := Min(FWorkSize.Y, Self.ClientHeight) - LAYER_PANEL_HEIGHT;
        y     := FMouseY + FSnapshotOffsetY;
        y     := Clamp(y, 0, LMaxY);

        Buffer.Draw(0, y, FPanelSnapshot);

        FSnapshotTopLeft := Point(0, y); // for other use ...
      end;
    end;
  end;

  Buffer.FrameRectS(Buffer.BoundsRect, clBlack32);
end;

procedure TigLayerPanelManager.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  LIndex      : Integer;
  LPanelRect  : TRect;
  LLayerPanel : TigCustomLayerPanel;
begin
  if Button = mbLeft then
  begin
    // prepare for moving a panel that under current mouse position
    PreparePanelSnapshotRendering(X, Y);

    FMouseDownX    := X;
    FMouseDownY    := Y;
    FLastX         := X;
    FLastY         := Y;
    FIsPanelMoving := False;

    // dealing with double click on a panel
    if ssDouble	in Shift then
    begin
      LIndex := GetPanelIndexAtXY(X, Y);

      if LIndex >= 0 then
      begin
        LPanelRect  := Self.GetPanelRect(LIndex);
        LLayerPanel := FPanelList.LayerPanels[LIndex];

        case FPanelTheme.GetPanelAreaAtXY(LLayerPanel, LPanelRect, X, Y) of
          spaLayerThumbnail:
            begin
              if Assigned(LLayerPanel.OnLayerThumbDblClick) then
              begin
                LLayerPanel.OnLayerThumbDblClick(LLayerPanel);
              end;
            end;

          spaMaskThumbnail:
            begin
              if Assigned(LLayerPanel.OnMaskThumbDblClick) then
              begin
                LLayerPanel.OnMaskThumbDblClick(LLayerPanel);
              end;
            end;

          spaLayerCaption:
            begin
              if Assigned(LLayerPanel.OnPanelDblClick) then
              begin
                LLayerPanel.OnPanelDblClick(LLayerPanel);
              end;
            end;
        end;
      end;
    end
    else
    begin
      // If the Double-Click has not been fired, we mark
      // the mouse left button is pressed. Doing this is for
      // preventing from the Double-Click opens a dialog and
      // after the dialog is closed, the current panel is still
      // in Moving mode.
      FLeftButtonDown := True;
    end;
  end;

  inherited; // respond to OnMouseDown
end;

procedure TigLayerPanelManager.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  FMouseX := X;
  FMouseY := Y;

  if FLeftButtonDown then
  begin
    if Abs(FMouseY - FMouseDownY) > 8 then
    begin
      if not FIsPanelMoving then
      begin
        FIsPanelMoving := Assigned(FPanelSnapshot);
      end;
    end;

    if FIsPanelMoving then
    begin
      if not Assigned(FScrollThread) then
      begin
        FScrollThread := TigScrollPanelThread.Create(Self);
      end;
      
      if Y <> FLastY then
      begin
        Invalidate;
      end;
    end;

    FLastX := X;
    FLastY := Y;
  end;
  
  inherited; // respond to OnMouseMove
end;

procedure TigLayerPanelManager.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  LIndex      : Integer;
  LLayerPanel : TigCustomLayerPanel;
  LPanelRect  : TRect;
  LValidArea  : TRect;
  LPos        : TPoint;
begin
  if FLeftButtonDown then
  begin
    FLeftButtonDown := False;

    if Assigned(FPanelList) then
    begin
      if FIsPanelMoving then
      begin
        FIsPanelMoving := False;
        ScrollThreadStop;

        LValidArea.TopLeft := ClientRect.TopLeft;
        LValidArea.Right   := ClientWidth;
        LValidArea.Bottom  := Min(ClientHeight, FWorkSize.Y);
        
        if Windows.PtInRect( LValidArea, Point(X, Y) ) then
        begin
          LPos := Point(X, Y);
        end
        else
        begin
          // get center point of the snapshot of a moving layer panel
          LPos.X := FSnapshotTopLeft.X + ClientWidth div 2;
          LPos.Y := FSnapshotTopLeft.Y + LAYER_PANEL_HEIGHT div 2;
        end;

        LIndex := GetPanelIndexAtXY(LPos.X, LPos.Y);

        FPanelList.Move(FMovingPanelIndex, LIndex);
        FPanelList.SelectLayerPanel(LIndex);

        // If the layer order is changed, the external callbacks should to
        // take care of the refreshing of the GUI of layer manager,
        // otherwise, we should to refresh the view by ourselves.
        if ScrollSelectedPanelInViewport or
           (FMovingPanelIndex = FPanelList.SelectedIndex) then
        begin
          Invalidate;
        end;
      end
      else
      begin
        LIndex := GetPanelIndexAtXY(X, Y);

        if LIndex >= 0 then
        begin
          LPanelRect  := Self.GetPanelRect(LIndex);
          LLayerPanel := FPanelList.LayerPanels[LIndex];

          case FPanelTheme.GetPanelAreaAtXY(LLayerPanel, LPanelRect, X, Y) of
            spaVisibleMark:
              begin
                LLayerPanel.IsLayerVisible := not LLayerPanel.IsLayerVisible;
              end;

            spaStageMark:
              begin
                // do nothing yet
              end;

            spaLayerThumbnail:
              begin
                FPanelList.SelectLayerPanel(LIndex);
                FPanelList.SelectedPanel.LayerProcessStage := lpsLayer;
              end;

            spaMaskLinkageMark:
              begin
                LLayerPanel.IsMaskLinked := not LLayerPanel.IsMaskLinked;
              end;

            spaMaskThumbnail:
              begin
                FPanelList.SelectLayerPanel(LIndex);
                FPanelList.SelectedPanel.LayerProcessStage := lpsMask;
              end;

            spaLayerCaption:
              begin
                FPanelList.SelectLayerPanel(LIndex);
              end;
          end;

          if ScrollSelectedPanelInViewport then
          begin
            Invalidate;
          end;
        end;
      end;
    end;
  end;

  inherited;  // respond to OnMouseUp
end;

procedure TigLayerPanelManager.KeyDown(var Key: Word; Shift: TShiftState);
var
  LCurIndex    : Integer;
  LTargetIndex : Integer;
begin
  if FIsPanelMoving then
  begin
    Exit;
  end;

  if Assigned(FPanelList) and (FPanelList.Count > 1) then
  begin
    case Key of
      VK_UP:
        begin
          LCurIndex    := FPanelList.SelectedIndex;
          LTargetIndex := LCurIndex + 1;

          if LCurIndex < FPanelList.MaxIndex then
          begin
            if ssShift in Shift then
            begin
              FPanelList.Move(LCurIndex, LTargetIndex);
            end
            else
            begin
              FPanelList.SelectLayerPanel(LTargetIndex);
            end;

            ScrollSelectedPanelInViewport;
          end;
        end;
        
      VK_DOWN:
        begin
          LCurIndex    := FPanelList.SelectedIndex;
          LTargetIndex := LCurIndex - 1;

          if LCurIndex > 0 then
          begin
            if ssShift in Shift then
            begin
              FPanelList.Move(LCurIndex, LTargetIndex);
            end
            else
            begin
              FPanelList.SelectLayerPanel(LTargetIndex);
            end;

            ScrollSelectedPanelInViewport;
          end;
        end;
    end;
  end;

  inherited;  // respond to OnKeyDown
end;

function TigLayerPanelManager.ScrollPanelInViewport(
  const APanelIndex: Integer): Boolean;
var
  LRect : TRect;
begin
  Result := False;
  
  if Assigned(FPanelList) and FPanelList.IsValidIndex(APanelIndex) then
  begin
    LRect := GetPanelRect(APanelIndex);

    if LRect.Top < Self.ClientRect.Top then
    begin
      Self.Scroll(Self.ClientRect.Top - LRect.Top);
      Result := True;
    end
    else if LRect.Bottom > Self.ClientRect.Bottom then
    begin
      Self.Scroll(Self.ClientRect.Bottom - LRect.Bottom);
      Result := True;
    end;
  end;
end;

function TigLayerPanelManager.ScrollSelectedPanelInViewport: Boolean;
var
  LIndex : Integer;
begin
  Result := False;
  
  if Assigned(FPanelList) and (FPanelList.Count > 0) then
  begin
    LIndex := FPanelList.SelectedIndex;
    Result := ScrollPanelInViewport(LIndex);
  end;
end;

function TigLayerPanelManager.GetPanelSnapshot(
  const APanelIndex: Integer): TBitmap32;
var
  LPanel : TigCustomLayerPanel;
begin
  Result := nil;

  if Assigned(FPanelList) and FPanelList.IsValidIndex(APanelIndex) then
  begin
    LPanel := FPanelList.LayerPanels[APanelIndex];
    Result := FPanelTheme.GetSnapshot(LPanel, Self.ClientWidth, LAYER_PANEL_HEIGHT);
  end;
end;

function TigLayerPanelManager.GetSelectedPanelSnapshot: TBitmap32;
begin
  Result := nil;

  if Assigned(FPanelList) then
  begin
    Result := GetPanelSnapshot(FPanelList.SelectedIndex);
  end;
end;

function TigLayerPanelManager.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := CanScrollDown;

  if Result then
  begin
    Self.Scroll(-FWheelDelta);
    Invalidate;
  end;
end;

function TigLayerPanelManager.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := CanScrollUp;

  if Result then
  begin
    Self.Scroll(FWheelDelta);
    Invalidate;
  end;
end;

{ TigScrollPanelThread }

constructor TigScrollPanelThread.Create(APanelManager: TigLayerPanelManager);
begin
  FPanelManager   := APanelManager;
  FreeOnTerminate := False;

  inherited Create(False);
  
  Priority := tpLower;
end;

procedure TigScrollPanelThread.Execute;
begin
  if Assigned(FPanelManager) then
  begin
    while (not Terminated) do
    begin
      with FPanelManager do
      begin
        if FIsPanelMoving and (FMouseX >= 0) and (FMouseX < ClientWidth) then
        begin
          if FMouseY < 0 then
          begin
            if CanScrollUp then
            begin
              Scroll(LAYER_PANEL_HEIGHT);
              Invalidate;
            end;
          end
          else if FMouseY > ClientHeight then
          begin
            if CanScrollDown then
            begin
              Scroll(-LAYER_PANEL_HEIGHT);
              Invalidate;
            end;
          end;

          Sleep(500);
        end;
      end;
    end;
  end;
end;

end.
