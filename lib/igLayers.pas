unit igLayers;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

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

uses
{ Delphi }
  Classes, Contnrs,
{ Graphics32 }
  GR32,
{ externals\Graphics32_add_ons }
  GR32_Add_BlendModes;

type
  TigLayerFeature = (lfNone, lfNormal);

  // mark process stage -- on the layer or on the mask
  TigLayerProcessStage = (lpsLayer, lpsMask);

  { Forward Declarations }
  TigLayerPanelList = class;

  { TigCustomLayerPanel }
  
  TigCustomLayerPanel = class(TPersistent)
  protected
    FOwner                : TigLayerPanelList;
    FLayerBitmap          : TBitmap32;
    FLayerThumb           : TBitmap32;
    FMaskBitmap           : TBitmap32;
    FMaskThumb            : TBitmap32;
    FLayerBlendMode       : TBlendMode32;
    FLayerBlendEvent      : TPixelCombineEvent;
    FLayerVisible         : Boolean;
    FLayerProcessStage    : TigLayerProcessStage;
    FLayerFeature         : TigLayerFeature;       // the feature of the layer
    FSelected             : Boolean;
    FDuplicated           : Boolean;               // indicate whether this layer is duplicated from another one
    FMaskEnabled          : Boolean;               // indicate whether this layer has a mask
    FMaskLinked           : Boolean;               // indicate whether this layer is linked to a mask
    FRealThumbRect        : TRect;
    FLayerName            : string;

    FOnChange             : TNotifyEvent;
    FOnThumbUpdate        : TNotifyEvent;
    FOnPanelDblClick      : TNotifyEvent;
    FOnLayerThumbDblClick : TNotifyEvent;
    FOnMaskThumbDblClick  : TNotifyEvent;

    function GetLayerOpacity: Byte;

    procedure SetLayerVisible(AValue: Boolean);
    procedure SetMaskEnabled(AValue: Boolean);
    procedure SetMaskLinked(AValue: Boolean);
    procedure SetLayerBlendMode(AValue: TBlendMode32);
    procedure SetLayerOpacity(AValue: Byte);
    procedure SetLayerProcessStage(AValue: TigLayerProcessStage);
    procedure CalcRealThumbRect; virtual;
    procedure LayerBlend(F: TColor32; var B: TColor32; M: TColor32); virtual;
    procedure InitMask;
  public
    constructor Create(AOwner: TigLayerPanelList;
      const ALayerWidth, ALayerHeight: Integer;
      const AFillColor: TColor32 = $00000000);

    destructor Destroy; override;

    procedure UpdateLayerThumbnail;
    procedure UpdateMaskThumbnail;
    procedure Changed; overload;
    procedure Changed(const ARect: TRect); overload;

    function EnableMask: Boolean;
    function DiscardMask: Boolean;

    property LayerBitmap          : TBitmap32            read FLayerBitmap;
    property LayerThumbnail       : TBitmap32            read FLayerThumb;
    property MaskThumbnail        : TBitmap32            read FMaskThumb;
    property IsLayerVisible       : Boolean              read FLayerVisible         write SetLayerVisible;
    property IsDuplicated         : Boolean              read FDuplicated;
    property IsSelected           : Boolean              read FSelected             write FSelected;
    property IsMaskEnabled        : Boolean              read FMaskEnabled;
    property IsMaskLinked         : Boolean              read FMaskLinked           write SetMaskLinked;
    property LayerName            : string               read FLayerName            write FLayerName;
    property LayerBlendMode       : TBlendMode32         read FLayerBlendMode       write SetLayerBlendMode;
    property LayerOpacity         : Byte                 read GetLayerOpacity       write SetLayerOpacity;
    property LayerProcessStage    : TigLayerProcessStage read FLayerProcessStage    write SetLayerProcessStage;
    property LayerFeature         : TigLayerFeature      read FLayerFeature;
    property OnChange             : TNotifyEvent         read FOnChange             write FOnChange;
    property OnThumbnailUpdate    : TNotifyEvent         read FOnThumbUpdate        write FOnThumbUpdate;
    property OnPanelDblClick      : TNotifyEvent         read FOnPanelDblClick      write FOnPanelDblClick;
    property OnLayerThumbDblClick : TNotifyEvent         read FOnLayerThumbDblClick write FOnLayerThumbDblClick;
    property OnMaskThumbDblClick  : TNotifyEvent         read FOnMaskThumbDblClick  write FOnMaskThumbDblClick;
  end;

  { TigNormalLayerPanel }

  TigNormalLayerPanel = class(TigCustomLayerPanel)
  private
    FAsBackground : Boolean; // if this layer is a background layer
  public
    constructor Create(AOwner: TigLayerPanelList;
      const ALayerWidth, ALayerHeight: Integer;
      const AFillColor: TColor32 = $00000000;
      const AsBackLayerPanel: Boolean = False);

    function ApplyMask: Boolean;

    property IsAsBackground : Boolean read FAsBackground;
  end;

  { TigLayerPanelList }

  TigLayerCombinedEvent = procedure (ASender: TObject; const ARect: TRect) of object;
  TigMergeLayerEvent = procedure (AResultPanel: TigCustomLayerPanel) of object;

  TigLayerPanelList = class(TPersistent)
  private
    FItems                : TObjectList;
    FSelectedPanel        : TigCustomLayerPanel;
    FCombineResult        : TBitmap32;
    FLayerWidth           : Integer;
    FLayerHeight          : Integer;

    FOnLayerCombined      : TigLayerCombinedEvent;
    FOnSelectionChanged   : TNotifyEvent;
    FOnLayerOrderChanged  : TNotifyEvent;
    FOnMergeVisibleLayers : TigMergeLayerEvent;
    FOnFlattenLayers      : TigMergeLayerEvent;

    FNormalLayerCount     : Integer;

    function GetPanelCount: Integer;
    function GetPanelMaxIndex: Integer;
    function GetSelectedPanelIndex: Integer;
    function GetLayerPanel(AIndex: Integer): TigCustomLayerPanel;
    function GetVisbileLayerCount: Integer;
    function GetVisibleNormalLayerCount: Integer;

    procedure BlendLayers; overload;
    procedure BlendLayers(const ARect: TRect); overload;
    procedure DeleteVisibleLayerPanels;
    procedure DeselectAllPanels;
    procedure InitLayerCounters;
    procedure SetLayerPanelInitialName(ALayerPanel: TigCustomLayerPanel);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(APanel: TigCustomLayerPanel);
    procedure SimpleAdd(APanel: TigCustomLayerPanel); 
    procedure Insert(AIndex: Integer; APanel: TigCustomLayerPanel);
    procedure Move(ACurIndex, ANewIndex: Integer);
    procedure SelectLayerPanel(const AIndex: Integer);
    procedure DeleteSelectedLayerPanel;
    procedure DeleteLayerPanel(AIndex: Integer);

    function CanFlattenLayers: Boolean;
    function CanMergeSelectedLayerDown: Boolean;
    function CanMergeVisbleLayers: Boolean;
    function FlattenLayers: Boolean;
    function MergeSelectedLayerDown: Boolean;
    function MergeVisibleLayers: Boolean;
    function IsValidIndex(const AIndex: Integer): Boolean;
    function GetHiddenLayerCount: Integer;

    property CombineResult                : TBitmap32             read FCombineResult;
    property Count                        : Integer               read GetPanelCount;
    property MaxIndex                     : Integer               read GetPanelMaxIndex;
    property SelectedIndex                : Integer               read GetSelectedPanelIndex;
    property LayerPanels[AIndex: Integer] : TigCustomLayerPanel   read GetLayerPanel;
    property SelectedPanel                : TigCustomLayerPanel   read FSelectedPanel;
    property OnLayerCombined              : TigLayerCombinedEvent read FOnLayerCombined      write FOnLayerCombined;
    property OnSelectionChanged           : TNotifyEvent          read FOnSelectionChanged   write FOnSelectionChanged;
    property OnLayerOrderChanged          : TNotifyEvent          read FOnLayerOrderChanged  write FOnLayerOrderChanged;
    property OnMergeVisibleLayers         : TigMergeLayerEvent    read FOnMergeVisibleLayers write FOnMergeVisibleLayers;
    property OnFlattenLayers              : TigMergeLayerEvent    read FOnFlattenLayers      write FOnFlattenLayers;
  end;

