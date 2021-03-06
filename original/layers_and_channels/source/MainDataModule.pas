unit MainDataModule;

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

// Update Date: 2015/04/15

interface

uses
{ Delphi }
  Windows, SysUtils, Classes, ActnList, Menus, Controls, ImgList, Dialogs,
  ExtDlgs,
{ miniGlue}
  ChildForm;

type
  TdmMain = class(TDataModule)
    mnMainForm: TMainMenu;
    actnlstMainMenu: TActionList;
    mnitmFile: TMenuItem;
    mnitmNew: TMenuItem;
    mnitmSeparator1: TMenuItem;
    mnitmOpen: TMenuItem;
    mnitmSeparator2: TMenuItem;
    mnitmSave: TMenuItem;
    mnitmSaveAs: TMenuItem;
    mnitmSeparator3: TMenuItem;
    mnitmExit: TMenuItem;
    actnCreateNewFile: TAction;
    actnExitApp: TAction;
    actnlstLayerForm: TActionList;
    imglstLLayerForm: TImageList;
    actnNewLayer: TAction;
    mnitmWindow: TMenuItem;
    mnitmCascade: TMenuItem;
    actnCascade: TAction;
    actnDeleteLayer: TAction;
    actnAddMask: TAction;
    mnitmLayer: TMenuItem;
    mnitmFlattenImage: TMenuItem;
    actnFlattenImage: TAction;
    mnitmMergeDown: TMenuItem;
    actnMergeDown: TAction;
    mnitmMergeVisible: TMenuItem;
    actnMergeVisible: TAction;
    opnpicdlgLoadLayers: TOpenPictureDialog;
    actnOpen: TAction;
    mnitmSeparator4: TMenuItem;
    mnitmNewAdjustmentLayer: TMenuItem;
    mnitmNewBCLayer: TMenuItem;
    actnNewAdjustmentLayer: TAction;
    actnNewBCLayer: TAction;
    pmLayerForm: TPopupMenu;
    mnitmPopNewBCLayer: TMenuItem;
    actnShowLayerPopupMenu: TAction;
    actnlstChannelForm: TActionList;
    actnNewAlphaChannel: TAction;
    actnDeleteChannel: TAction;
    pmChannelForm: TPopupMenu;
    mnitmDuplicateChannel: TMenuItem;
    mnitmDeleteChannel: TMenuItem;
    actnDuplicateChannel: TAction;
    actnMenuDeleteChannel: TAction;
    procedure actnCreateNewFileExecute(Sender: TObject);
    procedure actnExitAppExecute(Sender: TObject);
    procedure actnNewLayerExecute(Sender: TObject);
    procedure actnNewLayerUpdate(Sender: TObject);
    procedure actnCascadeExecute(Sender: TObject);
    procedure WindowAlignActionUpdate(Sender: TObject);
    procedure actnDeleteLayerExecute(Sender: TObject);
    procedure actnDeleteLayerUpdate(Sender: TObject);
    procedure actnAddMaskExecute(Sender: TObject);
    procedure actnAddMaskUpdate(Sender: TObject);
    procedure actnFlattenImageExecute(Sender: TObject);
    procedure actnFlattenImageUpdate(Sender: TObject);
    procedure actnMergeDownExecute(Sender: TObject);
    procedure actnMergeDownUpdate(Sender: TObject);
    procedure actnMergeVisibleExecute(Sender: TObject);
    procedure actnMergeVisibleUpdate(Sender: TObject);
    procedure actnOpenExecute(Sender: TObject);
    procedure actnNewAdjustmentLayerExecute(Sender: TObject);
    procedure actnNewAdjustmentLayerUpdate(Sender: TObject);
    procedure actnNewBCLayerExecute(Sender: TObject);
    procedure ShowLayerPopupMenuExecute(Sender: TObject);
    procedure actnShowLayerPopupMenuUpdate(Sender: TObject);
    procedure actnNewAlphaChannelExecute(Sender: TObject);
    procedure actnNewAlphaChannelUpdate(Sender: TObject);
    procedure actnDeleteChannelExecute(Sender: TObject);
    procedure actnDeleteChannelUpdate(Sender: TObject);
    procedure actnMenuDeleteChannelExecute(Sender: TObject);
    procedure actnMenuDeleteChannelUpdate(Sender: TObject);
    procedure actnDuplicateChannelUpdate(Sender: TObject);
    procedure actnDuplicateChannelExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmMain: TdmMain;
  gActiveChildForm: TfrmChild;

