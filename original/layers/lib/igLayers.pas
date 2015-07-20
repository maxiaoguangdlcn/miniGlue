unit igLayers;

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

// Update Date: 2015/07/14

interface

uses
{ Delphi }
  Classes, Contnrs,
{ Graphics32 }
  GR32,
{ externals\Graphics32_add_ons }
  GR32_Add_BlendModes;

type
  TigLayerPixelFeature = (lpfNone,
                          lpfNormalPixelized,   // Such layers can be editing with any tools,
                                                // example of such a layer is Normal layer.
                          lpfSpecialPixelized,  // Such layers can be editing only with its own specific tools,
                                                // example of such a layer is Gradient layer.
                          lpfNonPixelized       // Such layers have dummy pixels, and can only take
                                                // effect on the blending result of beneath layers
                          );

  // mark process stage -- on the layer or on the mask
  TigLayerProcessStage = (lpsLayer, lpsMask);

  { Forward Declarations }
  TigLayerList = class;
  TigClassCounter = class;

  { TigCustomLayer }
  
  TigCustomLayer = class(TPersistent)
  protected
    FOwner                : TigLayerList;
    FLayerBitmap          : TBitmap32;
    FLayerThumb           : TBitmap32;
    FMaskBitmap           : TBitmap32;
    FMaskThumb            : TBitmap32;
    FLogoBitmap           : TBitmap32;
    FLogoThumb            : TBitmap32;
    FLayerBlendMode       : TBlendMode32;
    FLayerBlendEvent      : TPixelCombineEvent;
    FLayerVisible         : Boolean;
    FLayerProcessStage    : TigLayerProcessStage;
    FPixelFeature         : TigLayerPixelFeature;  // the pixel feature of the layer
    FSelected             : Boolean;
    FDuplicated           : Boolean;               // indicate whether this layer is duplicated from another one
    FMaskEnabled          : Boolean;               // indicate whether this layer has a mask
    FMaskLinked           : Boolean;               // indicate whether this layer is linked to a mask
    FLayerThumbEnabled    : Boolean;               // indicate whether this layer has a layer thumbnail
    FLogoThumbEnabled     : Boolean;               // indicate whether this layer has a logo thumbnail
    FRealThumbRect        : TRect;
    FDefaultLayerName     : string;
    FLayerName            : string;                // current layer name

    FOnChange             : TNotifyEvent;
    FOnMaskEnabled        : TNotifyEvent;
    FOnMaskDisabled       : TNotifyEvent;
    FOnThumbUpdate        : TNotifyEvent;
    FOnPanelDblClick      : TNotifyEvent;
    FOnLayerThumbDblClick : TNotifyEvent;
    FOnMaskThumbDblClick  : TNotifyEvent;
    FOnLogoThumbDblClick  : TNotifyEvent;

    function GetLayerOpacity: Byte;
    
    function GetThumbZoomScale(
      const ASrcWidth, ASrcHeight, AThumbWidth, AThumbHeight: Integer): Single;

    function GetRealThumbRect(
      const ASrcWidth, ASrcHeight, AThumbWidth, AThumbHeight: Integer;
      const AMarginSize: Integer = 4): TRect;

    procedure SetLayerVisible(AValue: Boolean);
    procedure SetMaskEnabled(AValue: Boolean);
    procedure SetMaskLinked(AValue: Boolean);
    procedure SetLayerBlendMode(AValue: TBlendMode32);
    procedure SetLayerOpacity(AValue: Byte);
    procedure SetLayerProcessStage(AValue: TigLayerProcessStage);
    procedure LayerBlend(F: TColor32; var B: TColor32; M: TColor32); virtual;
    procedure InitMask;
  public
    constructor Create(AOwner: TigLayerList;
      const ALayerWidth, ALayerHeight: Integer;
      const AFillColor: TColor32 = $00000000);

    destructor Destroy; override;

    procedure UpdateLayerThumbnail; virtual;
    procedure UpdateMaskThumbnail;
    procedure UpdateLogoThumbnail; virtual;
    procedure Changed; overload;
    procedure Changed(const ARect: TRect); overload;

    function EnableMask: Boolean;
    function DiscardMask: Boolean;

    property LayerBitmap          : TBitmap32            read FLayerBitmap;
    property LayerThumbnail       : TBitmap32            read FLayerThumb;
    property MaskBitmap           : TBitmap32            read FMaskBitmap;
    property MaskThumbnail        : TBitmap32            read FMaskThumb;
    property LogoBitmap           : TBitmap32            read FLogoBitmap;
    property LogoThumbnail        : TBitmap32            read FLogoThumb;
    property IsLayerVisible       : Boolean              read FLayerVisible         write SetLayerVisible;
    property IsDuplicated         : Boolean              read FDuplicated;
    property IsSelected           : Boolean              read FSelected             write FSelected;
    property IsMaskEnabled        : Boolean              read FMaskEnabled;
    property IsMaskLinked         : Boolean              read FMaskLinked           write SetMaskLinked;
    property IsLayerThumbEnabled  : Boolean              read FLayerThumbEnabled;
    property IsLogoThumbEnabled   : Boolean              read FLogoThumbEnabled;
    property LayerName            : string               read FLayerName            write FLayerName;
    property LayerBlendMode       : TBlendMode32         read FLayerBlendMode       write SetLayerBlendMode;
    property LayerOpacity         : Byte                 read GetLayerOpacity       write SetLayerOpacity;
    property LayerProcessStage    : TigLayerProcessStage read FLayerProcessStage    write SetLayerProcessStage;
    property PixelFeature         : TigLayerPixelFeature read FPixelFeature;
    property OnChange             : TNotifyEvent         read FOnChange             write FOnChange;
    property OnThumbnailUpdate    : TNotifyEvent         read FOnThumbUpdate        write FOnThumbUpdate;
    property OnMaskEnabled        : TNotifyEvent         read FOnMaskEnabled        write FOnMaskEnabled;
    property OnMaskDisabled       : TNotifyEvent         read FOnMaskDisabled       write FOnMaskDisabled;
    property OnPanelDblClick      : TNotifyEvent         read FOnPanelDblClick      write FOnPanelDblClick;
    property OnLayerThumbDblClick : TNotifyEvent         read FOnLayerThumbDblClick write FOnLayerThumbDblClick;
    property OnMaskThumbDblClick  : TNotifyEvent         read FOnMaskThumbDblClick  write FOnMaskThumbDblClick;
    property OnLogoThumbDblClick  : TNotifyEvent         read FOnLogoThumbDblClick  write FOnLogoThumbDblClick;
  end;

  { TigNormalLayer }

  TigNormalLayer = class(TigCustomLayer)
  private
    FAsBackground : Boolean; // if this layer is a background layer
  public
    constructor Create(AOwner: TigLayerList;
      const ALayerWidth, ALayerHeight: Integer;
      const AFillColor: TColor32 = $00000000;
      const AsBackLayer: Boolean = False);

    function ApplyMask: Boolean;

    property IsAsBackground : Boolean read FAsBackground;
  end;

  { TigLayerList }

  TigLayerCombinedEvent = procedure (ASender: TObject; const ARect: TRect) of object;
  TigMergeLayerEvent = procedure (AResultLayer: TigCustomLayer) of object;

  TigLayerList = class(TPersistent)
  private
    FItems                : TObjectList;
    FSelectedLayer        : TigCustomLayer;
    FCombineResult        : TBitmap32;
    FLayerWidth           : Integer;
    FLayerHeight          : Integer;

    FOnLayerCombined      : TigLayerCombinedEvent;
    FOnSelectionChanged   : TNotifyEvent;
    FOnLayerOrderChanged  : TNotifyEvent;
    FOnMergeVisibleLayers : TigMergeLayerEvent;
    FOnFlattenLayers      : TigMergeLayerEvent;

    FLayerTypeCounter     : TigClassCounter;

    function GetLayerCount: Integer;
    function GetLayerMaxIndex: Integer;
    function GetSelectedLayerIndex: Integer;
    function GetLayer(AIndex: Integer): TigCustomLayer;
    function GetVisbileLayerCount: Integer;
    function GetVisibleNormalLayerCount: Integer;

    procedure BlendLayers; overload;
    procedure BlendLayers(const ARect: TRect); overload;
    procedure DeleteVisibleLayers;
    procedure DeselectAllLayers;
    procedure SetLayerInitialName(ALayer: TigCustomLayer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(ALayer: TigCustomLayer);
    procedure SimpleAdd(ALayer: TigCustomLayer); 
    procedure Insert(AIndex: Integer; ALayer: TigCustomLayer);
    procedure Move(ACurIndex, ANewIndex: Integer);
    procedure SelectLayer(const AIndex: Integer);
    procedure DeleteSelectedLayer;
    procedure DeleteLayer(AIndex: Integer);
    procedure CancelLayer(AIndex: Integer);

    function CanFlattenLayers: Boolean;
    function CanMergeSelectedLayerDown: Boolean;
    function CanMergeVisbleLayers: Boolean;
    function FlattenLayers: Boolean;
    function MergeSelectedLayerDown: Boolean;
    function MergeVisibleLayers: Boolean;
    function IsValidIndex(const AIndex: Integer): Boolean;
    function GetHiddenLayerCount: Integer;

    property CombineResult           : TBitmap32             read FCombineResult;
    property Count                   : Integer               read GetLayerCount;
    property MaxIndex                : Integer               read GetLayerMaxIndex;
    property SelectedIndex           : Integer               read GetSelectedLayerIndex;
    property Layers[AIndex: Integer] : TigCustomLayer        read GetLayer;
    property SelectedLayer           : TigCustomLayer        read FSelectedLayer;
    property OnLayerCombined         : TigLayerCombinedEvent read FOnLayerCombined      write FOnLayerCombined;
    property OnSelectionChanged      : TNotifyEvent          read FOnSelectionChanged   write FOnSelectionChanged;
    property OnLayerOrderChanged     : TNotifyEvent          read FOnLayerOrderChanged  write FOnLayerOrderChanged;
    property OnMergeVisibleLayers    : TigMergeLayerEvent    read FOnMergeVisibleLayers write FOnMergeVisibleLayers;
    property OnFlattenLayers         : TigMergeLayerEvent    read FOnFlattenLayers      write FOnFlattenLayers;
  end;


  { TigClassRec }

  TigClassRec = class(TObject)
  private
    FName  : ShortString;
    FCount : Integer;
  public
    constructor Create(const AClassName: ShortString);

    property Name  : ShortString read FName  write FName;
    property Count : Integer     read FCount write FCount;
  end;


  { TigClassCounter }

  TigClassCounter = class(TPersistent)
  private
    FItems : TObjectList;

    function GetIndex(const AClassName: ShortString): Integer;
    function IsValidIndex(const AIndex: Integer): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Increase(const AClassName: ShortString);
    procedure Decrease(const AClassName: ShortString);
    procedure Clear;

    function GetCount(const AClassName: ShortString): Integer;
  end;

const
  LAYER_THUMB_SIZE = 36;
  LAYER_LOGO_SIZE  = 36;

implementation

uses
{ Delphi }
  SysUtils, Graphics, Math,
{ Graphics32 }
  GR32_LowLevel,
{ miniGlue lib }
  igPaintFuncs;


{ TigCustomLayer }

constructor TigCustomLayer.Create(AOwner: TigLayerList;
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
  FLayerThumbEnabled := False;               
  FLogoThumbEnabled  := False;
  FDefaultLayerName  := '';
  FLayerName         := '';
  FLayerProcessStage := lpsLayer;
  FPixelFeature      := lpfNone;
  
  FOnChange             := nil;
  FOnThumbUpdate        := nil;
  FOnMaskEnabled        := nil;
  FOnMaskDisabled       := nil;
  FOnPanelDblClick      := nil;
  FOnLayerThumbDblClick := nil;
  FOnMaskThumbDblClick  := nil;
  FOnLogoThumbDblClick  := nil;

  FLayerBitmap := TBitmap32.Create;
  with FLayerBitmap do
  begin
    DrawMode    := dmBlend;
    CombineMode := cmMerge;
    
    SetSize(ALayerWidth, ALayerHeight);
    Clear(AFillColor);
  end;

  FMaskBitmap := nil;
  FMaskThumb  := nil;
  FLogoBitmap := nil;
  FLogoThumb  := nil;

  FRealThumbRect := GetRealThumbRect(ALayerWidth, ALayerHeight,
                                     LAYER_THUMB_SIZE, LAYER_THUMB_SIZE);
end;

destructor TigCustomLayer.Destroy;
begin
  FLayerBlendEvent      := nil;
  FOwner                := nil;
  FOnChange             := nil;
  FOnThumbUpdate        := nil;
  FOnPanelDblClick      := nil;
  FOnLayerThumbDblClick := nil;
  FOnMaskThumbDblClick  := nil;
  FOnLogoThumbDblClick  := nil;
  
  FLayerBitmap.Free;
  FLayerThumb.Free;
  FMaskBitmap.Free;
  FMaskThumb.Free;
  FLogoBitmap.Free;
  FLogoThumb.Free;
  
  inherited;
end;

function TigCustomLayer.GetLayerOpacity: Byte;
begin
  Result := FLayerBitmap.MasterAlpha and $FF;
end;

function TigCustomLayer.GetThumbZoomScale(
  const ASrcWidth, ASrcHeight, AThumbWidth, AThumbHeight: Integer): Single;
var
  ws, hs : Single;
begin
  if (ASrcWidth <= AThumbWidth) and (ASrcHeight <= AThumbHeight) then
  begin
    Result := 1.0;
  end
  else
  begin
    ws := AThumbWidth  / ASrcWidth;
    hs := AThumbHeight / ASrcHeight;

    if ws < hs then
    begin
      Result := ws;
    end
    else
    begin
      Result := hs;
    end;
  end;
end;

function TigCustomLayer.GetRealThumbRect(
  const ASrcWidth, ASrcHeight, AThumbWidth, AThumbHeight: Integer;
  const AMarginSize: Integer = 4): TRect;
var
  LThumbWidth  : Integer;
  LThumbHeight : Integer;
  LScale       : Single;
begin
  LScale := GetThumbZoomScale(ASrcWidth, ASrcHeight,
    AThumbWidth - AMarginSize, AThumbHeight - AMarginSize);

  LThumbWidth  := Round(ASrcWidth  * LScale);
  LThumbHeight := Round(ASrcHeight * LScale);

  with Result do
  begin
    Left   := (LAYER_THUMB_SIZE - LThumbWidth)  div 2;
    Top    := (LAYER_THUMB_SIZE - LThumbHeight) div 2;
    Right  := Left + LThumbWidth;
    Bottom := Top  + LThumbHeight;
  end;
end;

procedure TigCustomLayer.SetLayerVisible(AValue: Boolean);
begin
  if FLayerVisible <> AValue then
  begin
    FLayerVisible := AValue;
    Changed;
  end;
end;

procedure TigCustomLayer.SetMaskEnabled(AValue: Boolean);
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

procedure TigCustomLayer.SetMaskLinked(AValue: Boolean);
begin
  if FMaskLinked <> AValue then
  begin
    FMaskLinked := AValue;
    Changed;
  end;
end;

procedure TigCustomLayer.SetLayerBlendMode(AValue: TBlendMode32);
begin
  if FLayerBlendMode <> AValue then
  begin
    FLayerBlendMode  := AValue;
    FLayerBlendEvent := GetBlendMode( Ord(FLayerBlendMode) );
    
    Changed;
  end;
end;

procedure TigCustomLayer.SetLayerOpacity(AValue: Byte);
begin
  if (FLayerBitmap.MasterAlpha and $FF) <> AValue then
  begin
    FLayerBitmap.MasterAlpha := AValue;
    Changed;
  end;
end;

procedure TigCustomLayer.SetLayerProcessStage(
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

procedure TigCustomLayer.LayerBlend(
  F: TColor32; var B: TColor32; M: TColor32);
begin
  FLayerBlendEvent(F, B, M);
end;

procedure TigCustomLayer.InitMask;
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

procedure TigCustomLayer.UpdateLayerThumbnail;
var
  LRect : TRect;
  LBmp  : TBitmap32;
begin
  LRect := FRealThumbRect;
  
  FLayerThumb.Clear( Color32(clBtnFace) );
  DrawCheckerboardPattern(FLayerThumb, LRect, True);

  LBmp := TBitmap32.Create;
  try
    // The thumbnail should not shows the MasterAlpha settings of the layer.
    // The MasterAlpha only takes effect when layer blending.
    LBmp.Assign(FLayerBitmap);
    LBmp.MasterAlpha := 255;

    FLayerThumb.Draw(LRect, LBmp.BoundsRect, LBmp);
  finally
    LBmp.Free;
  end;

  InflateRect(LRect, 1, 1);
  FLayerThumb.FrameRectS(LRect, clBlack32);

  if Assigned(FOnThumbUpdate) then
  begin
    FOnThumbUpdate(Self);
  end;
end;

procedure TigCustomLayer.UpdateMaskThumbnail;
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

procedure TigCustomLayer.UpdateLogoThumbnail;
var
  LRect : TRect;
begin
  LRect := GetRealThumbRect(FLogoBitmap.Width, FLogoBitmap.Height,
                            LAYER_LOGO_SIZE, LAYER_LOGO_SIZE);
  
  FLogoThumb.Clear( Color32(clBtnFace) );
  FLogoThumb.Draw(LRect, FLogoBitmap.BoundsRect, FLogoBitmap);

  InflateRect(LRect, 1, 1);
  FLogoThumb.FrameRectS(LRect, clBlack32);

  if Assigned(FOnThumbUpdate) then
  begin
    FOnThumbUpdate(Self);
  end;
end;

procedure TigCustomLayer.Changed;
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

procedure TigCustomLayer.Changed(const ARect: TRect);
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
function TigCustomLayer.EnableMask: Boolean;
begin
  Result := False;

  if not FMaskEnabled then
  begin
    SetMaskEnabled(True);

    if Assigned(FOnMaskEnabled) then
    begin
      FOnMaskEnabled(Self);
    end;

    Result := FMaskEnabled;
  end;
end;

// discard the mask settings, if any
function TigCustomLayer.DiscardMask: Boolean;
begin
  Result := False;

  if FMaskEnabled then
  begin
    SetMaskEnabled(False);
    Self.Changed;

    if Assigned(FOnMaskDisabled) then
    begin
      FOnMaskDisabled(Self);
    end;

    Result := not FMaskEnabled;
  end;
end;

{ TigNormalLayer }

constructor TigNormalLayer.Create(AOwner: TigLayerList;
  const ALayerWidth, ALayerHeight: Integer;
  const AFillColor: TColor32 = $00000000;
  const AsBackLayer: Boolean = False);
begin
  inherited Create(AOwner, ALayerWidth, ALayerHeight, AFillColor);

  FPixelFeature      := lpfNormalPixelized;
  FAsBackground      := AsBackLayer;
  FDefaultLayerName  := 'Layer';
  FLayerThumbEnabled := True;

  if FAsBackground then
  begin
    FDefaultLayerName := 'Background';
    FLayerName        := FDefaultLayerName;
  end;

  FLayerThumb := TBitmap32.Create;
  with FLayerThumb do
  begin
    SetSize(LAYER_THUMB_SIZE, LAYER_THUMB_SIZE);
  end;

  UpdateLayerThumbnail;
end;

// applying the mask settings to the alpha channel of each pixel on the
// layer bitmap, and then disable the mask
function TigNormalLayer.ApplyMask: Boolean;
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

{ TigLayerList }

constructor TigLayerList.Create;
begin
  inherited;

  FSelectedLayer        := nil;
  FOnLayerCombined      := nil;
  FOnSelectionChanged   := nil;
  FOnLayerOrderChanged  := nil;
  FOnMergeVisibleLayers := nil;
  FOnFlattenLayers      := nil;

  FItems            := TObjectList.Create(True);
  FLayerTypeCounter := TigClassCounter.Create;

  FCombineResult := TBitmap32.Create;
  with FCombineResult do
  begin
    DrawMode := dmBlend;
  end;
end;

destructor TigLayerList.Destroy;
begin
  FItems.Clear;
  FItems.Free;
  FCombineResult.Free;
  FLayerTypeCounter.Free;
  
  inherited;
end;

function TigLayerList.GetLayerCount: Integer;
begin
  Result := FItems.Count;
end;

function TigLayerList.GetLayerMaxIndex: Integer;
begin
  Result := FItems.Count - 1;
end;

function TigLayerList.GetSelectedLayerIndex: Integer;
var
  i : Integer;
begin
  Result := -1;

  if (FItems.Count > 0) and Assigned(FSelectedLayer) then
  begin
    for i := 0 to (FItems.Count - 1) do
    begin
      if FSelectedLayer = Self.Layers[i] then
      begin
        Result := i;
        Break;
      end;
    end;
  end;
end;

function TigLayerList.GetLayer(AIndex: Integer): TigCustomLayer;
begin
  Result := nil;

  if ISValidIndex(AIndex) then
  begin
    Result := TigCustomLayer(FItems.Items[AIndex]);
  end;
end;

function TigLayerList.GetVisbileLayerCount: Integer;
var
  i : Integer;
begin
  Result := 0;

  if FItems.Count > 0 then
  begin
    for i := 0 to (FItems.Count - 1) do
    begin
      if Self.Layers[i].IsLayerVisible then
      begin
        Inc(Result);
      end;
    end;
  end;
end;

// TODO: Perhaps need to rename this function
// to 'GetVisibleNormalPixelizedLayerCount'
function TigLayerList.GetVisibleNormalLayerCount: Integer;
var
  i      : Integer;
  LLayer : TigCustomLayer;
begin
  Result := 0;

  if FItems.Count > 0 then
  begin
    for i := 0 to (FItems.Count - 1) do
    begin
      LLayer := Self.Layers[i];

      if LLayer.IsLayerVisible and
         (LLayer.PixelFeature = lpfNormalPixelized) then
      begin
        Inc(Result);
      end;
    end;
  end;
end;

procedure TigLayerList.BlendLayers;
var
  i, j        : Integer;
  LPixelCount : Integer;
  m           : Cardinal;
  LLayer      : TigCustomLayer;
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
        LLayer := GetLayer(i);

        if not LLayer.IsLayerVisible then
        begin
          Continue;
        end;

        LForeBits := @LLayer.FLayerBitmap.Bits[0];
        LBackBits := @FCombineResult.Bits[0];

        if LLayer.IsMaskEnabled and LLayer.IsMaskLinked then
        begin
          LMaskBits := @LLayer.FMaskBitmap.Bits[0];
        end;

        for j := 1 to LPixelCount do
        begin
          m := LLayer.FLayerBitmap.MasterAlpha;

          if LLayer.IsMaskEnabled and LLayer.IsMaskLinked then
          begin
            // adjust the MasterAlpha with Mask setting
            m := m * (LMaskBits^ and $FF) div 255;
          end;

          LLayer.LayerBlend(LForeBits^, LBackBits^, m);

          Inc(LForeBits);
          Inc(LBackBits);
          if LLayer.IsMaskEnabled and LLayer.IsMaskLinked then
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

procedure TigLayerList.BlendLayers(const ARect: TRect);
var
  LRect        : TRect;
  i            : Integer;
  x, y, xx, yy : Integer;
  LRectWidth   : Integer;
  LRectHeight  : Integer;
  m            : Cardinal;
  LLayer       : TigCustomLayer;
  LResultRow   : PColor32Array;
  LLayerRow    : PColor32Array;
  LMaskRow     : PColor32Array;
begin
{$RANGECHECKS OFF}

  LMaskRow := nil;

  LRect.Left   := Math.Min(ARect.Left, ARect.Right);
  LRect.Right  := Math.Max(ARect.Left, ARect.Right);
  LRect.Top    := Math.Min(ARect.Top, ARect.Bottom);
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
    FCombineResult.FillRectS(LRect, $00000000);

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
          LLayer := GetLayer(i);

          if not LLayer.IsLayerVisible then
          begin
            Continue;
          end;

          // get entries of one line pixels on each layer bitmap ...
          LLayerRow := LLayer.FLayerBitmap.ScanLine[yy];

          if LLayer.IsMaskEnabled and LLayer.IsMaskLinked then
          begin
            // get entries of one line pixels on each layer mask bitmap, if any ...
            LMaskRow := LLayer.FMaskBitmap.ScanLine[yy];
          end;

          for x := 0 to (LRectWidth - 1) do
          begin
            xx := x + LRect.Left;

            if (xx < 0) or (xx >= FLayerWidth) then
            begin
              Continue;
            end;

            // blending ...
            m := LLayer.FLayerBitmap.MasterAlpha;

            if LLayer.IsMaskEnabled and LLayer.IsMaskLinked then
            begin
              // adjust the MasterAlpha with Mask setting
              m := m * (LMaskRow[xx] and $FF) div 255;
            end;

            LLayer.LayerBlend(LLayerRow[xx], LResultRow[xx], m);
          end;
        end;
      end;
    end;

  finally
    FCombineResult.EndUpdate;
  end;

  if Assigned(FOnLayerCombined) then
  begin
    FOnLayerCombined(Self, LRect);
  end;
     
{$RANGECHECKS ON}
end;

procedure TigLayerList.DeleteVisibleLayers;
var
  i      : Integer;
  LLayer : TigCustomLayer;
begin
  if FItems.Count > 0 then
  begin
    for i := (FItems.Count - 1) downto 0 do
    begin
      LLayer := Self.Layers[i];

      if LLayer.IsLayerVisible then
      begin
        FItems.Delete(i);
      end;
    end;
  end;
end;

procedure TigLayerList.DeselectAllLayers;
var
  i : Integer;
begin
  if FItems.Count > 0 then
  begin
    Self.FSelectedLayer := nil;

    for i := 0 to (FItems.Count - 1) do
    begin
      // NOTICE :
      //   Setting with field FSelected, not with property Selected,
      //   for avoiding the setter of property be invoked.
      GetLayer(i).FSelected := False;
    end;
  end;
end;

procedure TigLayerList.SetLayerInitialName(ALayer: TigCustomLayer);
var
  LNumber : Integer;
begin
  if Assigned(ALayer) then
  begin
    if ALayer is TigNormalLayer then
    begin
      if TigNormalLayer(ALayer).IsAsBackground then
      begin
        Exit;
      end;
    end;

    LNumber := FLayerTypeCounter.GetCount(ALayer.ClassName);
    ALayer.LayerName := ALayer.FDefaultLayerName + ' ' + IntToStr(LNumber);
  end;
end;

procedure TigLayerList.Add(ALayer: TigCustomLayer);
begin
  if Assigned(ALayer) then
  begin
    FItems.Add(ALayer);

    // we don't count background layers
    if ALayer is TigNormalLayer then
    begin
      if not TigNormalLayer(ALayer).IsAsBackground then
      begin
        FLayerTypeCounter.Increase(ALayer.ClassName);
      end;
    end
    else
    begin
      FLayerTypeCounter.Increase(ALayer.ClassName);
    end;

    // first adding
    if FItems.Count = 1 then
    begin
      FLayerWidth  := ALayer.FLayerBitmap.Width;
      FLayerHeight := ALayer.FLayerBitmap.Height;
      
      FCombineResult.SetSize(FLayerWidth, FLayerHeight);
    end;

    BlendLayers;
    SelectLayer(FItems.Count - 1);

    if not FSelectedLayer.IsDuplicated then
    begin
      SetLayerInitialName(FSelectedLayer);
    end;
  end;
end;

// This procedure does the similar thing as the Add() procedure above,
// but it won't blend layers, invoke callback functions, etc.
// It simply adds a layer to a layer list.
procedure TigLayerList.SimpleAdd(ALayer: TigCustomLayer);
begin
  if Assigned(ALayer) then
  begin
    FItems.Add(ALayer);
    
    // first adding
    if FItems.Count = 1 then
    begin
      FLayerWidth  := ALayer.FLayerBitmap.Width;
      FLayerHeight := ALayer.FLayerBitmap.Height;
      
      FCombineResult.SetSize(FLayerWidth, FLayerHeight);
    end;
  end;
end; 

procedure TigLayerList.Insert(AIndex: Integer; ALayer: TigCustomLayer);
begin
  if Assigned(ALayer) then
  begin
    AIndex := Clamp(AIndex, 0, FItems.Count);
    FItems.Insert(AIndex, ALayer);
    
    // we don't count background layers
    if ALayer is TigNormalLayer then
    begin
      if not TigNormalLayer(ALayer).IsAsBackground then
      begin
        FLayerTypeCounter.Increase(ALayer.ClassName);
      end;
    end
    else
    begin
      FLayerTypeCounter.Increase(ALayer.ClassName);
    end;
    
    BlendLayers;
    SelectLayer(AIndex);

    if not FSelectedLayer.IsDuplicated then
    begin
      SetLayerInitialName(FSelectedLayer);
    end;
  end;
end;

procedure TigLayerList.Move(ACurIndex, ANewIndex: Integer);
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

procedure TigLayerList.SelectLayer(const AIndex: Integer);
var
  LLayer : TigCustomLayer;
begin
  LLayer := GetLayer(AIndex);

  if Assigned(LLayer) then
  begin
    if FSelectedLayer <> LLayer then
    begin
      DeselectAllLayers;

      FSelectedLayer           := LLayer;
      FSelectedLayer.FSelected := True;

      if Assigned(FOnSelectionChanged) then
      begin
        FOnSelectionChanged(Self);
      end;
    end;
  end;
end;

procedure TigLayerList.DeleteSelectedLayer;
var
  LIndex : Integer;
begin
  LIndex := GetSelectedLayerIndex;
  DeleteLayer(LIndex);
end;

procedure TigLayerList.DeleteLayer(AIndex: Integer);
begin
  if (FItems.Count = 1) or ( not IsValidIndex(AIndex) ) then
  begin
    Exit;
  end;

  FSelectedLayer := nil;

  FItems.Delete(AIndex);
  BlendLayers;

  // select the previous layer ...

  AIndex := AIndex - 1;

  if AIndex < 0 then
  begin
    AIndex := 0;
  end;

  SelectLayer(AIndex);
end;

// This method is similar to DeleteLayer(), but it will also
// modify the statistics in Layer Type Counter.
procedure TigLayerList.CancelLayer(AIndex: Integer);
var
  LLayer : TigCustomLayer;
begin
  if (FItems.Count = 1) or ( not IsValidIndex(AIndex) ) then
  begin
    Exit;
  end;

  LLayer := Self.Layers[AIndex];
  Self.FLayerTypeCounter.Decrease(LLayer.ClassName);

  DeleteLayer(AIndex);
end;

function TigLayerList.CanFlattenLayers: Boolean;
begin
  Result := False;

  if FItems.Count > 0 then
  begin
    if FItems.Count = 1 then
    begin
      if Self.SelectedLayer is TigNormalLayer then
      begin
        // If the only layer is a Normal layer but not as background layer,
        // we could flatten it as a background layer
        Result := not TigNormalLayer(Self.SelectedLayer).IsAsBackground;
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

function TigLayerList.CanMergeSelectedLayerDown: Boolean;
var
  LPrevIndex : Integer;
  LPrevLayer : TigCustomLayer;
begin
  Result     := False;
  LPrevIndex := Self.SelectedIndex - 1;

  if IsValidIndex(LPrevIndex) then
  begin
    LPrevLayer := Self.Layers[LPrevIndex];

    // can only merge down to a visible Normal layer
    Result := FSelectedLayer.IsLayerVisible and
              LPrevLayer.IsLayerVisible and
              (LPrevLayer.PixelFeature = lpfNormalPixelized);
  end;
end;

function TigLayerList.CanMergeVisbleLayers: Boolean;
begin
  Result := FSelectedLayer.IsLayerVisible and
            (GetVisibleNormalLayerCount > 0) and (GetVisbileLayerCount > 1);
end;

function TigLayerList.FlattenLayers: Boolean;
var
  LBackLayer : TigCustomLayer;
begin
  Result := CanFlattenLayers;
  
  if Result then
  begin
    LBackLayer := TigNormalLayer.Create(Self, FLayerWidth, FLayerHeight, clWhite32, True);

    with LBackLayer do
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
    FLayerTypeCounter.Clear;
    Self.Add(LBackLayer);
    Self.SelectLayer(0);

    if Assigned(FOnFlattenLayers) then
    begin
      FOnFlattenLayers(Self.FSelectedLayer);
    end;
  end;
end;

function TigLayerList.MergeSelectedLayerDown: Boolean;
var
  i             : Integer;
  m             : Cardinal;
  LMaskEffected : Boolean;
  LPrevIndex    : Integer;
  LPrevLayer    : TigCustomLayer;
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
    LPrevLayer := Self.Layers[LPrevIndex];

    LForeBits := @FSelectedLayer.FLayerBitmap.Bits[0];
    LBackBits := @LPrevLayer.FLayerBitmap.Bits[0];

    if (FSelectedLayer.IsMaskEnabled) and (FSelectedLayer.IsMaskLinked) then
    begin
      LMaskBits     := @FSelectedLayer.FMaskBitmap.Bits[0];
      LMaskEffected := True;
    end;

    for i := 1 to (FLayerWidth * FLayerHeight) do
    begin
      m := FSelectedLayer.FLayerBitmap.MasterAlpha;
      
      if LMaskEffected then
      begin
        // adjust the MasterAlpha with Mask setting
        m := m * (LMaskBits^ and $FF) div 255;
      end;

      FSelectedLayer.LayerBlend(LForeBits^, LBackBits^, m);

      Inc(LForeBits);
      Inc(LBackBits);

      if LMaskEffected then
      begin
        Inc(LMaskBits);
      end;
    end;

    LPrevLayer.UpdateLayerThumbnail;

    // this routine will make the previous layer be selected automatically
    DeleteSelectedLayer;
    BlendLayers;
  end;
end;

function TigLayerList.MergeVisibleLayers: Boolean;
var
  LMergedLayer  : TigCustomLayer;
  LAsBackground : Boolean;
begin
  Result := Self.CanMergeVisbleLayers;

  if Result then
  begin
    LAsBackground := False;
    
    if FSelectedLayer is TigNormalLayer then
    begin
      LAsBackground := TigNormalLayer(FSelectedLayer).FAsBackground;
    end;

    LMergedLayer := TigNormalLayer.Create(Self,
      FLayerWidth, FLayerHeight, $00000000, LAsBackground);

    with LMergedLayer do
    begin
      FLayerBitmap.Assign(FCombineResult);
      UpdateLayerThumbnail;

      FLayerName := FSelectedLayer.FLayerName;
    end;
    
    DeleteVisibleLayers;
    FSelectedLayer := nil;

    FItems.Insert(0, LMergedLayer);
    Self.SelectLayer(0);

    if Assigned(FOnMergeVisibleLayers) then
    begin
      FOnMergeVisibleLayers(Self.FSelectedLayer);
    end;
  end;
end;

function TigLayerList.IsValidIndex(const AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex < FItems.Count);
end;

function TigLayerList.GetHiddenLayerCount: Integer;
var
  i : Integer;
begin
  Result := 0;

  if FItems.Count > 0 then
  begin
    for i := 0 to (FItems.Count - 1) do
    begin
      if not Self.Layers[i].IsLayerVisible then
      begin
        Inc(Result);
      end;
    end;
  end;
end;

{ TigClassRec }

constructor TigClassRec.Create(const AClassName: ShortString);
begin
  inherited Create;

  FName  := AClassName;
  FCount := 1;
end;

{ TigClassCounter }

constructor TigClassCounter.Create;
begin
  inherited;

  FItems := TObjectList.Create;
end;

destructor TigClassCounter.Destroy;
begin
  FItems.Clear;
  FItems.Free;

  inherited;
end;

procedure TigClassCounter.Clear;
begin
  FItems.Clear;
end;

// This method will decrease the number of a class name in the counter.
procedure TigClassCounter.Decrease(const AClassName: ShortString);
var
  LIndex : Integer;
  LRec   : TigClassRec;
begin
  if AClassName = '' then
  begin
    Exit;
  end;

  LIndex := Self.GetIndex(AClassName);

  if Self.IsValidIndex(LIndex) then
  begin
    LRec       := TigClassRec(FItems.Items[LIndex]);
    LRec.Count := LRec.Count - 1;

    if LRec.Count = 0 then
    begin
      FItems.Delete(LIndex);
    end;
  end;
end;

function TigClassCounter.GetCount(const AClassName: ShortString): Integer;
var
  i    : Integer;
  LRec : TigClassRec;
begin
  Result := 0;

  if AClassName = '' then
  begin
    Exit;
  end;

  if FItems.Count > 0 then
  begin
    for i := 0 to (FItems.Count - 1) do
    begin
      LRec := TigClassRec(FItems.Items[i]);

      if AClassName = LRec.Name then
      begin
        Result := LRec.Count;
        Break;
      end;
    end;
  end;
end;

function TigClassCounter.GetIndex(const AClassName: ShortString): Integer;
var
  i    : Integer;
  LRec : TigClassRec;
begin
  Result := -1;

  if AClassName = '' then
  begin
    Exit;
  end;

  if FItems.Count > 0 then
  begin
    for i := 0 to (FItems.Count - 1) do
    begin
      LRec := TigClassRec(FItems.Items[i]);

      if AClassName = LRec.Name then
      begin
        Result := i;
        Break;
      end;
    end;
  end;
end;

// This method will increase the number of a class name in the counter.
procedure TigClassCounter.Increase(const AClassName: ShortString);
var
  LIndex : Integer;
  LRec   : TigClassRec;
begin
  if AClassName = '' then
  begin
    Exit;
  end;

  LIndex := Self.GetIndex(AClassName);

  if Self.IsValidIndex(LIndex) then
  begin
    LRec       := TigClassRec(FItems.Items[LIndex]);
    LRec.Count := LRec.Count + 1;
  end
  else
  begin
    LRec := TigClassRec.Create(AClassName);
    FItems.Add(LRec);
  end;
end;

function TigClassCounter.IsValidIndex(const AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex < FItems.Count);
end;

end.