const
  LAYER_THUMB_SIZE = 36;

implementation

uses
{ Delphi }
  SysUtils, Graphics, Math,
{ Graphics32 }
  GR32_LowLevel,
{ miniGlue lib }
  igPaintFuncs;

{$R igIcons.res}

const
  LAYER_NAME_BACKGROUND = 'Background';
  LAYER_NAME_Normal     = 'Layer ';

{ TigCustomLayerPanel }

constructor TigCustomLayerPanel.Create(AOwner: TigLayerPanelList;
  const ALayerWidth, ALayerHeight: Integer;
  const AFillColor: TColor32 = $00000000);
begin
  inherited Create;

  FOwner             := AOwner;
  FLayerBlendMode    := bbmNormal32;
  FLayerBlendEvent   := GetBlendMode( Ord(FLayerBlendMode) );
  FDuplicated        := False;
  FLayerVisible      := True;
  FSelected          := True;
  FMaskEnabled       := False;
  FMaskLinked        := False;
  FLayerName         := '';
  FLayerProcessStage := lpsLayer;
  FLayerFeature      := lfNone;
  
  FOnChange             := nil;
  FOnThumbUpdate        := nil;
  FOnPanelDblClick      := nil;
  FOnLayerThumbDblClick := nil;
  FOnMaskThumbDblClick  := nil; 

  FLayerBitmap := TBitmap32.Create;
  with FLayerBitmap do
  begin
    DrawMode    := dmBlend;
    CombineMode := cmMerge;
    
    SetSize(ALayerWidth, ALayerHeight);
    Clear(AFillColor);
  end;

  FLayerThumb := TBitmap32.Create;
  with FLayerThumb do
  begin
    SetSize(LAYER_THUMB_SIZE, LAYER_THUMB_SIZE);
  end;

  FMaskBitmap := nil;
  FMaskThumb  := nil;

  CalcRealThumbRect;
  UpdateLayerThumbnail;


  // test
