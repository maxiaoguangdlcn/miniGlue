unit igBmp;

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

(* ***** BEGIN NOTICE BLOCK *****
 *
 * For using this unit, please always add it into the project,
 * not just reference it by Search Path settings. Adding unit to
 * project will make the code in Initialization/Finalization part
 * of the unit be invoked.
 *
 * And also notice that, the unit igGraphics.pas should be added
 * to a project before this unit. Please check out the code at
 * the end of this unit for details.
 *
 * ***** END NOTICE BLOCK *****)

uses
{ Delphi }
  Classes,
{ Graphics32 }
  GR32,
{ miniGlue lib }
  igGraphics;

type
  { TigBmpReader }

  TigBmpReader = class(TigGraphicReader)
  public
    class function IsValidFormat(AStream: TStream): Boolean; override;
    function LoadFromStream(AStream: TStream): TBitmap32; override;
  end;

implementation

uses
{ Delphi }
  Graphics;

const
  C_BMP_MARKER = $4D42;     // http://en.wikipedia.org/wiki/Bitmap_file_format

{ TigBmpReader }

class function TigBmpReader.IsValidFormat(AStream: TStream): Boolean;
var
  LMagic : Word;
begin
  Result := False;

  if Assigned(AStream) then
  begin
    AStream.Read(LMagic, 2);

    Result := (LMagic = C_BMP_MARKER);
  end;
end;

function TigBmpReader.LoadFromStream(AStream: TStream): TBitmap32;
begin
  Result := nil;

  if Assigned(AStream) then
  begin
    Result := TBitmap32.Create;
    Result.LoadFromStream(AStream);
  end;
end;

initialization
  // Unit igGraphics.pas should be added to a project before this unit,
  // for making the following function call available.
  igGraphics.RegisterGraphicsFileReader('bmp', TigBmpReader, 'Bitmaps (*.bmp)');

end.