const
  DEFAULT_CHECKERBOARD_SIZE = 8;

implementation

uses
{ Delphi }
  Forms,
{ Graphics32 }
  GR32,
{ miniGlue lib }
  igLayers,
  igLayerIO,
  igChannels,
  igChannelManager,
  igBrightContrastLayer,
  igPaintFuncs,
{ miniGlue }
  MainForm,
  NewFileForm,
  LayerBrightContrastForm,
  DuplicateChannelForm;

{$R *.dfm}

{ Private Methods }

procedure InitGlobals;
begin
  gActiveChildForm := nil;
end;

{ TdmMain }

procedure TdmMain.actnCreateNewFileExecute(Sender: TObject);
var
  LLayer : TigCustomLayer;
  LRect  : TRect;
begin
  frmNewFile := TfrmNewFile.Create(nil);
  try
    if frmNewFile.ShowModal = mrOK then
    begin
      gActiveChildForm := TfrmChild.Create(nil);

      with gActiveChildForm do
      begin
        Caption := 'Untitled';

        // set background size before create background layer
        imgWorkArea.Bitmap.SetSize(frmNewFile.BitmapWidth, frmNewFile.BitmapHeight);
        imgWorkArea.Bitmap.Clear($00000000);

        // draw checkerboard pattern
        CheckerboardBmp.SetSizeFrom(imgWorkArea.Bitmap);
        DrawCheckerboardPattern(CheckerboardBmp, DEFAULT_CHECKERBOARD_SIZE);

        // create background layer
        LLayer := CreateNormalLayer(clWhite32, True);
        LayerList.Add(LLayer);

        // channels ...
        LRect             := imgWorkArea.GetBitmapRect;
        LRect.TopLeft     := imgWorkArea.ControlToBitmap(LRect.TopLeft);
        LRect.BottomRight := imgWorkArea.ControlToBitmap(LRect.BottomRight);

        ChannelManager.UpdateColorChannelThumbnails(LayerList.CombineResult);
        ChannelManager.ChannelLayerLocation := FloatRect(LRect);

        if WindowState = wsNormal then
        begin
          // set client size of the child form
          ClientWidth  := imgWorkArea.Bitmap.Width  + imgWorkArea.ScrollBars.Size;
          ClientHeight := imgWorkArea.Bitmap.Height + imgWorkArea.ScrollBars.Size;
        end;
      end;
    end;

  finally
    FreeAndNil(frmNewFile);
  end;
end;

procedure TdmMain.actnExitAppExecute(Sender: TObject);
begin
  frmMain.Close;
end;

procedure TdmMain.actnNewLayerExecute(Sender: TObject);
var
  LLayer      : TigCustomLayer;
  LLayerIndex : Integer;
begin
  Screen.Cursor := crHourGlass;
  try
    with gActiveChildForm do
    begin
      Randomize;

      LLayer := CreateNormalLayer( $FF000000 or Cardinal(Random($FFFFFF)), False );
      LLayerIndex := LayerList.SelectedIndex + 1;

      LayerList.Insert(LLayerIndex, LLayer);
      LayerList.SelectedLayer.Changed();
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TdmMain.actnNewLayerUpdate(Sender: TObject);
begin
  actnNewLayer.Enabled := Assigned(gActiveChildForm);
end;

procedure TdmMain.actnCascadeExecute(Sender: TObject);
begin
  frmMain.Cascade;
end;

procedure TdmMain.WindowAlignActionUpdate(Sender: TObject);
begin
  actnCascade.Enabled := (frmMain.MDIChildCount > 0);
end;

procedure TdmMain.actnDeleteLayerExecute(Sender: TObject);
var
  LModalResult : TModalResult;
