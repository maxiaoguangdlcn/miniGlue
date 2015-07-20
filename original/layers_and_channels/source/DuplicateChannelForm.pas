unit DuplicateChannelForm;

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
  Dialogs, StdCtrls, Buttons,
{ miniGlue }
  igChannels;

type
  TfrmDuplicateChannel = class(TForm)
    lblDuplicateChannelName: TLabel;
    lblDuplicateChannelAs: TLabel;
    edtDuplicateChannelAs: TEdit;
    chckbxInvertChannel: TCheckBox;
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    procedure btbtnOKClick(Sender: TObject);
  private
    { private declarations }
  public
    procedure FormSetup(AChannel: TigCustomChannel);
  end;

var
  frmDuplicateChannel: TfrmDuplicateChannel;

implementation

{$R *.dfm}

procedure TfrmDuplicateChannel.FormSetup(AChannel: TigCustomChannel);
begin
  if not Assigned(AChannel) then
  begin
    raise Exception.Create('[Error] TfrmDuplicateChannel.FormSetup(): Parameter AChannel is nil.');
  end;

  lblDuplicateChannelName.Caption := lblDuplicateChannelName.Caption + ' ' + AChannel.ChannelName;
  edtDuplicateChannelAs.Text      := AChannel.ChannelName + ' copy';
end; 

procedure TfrmDuplicateChannel.btbtnOKClick(Sender: TObject);
begin
  if edtDuplicateChannelAs.Text = '' then
  begin
    MessageDlg('The Channel Name cannot be empty.', mtError, [mbOK], 0);
    edtDuplicateChannelAs.SetFocus;

    Self.ModalResult := mrNone;
  end;
end;

end.