//  Self.EnableMask;
//  Self.FMaskBitmap.FillRectS( 20, 20, 120, 120, $FF7F7F7F );
//  Self.IsMaskLinked := True;
//  Self.UpdateMaskThumbnail;
end;

destructor TigCustomLayerPanel.Destroy;
begin
  FLayerBlendEvent      := nil;
  FOwner                := nil;
  FOnChange             := nil;
  FOnThumbUpdate        := nil;
  FOnPanelDblClick      := nil;
  FOnLayerThumbDblClick := nil;
  FOnMaskThumbDblClick  := nil;
  
  FLayerBitmap.Free;
  FLayerThumb.Free;
  FMaskBitmap.Free;
  FMaskThumb.Free;
  
  inherited;
end;

function TigCustomLayerPanel.GetLayerOpacity: Byte;
begin
  Result := FLayerBitmap.MasterAlpha and $FF;
end;

procedure TigCustomLayerPanel.SetLayerVisible(AValue: Boolean);
begin
  if FLayerVisible <> AValue then
  begin
    FLayerVisible := AValue;
    Changed;
  end;
end;

procedure TigCustomLayerPanel.SetMaskEnabled(AValue: Boolean);
begin
  if FMaskEnabled <> AValue then
  begin
    FMaskEnabled := AValue;

    if FMaskEnabled then
    begin
      FLayerProcessStage := lpsMask;
      FMaskLinked        := True;
      
      InitMask;
    end
    else
    begin
      FLayerProcessStage := lpsLayer;
      FMaskLinked        := False;
      
      FreeAndNil(FMaskBitmap);
      FreeAndNil(FMaskThumb);
    end;
  end;
end;

procedure TigCustomLayerPanel.SetMaskLinked(AValue: Boolean);
begin
  if FMaskLinked <> AValue then
  begin
    FMaskLinked := AValue;
    Changed;
  end;
end;

procedure TigCustomLayerPanel.SetLayerBlendMode(AValue: TBlendMode32);
begin
  if FLayerBlendMode <> AValue then
  begin
    FLayerBlendMode  := AValue;
    FLayerBlendEvent := GetBlendMode( Ord(FLayerBlendMode) );
    
    Changed;
  end;
end;

procedure TigCustomLayerPanel.SetLayerOpacity(AValue: Byte);
begin
  if (FLayerBitmap.MasterAlpha and $FF) <> AValue then
  begin
    FLayerBitmap.MasterAlpha := AValue;
    Changed;
  end;
end;

procedure TigCustomLayerPanel.SetLayerProcessStage(
  AValue: TigLayerProcessStage);
begin
  if FLayerProcessStage <> AValue then
  begin
    FLayerProcessStage := AValue;

    if Assigned(FOnChange) then
    begin
      FOnChange(Self);
    end;
  end;
end;

procedure TigCustomLayerPanel.CalcRealThumbRect;
var
  LThumbWidth  : Integer;
  LThumbHeight : Integer;
  ws, hs       : Single;
begin
  LThumbWidth  := FLayerThumb.Width  - 4;
  LThumbHeight := FLayerThumb.Height - 4;

  if (FLayerBitmap.Width  <= LThumbWidth) and
     (FLayerBitmap.Height <= LThumbHeight) then
  begin
    LThumbWidth  := FLayerBitmap.Width;
    LThumbHeight := FLayerBitmap.Height;
  end
  else
  begin
    ws := LThumbWidth  / FLayerBitmap.Width;
    hs := LThumbHeight / FLayerBitmap.Height;

    if ws < hs then
    begin
      LThumbWidth  := Round(FLayerBitmap.Width  * ws);
      LThumbHeight := Round(FLayerBitmap.Height * ws);
    end
    else
    begin
      LThumbWidth  := Round(FLayerBitmap.Width  * hs);
      LThumbHeight := Round(FLayerBitmap.Height * hs);
    end;
  end;

  with FRealThumbRect do
  begin
    Left   := (FLayerThumb.Width  - LThumbWidth)  div 2;
    Top    := (FLayerThumb.Height - LThumbHeight) div 2;
    Right  := Left + LThumbWidth;
    Bottom := Top  + LThumbHeight;
  end;
