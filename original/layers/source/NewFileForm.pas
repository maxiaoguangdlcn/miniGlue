unit NewFileForm;

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
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TfrmNewFile = class(TForm)
    grpbxBitmapDimension: TGroupBox;
    lblWidth: TLabel;
    edtWidth: TEdit;
    edtHeight: TEdit;
    lblHeight: TLabel;
    btbtnOK: TBitBtn;
    btbtnCancel: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure edtWidthChange(Sender: TObject);
    procedure edtHeightChange(Sender: TObject);
  private
    FBitmapWidth  : Integer;
    FBitmapHeight : Integer;
  public
    property BitmapWidth  : Integer read FBitmapWidth;
    property BitmapHeight : Integer read FBitmapHeight;
  end;

var
  frmNewFile: TfrmNewFile;

implementation

uses
{ Graphics32 }
  GR32_LowLevel;

{$R *.dfm}

const
  MIN_SIZE       = 16;
  MAX_SIZE       = 2046;
  DEFAULT_WIDTH  = 640;
  DEFAULT_HEIGHT = 480;

procedure TfrmNewFile.FormCreate(Sender: TObject);
begin
  FBitmapWidth  := DEFAULT_WIDTH;
  FBitmapHeight := DEFAULT_HEIGHT;

  edtWidth.Text  := IntToStr(FBitmapWidth);
  edtHeight.Text := IntToStr(FBitmapHeight);
end;

procedure TfrmNewFile.edtWidthChange(Sender: TObject);
begin
  try
    FBitmapWidth  := StrToInt(edtWidth.Text);
    FBitmapWidth  := Clamp(FBitmapWidth, MIN_SIZE, MAX_SIZE);
    edtWidth.Text := IntToStr(FBitmapWidth);
  except
    edtWidth.Text := IntToStr(FBitmapWidth);
  end;
end;

procedure TfrmNewFile.edtHeightChange(Sender: TObject);
begin
  try
    FBitmapHeight  := StrToInt(edtHeight.Text);
    FBitmapHeight  := Clamp(FBitmapHeight, MIN_SIZE, MAX_SIZE);
    edtHeight.Text := IntToStr(FBitmapHeight);
  except
    edtHeight.Text := IntToStr(FBitmapHeight);
  end;
end;

end.
