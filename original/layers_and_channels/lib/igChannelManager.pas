unit igChannelManager;

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
{ Graphics32 }
  GR32,
  GR32_Layers,
{ miniGlue lib }
  igChannels;

type
  // channel types
  TigChannelSelector = (csRed, csGreen, csBlue, csGrayscale, csAlpha);
  TigChannelSet      = set of TigChannelSelector;

  TigChannelType = (ctColorChannel,
                    ctAlphaChannel,
                    ctLayerMaskChannel,
                    ctQuickMaskChannel);

  TigChannelDblClick = procedure (AChannel: TigCustomChannel; const AChannelType: TigChannelType) of object;
  TigChannelVisibleChanged = procedure (const AChannelType: TigChannelType) of object;
  TigInsertAlphaChannelEvent = procedure (AList: TigAlphaChannelList; const AIndex: Integer) of object;
  TigSelectedChannelChangedEvent = procedure (const ACurrentChannelType: TigChannelType) of object;


  { TigCustomChannelManager }

  TigCustomChannelManager = class(TPersistent)
  private
    function GetSelectedAlphaChannel: TigAlphaChannel;
    procedure SetChannelLayerBaseIndex(const AValue: Integer);
  protected
    FColorChannelList        : TigChannelList;  // holding color channels for RGB, Red, Green, Blue, CMYK, Cyan, etc.
    FAlphaChannelList        : TigAlphaChannelList;
    FLayerMaskChannel        : TigAlphaChannel;
    FQuickMaskChannel        : TigAlphaChannel;
    FCurrentChannelType      : TigChannelType;
    FChannelPreviewSet       : TigChannelSet;        // indicate which channel will be shown on the channel preview layer
    FSelectedColorChannels   : TigChannelSet;        // indicate which color channels have been selected
    FAlphaChannelMultiSelect : Boolean;              // whether we could select multiple alpha channels at a time

    // Pointer to an outside layer collection for holding
    // channel layers for layer mask channel, quick mask channel and
    // alpha channels.
    FLayers                   : TLayerCollection;
    FChannelLayerLocation     : TFloatRect;
    FChannelLayerBaseIndex    : Integer;
    FDefaultMaskColor         : TColor32;              // default mask color for alpha channels layer blending

    FOnInsertAlphaChannel     : TigInsertAlphaChannelEvent;
    FOnAlphaChannelDelete     : TNotifyEvent;
    FOnChannelDblClick        : TigChannelDblClick;
    FOnChannelThumbUpdate     : TNotifyEvent;
    FOnChannelVisibleChanged  : TigChannelVisibleChanged;
    FOnLayerMaskChannelCreate : TNotifyEvent;
    FOnLayerMaskChannelDelete : TNotifyEvent;
    FOnQuickMaskChannelCreate : TNotifyEvent;
    FOnQuickMaskChannelDelete : TNotifyEvent;
    FOnSelectedChannelChanged : TigSelectedChannelChangedEvent;

    procedure ChannelPreviewLayerBlend(F: TColor32; var B: TColor32; M: TColor32); virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddNewAlphaChannel(const AChannelBmpWidth, AChannelBmpHeight: Integer;
      const AAccumCount: Boolean = True); virtual;

    procedure BlendByColorChannelSettings(ASrcBitmap, ADstBitmap: TBitmap32;
      const ARect: TRect); virtual; abstract;

    procedure CreateLayerMaskChannel(AMaskBmp: TBitmap32; const AChannelName: string); virtual;
    procedure CreateQuickMaskChannel(const AChannelWidth, AChannelHeight: Integer); virtual;
    procedure DeleteAlphaChannel(const AIndex: Integer); virtual;
    procedure DeleteLayerMaskChannel; virtual;
    procedure DeleteQuickMaskChannel; virtual;
    procedure DeleteSelectedAlphaChannels; virtual;

    procedure SelectAlphaChannel(const AIndex: Integer; const AMultiSelect: Boolean); virtual; abstract;
    procedure SelectColorChannel(const AIndex: Integer; const AMultiSelect: Boolean); virtual; abstract;
    procedure SelectLayerMaskChannel; virtual; abstract;
    procedure SelectQuickMaskChannel; virtual; abstract;

    procedure ToggleAlphaChannelVisible(const AIndex: Integer); virtual; abstract;
    procedure ToggleColorChannelVisible(const AIndex: Integer); virtual; abstract;
    procedure ToggleLayerMaskChannelVisible; virtual; abstract;
    procedure ToggleQuickMaskChannelVisible; virtual; abstract;
    
    procedure UpdateColorChannelThumbnails(ABitmap: TCustomBitmap32); virtual;

    property AlphaChannelMultiSelect  : Boolean                        read FAlphaChannelMultiSelect  write FAlphaChannelMultiSelect;
    property AlphaChannelList         : TigAlphaChannelList            read FAlphaChannelList;
    property ChannelLayerBaseIndex    : Integer                        read FChannelLayerBaseIndex    write SetChannelLayerBaseIndex;
    property ChannelLayerLocation     : TFloatRect                     read FChannelLayerLocation     write FChannelLayerLocation;
    property ColorChannelList         : TigChannelList                 read FColorChannelList;
    property CurrentChannelType       : TigChannelType                 read FCurrentChannelType;
    property DefaultMaskColor         : TColor32                       read FDefaultMaskColor         write FDefaultMaskColor;
    property Layers                   : TLayerCollection               read FLayers                   write FLayers;
    property LayerMaskChannel         : TigAlphaChannel                read FLayerMaskChannel;
    property OnAlphaChannelDelete     : TNotifyEvent                   read FOnAlphaChannelDelete     write FOnAlphaChannelDelete;
    property OnChannelDblClick        : TigChannelDblClick             read FOnChannelDblClick        write FOnChannelDblClick;
    property OnChannelThumbnailUpdate : TNotifyEvent                   read FOnChannelThumbUpdate     write FOnChannelThumbUpdate;
    property OnChannelVisibleChanged  : TigChannelVisibleChanged       read FOnChannelVisibleChanged  write FOnChannelVisibleChanged;
    property OnInsertAlphaChannel     : TigInsertAlphaChannelEvent     read FOnInsertAlphaChannel     write FOnInsertAlphaChannel;
    property OnLayerMaskChannelCreate : TNotifyEvent                   read FOnLayerMaskChannelCreate write FOnLayerMaskChannelCreate;
    property OnLayerMaskChannelDelete : TNotifyEvent                   read FOnLayerMaskChannelDelete write FOnLayerMaskChannelDelete;
    property OnQuickMaskChannelCreate : TNotifyEvent                   read FOnQuickMaskChannelCreate write FOnQuickMaskChannelCreate;
    property OnQuickMaskChannelDelete : TNotifyEvent                   read FOnQuickMaskChannelDelete write FOnQuickMaskChannelDelete;
    property OnSelectedChannelChanged : TigSelectedChannelChangedEvent read FOnSelectedChannelChanged write FOnSelectedChannelChanged;
    property QuickMaskChannel         : TigAlphaChannel                read FQuickMaskChannel;
    property SelectedAlphaChannel     : TigAlphaChannel                read GetSelectedAlphaChannel;
    property SelectedColorChannels    : TigChannelSet                  read FSelectedColorChannels;
  end;