end;

procedure TigCustomLayerPanel.LayerBlend(
  F: TColor32; var B: TColor32; M: TColor32);
begin
  FLayerBlendEvent(F, B, M);
end;

procedure TigCustomLayerPanel.InitMask;
begin
  if not Assigned(FMaskBitmap) then
  begin
    FMaskBitmap := TBitmap32.Create;
  end;

  with FMaskBitmap do
  begin
    SetSizeFrom(FLayerBitmap);
    Clear(clWhite32);
  end;

  if not Assigned(FMaskThumb) then
  begin
    FMaskThumb := TBitmap32.Create;
  end;

  with FMaskThumb do
  begin
    SetSize(LAYER_THUMB_SIZE, LAYER_THUMB_SIZE);
  end;

  UpdateMaskThumbnail;
end;

procedure TigCustomLayerPanel.UpdateLayerThumbnail;
var
  LRect : TRect;
begin
  LRect := FRealThumbRect;
  
  FLayerThumb.Clear( Color32(clBtnFace) );
  DrawCheckerboardPattern(FLayerThumb, LRect, True);
  FLayerThumb.Draw(LRect, FLayerBitmap.BoundsRect, FLayerBitmap);

  InflateRect(LRect, 1, 1);
  FLayerThumb.FrameRectS(LRect, clBlack32);

  if Assigned(FOnThumbUpdate) then
  begin
    FOnThumbUpdate(Self);
  end;
end;

procedure TigCustomLayerPanel.UpdateMaskThumbnail;
var
  LRect : TRect;
begin
  LRect := FRealThumbRect;
  
  FMaskThumb.Clear( Color32(clBtnFace) );
  FMaskThumb.Draw(LRect, FMaskBitmap.BoundsRect, FMaskBitmap);

  InflateRect(LRect, 1, 1);
  FMaskThumb.FrameRectS(LRect, clBlack32);

  if Assigned(FOnThumbUpdate) then
  begin
    FOnThumbUpdate(Self);
  end; 
end;

procedure TigCustomLayerPanel.Changed;
begin
  if Assigned(FOwner) then
  begin
    FOwner.BlendLayers;
  end; 

  if Assigned(FOnChange) then
  begin
    FOnChange(Self);
  end;
end;

procedure TigCustomLayerPanel.Changed(const ARect: TRect);
begin
  if Assigned(FOwner) then
  begin
    FOwner.BlendLayers(ARect);
  end;

  if Assigned(FOnChange) then
  begin
    FOnChange(Self);
  end;
end;

// enable mask, if it has not ...
function TigCustomLayerPanel.EnableMask: Boolean;
begin
  Result := False;

  if not FMaskEnabled then
  begin
    SetMaskEnabled(True);

    if Assigned(FOnChange) then
    begin
      FOnChange(Self);
    end;

    Result := FMaskEnabled;
  end;
end;

// discard the mask settings, if any
function TigCustomLayerPanel.DiscardMask: Boolean;
begin
  Result := False;

  if FMaskEnabled then
  begin
    SetMaskEnabled(False);
    Self.Changed;

    Result := not FMaskEnabled;
  end;
end;

{ TigNormalLayerPanel }

constructor TigNormalLayerPanel.Create(AOwner: TigLayerPanelList;
  const ALayerWidth, ALayerHeight: Integer;
  const AFillColor: TColor32 = $00000000;
  const AsBackLayerPanel: Boolean = False);
begin
  inherited Create(AOwner, ALayerWidth, ALayerHeight, AFillColor);

  FLayerFeature := lfNormal;
  FAsBackground := AsBackLayerPanel;

  if FAsBackground then
  begin
    FLayerName := LAYER_NAME_BACKGROUND;
  end;
end;

// applying the mask settings to the alpha channel of each pixel on the
// layer bitmap, and then disable the mask
function TigNormalLayerPanel.ApplyMask: Boolean;
var
  i           : Integer;
  a, m        : Cardinal;
  LLayerBits  : PColor32;
  LMaskBits   : PColor32;
  LMaskLinked : Boolean;
begin
  Result := False;

  if FMaskEnabled then
  begin
    LLayerBits := @FLayerBitmap.Bits[0];
    LMaskBits  := @FMaskBitmap.Bits[0];

    for i := 1 to (FLayerBitmap.Width * FLayerBitmap.Height) do
    begin
      m := LMaskBits^ and $FF;
      a := LLayerBits^ shr 24 and $FF;
      a := a * m div 255;

      LLayerBits^ := (a shl 24) or (LLayerBits^ and $FFFFFF);

      Inc(LLayerBits);
      Inc(LMaskBits);
    end;

    LMaskLinked := Self.FMaskLinked;  // remember the mask linked state for later use
    SetMaskEnabled(False);            // disable the mask first

    // if not link with mask, after disable the mask, we need to merge layer
    // to get new blending result, otherwise we don't need to do it, because
    // the current blending result is correct 
    if not LMaskLinked then
    begin
      if Assigned(FOwner) then
      begin
        FOwner.BlendLayers;
      end;
    end;

    UpdateLayerThumbnail;
    
    Result := not FMaskEnabled;
  end;
