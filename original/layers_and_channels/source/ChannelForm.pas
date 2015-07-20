unit ChannelForm;

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
 * Update Date: May 1, 2014
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
  Dialogs, ComCtrls, ToolWin, Buttons, 
{ miniGlue lib }
  igChannelViewer;

type
  TfrmChannels = class(TForm)
    tlbrChannels: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    spdbtnStandardMode: TSpeedButton;
    spdbtnQuickMaskMode: TSpeedButton;
    tlbtnNewAlphaChannel: TToolButton;
    tlbtnDeleteAlphaChannel: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure spdbtnStandardModeClick(Sender: TObject);
    procedure spdbtnQuickMaskModeClick(Sender: TObject);
  private
    FChannelViewer : TigChannelViewer;

    procedure OnChannelViewerRightClick(ASender: TObject);
  public
    property ChannelViewer : TigChannelViewer read FChannelViewer;
  end;

var
  frmChannels: TfrmChannels;

implementation

uses
{ miniGlue }
  MainDataModule;

{$R *.dfm}

procedure TfrmChannels.FormCreate(Sender: TObject);
begin
  FChannelViewer := TigChannelViewer.Create(Self);
  
  with FChannelViewer do
  begin
    Parent                  := Self;
    Align                   := alClient;
    OnMouseRightButtonClick := Self.OnChannelViewerRightClick;
  end;
end;

procedure TfrmChannels.FormDestroy(Sender: TObject);
begin
  FChannelViewer.Free;
end;

procedure TfrmChannels.OnChannelViewerRightClick(ASender: TObject);
var
  LPoint : TPoint;
begin
  GetCursorPos(LPoint);

  dmMain.pmChannelForm.Popup(LPoint.X, LPoint.Y);
end;

procedure TfrmChannels.spdbtnStandardModeClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    with gActiveChildForm do
    begin
      if Assigned(ChannelManager.QuickMaskChannel) then
      begin
        ChannelManager.DeleteQuickMaskChannel;
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmChannels.spdbtnQuickMaskModeClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    with gActiveChildForm do
    begin
      if not Assigned(ChannelManager.QuickMaskChannel) then
      begin
        ChannelManager.CreateQuickMaskChannel(imgWorkArea.Bitmap.Width, imgWorkArea.Bitmap.Height);
      end;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

end.