begin
  with gActiveChildForm do
  begin
    if LayerList.Count > 0 then
    begin
      case LayerList.SelectedLayer.LayerProcessStage of
        lpsLayer:
          begin
            DeleteCurrentLayer();
          end;

        lpsMask:
          begin
            if LayerList.SelectedLayer is TigNormalLayer then
            begin
              LModalResult := MessageDlg('Apply mask to layer before removing?',
                                          mtConfirmation,
                                          [mbYes, mbNo, mbCancel], 0);

              case LModalResult of
                mrYes:
                  begin
                    TigNormalLayer(LayerList.SelectedLayer).ApplyMask;
                  end;

                mrNo:
                  begin
                    LayerList.SelectedLayer.DiscardMask;
                  end;
              end;
            end
            else
            begin
              if MessageDlg('Discard mask?', mtConfirmation,
                            [mbYes, mbNo], 0) = mrYes then
              begin
                LayerList.SelectedLayer.DiscardMask;
              end;
            end;
          end;
      end;
    end;
  end;
end;

procedure TdmMain.actnDeleteLayerUpdate(Sender: TObject);
begin
  if Assigned(gActiveChildForm) then
  begin
    with gActiveChildForm do
    begin
      if LayerList.Count > 0 then
      begin
        if LayerList.Count = 1 then
        begin
          actnDeleteLayer.Enabled := (LayerList.SelectedLayer.LayerProcessStage = lpsMask);
        end
        else
        begin
          actnDeleteLayer.Enabled := (LayerList.SelectedIndex >= 0);
        end;
      end;
    end;
  end
  else
  begin
    actnDeleteLayer.Enabled := False;
  end;
end;

procedure TdmMain.actnAddMaskExecute(Sender: TObject);
begin
  with gActiveChildForm do
  begin
    LayerList.SelectedLayer.EnableMask;
  end;                              
end;

procedure TdmMain.actnAddMaskUpdate(Sender: TObject);
begin
  actnAddMask.Enabled := Assigned(gActiveChildForm) and
                         Assigned(gActiveChildForm.LayerList.SelectedLayer) and
                         (not gActiveChildForm.LayerList.SelectedLayer.IsMaskEnabled);
end;

procedure TdmMain.actnFlattenImageExecute(Sender: TObject);
begin
  with gActiveChildForm do
  begin
    if LayerList.GetHiddenLayerCount > 0 then
    begin
      if MessageDlg('Discard hidden layers?', mtConfirmation, [mbOK, mbCancel], 0) = mrOK then
      begin
        LayerList.FlattenLayers;
      end;
    end
    else
    begin
      LayerList.FlattenLayers;
    end;
  end;
end;

procedure TdmMain.actnFlattenImageUpdate(Sender: TObject);
begin
  actnFlattenImage.Enabled := Assigned(gActiveChildForm) and
                              gActiveChildForm.LayerList.CanFlattenLayers;
end;

procedure TdmMain.actnMergeDownExecute(Sender: TObject);
begin
  gActiveChildForm.LayerList.MergeSelectedLayerDown;
end;

procedure TdmMain.actnMergeDownUpdate(Sender: TObject);
begin
  actnMergeDown.Enabled := Assigned(gActiveChildForm) and
                           gActiveChildForm.LayerList.CanMergeSelectedLayerDown;
end;

procedure TdmMain.actnMergeVisibleExecute(Sender: TObject);
begin
  gActiveChildForm.LayerList.MergeVisibleLayers; 
end;

procedure TdmMain.actnMergeVisibleUpdate(Sender: TObject);
begin
  actnMergeVisible.Enabled := Assigned(gActiveChildForm) and
                              gActiveChildForm.LayerList.CanMergeVisbleLayers;
end;

procedure TdmMain.actnOpenExecute(Sender: TObject);
var
  LRect : TRect;