function GetChannelMap(ASourceBitmap: TBitmap32;
  const AChannel: TigChannelSelector; const AInvert: Boolean): TBitmap32;


implementation

uses
{ Standard }
  SysUtils;


function GetChannelMap(ASourceBitmap: TBitmap32;
  const AChannel: TigChannelSelector; const AInvert: Boolean): TBitmap32;
var
  i             : Integer;
  a, r, g, b, v : Cardinal;
  p1, p2        : PColor32;
begin
  Result := nil;
  
  if not Assigned(ASourceBitmap) then
  begin
    Exit;
  end;

  Result := TBitmap32.Create;
  Result.SetSizeFrom(ASourceBitmap);

  p1 := @ASourceBitmap.Bits[0];
  p2 := @Result.Bits[0];

  for i := 1 to (Result.Width * Result.Height) do
  begin
    case AChannel of
      csRed:
        begin
          v := p1^ shr 16 and $FF;
        end;

      csGreen:
        begin
          v := p1^ shr 8 and $FF;
        end;

      csBlue:
        begin
          v := p1^ and $FF;
        end;

      csGrayscale:
        begin
          r := p1^ shr 16 and $FF;
          g := p1^ shr 8 and $FF;
          b := p1^ and $FF;
          v := (r + g + b) div 3;
        end;

      csAlpha:
        begin
          v := p1^ shr 24 and $FF;
        end;
        
    else
      v := 0;
    end;

    // Take alpha channel into account, make the extracted channel info
    // be against a white background when the alpha channel is not 255.
    a := p1^ shr 24 and $FF;
    v := ( v * a + 255 * (255 - a) ) div 255;

    if AInvert then
    begin
      v := 255 - v;
    end;

    p2^ := $FF000000 or (v shl 16) or (v shl 8) or v;
    
    Inc(p1);
    Inc(p2);
  end;
