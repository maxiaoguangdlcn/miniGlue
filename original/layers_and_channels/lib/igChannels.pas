unit igChannels;

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
 * Update Date: November 18th, 2014
 *
 * The Initial Developer of this unit are
 *   Ma Xiaoguang and Ma Xiaoming < gmbros[at]hotmail[dot]com >
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

interface

uses
{ Standard }
  Classes,
  Contnrs,
{ Graphics32 }
  GR32,
  GR32_Layers;

type
  TigMaskColorIndicator = (mciMaskedArea, mciSelectedArea);
  TigMaskColorType      = (mctColor, mctGrayscale);

  { TigCustomChannel }
  
  TigCustomChannel = class(TPersistent)
  protected
    FChannelThumb   : TBitmap32;
    FSelected       : Boolean;   // indicate whether the channel is selected
    FChannelVisible : Boolean;   // indicate whether the channel is visible
    FChannelName    : string;

    FOnThumbUpdate  : TNotifyEvent;  

    function GetRealThumbRect(ASrcBitmap: TCustomBitmap32;
      const AMarginSize: Integer = 4): TRect;

    function GetThumbZoomScale(
      const ASrcWidth, ASrcHeight, AThumbWidth, AThumbHeight: Integer): Single;

    procedure SetChannelVisible(const AValue: Boolean); virtual;
  public
    constructor Create;
    destructor Destroy; override;

    procedure UpdateChannelThumbnail(ABitmap: TCustomBitmap32); virtual; abstract;

    property ChannelName       : string       read FChannelName    write FChannelName;
    property ChannelThumbnail  : TBitmap32    read FChannelThumb;
    property IsChannelVisible  : Boolean      read FChannelVisible write SetChannelVisible;
    property IsSelected        : Boolean      read FSelected       write FSelected;
    property OnThumbnailUpdate : TNotifyEvent read FOnThumbUpdate  write FOnThumbUpdate;
  end;

  { TigAlphaChannel }

  TigAlphaChannel = class(TigCustomChannel)
  private
    FChannelLayer       : TBitmapLayer;
    FMaskColor          : TColor32;
    FMaskColorIndicator : TigMaskColorIndicator;
    FMaskColorType      : TigMaskColorType;

    function GetMaskOpacity: Byte;

    procedure ChannelLayerBlend(F: TColor32; var B: TColor32; M: TColor32);
    procedure SetMaskColorIndicator(AValue: TigMaskColorIndicator);
    procedure SetMaskOpacity(AValue: Byte);
  protected
    procedure SetChannelVisible(const AValue: Boolean); override;
  public
    constructor Create; overload;

    constructor Create(ACollection: TLayerCollection;
      const ALayerIndex, ALayerBmpWidth, ALayerBmpHeight: Integer;
      const ALayerLocation: TFloatRect; const AMaskColor: TColor32); overload;

    constructor Create(ACollection: TLayerCollection;
      const ALayerIndex: Integer; AChannelBmp: TBitmap32;
      const ALayerLocation: TFloatRect; const AMaskColor: TColor32); overload;

    destructor Destroy; override;

    procedure UpdateChannelThumbnail; reintroduce;

    property ChannelLayer       : TBitmapLayer          read FChannelLayer;
    property MaskColor          : TColor32              read FMaskColor          write FMaskColor;
    property MaskColorIndicator : TigMaskColorIndicator read FMaskColorIndicator write SetMaskColorIndicator;
    property MaskColorType      : TigMaskColorType      read FMaskColorType      write FMaskColorType;
    property MaskOpacity        : Byte                  read GetMaskOpacity      write SetMaskOpacity;
  end;

  { TigChannelList }

  TigChannelList = class(TPersistent)
  protected
    FItems           : TObjectList;
    FSelectedIndex   : Integer;
    FSelectedChannel : TigCustomChannel;

    function GetChannel(AIndex: Integer): TigCustomChannel;
    function GetFirstSelectedChannelIndex: Integer;
    function GetChannelCount: Integer;
    function GetChannelMaxIndex: Integer;
    function GetSelectedChannelCount: Integer;
    function GetVisibleChannelCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(AChannel: TigCustomChannel);
    procedure DeleteChannel(const AIndex: Integer);
    procedure DeleteSelectedChannels;
    procedure DeselectAllChannels;
    procedure SelectAllChannels;
    procedure SelectChannel(const AIndex: Integer; const AMultiSelect: Boolean);
    procedure ShowAllChannels;
    procedure HideAllChannels;

    function IsValidIndex(const AIndex: Integer): Boolean;
    function Move(ACurIndex, ANewIndex: Integer): Boolean; virtual;

    property Count                     : Integer          read GetChannelCount;
    property FirstSelectedIndex        : Integer          read GetFirstSelectedChannelIndex;
    property MaxIndex                  : Integer          read GetChannelMaxIndex;
    property Channels[AIndex: Integer] : TigCustomChannel read GetChannel;
    property SelectedChannelCount      : Integer          read GetSelectedChannelCount;
    property SelectedIndex             : Integer          read FSelectedIndex;
    property SelectedChannel           : TigCustomChannel read FSelectedChannel;
    property VisibleChannelCount       : Integer          read GetVisibleChannelCount;
  end;

  { TigAlphaChannelList }

  TigAlphaChannelList = class(TigChannelList)
  private
    FAccumulatedCount : Integer;   // count how many alpha channels have been added to this list

    function GetSelectedAlphaChannel: TigAlphaChannel;
  public
    constructor Create;

    procedure Add(AChannel: TigAlphaChannel; const AAccumulateCount: Boolean); reintroduce;
    procedure SetMaskColorTypeForVisibleChannels(const AType: TigMaskColorType);

    property SelectedChannel: TigAlphaChannel read GetSelectedAlphaChannel;
  end;

