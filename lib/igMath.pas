unit igMath;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

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
  Types;

function GetRectSize(const ARect: TRect): TSize;
function AddRects(const ARect1, ARect2: TRect): TRect;


implementation

uses
  Math;


function GetRectSize(const ARect: TRect): TSize;
begin
  Result.cx := ARect.Right - ARect.Left + 1;
  Result.cy := ARect.Bottom - ARect.Top + 1;
end;

function AddRects(const ARect1, ARect2: TRect): TRect;
begin
  Result.Left   := Min(ARect1.Left,   ARect2.Left);
  Result.Top    := Min(ARect1.Top,    ARect2.Top);
  Result.Right  := Max(ARect1.Right,  ARect2.Right);
  Result.Bottom := Max(ARect1.Bottom, ARect2.Bottom);
end;

end.
