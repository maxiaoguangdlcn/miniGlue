unit LayerForm;

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
 * Update Date: Feb 17, 2014 
 *
 * The Initial Developer of this unit are
 *   Ma Xiaoguang and Ma Xiaoming < gmbros[at]hotmail[dot]com >
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ToolWin, ComCtrls, ExtCtrls, StdCtrls,
{ Graphics32 }
  GR32_RangeBars,
{ miniGlue lib }
  igLayerPanelManager;

type
  TfrmLayers = class(TForm)
    tlbrLayers: TToolBar;
    tlbnNewLayer: TToolButton;
    tlbnSeparator1: TToolButton;
    tlbrBlendModes: TToolBar;
    cmbbxBlendModes: TComboBox;
    tlbnSeparator2: TToolButton;
    tlbrLayerOpacity: TToolBar;
    ToolButton1: TToolButton;
    ggbrLayerOpacity: TGaugeBar;
    edtLayerOpacity: TEdit;
    lblLayerOpacity: TLabel;
    tlbtnDeleteLayer: TToolButton;
    tlbrAddMask: TToolButton;
    ToolButton2: TToolButton;
    ComboBox1: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ChangeLayerBlendMode(Sender: TObject);
    procedure ggbrLayerOpacityChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
  private
    FLayerPanelManager : TigLayerPanelManager;
  public
    property LayerPanelManager : TigLayerPanelManager read FLayerPanelManager;
  end;

var
  frmLayers: TfrmLayers;

implementation

uses
{ externals\Graphics32_add_ons }
  GR32_Add_BlendModes,
{ miniGlue }
  MainDataModule,

  // Test
  igBrightContrastLayer,
  igPaintFuncs;

{$R *.dfm}

procedure TfrmLayers.FormCreate(Sender: TObject);
begin
  FLayerPanelManager        := TigLayerPanelManager.Create(Self);
  FLayerPanelManager.Parent := Self;
  FLayerPanelManager.Align  := alClient;

  cmbbxBlendModes.Items     := BlendModeList;
  cmbbxBlendModes.ItemIndex := 0;
end;

procedure TfrmLayers.FormDestroy(Sender: TObject);
begin
  FLayerPanelManager.Free;
end;

procedure TfrmLayers.FormActivate(Sender: TObject);
begin
  if Assigned(FLayerPanelManager) then
  begin
    FLayerPanelManager.SetFocus;
  end;
end;

procedure TfrmLayers.ChangeLayerBlendMode(Sender: TObject);
begin
  if Assigned(gActiveChildForm) then
  begin
    with gActiveChildForm do
    begin
      LayerList.SelectedLayer.LayerBlendMode := TBlendMode32(cmbbxBlendModes.ItemIndex);
    end;
  end;
end;

procedure TfrmLayers.ggbrLayerOpacityChange(Sender: TObject);
begin
  edtLayerOpacity.Text := IntToStr(ggbrLayerOpacity.Position);
  
  if Assigned(gActiveChildForm) then
  begin
    with gActiveChildForm do
    begin
      LayerList.SelectedLayer.LayerOpacity := MulDiv(ggbrLayerOpacity.Position, 255, 100);
    end;
  end;
end;

procedure TfrmLayers.ComboBox1Change(Sender: TObject);
var
  LScale : Single;
begin
  LScale := 1.0;
  
  case ComboBox1.ItemIndex of
     0: LScale := 0.02;
     1: LScale := 0.05;
     2: LScale := 0.25;
     3: LScale := 0.5;
     4: LScale := 0.75;
     5: LScale := 1.0;
     6: LScale := 1.25;
     7: LScale := 1.5;
     8: LScale := 2.0;
     9: LScale := 4.0;
    10: LScale := 8.0;
    11: LScale := 16.0;
  end;

  if Assigned(gActiveChildForm) then
  begin
    // setting viewing scale of image viewer
    gActiveChildForm.imgWorkArea.Scale := LScale;
  end
  else
  begin
    ComboBox1.ItemIndex := 5;
  end;
end;

end.