end;

{ TigLayerPanelList }

constructor TigLayerPanelList.Create;
begin
  inherited;

  FSelectedPanel        := nil;
  FOnLayerCombined      := nil;
  FOnSelectionChanged   := nil;
  FOnLayerOrderChanged  := nil;
  FOnMergeVisibleLayers := nil;
  FOnFlattenLayers      := nil;

  FItems := TObjectList.Create(True);

  FCombineResult := TBitmap32.Create;
  with FCombineResult do
  begin
    DrawMode := dmBlend;
  end;

  InitLayerCounters;
end;

destructor TigLayerPanelList.Destroy;
begin
  FItems.Clear;
  FItems.Free;
  FCombineResult.Free;
  
  inherited;
end;

function TigLayerPanelList.GetPanelCount: Integer;
begin
  Result := FItems.Count;
end;

function TigLayerPanelList.GetPanelMaxIndex: Integer;
begin
  Result := FItems.Count - 1;
end;

function TigLayerPanelList.GetSelectedPanelIndex: Integer;
var
  i : Integer;
begin
  Result := -1;

  if (FItems.Count > 0) and Assigned(FSelectedPanel) then
  begin
    for i := 0 to (FItems.Count - 1) do
    begin
      if FSelectedPanel = Self.LayerPanels[i] then
      begin
        Result := i;
        Break;
      end;
    end;
  end;
end;

function TigLayerPanelList.GetLayerPanel(AIndex: Integer): TigCustomLayerPanel;
begin
  Result := nil;

  if ISValidIndex(AIndex) then
  begin
    Result := TigCustomLayerPanel(FItems.Items[AIndex]);
  end;
end;

function TigLayerPanelList.GetVisbileLayerCount: Integer;
var
  i : Integer;
begin
  Result := 0;

  if FItems.Count > 0 then
  begin
    for i := 0 to (FItems.Count - 1) do
    begin
      if Self.LayerPanels[i].IsLayerVisible then
      begin
        Inc(Result);
      end;
    end;
  end;
end;

function TigLayerPanelList.GetVisibleNormalLayerCount: Integer;
var
  i           : Integer;
  LLayerPanel : TigCustomLayerPanel;
begin
  Result := 0;

  if FItems.Count > 0 then
  begin
    for i := 0 to (FItems.Count - 1) do
    begin
      LLayerPanel := Self.LayerPanels[i];

      if LLayerPanel.IsLayerVisible and (LLayerPanel.LayerFeature = lfNormal) then
      begin
        Inc(Result);
      end;
    end;
  end;
end;

procedure TigLayerPanelList.BlendLayers;
var
  i, j        : Integer;
  LPixelCount : Integer;
  m           : Cardinal;
  LLayerPanel : TigCustomLayerPanel;
  LForeBits   : PColor32;
  LBackBits   : PColor32;
  LMaskBits   : PColor32;
begin
  LMaskBits := nil;

  FCombineResult.BeginUpdate;
  try
    FCombineResult.Clear($00000000);

    if FItems.Count > 0 then
    begin
      LPixelCount := FLayerWidth * FLayerHeight;

      for i := 0 to (FItems.Count - 1) do
      begin
        LLayerPanel := GetLayerPanel(i);

        if not LLayerPanel.IsLayerVisible then
        begin
          Continue;
        end;

        LForeBits := @LLayerPanel.FLayerBitmap.Bits[0];
        LBackBits := @FCombineResult.Bits[0];

        if LLayerPanel.IsMaskEnabled and LLayerPanel.IsMaskLinked then
        begin
          LMaskBits := @LLayerPanel.FMaskBitmap.Bits[0];
        end;

        for j := 1 to LPixelCount do
        begin
          m := LLayerPanel.FLayerBitmap.MasterAlpha;

          if LLayerPanel.IsMaskEnabled and LLayerPanel.IsMaskLinked then
          begin
            // adjust the MasterAlpha with Mask setting
            m := m * (LMaskBits^ and $FF) div 255;
          end;

          LLayerPanel.LayerBlend(LForeBits^, LBackBits^, m);

          Inc(LForeBits);
          Inc(LBackBits);
          if LLayerPanel.IsMaskEnabled and LLayerPanel.IsMaskLinked then
          begin
            Inc(LMaskBits);
          end;
        end;
      end;
    end;

  finally
    FCombineResult.EndUpdate;
  end;

  if Assigned(FOnLayerCombined) then
  begin
    FOnLayerCombined( Self, Rect(0, 0, FLayerWidth, FLayerHeight) );
  end;
