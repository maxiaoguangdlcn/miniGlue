unit igTool;

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
 * The Initial Developer of the Original Code is
 *   Ma Xiaoguang and Ma Xiaoming  < gmbros[at]hotmail[dot]com >
 *
 *
 * Contributor(s):
 *
 *
 * ***** END LICENSE BLOCK ***** *)

interface

uses
{ Delphi }
  Classes, Controls,
{ Graphics32 }
  GR32;

type
  TigCustomTool = class(TPersistent)
  protected
    FMouseLeftButtonDown : Boolean;
  public
    constructor Create;

    procedure MouseDown(ASender: TObject; AButton: TMouseButton;
      AShift: TShiftState; AX, AY: Integer; ABitmap: TCustomBitmap32); virtual; abstract;

    procedure MouseMove(ASender: TObject; AShift: TShiftState; AX, AY: Integer;
      ABitmap: TCustomBitmap32); virtual; abstract;

    procedure MouseUp(ASender: TObject; AButton: TMouseButton;
      AShift: TShiftState; AX, AY: Integer; ABitmap: TCustomBitmap32); virtual; abstract;
  end;

implementation

{ TigCustomTool }

constructor TigCustomTool.Create;
begin
  inherited;

  FMouseLeftButtonDown := False;
end;


end.