end;


{ TigCustomChannelManager }

constructor TigCustomChannelManager.Create;
begin
  inherited;

  FColorChannelList        := TigChannelList.Create;
  FAlphaChannelList        := TigAlphaChannelList.Create;
  FLayerMaskChannel        := nil;
  FQuickMaskChannel        := nil;
  FLayers                  := nil;
  FChannelLayerLocation    := FloatRect(0, 0, 0, 0);
  FChannelLayerBaseIndex   := 0;
  FAlphaChannelMultiSelect := False;

  FCurrentChannelType    := ctColorChannel;
  FChannelPreviewSet     := [];
  FSelectedColorChannels := [];
  FDefaultMaskColor      := clRed32;

  FOnAlphaChannelDelete     := nil;
  FOnChannelDblClick        := nil;
  FOnChannelVisibleChanged  := nil;
  FOnChannelThumbUpdate     := nil;
  FOnInsertAlphaChannel     := nil;
  FOnLayerMaskChannelCreate := nil;
  FOnLayerMaskChannelDelete := nil;
  FOnQuickMaskChannelCreate := nil;
  FOnQuickMaskChannelDelete := nil;
  FOnSelectedChannelChanged := nil;
end;

destructor TigCustomChannelManager.Destroy;
begin
  FLayers                   := nil;
  FOnAlphaChannelDelete     := nil;
  FOnChannelDblClick        := nil;
  FOnChannelThumbUpdate     := nil;
  FOnChannelVisibleChanged  := nil;
  FOnInsertAlphaChannel     := nil;
  FOnLayerMaskChannelCreate := nil;
  FOnLayerMaskChannelDelete := nil;
  FOnQuickMaskChannelCreate := nil;
  FOnQuickMaskChannelDelete := nil;
  FOnSelectedChannelChanged := nil;

  FAlphaChannelList.Free;
  FLayerMaskChannel.Free;
  FQuickMaskChannel.Free;
  FColorChannelList.Free;

  inherited;
end;

procedure TigCustomChannelManager.AddNewAlphaChannel(
  const AChannelBmpWidth, AChannelBmpHeight: Integer;
  const AAccumCount: Boolean = True);
var
  LLayerIndex   : Integer;
  LAlphaChannel : TigAlphaChannel;
begin
  if not Assigned(FLayers) then
  begin
    raise Exception.Create('[Error] TigCustomChannelManager.AddNewAlphaChannel(): field FLayers is nil. ');
  end;

  LLayerIndex := FChannelLayerBaseIndex;
  
  if Assigned(FLayerMaskChannel) then
  begin
    Inc(LLayerIndex);
  end;

  LLayerIndex := LLayerIndex + FAlphaChannelList.Count;
  
  LAlphaChannel := TigAlphaChannel.Create(FLayers,
                                          LLayerIndex,
                                          AChannelBmpWidth,
                                          AChannelBmpHeight,
                                          FChannelLayerLocation,
                                          FDefaultMaskColor);

  LAlphaChannel.OnThumbnailUpdate  := FOnChannelThumbUpdate;

  FAlphaChannelList.Add(LAlphaChannel, AAccumCount);

  if Assigned(FOnInsertAlphaChannel) then
  begin
    FOnInsertAlphaChannel(FAlphaChannelList, FAlphaChannelList.Count - 1);
  end;
end;

procedure TigCustomChannelManager.CreateLayerMaskChannel(AMaskBmp: TBitmap32;
  const AChannelName: string);