end;

procedure TigLayerPanelList.BlendLayers(const ARect: TRect);
var
  LRect        : TRect;
  i            : Integer;
  x, y, xx, yy : Integer;
  LRectWidth   : Integer;
  LRectHeight  : Integer;
  m            : Cardinal;
  LLayerPanel  : TigCustomLayerPanel;
  LResultRow   : PColor32Array;
  LLayerRow    : PColor32Array;
  LMaskRow     : PColor32Array;
begin
{$RANGECHECKS OFF}

  LMaskRow := nil;

  LRect.Left   := Math.Min(ARect.Left, ARect.Right);
  LRect.Right  := Math.Max(ARect.Left, ARect.Right);
  LRect.Top    := Math.Min(ARect.Top, ARect.Right);
  LRect.Bottom := Math.Max(ARect.Top, ARect.Bottom);
  
  if (LRect.Left = LRect.Right) or
     (LRect.Top = LRect.Bottom) or
     (LRect.Left > FLayerWidth) or
     (LRect.Top > FLayerHeight) or
     (LRect.Right <= 0) or
     (LRect.Bottom <= 0) then
  begin
    Exit;
  end;

  LRectWidth  := LRect.Right - LRect.Left + 1;
  LRectHeight := LRect.Bottom - LRect.Top + 1;

  FCombineResult.BeginUpdate;
  try
    if FItems.Count > 0 then
    begin
      for y := 0 to (LRectHeight - 1) do
      begin
        yy := y + LRect.Top;

        if (yy < 0) or (yy >= FLayerHeight) then
        begin
          Continue;
        end;

        // get entries of one line pixels on the background bitmap ...
        LResultRow := FCombineResult.ScanLine[yy];

        for i := 0 to (FItems.Count - 1) do
        begin
          LLayerPanel := GetLayerPanel(i);

          if not LLayerPanel.IsLayerVisible then
          begin
            Continue;
          end;

          // get entries of one line pixels on each layer bitmap ...
          LLayerRow := LLayerPanel.FLayerBitmap.ScanLine[yy];

          if LLayerPanel.IsMaskEnabled and LLayerPanel.IsMaskLinked then
          begin
            // get entries of one line pixels on each layer mask bitmap, if any ...
            LMaskRow := LLayerPanel.FMaskBitmap.ScanLine[yy];
          end;

          for x := 0 to (LRectWidth - 1) do
          begin
            xx := x + LRect.Left;

            if (xx < 0) or (xx >= FLayerWidth) then
            begin
              Continue;
            end;

            if i = 0 then
            begin
              LResultRow[xx] := $00000000;
            end;

            // blending ...
            m := LLayerPanel.FLayerBitmap.MasterAlpha;

            if LLayerPanel.IsMaskEnabled and LLayerPanel.IsMaskLinked then
            begin
              // adjust the MasterAlpha with Mask setting
              m := m * (LMaskRow[xx] and $FF) div 255;
            end;

            LLayerPanel.LayerBlend(LLayerRow[xx], LResultRow[xx], m);
          end;
        end;
      end;
    end;

  finally
    FCombineResult.EndUpdate;
  end;

  if Assigned(FOnLayerCombined) then
  begin
    FOnLayerCombined(Self, ARect);
  end;
     
{$RANGECHECKS ON}
end;

procedure TigLayerPanelList.DeleteVisibleLayerPanels;
var
  i           : Integer;
  LLayerPanel : TigCustomLayerPanel;
begin
  if FItems.Count > 0 then
  begin
    for i := (FItems.Count - 1) downto 0 do
    begin
      LLayerPanel := Self.LayerPanels[i];

      if LLayerPanel.IsLayerVisible then
      begin
        FItems.Delete(i);
      end;
    end;
  end;
end;

procedure TigLayerPanelList.DeselectAllPanels;
var
  i : Integer;
begin
  if FItems.Count > 0 then
  begin
    Self.FSelectedPanel := nil;

    for i := 0 to (FItems.Count - 1) do
    begin
      // NOTICE :
      //   Setting with field FSelected, not with property Selected,
      //   for avoiding the setter of property be invoked.
      GetLayerPanel(i).FSelected := False;
    end;
  end;
end;

procedure TigLayerPanelList.InitLayerCounters;
begin
  FNormalLayerCount := 0;
end;

procedure TigLayerPanelList.SetLayerPanelInitialName(
  ALayerPanel: TigCustomLayerPanel);
begin
  if Assigned(ALayerPanel) then
  begin
    case ALayerPanel.LayerFeature of
      lfNormal:
        begin
          with TigNormalLayerPanel(ALayerPanel) do
          begin
            if not FAsBackground then
            begin
              Inc(FNormalLayerCount);
              FLayerName := LAYER_NAME_NORMAL + IntToStr(FNormalLayerCount);
            end;
          end;
        end;
    end;
  end;