const
  CHANNEL_THUMB_SIZE = 36;

implementation

uses
{ Standard }
  SysUtils,
  Graphics,
{ external lib}
  GR32_Add_BlendModes;

{ TigCustomChannel }

constructor TigCustomChannel.Create;
begin
  inherited Create;

  FChannelThumb := TBitmap32.Create;
  with FChannelThumb do
  begin
    SetSize(CHANNEL_THUMB_SIZE, CHANNEL_THUMB_SIZE);
  end;

  FSelected       := True;
  FChannelVisible := True;
  FChannelName    := '';

  FOnThumbUpdate := nil;    
end;

destructor TigCustomChannel.Destroy;
begin
  FOnThumbUpdate := nil;

  FChannelThumb.Free;

  inherited;
end;

function TigCustomChannel.GetRealThumbRect(ASrcBitmap: TCustomBitmap32;
  const AMarginSize: Integer = 4): TRect;
var
  LThumbWidth  : Integer;
  LThumbHeight : Integer;
  LScale       : Single;
begin
  LScale := GetThumbZoomScale(ASrcBitmap.Width, ASrcBitmap.Height,
    CHANNEL_THUMB_SIZE - AMarginSize, CHANNEL_THUMB_SIZE - AMarginSize);

  LThumbWidth  := Round(ASrcBitmap.Width  * LScale);
  LThumbHeight := Round(ASrcBitmap.Height * LScale);

  with Result do
  begin
    Left   := (CHANNEL_THUMB_SIZE - LThumbWidth)  div 2;
    Top    := (CHANNEL_THUMB_SIZE - LThumbHeight) div 2;
    Right  := Left + LThumbWidth;
    Bottom := Top  + LThumbHeight;
  end;
end;

