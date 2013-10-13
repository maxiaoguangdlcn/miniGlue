unit LayerBrightContrastForm;

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
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, 
{ Graphics32 }
  GR32_RangeBars,
{ miniGlue lib }
  igBrightContrastLayer;

type
  TfrmLayerBrightContrast = class(TForm)
    lblBrightness: TLabel;
    edtBrightness: TEdit;
    ggbrBrightness: TGaugeBar;
    lblContrast: TLabel;
    edtContrast: TEdit;
    ggbrContrast: TGaugeBar;
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    procedure ggbrBrightnessMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ggbrContrastMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ggbrBrightnessChange(Sender: TObject);
    procedure ggbrContrastChange(Sender: TObject);
  private
    FBCLayerPanel : TigBrightContrastLayerPanel;  // pointer to a BC layer panel
  public
    procedure AssociateToBCLayerPanel(const ABCPanel: TigBrightContrastLayerPanel);
  end;

var
  frmLayerBrightContrast: TfrmLayerBrightContrast;

implementation

{$R *.dfm}

const
  ADJUST_BASE_VALUE = 100;

procedure TfrmLayerBrightContrast.AssociateToBCLayerPanel(
  const ABCPanel: TigBrightContrastLayerPanel);
begin
  if Assigned(ABCPanel) then
  begin
    FBCLayerPanel := ABCPanel;

    ggbrBrightness.Position := FBCLayerPanel.BrightAmount + ADJUST_BASE_VALUE;
    ggbrContrast.Position   := FBCLayerPanel.ContrastAmount + ADJUST_BASE_VALUE;

    edtBrightness.Text := IntToStr(FBCLayerPanel.BrightAmount);
    edtContrast.Text   := IntToStr(FBCLayerPanel.ContrastAmount);
  end;
end;

procedure TfrmLayerBrightContrast.ggbrBrightnessChange(Sender: TObject);
begin
  edtBrightness.Text := IntToStr(ggbrBrightness.Position - ADJUST_BASE_VALUE);
end;

procedure TfrmLayerBrightContrast.ggbrBrightnessMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FBCLayerPanel) then
  begin
    Screen.Cursor := crHourGlass;
    try
      FBCLayerPanel.BrightAmount := ggbrBrightness.Position - ADJUST_BASE_VALUE;
      FBCLayerPanel.Changed;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

procedure TfrmLayerBrightContrast.ggbrContrastChange(Sender: TObject);
begin
  edtContrast.Text := IntToStr(ggbrContrast.Position - ADJUST_BASE_VALUE);
end;

procedure TfrmLayerBrightContrast.ggbrContrastMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FBCLayerPanel) then
  begin
    Screen.Cursor := crHourGlass;
    try
      FBCLayerPanel.ContrastAmount := ggbrContrast.Position - ADJUST_BASE_VALUE;
      FBCLayerPanel.Changed;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;


end.