end;

procedure TigLayerPanelList.Add(APanel: TigCustomLayerPanel);
begin
  if Assigned(APanel) then
  begin
    FItems.Add(APanel);
    
    // first adding
    if FItems.Count = 1 then
    begin
      FLayerWidth  := APanel.FLayerBitmap.Width;
      FLayerHeight := APanel.FLayerBitmap.Height;
      
      FCombineResult.SetSize(FLayerWidth, FLayerHeight);
    end;

    BlendLayers;
    SelectLayerPanel(FItems.Count - 1);

    if not FSelectedPanel.IsDuplicated then
    begin
      SetLayerPanelInitialName(FSelectedPanel);
    end;
  end;
end;

// This procedure does the similar thing as the Add() procedure above,
// but it won't blend layers, invoke callback functions, etc.
// It simply adds a panel to a layer panel list.
procedure TigLayerPanelList.SimpleAdd(APanel: TigCustomLayerPanel);
begin
  if Assigned(APanel) then
  begin
    FItems.Add(APanel);
    
    // first adding
    if FItems.Count = 1 then
    begin
      FLayerWidth  := APanel.FLayerBitmap.Width;
      FLayerHeight := APanel.FLayerBitmap.Height;
      
      FCombineResult.SetSize(FLayerWidth, FLayerHeight);
    end;
  end;
end; 

procedure TigLayerPanelList.Insert(AIndex: Integer;
  APanel: TigCustomLayerPanel);
begin
  if Assigned(APanel) then
  begin
    AIndex := Clamp(AIndex, 0, FItems.Count);
    FItems.Insert(AIndex, APanel);
    
    BlendLayers;
    SelectLayerPanel(AIndex);

    if not FSelectedPanel.IsDuplicated then
    begin
      SetLayerPanelInitialName(FSelectedPanel);
    end;
  end;
end;

procedure TigLayerPanelList.Move(ACurIndex, ANewIndex: Integer);
begin
  if IsValidIndex(ACurIndex) and
     IsValidIndex(ANewIndex) and
     (ACurIndex <> ANewIndex) then
  begin
    FItems.Move(ACurIndex, ANewIndex);
    BlendLayers;

    if Assigned(FOnLayerOrderChanged) then
    begin
      FOnLayerOrderChanged(Self);
    end;
  end;
end;

procedure TigLayerPanelList.SelectLayerPanel(const AIndex: Integer);
var
  LLayerPanel : TigCustomLayerPanel;
begin
  LLayerPanel := GetLayerPanel(AIndex);

  if Assigned(LLayerPanel) then
  begin
    if FSelectedPanel <> LLayerPanel then
    begin
      DeselectAllPanels;

      FSelectedPanel           := LLayerPanel;
      FSelectedPanel.FSelected := True;

      if Assigned(FOnSelectionChanged) then
      begin
        FOnSelectionChanged(Self);
      end;
    end;
  end;
end;

procedure TigLayerPanelList.DeleteSelectedLayerPanel;
var
  LIndex : Integer;
begin
  LIndex := GetSelectedPanelIndex;
  DeleteLayerPanel(LIndex);
end;

procedure TigLayerPanelList.DeleteLayerPanel(AIndex: Integer);
begin
  if (FItems.Count = 1) or
     (not IsValidIndex(AIndex)) then
  begin
    Exit;
  end;

  FSelectedPanel := nil;

  FItems.Delete(AIndex);
  BlendLayers;

  // select the previous layer ...

  AIndex := AIndex - 1;

  if AIndex < 0 then
  begin
    AIndex := 0;
  end;

  SelectLayerPanel(AIndex);
end;

function TigLayerPanelList.CanFlattenLayers: Boolean;
begin
  Result := False;

  if FItems.Count > 0 then
  begin
    if FItems.Count = 1 then
    begin
      if Self.SelectedPanel.LayerFeature = lfNormal then
      begin
        // If the only layer is a Normal layer but not as background layer,
        // we could flatten it as a background layer
        Result := not TigNormalLayerPanel(Self.SelectedPanel).IsAsBackground;
      end;
    end
    else
    begin
      // we could flatten layers as long as the numnber of layers
      // is greater than one
      Result := True;
    end;
  end;
end;

function TigLayerPanelList.CanMergeSelectedLayerDown: Boolean;
var
  LPrevIndex : Integer;
  LPrevPanel : TigCustomLayerPanel;
begin
  Result     := False;
  LPrevIndex := Self.SelectedIndex - 1;

  if IsValidIndex(LPrevIndex) then
  begin
    LPrevPanel := Self.LayerPanels[LPrevIndex];

    // can only merge down to a visible Normal layer
    Result := FSelectedPanel.IsLayerVisible and
              (LPrevPanel.LayerFeature = lfNormal) and LPrevPanel.IsLayerVisible;
  end;
