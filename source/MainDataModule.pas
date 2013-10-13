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
    actnShowLayerPopupMenu: TAction;
    pmLayerForm: TPopupMenu;
    mnitmPopNewBCLayer: TMenuItem;
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
    procedure actnShowLayerPopupMenuExecute(Sender: TObject);
    procedure actnShowLayerPopupMenuUpdate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmMain: TdmMain;
  gActiveChildForm: TfrmChild;

implementation

uses
{ Delphi }
  Forms,
{ Graphics32 }
  GR32,
{ miniGlue lib }
  igLayers,
  igLayerIO,
  igBrightContrastLayer, 
{ miniGlue }
  MainForm,
  NewFileForm,
  LayerBrightContrastForm;

{$R *.dfm}

{ Private Methods }

procedure InitGlobals;
begin
  gActiveChildForm := nil;
end;

{ TdmMain }

procedure TdmMain.actnCreateNewFileExecute(Sender: TObject);
var
  LLayerPanel : TigCustomLayerPanel;
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

        // create background layer
        LLayerPanel := CreateNormalLayer(clWhite32, True);
        LayerPanelList.Add(LLayerPanel);

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
  LLayerPanel : TigCustomLayerPanel;
  LPanelIndex : Integer;
begin
  Screen.Cursor := crHourGlass;
  try
    with gActiveChildForm do
    begin
      Randomize;
      
      LLayerPanel := CreateNormalLayer( $FF000000 or Cardinal(Random($FFFFFF)), False );
      LPanelIndex := LayerPanelList.SelectedIndex + 1;

      LayerPanelList.Insert(LPanelIndex, LLayerPanel);
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
    if LayerPanelList.Count > 0 then
    begin
      case LayerPanelList.SelectedPanel.LayerProcessStage of
        lpsLayer:
          begin
            DeleteCurrentLayer;
          end;

        lpsMask:
          begin
            if LayerPanelList.SelectedPanel is TigNormalLayerPanel then
            begin
              LModalResult := MessageDlg('Apply mask to layer before removing?',
                                          mtConfirmation,
                                          [mbYes, mbNo, mbCancel], 0);

              case LModalResult of
                mrYes:
                  begin
                    TigNormalLayerPanel(LayerPanelList.SelectedPanel).ApplyMask;
                  end;

                mrNo:
                  begin
                    LayerPanelList.SelectedPanel.DiscardMask;
                  end;
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
      if LayerPanelList.Count > 0 then
      begin
        if LayerPanelList.Count = 1 then
        begin
          actnDeleteLayer.Enabled := (LayerPanelList.SelectedPanel.LayerProcessStage = lpsMask);
        end
        else
        begin
          actnDeleteLayer.Enabled := (LayerPanelList.SelectedIndex >= 0);
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
    LayerPanelList.SelectedPanel.EnableMask;
  end;                              
end;

procedure TdmMain.actnAddMaskUpdate(Sender: TObject);
begin
  actnAddMask.Enabled := Assigned(gActiveChildForm) and
                         Assigned(gActiveChildForm.LayerPanelList.SelectedPanel) and
                         (not gActiveChildForm.LayerPanelList.SelectedPanel.IsMaskEnabled);
end;

procedure TdmMain.actnFlattenImageExecute(Sender: TObject);
begin
  with gActiveChildForm do
  begin
    if LayerPanelList.GetHiddenLayerCount > 0 then
    begin
      if MessageDlg('Discard hidden layers?', mtConfirmation, [mbOK, mbCancel], 0) = mrOK then
      begin
        LayerPanelList.FlattenLayers;
      end;
    end
    else
    begin
      LayerPanelList.FlattenLayers;
    end;
  end;
end;

procedure TdmMain.actnFlattenImageUpdate(Sender: TObject);
begin
  actnFlattenImage.Enabled := Assigned(gActiveChildForm) and
                              gActiveChildForm.LayerPanelList.CanFlattenLayers;
end;

procedure TdmMain.actnMergeDownExecute(Sender: TObject);
begin
  gActiveChildForm.LayerPanelList.MergeSelectedLayerDown;
end;

procedure TdmMain.actnMergeDownUpdate(Sender: TObject);
begin
  actnMergeDown.Enabled := Assigned(gActiveChildForm) and
                           gActiveChildForm.LayerPanelList.CanMergeSelectedLayerDown;
end;

procedure TdmMain.actnMergeVisibleExecute(Sender: TObject);
begin
  gActiveChildForm.LayerPanelList.MergeVisibleLayers; 
end;

procedure TdmMain.actnMergeVisibleUpdate(Sender: TObject);
begin
  actnMergeVisible.Enabled := Assigned(gActiveChildForm) and
                              gActiveChildForm.LayerPanelList.CanMergeVisbleLayers;
end;

procedure TdmMain.actnOpenExecute(Sender: TObject);
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
            igLayerIO.gLayerReaders.LoadFromFile(opnpicdlgLoadLayers.FileName, LayerPanelList);
            LayerPanelList.SelectLayerPanel(0);
            SetCallbacksForLayerPanelsInList
          end;

          // set background size before create background layer
          imgWorkArea.Bitmap.SetSize(LayerPanelList.SelectedPanel.LayerBitmap.Width,
                                     LayerPanelList.SelectedPanel.LayerBitmap.Height);

          imgWorkArea.Bitmap.Clear($00000000);

          // update the view
          LayerPanelList.SelectedPanel.Changed;

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
  LLayerPanel       : TigCustomLayerPanel;
  LModalResult      : TModalResult;
begin
  Screen.Cursor := crHourGlass;
  try
    with gActiveChildForm do
    begin
      LOldSelectedIndex := LayerPanelList.SelectedIndex;
      
      LLayerPanel := CreateBrightContrastLayer();
      LayerPanelList.Insert(LOldSelectedIndex + 1, LLayerPanel);

      frmLayerBrightContrast := TfrmLayerBrightContrast.Create(nil);
      try
        frmLayerBrightContrast.AssociateToBCLayerPanel( TigBrightContrastLayerPanel(LLayerPanel) );

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
            LayerPanelList.CancelLayerPanel(LOldSelectedIndex + 1);
          end;
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TdmMain.actnShowLayerPopupMenuExecute(Sender: TObject);
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

initialization
  InitGlobals;

end.