function TigCustomChannel.GetThumbZoomScale(
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

procedure TigCustomChannel.SetChannelVisible(const AValue: Boolean);
begin
  if FChannelVisible <> AValue then
  begin
    FChannelVisible := AValue;
  end;
end;

{ TigAlphaChannel }

constructor TigAlphaChannel.Create;
begin
  inherited;

  FSelected           := False;
  FMaskColor          := clRed32;
  FMaskColorIndicator := mciMaskedArea;
  FMaskColorType      := mctColor;
end;

constructor TigAlphaChannel.Create(ACollection: TLayerCollection;
  const ALayerIndex, ALayerBmpWidth, ALayerBmpHeight: Integer;
  const ALayerLocation: TFloatRect; const AMaskColor: TColor32);
begin
  if not Assigned(ACollection) then
  begin
    raise Exception.Create('[Error] TigAlphaChannel.Create(): parameter ACollection is nil.');
  end;

  if ALayerIndex < 0 then
  begin
    raise Exception.Create('[Error] TigAlphaChannel.Create(): parameter ALayerIndex less than zero.');
  end;

  Self.Create;
  FMaskColor := AMaskColor;

  ACollection.Insert(ALayerIndex, TBitmapLayer);

  FChannelLayer := TBitmapLayer(ACollection[ALayerIndex]);

  with FChannelLayer do
  begin
    Bitmap.DrawMode       := dmCustom;
    Bitmap.OnPixelCombine := Self.ChannelLayerBlend;
    Bitmap.MasterAlpha    := 128;
    
    Bitmap.SetSize(ALayerBmpWidth, ALayerBmpHeight);
    Bitmap.Clear($FF000000);
    
    Location := ALayerLocation;
    Scaled   := True;
    Visible  := True;
  end;

  UpdateChannelThumbnail;
end;

constructor TigAlphaChannel.Create(ACollection: TLayerCollection;
  const ALayerIndex: Integer; AChannelBmp: TBitmap32;
  const ALayerLocation: TFloatRect; const AMaskColor: TColor32);
begin
  if not Assigned(ACollection) then
  begin
    raise Exception.Create('[Error] TigAlphaChannel.Create(): parameter ACollection is nil.');
  end;

  if not Assigned(AChannelBmp) then
  begin
    raise Exception.Create('[Error] TigAlphaChannel.Create(): parameter AChannelBmp is nil.');
  end;

  if ALayerIndex < 0 then
  begin
    raise Exception.Create('[Error] TigAlphaChannel.Create(): parameter ALayerIndex less than zero.');
  end;

  Self.Create;
  FMaskColor := AMaskColor;

  ACollection.Insert(ALayerIndex, TBitmapLayer);

  FChannelLayer := TBitmapLayer(ACollection[ALayerIndex]);

  with FChannelLayer do
  begin
    Bitmap.Assign(AChannelBmp);
    
    Bitmap.DrawMode       := dmCustom;
    Bitmap.OnPixelCombine := Self.ChannelLayerBlend;
    Bitmap.MasterAlpha    := 128;
    
    Location := ALayerLocation;
    Scaled   := True;
    Visible  := True;
  end;

  UpdateChannelThumbnail;
end;

destructor TigAlphaChannel.Destroy;
begin
  FChannelLayer.Free;

  inherited;
end;

procedure TigAlphaChannel.ChannelLayerBlend(
  F: TColor32; var B: TColor32; M: TColor32);
var
  LAlpha   : Cardinal;
  LForeRGB : TColor32;
begin
  LAlpha := ( 255 - (F and $FF) ) shl 24;

  case FMaskColorType of
    mctColor:
      begin
        LForeRGB := LAlpha or (FMaskColor and $FFFFFF);
        
        Blendmode.NormalBlend(LForeRGB, B, M);
      end;

    mctGrayscale:
      begin
        B := F;
      end;
  end;
end;

function TigAlphaChannel.GetMaskOpacity: Byte;
begin
  Result := FChannelLayer.Bitmap.MasterAlpha;
end;

procedure TigAlphaChannel.SetChannelVisible(const AValue: Boolean);
begin
  inherited;

  FChannelLayer.Visible := FChannelVisible;
end;

procedure TigAlphaChannel.SetMaskColorIndicator(
  AValue: TigMaskColorIndicator);
var
  i       : Integer;
  r, g, b : Cardinal;
  p       : PColor32;
begin
  if FMaskColorIndicator <> AValue then
  begin
    FMaskColorIndicator := AValue;

    // invert channel layer map ...
    p := @FChannelLayer.Bitmap.Bits[0];

    for i := 1 to (FChannelLayer.Bitmap.Width * FChannelLayer.Bitmap.Height) do
    begin
      r := 255 - (p^ shr 16 and $FF);
      g := 255 - (p^ shr 8 and $FF);
      b := 255 - (p^ and $FF);

      p^ := (p^ and $FF000000) or (r shl 16) or (g shl 8) or b;

      Inc(p);
    end;

    Self.UpdateChannelThumbnail;
  end;
end;

procedure TigAlphaChannel.SetMaskOpacity(AValue: Byte);
begin
  if FChannelLayer.Bitmap.MasterAlpha <> AValue then
  begin
    FChannelLayer.Bitmap.MasterAlpha := AValue;
  end;
end;

procedure TigAlphaChannel.UpdateChannelThumbnail;
var
  LRect : TRect;
  LBmp  : TBitmap32;
begin
  if Assigned(FChannelLayer) then
  begin
    LRect := Self.GetRealThumbRect(FChannelLayer.Bitmap);

    FChannelThumb.Clear( Color32(clBtnFace) );

    LBmp := TBitmap32.Create;
    try
      LBmp.Assign(FChannelLayer.Bitmap);
      LBmp.DrawMode := dmOpaque;

      FChannelThumb.Draw(LRect, LBmp.BoundsRect, LBmp);
    finally
      LBmp.Free;
    end;

    InflateRect(LRect, 1, 1);
    FChannelThumb.FrameRectS(LRect, clBlack32);

    if Assigned(FOnThumbUpdate) then
    begin
      FOnThumbUpdate(Self);
    end;
  end;
end;

{ TigChannelList }

constructor TigChannelList.Create;
begin
  inherited;

  FItems           := TObjectList.Create;
  FSelectedIndex   := -1;
  FSelectedChannel := nil;
end;

destructor TigChannelList.Destroy;
begin
  FItems.Free;

  inherited;
end;

procedure TigChannelList.Add(AChannel: TigCustomChannel);
begin
  if Assigned(AChannel) then
  begin
    FItems.Add(AChannel);
  end;
end;

procedure TigChannelList.DeleteChannel(const AIndex: Integer);
begin
  if not IsValidIndex(AIndex) then
  begin
    Exit;
  end;

  FItems.Delete(AIndex);
  DeselectAllChannels;
end;

procedure TigChannelList.DeleteSelectedChannels;
var
  i : Integer;
begin
  if FItems.Count > 0 then
  begin
    for i := (FItems.Count - 1) downto 0 do
    begin
      if TigCustomChannel(FItems.Items[i]).IsSelected then
      begin
        FItems.Delete(i);
      end;
    end;

    FSelectedIndex   := -1;
    FSelectedChannel := nil;
  end;
end;

procedure TigChannelList.DeselectAllChannels;
var
  i        : Integer;
  LChannel : TigCustomChannel;
begin
  if FItems.Count > 0 then
  begin
    for i := 0 to (FItems.Count - 1) do
    begin
      LChannel           := TigCustomChannel(FItems.Items[i]);
      LChannel.FSelected := False;
    end;

    FSelectedChannel := nil;
    FSelectedIndex   := -1;
  end;
end;

function TigChannelList.GetChannel(AIndex: Integer): TigCustomChannel;
begin
  Result := nil;

  if IsValidIndex(AIndex) then
  begin
    Result := TigCustomChannel(FItems.Items[AIndex]);
  end;
end;

function TigChannelList.GetFirstSelectedChannelIndex: Integer;
var
  i : Integer;
begin
  Result := -1;

  if FItems.Count > 0 then
  begin
    for i := 0 to (FItems.Count - 1) do
    begin
      if TigCustomChannel(FItems.Items[i]).FSelected then
      begin
        Result := i;
        Break;
      end;
    end;
  end;
end;

function TigChannelList.GetChannelCount: Integer;
begin
  Result := FItems.Count;
end;

function TigChannelList.GetChannelMaxIndex: Integer;
begin
  Result := FItems.Count - 1;
end;

function TigChannelList.GetSelectedChannelCount: Integer;
var
  i : Integer;
begin
  Result := 0;

  if FItems.Count > 0 then
  begin
    for i := 0 to (FItems.Count - 1) do
    begin
      if TigCustomChannel(FItems.Items[i]).IsSelected then
      begin
        Inc(Result);
      end;
    end;
  end;
end;

function TigChannelList.GetVisibleChannelCount: Integer;
var
  i : Integer;
begin
  Result := 0;

  if FItems.Count > 0 then
  begin
    for i := 0 to (FItems.Count - 1) do
    begin
      if TigCustomChannel(FItems.Items[i]).IsChannelVisible then
      begin
        Inc(Result);
      end;
    end;
  end;
end;

procedure TigChannelList.HideAllChannels;
var
  i        : Integer;
  LChannel : TigCustomChannel;
begin
  if FItems.Count > 0 then
  begin
    for i := 0 to (FItems.Count - 1) do
    begin
      LChannel                  := TigCustomChannel(FItems.Items[i]);
      LChannel.IsChannelVisible := False;
    end;
  end;
end;

function TigChannelList.IsValidIndex(const AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex < FItems.Count);
end;

function TigChannelList.Move(ACurIndex, ANewIndex: Integer): Boolean;
begin
  Result := False;
  
  if IsValidIndex(ACurIndex) and
     IsValidIndex(ANewIndex) and
     (ACurIndex <> ANewIndex) then
  begin
    FItems.Move(ACurIndex, ANewIndex);
    Result := True;
  end;
end;

procedure TigChannelList.SelectAllChannels;
var
  i        : Integer;
  LChannel : TigCustomChannel;
begin
  if FItems.Count > 0 then
  begin
    for i := 0 to (FItems.Count - 1) do
    begin
      LChannel           := TigCustomChannel(FItems.Items[i]);
      LChannel.FSelected := True;
    end;

    FSelectedChannel := nil;
    FSelectedIndex   := -1;
  end;
end;

procedure TigChannelList.SelectChannel(const AIndex: Integer;
  const AMultiSelect: Boolean);
begin
  if not IsValidIndex(AIndex) then
  begin
    Exit;
  end;

  if not AMultiSelect then
  begin
    DeselectAllChannels;

    FSelectedIndex              := AIndex;
    FSelectedChannel            := TigCustomChannel(FItems.Items[AIndex]);
    FSelectedChannel.IsSelected := True;
  end
  else
  begin
    TigCustomChannel(FItems.Items[AIndex]).IsSelected := True;

    if GetSelectedChannelCount = 1 then
    begin
      // if the selected channel above is the only one in the list ...
      FSelectedIndex   := AIndex;
      FSelectedChannel := TigCustomChannel(FItems.Items[AIndex]);
    end
    else
    begin
      FSelectedIndex   := -1;
      FSelectedChannel := nil;
    end;
  end;
end;

procedure TigChannelList.ShowAllChannels;
var
  i        : Integer;
  LChannel : TigCustomChannel;
begin
  if FItems.Count > 0 then
  begin
    for i := 0 to (FItems.Count - 1) do
    begin
      LChannel                  := TigCustomChannel(FItems.Items[i]);
      LChannel.IsChannelVisible := True;
    end;
  end;
end;

{ TigAlphaChannelList }

constructor TigAlphaChannelList.Create;
begin
  inherited;

  FAccumulatedCount := 0;
end;

procedure TigAlphaChannelList.Add(AChannel: TigAlphaChannel;
  const AAccumulateCount: Boolean);
begin
  if Assigned(AChannel) then
  begin
    FItems.Add(AChannel);
  end;

  if AAccumulateCount then
  begin
    Inc(FAccumulatedCount);

    // give the added alpha channel a default name
    AChannel.ChannelName := 'Alpha ' + IntToStr(FAccumulatedCount);
  end;
end;

function TigAlphaChannelList.GetSelectedAlphaChannel: TigAlphaChannel;
begin
  Result := nil;

  if Assigned(FSelectedChannel) then
  begin
    Result := TigAlphaChannel(FSelectedChannel);
  end;
end;

procedure TigAlphaChannelList.SetMaskColorTypeForVisibleChannels(
  const AType: TigMaskColorType);
var
  i             : Integer;
  LAlphaChannel : TigAlphaChannel;
begin
  if Self.Count > 0 then
  begin
    for i := 0 to Self.MaxIndex do
    begin
      LAlphaChannel := TigAlphaChannel(Self.Channels[i]);

      if LAlphaChannel.IsChannelVisible then
      begin
        LAlphaChannel.MaskColorType := AType;
      end;
    end;
  end;
end;


end.