end;

function TigLayerPanelList.CanMergeVisbleLayers: Boolean;
begin
  Result := FSelectedPanel.IsLayerVisible and
            (GetVisibleNormalLayerCount > 0) and (GetVisbileLayerCount > 1);
end;

function TigLayerPanelList.FlattenLayers: Boolean;
var
  LBackPanel : TigCustomLayerPanel;
begin
  Result := CanFlattenLayers;
  
  if Result then
  begin
    LBackPanel := TigNormalLayerPanel.Create(Self, FLayerWidth, FLayerHeight, clWhite32, True);

    with LBackPanel do
    begin
      // Note that, if the background layer has special properties as the one
      // in Photoshop, we should draw the combined result onto a white
      // background. But for now, we haven't figure out how to do the same
      // thing as PS, so we just make the combined result as the background
      // layer.
      
      //LayerBitmap.Draw(0, 0, FCombineResult);
      LayerBitmap.Assign(FCombineResult);
      UpdateLayerThumbnail;
    end;

    FItems.Clear;
    InitLayerCounters;
    Self.Add(LBackPanel);
    Self.SelectLayerPanel(0);

    if Assigned(FOnFlattenLayers) then
    begin
      FOnFlattenLayers(Self.FSelectedPanel);
    end;
  end;
end;

function TigLayerPanelList.MergeSelectedLayerDown: Boolean;
var
  i             : Integer;
  m             : Cardinal;
  LMaskEffected : Boolean;
  LPrevIndex    : Integer;
  LPrevPanel    : TigCustomLayerPanel;
  LForeBits     : PColor32;
  LBackBits     : PColor32;
  LMaskBits     : PColor32;
begin
  Result := CanMergeSelectedLayerDown;

  LMaskEffected := False;
  LMaskBits     := nil;

  if Result then
  begin
    LPrevIndex := SelectedIndex - 1;
    LPrevPanel := Self.LayerPanels[LPrevIndex];

    LForeBits := @FSelectedPanel.FLayerBitmap.Bits[0];
    LBackBits := @LPrevPanel.FLayerBitmap.Bits[0];

    if (FSelectedPanel.IsMaskEnabled) and (FSelectedPanel.IsMaskLinked) then
    begin
      LMaskBits     := @FSelectedPanel.FMaskBitmap.Bits[0];
      LMaskEffected := True;
    end;

    for i := 1 to (FLayerWidth * FLayerHeight) do
    begin
      m := FSelectedPanel.FLayerBitmap.MasterAlpha;
      
      if LMaskEffected then
      begin
        // adjust the MasterAlpha with Mask setting
        m := m * (LMaskBits^ and $FF) div 255;
      end;

      FSelectedPanel.LayerBlend(LForeBits^, LBackBits^, m);

      Inc(LForeBits);
      Inc(LBackBits);

      if LMaskEffected then
      begin
        Inc(LMaskBits);
      end;
    end;

    LPrevPanel.UpdateLayerThumbnail;

    // this routine will make the previous layer be selected automatically
    DeleteSelectedLayerPanel;
    BlendLayers;
  end;
end;

function TigLayerPanelList.MergeVisibleLayers: Boolean;
var
  LMergedPanel  : TigCustomLayerPanel;
  LAsBackground : Boolean;
begin
  Result := Self.CanMergeVisbleLayers;

  if Result then
  begin
    LAsBackground := False;
    
    if FSelectedPanel.LayerFeature = lfNormal then
    begin
      LAsBackground := TigNormalLayerPanel(FSelectedPanel).FAsBackground;
    end;

    LMergedPanel := TigNormalLayerPanel.Create(Self,
      FLayerWidth, FLayerHeight, $00000000, LAsBackground);

    with LMergedPanel do
    begin
      FLayerBitmap.Assign(FCombineResult);
      UpdateLayerThumbnail;

      FLayerName := FSelectedPanel.FLayerName;
    end;
    
    DeleteVisibleLayerPanels;
    FSelectedPanel := nil;

    FItems.Insert(0, LMergedPanel);
    Self.SelectLayerPanel(0);

    if Assigned(FOnMergeVisibleLayers) then
    begin
      FOnMergeVisibleLayers(Self.FSelectedPanel);
    end;
  end;
end;

function TigLayerPanelList.IsValidIndex(const AIndex: Integer): Boolean;
begin
  Result := (FItems.Count > 0) and (AIndex >= 0) and (AIndex < FItems.Count);
end;

function TigLayerPanelList.GetHiddenLayerCount: Integer;
var
  i : Integer;
begin
  Result := 0;

  if FItems.Count > 0 then
  begin
    for i := 0 to (FItems.Count - 1) do
    begin
      if not Self.LayerPanels[i].IsLayerVisible then
      begin
        Inc(Result);
      end;
    end;
  end;
end;


end.