begin
  if Assigned(igLayerIO.gLayerReaders) then
  begin
    opnpicdlgLoadLayers.Filter := igLayerIO.gLayerReaders.Filter;

    if opnpicdlgLoadLayers.Execute then
    begin
      Screen.Cursor := crHourGlass;
      try
        gActiveChildForm := TfrmChild.Create(nil);

        with gActiveChildForm do
        begin
          Caption := ExtractFileName(opnpicdlgLoadLayers.FileName);

          // create background layer from file
          if Assigned(igLayerIO.gLayerReaders) and
             (igLayerIO.gLayerReaders.Count > 0) then
          begin
            igLayerIO.gLayerReaders.LoadFromFile(opnpicdlgLoadLayers.FileName, LayerList);
            LayerList.SelectLayer(0);
            SetCallbacksForLayersInList();
          end;

          // set background size before create background layer
          imgWorkArea.Bitmap.SetSize(LayerList.SelectedLayer.LayerBitmap.Width,
                                     LayerList.SelectedLayer.LayerBitmap.Height);

          imgWorkArea.Bitmap.Clear($00000000);

          // draw checkerboard pattern
          CheckerboardBmp.SetSizeFrom(imgWorkArea.Bitmap);
          DrawCheckerboardPattern(CheckerboardBmp, DEFAULT_CHECKERBOARD_SIZE);

          // update the view
          LayerList.SelectedLayer.Changed;

          // channels ...
          LRect             := imgWorkArea.GetBitmapRect;
          LRect.TopLeft     := imgWorkArea.ControlToBitmap(LRect.TopLeft);
          LRect.BottomRight := imgWorkArea.ControlToBitmap(LRect.BottomRight);
          
          ChannelManager.UpdateColorChannelThumbnails(LayerList.CombineResult);
          ChannelManager.ChannelLayerLocation := FloatRect(LRect);

          if WindowState = wsNormal then
          begin
            // set client size of the child form
            ClientWidth  := imgWorkArea.Bitmap.Width  + imgWorkArea.ScrollBars.Size;
            ClientHeight := imgWorkArea.Bitmap.Height + imgWorkArea.ScrollBars.Size;
          end;
        end;

      finally
        Screen.Cursor := crDefault;
      end;
    end;
  end; 
end;

procedure TdmMain.actnNewAdjustmentLayerExecute(Sender: TObject);
begin
  // do nothing
end;

procedure TdmMain.actnNewAdjustmentLayerUpdate(Sender: TObject);
begin
  actnNewAdjustmentLayer.Enabled := Assigned(gActiveChildForm);
end;

procedure TdmMain.actnNewBCLayerExecute(Sender: TObject);
var
  LOldSelectedIndex : Integer;
  LLayer            : TigCustomLayer;
  LModalResult      : TModalResult;
begin
  Screen.Cursor := crHourGlass;
  try
    with gActiveChildForm do
    begin
      LOldSelectedIndex := LayerList.SelectedIndex;
      
      LLayer := CreateBrightContrastLayer();
      LayerList.Insert(LOldSelectedIndex + 1, LLayer);

      frmLayerBrightContrast := TfrmLayerBrightContrast.Create(nil);
      try
        frmLayerBrightContrast.AssociateToBCLayer( TigBrightContrastLayer(LLayer) );

        LModalResult := frmLayerBrightContrast.ShowModal;
      finally
        FreeAndNil(frmLayerBrightContrast);
      end;

      case LModalResult of
        mrOK:
          begin
            LLayer.EnableMask;
          end;

        mrCancel:
          begin
            LayerList.CancelLayer(LOldSelectedIndex + 1);
          end;
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TdmMain.ShowLayerPopupMenuExecute(Sender: TObject);
var
  LPoint : TPoint;
begin
  GetCursorPos(LPoint); // get cursor position on the screen

  // pop up the menu at current position
  pmLayerForm.Popup(LPoint.X, LPoint.Y);
end;

procedure TdmMain.actnShowLayerPopupMenuUpdate(Sender: TObject);
begin
  actnShowLayerPopupMenu.Enabled := Assigned(gActiveChildForm);
end;

