unit ChannelOptionsForm;

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
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Buttons,
{ miniGlue }
  igChannels,
  igChannelManager;

type
  TfrmChannelOptions = class(TForm)
    lblChannelName: TLabel;
    edtChannelName: TEdit;
    rdgrpColorIndicator: TRadioGroup;
    grpbxColor: TGroupBox;
    shpMaskColor: TShape;
    lblMaskOpacity: TLabel;
    edtMaskOpacity: TEdit;
    Label1: TLabel;
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    clrdlgMaskColorSelector: TColorDialog;
    procedure shpMaskColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtMaskOpacityChange(Sender: TObject);
    procedure btbtnOKClick(Sender: TObject);
  private
    FAssociatedChannel : TigAlphaChannel;
  public
    procedure FormSetup(AChannel: TigAlphaChannel;
      const AChannelType: TigChannelType);
  end;

var
  frmChannelOptions: TfrmChannelOptions;

implementation

uses
{ Graphics32 }
  GR32,
  GR32_LowLevel;

{$R *.dfm}

procedure TfrmChannelOptions.shpMaskColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  clrdlgMaskColorSelector.Color := shpMaskColor.Brush.Color;

  if clrdlgMaskColorSelector.Execute then
  begin
    shpMaskColor.Brush.Color := clrdlgMaskColorSelector.Color;
  end;
end;

procedure TfrmChannelOptions.edtMaskOpacityChange(Sender: TObject);
var
  LChangedValue: Integer;
begin
  try
    LChangedValue := StrToInt(edtMaskOpacity.Text);
    LChangedValue := Clamp(LChangedValue, 0, 100);

    edtMaskOpacity.Text := IntToStr(LChangedValue);
  except
    edtMaskOpacity.Text := IntToStr(Round(FAssociatedChannel.MaskOpacity / 255 * 100));
  end; 
end;

procedure TfrmChannelOptions.FormSetup(AChannel: TigAlphaChannel;
  const AChannelType: TigChannelType);
begin
  FAssociatedChannel  := AChannel;
  edtChannelName.Text := AChannel.ChannelName;

  case AChannelType of
    ctLayerMaskChannel:
      begin
        Caption                      := 'Layer Mask Options';
        lblChannelName.Caption      := 'Name: ' + edtChannelName.Text;
        grpbxColor.Caption          := 'Overlay';
        rdgrpColorIndicator.Enabled := False;
      end;

    ctQuickMaskChannel:
      begin
        Caption                := 'Quick Mask Options';
        lblChannelName.Caption := 'Name: ' + edtChannelName.Text;
      end;
  end;

  edtChannelName.Visible        := (AChannelType = ctAlphaChannel);
  rdgrpColorIndicator.ItemIndex := Ord(AChannel.MaskColorIndicator);
  shpMaskColor.Brush.Color      := WinColor(AChannel.MaskColor);
  edtMaskOpacity.Text           := IntToStr(Round(AChannel.MaskOpacity / 255 * 100));
end;

procedure TfrmChannelOptions.btbtnOKClick(Sender: TObject);
begin
  if edtChannelName.Text = '' then
  begin
    MessageDlg('The Channel Name cannot be empty.', mtError, [mbOK], 0);
    edtChannelName.SetFocus;

    Self.ModalResult := mrNone;
  end;
end;

end.
