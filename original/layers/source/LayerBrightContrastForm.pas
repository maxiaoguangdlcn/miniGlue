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
 * Update Date: November 11th, 2014
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
    FBCLayer : TigBrightContrastLayer;  // pointer to a BC layer 
  public
    procedure AssociateToBCLayer(const ABCLayer: TigBrightContrastLayer);
  end;

var
  frmLayerBrightContrast: TfrmLayerBrightContrast;

implementation

{$R *.dfm}

const
  ADJUST_BASE_VALUE = 100;

procedure TfrmLayerBrightContrast.AssociateToBCLayer(
  const ABCLayer: TigBrightContrastLayer);
begin
  if Assigned(ABCLayer) then
  begin
    FBCLayer := ABCLayer;

    ggbrBrightness.Position := FBCLayer.BrightAmount + ADJUST_BASE_VALUE;
    ggbrContrast.Position   := FBCLayer.ContrastAmount + ADJUST_BASE_VALUE;

    edtBrightness.Text := IntToStr(FBCLayer.BrightAmount);
    edtContrast.Text   := IntToStr(FBCLayer.ContrastAmount);
  end;
end;

procedure TfrmLayerBrightContrast.ggbrBrightnessChange(Sender: TObject);
begin
  edtBrightness.Text := IntToStr(ggbrBrightness.Position - ADJUST_BASE_VALUE);
end;

procedure TfrmLayerBrightContrast.ggbrBrightnessMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FBCLayer) then
  begin
    Screen.Cursor := crHourGlass;
    try
      FBCLayer.BrightAmount := ggbrBrightness.Position - ADJUST_BASE_VALUE;
      FBCLayer.Changed;
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
  if Assigned(FBCLayer) then
  begin
    Screen.Cursor := crHourGlass;
    try
      FBCLayer.ContrastAmount := ggbrContrast.Position - ADJUST_BASE_VALUE;
      FBCLayer.Changed;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
end;

end.