procedure TdmMain.actnNewAlphaChannelExecute(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    with gActiveChildForm do
    begin
      ChannelManager.AddNewAlphaChannel(imgWorkArea.Bitmap.Width, imgWorkArea.Bitmap.Height);
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TdmMain.actnNewAlphaChannelUpdate(Sender: TObject);
begin
  actnNewAlphaChannel.Enabled := Assigned(gActiveChildForm);
end;

procedure TdmMain.actnDeleteChannelExecute(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    with gActiveChildForm do
    begin
      case ChannelManager.CurrentChannelType of
        ctAlphaChannel:
          begin
            ChannelManager.DeleteSelectedAlphaChannels;
          end;

        ctLayerMaskChannel:
          begin
            // Here, we delete the layer mask channel with the following
            // action. It will get the layer mask channel deleted.
            actnDeleteLayerExecute(Sender);
          end;

        ctQuickMaskChannel:
          begin
            ChannelManager.DeleteQuickMaskChannel;
          end;
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TdmMain.actnDeleteChannelUpdate(Sender: TObject);
begin
  actnDeleteChannel.Enabled := Assigned(gActiveChildForm) and
                               (gActiveChildForm.ChannelManager.CurrentChannelType <> ctColorChannel);
end;

procedure TdmMain.actnMenuDeleteChannelExecute(Sender: TObject);
begin
  actnDeleteChannelExecute(Sender);
end;

procedure TdmMain.actnMenuDeleteChannelUpdate(Sender: TObject);
begin
  actnMenuDeleteChannel.Enabled := Assigned(gActiveChildForm) and
                                   (gActiveChildForm.ChannelManager.CurrentChannelType <> ctColorChannel);
end;

procedure TdmMain.actnDuplicateChannelExecute(Sender: TObject);
var
  LChannel      : TigCustomChannel;
  LChannelMap   : TBitmap32;
  LChannelType  : TigChannelSelector;
begin
  LChannel     := nil;
  LChannelType := csRed;
  
  with gActiveChildForm do
  begin
    case ChannelManager.CurrentChannelType of
      ctColorChannel:
        begin
          if csRed in ChannelManager.SelectedColorChannels then
          begin
            LChannel     := ChannelManager.ColorChannelList.Channels[1];
            LChannelType := csRed;
          end
          else if csGreen in ChannelManager.SelectedColorChannels then
          begin
            LChannel     := ChannelManager.ColorChannelList.Channels[2];
            LChannelType := csGreen;
          end
          else if csBlue in ChannelManager.SelectedColorChannels then
          begin
            LChannel     := ChannelManager.ColorChannelList.Channels[3];
            LChannelType := csBlue;
          end;
        end;

      ctAlphaChannel:
        begin
          LChannel     := ChannelManager.SelectedAlphaChannel;
          LChannelType := csGrayscale;
        end;

      ctLayerMaskChannel:
        begin
          LChannel     := ChannelManager.LayerMaskChannel;
          LChannelType := csGrayscale;
        end;

      ctQuickMaskChannel:
        begin
          LChannel     := ChannelManager.QuickMaskChannel;
          LChannelType := csGrayscale;
        end;
    end;

    frmDuplicateChannel := TfrmDuplicateChannel.Create(Application);
    try
      frmDuplicateChannel.FormSetup(LChannel);

      if frmDuplicateChannel.ShowModal = mrOK then
      begin
        case ChannelManager.CurrentChannelType of
          ctColorChannel:
            begin
              LChannelMap := GetChannelMap(LayerList.CombineResult, LChannelType,
                frmDuplicateChannel.chckbxInvertChannel.Checked);
            end;

          ctAlphaChannel:
            begin
              LChannelMap := GetChannelMap(
                ChannelManager.SelectedAlphaChannel.ChannelLayer.Bitmap,
                LChannelType, frmDuplicateChannel.chckbxInvertChannel.Checked);
            end;

          ctLayerMaskChannel:
            begin
              LChannelMap := GetChannelMap(
                ChannelManager.LayerMaskChannel.ChannelLayer.Bitmap,
                LChannelType, frmDuplicateChannel.chckbxInvertChannel.Checked);
            end;

          ctQuickMaskChannel:
            begin
              LChannelMap := GetChannelMap(
                ChannelManager.QuickMaskChannel.ChannelLayer.Bitmap,
                LChannelType, frmDuplicateChannel.chckbxInvertChannel.Checked);
            end;

        else
          LChannelMap := nil;
        end;

        if Assigned(LChannelMap) then
        begin
          ChannelManager.AddNewAlphaChannel(imgWorkArea.Bitmap.Width, imgWorkArea.Bitmap.Height);

          with ChannelManager.SelectedAlphaChannel do
          begin
            ChannelName := frmDuplicateChannel.edtDuplicateChannelAs.Text;
            
            ChannelLayer.Bitmap.Draw(0, 0, LChannelMap);
            UpdateChannelThumbnail;
          end;

          LChannelMap.Free;
        end;
      end;
    finally
      FreeAndNil(frmDuplicateChannel);
    end;
  end;
end;

procedure TdmMain.actnDuplicateChannelUpdate(Sender: TObject);
begin
  // we can only duplicate single channel ...
  actnDuplicateChannel.Enabled := Assigned(gActiveChildForm) and
                                  ( not gActiveChildForm.ChannelManager.ColorChannelList.Channels[0].IsSelected);
end;

initialization
  InitGlobals;

end.
