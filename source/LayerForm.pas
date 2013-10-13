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
    tlbtnNewFillAdjustmentLayer: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ChangeLayerBlendMode(Sender: TObject);
    procedure ggbrLayerOpacityChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
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
  MainDataModule;

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
      LayerPanelList.SelectedPanel.LayerBlendMode := TBlendMode32(cmbbxBlendModes.ItemIndex);
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
      LayerPanelList.SelectedPanel.LayerOpacity := MulDiv(ggbrLayerOpacity.Position, 255, 100);
    end;
  end;
end;

end.