begin
  if not Assigned(AMaskBmp) then
  begin
    raise Exception.Create('[Error] TigCustomChannelManager.CreateLayerMaskChannel(): parameter AMaskBmp is nil. ');
  end;

  if not Assigned(FLayers) then
  begin
    raise Exception.Create('[Error] TigCustomChannelManager.CreateLayerMaskChannel(): field FLayers is nil. ');
  end;

  if not Assigned(FLayerMaskChannel) then
  begin
    FLayerMaskChannel := TigAlphaChannel.Create(FLayers,
      FChannelLayerBaseIndex, AMaskBmp, FChannelLayerLocation,
      FDefaultMaskColor);

    FLayerMaskChannel.IsChannelVisible  := False;
    FLayerMaskChannel.ChannelName       := AChannelName;
    FLayerMaskChannel.OnThumbnailUpdate := FOnChannelThumbUpdate;

    if Assigned(FOnLayerMaskChannelCreate) then
    begin
      FOnLayerMaskChannelCreate(FLayerMaskChannel);
    end;
  end;
end;

procedure TigCustomChannelManager.CreateQuickMaskChannel(
  const AChannelWidth, AChannelHeight: Integer);
var
  LLayerIndex : Integer;
begin
  if not Assigned(FQuickMaskChannel) then
  begin
    LLayerIndex := FChannelLayerBaseIndex;

    if Assigned(FLayerMaskChannel) then
    begin
      Inc(LLayerIndex);
    end;

    LLayerIndex := LLayerIndex + FAlphaChannelList.Count;

    FQuickMaskChannel := TigAlphaChannel.Create(FLayers,
      LLayerIndex, AChannelWidth, AChannelHeight, FChannelLayerLocation,
      FDefaultMaskColor);

    FQuickMaskChannel.ChannelLayer.Bitmap.Clear($FFFFFFFF);
    FQuickMaskChannel.UpdateChannelThumbnail;
    
    FQuickMaskChannel.ChannelName       := 'Quick Mask';
    FQuickMaskChannel.OnThumbnailUpdate := FOnChannelThumbUpdate;

    if Assigned(FOnQuickMaskChannelCreate) then
    begin
      FOnQuickMaskChannelCreate(FQuickMaskChannel);
    end;
  end;
end;

procedure TigCustomChannelManager.DeleteAlphaChannel(const AIndex: Integer);
begin
  FAlphaChannelList.DeleteChannel(AIndex);

  if Assigned(FOnAlphaChannelDelete) then
  begin
    FOnAlphaChannelDelete(Self);
  end;
end;

procedure TigCustomChannelManager.DeleteLayerMaskChannel;
begin
  if Assigned(FLayerMaskChannel) then
  begin
    FreeAndNil(FLayerMaskChannel);

    if Assigned(FOnLayerMaskChannelDelete) then
    begin
      FOnLayerMaskChannelDelete(Self);
    end;
  end;
end;

procedure TigCustomChannelManager.DeleteQuickMaskChannel;
begin
  if Assigned(FQuickMaskChannel) then
  begin
    FreeAndNil(FQuickMaskChannel);

    if Assigned(FOnQuickMaskChannelDelete) then
    begin
      FOnQuickMaskChannelDelete(Self);
    end;
  end;
end;

procedure TigCustomChannelManager.DeleteSelectedAlphaChannels;
begin
  FAlphaChannelList.DeleteSelectedChannels;

  if Assigned(FOnAlphaChannelDelete) then
  begin
    FOnAlphaChannelDelete(Self);
  end;
end;

function TigCustomChannelManager.GetSelectedAlphaChannel: TigAlphaChannel;
begin
  Result := FAlphaChannelList.SelectedChannel;
end;

procedure TigCustomChannelManager.SetChannelLayerBaseIndex(
  const AValue: Integer);
begin
  if (AValue >= 0) and (AValue <> FChannelLayerBaseIndex) then
  begin
    FChannelLayerBaseIndex := AValue;
  end; 
end;

// update color channel thumbnails respectively with the passed bitmap
procedure TigCustomChannelManager.UpdateColorChannelThumbnails(
  ABitmap: TCustomBitmap32);
var
  i        : Integer;
  LChannel : TigCustomChannel;
begin
  if Assigned(ABitmap) and (FColorChannelList.Count > 0) then
  begin
    for i := 0 to (FColorChannelList.Count - 1) do
    begin
      LChannel := TigCustomChannel(FColorChannelList.Channels[i]);
      LChannel.UpdateChannelThumbnail(ABitmap);
    end;

    if Assigned(FOnChannelThumbUpdate) then
    begin
      FOnChannelThumbUpdate(Self);
    end;
  end;
end;


end.
