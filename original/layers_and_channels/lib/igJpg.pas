unit igJpg;

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
  SysUtils, Classes,
{ Graphics32 }
  GR32,
{ miniGlue lib}
  igGraphics;

type
  { TigJpgReader }

  TigJpgReader = class(TigGraphicsReader)
  public
    class function IsValidFormat(AStream: TStream): Boolean; override;
    function LoadFromStream(AStream: TStream): TBitmap32; override;
  end;


implementation

uses
{ Delphi }
  JPEG, Graphics;

const
  C_JPG_MARKER_1 = $D8FF; // http://en.wikipedia.org/wiki/JPEG_file_format
  C_JPG_MARKER_2 = $E0FF; // http://www.daevius.com/information-jpeg-file-format

{ TigJpgReader }

class function TigJpgReader.IsValidFormat(AStream: TStream): Boolean;
var
  LMagic1 : Word;
  LMagic2 : Word;
begin
  Result := False;

  if Assigned(AStream) then
  begin
    AStream.Read(LMagic1, 2);
    AStream.Read(LMagic2, 2);

    Result := (LMagic1 = C_JPG_MARKER_1){ and (LMagic2 = C_JPG_MARKER_2)};
  end;
end;

function TigJpgReader.LoadFromStream(AStream: TStream): TBitmap32;
var
  LJpgImage : TJPEGImage;
  LWinBmp   : TBitmap;
begin
  Result := nil;

  if Assigned(AStream) then
  begin
    LJpgImage := TJPEGImage.Create;
    LWinBmp   := TBitmap.Create;
    try
      LJpgImage.LoadFromStream(AStream);

      LWinBmp.Width       := LJpgImage.Width;
      LWinBmp.Height      := LJpgImage.Height;
      LWinBmp.PixelFormat := pf24bit;
      LWinBmp.Canvas.Draw(0, 0, LJpgImage);

      Result := TBitmap32.Create;
      Result.Assign(LWinBmp);
    finally
      LJpgImage.Free;
      LWinBmp.Free;
    end;
  end;
end;

initialization
  // Unit igGraphics.pas should be added to a project before this unit,
  // for making the following function call available.
  igGraphics.RegisterGraphicsFileReader('jpg', 'JPEG (*.jpg)', TigJpgReader);

end.
