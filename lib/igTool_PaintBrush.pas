unit igTool_PaintBrush;

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
  Classes,
  GR32,
  igTool_CustomBrush;

type
  { TigPaintBrush }

  TigPaintBrush = class(TigCustomBrush)
  private
    FColor : TColor32;
  protected
    procedure Paint(ADestBmp: TBitmap32; const AX, AY: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Color : TColor32 read FColor write FColor;
  end;

implementation

uses
  GR32_Add_BlendModes;

{ TigPaintBrush }

constructor TigPaintBrush.Create(AOwner: TComponent);
begin
  inherited;

  FColor := clBlack32;
end;

procedure TigPaintBrush.Paint(ADestBmp: TBitmap32; const AX, AY: Integer);
var
  i, j           : Integer;
  LPaintX        : Integer;
  LPaintY        : Integer;
  LHalfWidth     : Integer;
  LHalfHeight    : Integer;
  m              : Byte;
  fa, fr, fg, fb : Byte;
  ba, br, bg, bb : Byte;
  LBlendColor    : TColor32;
  LSrcRow        : PColor32Array;
  LMskRow        : PColor32Array;
  LDstRow        : PColor32Array;
begin
  if ( not Assigned(ADestBmp) ) or
     ( not Assigned(FSourceBitmap) ) or
     ( not Assigned(FStrokeMask) ) or
     ( FSourceBitmap.Width <> ADestBmp.Width ) or
     ( FSourceBitmap.Height <> ADestBmp.Height) then
  begin
    Exit;
  end;

{$RANGECHECKS OFF}

  // calculate the half size of the brush stroke
  LHalfWidth  := FStrokeMask.Width div 2;
  LHalfHeight := FStrokeMask.Height div 2;

  // blend with shaped mask
  for j := 0 to (FStrokeMask.Height - 1) do
  begin
    LPaintY := AY - LHalfHeight + j;

    if (LPaintY < 0) or (LPaintY >= ADestBmp.Height) then
    begin
      Continue;
    end;

    LSrcRow := FSourceBitmap.ScanLine[LPaintY];
    LMskRow := FStrokeMask.ScanLine[j];
    LDstRow := ADestBmp.ScanLine[LPaintY];

    for i := 0 to (FStrokeMask.Width - 1) do
    begin
      LPaintX := AX - LHalfWidth + i;

      if (LPaintX < 0) or (LPaintX >= ADestBmp.Width) then
      begin
        Continue;
      end;

      m := LMskRow[i] and $FF;

      if m = 0 then
      begin
        Continue;
      end;

      ba := LDstRow[LPaintX] shr 24 and $FF;

      if ba > 0 then
      begin
        // blend color with blend mode
        LBlendColor := ARGBBlendByMode(FColor, LSrcRow[LPaintX], FOpacity, FBlendMode);

        fa := LBlendColor shr 24 and $FF;
        fr := LBlendColor shr 16 and $FF;
        fg := LBlendColor shr  8 and $FF;
        fb := LBlendColor        and $FF;

        br := LDstRow[LPaintX] shr 16 and $FF;
        bg := LDstRow[LPaintX] shr  8 and $FF;
        bb := LDstRow[LPaintX]        and $FF;

        ba := ( fa * m + ba * (255 - m) ) div 255; // blend alpha by brush shape
        br := ( fr * m + br * (255 - m) ) div 255;
        bg := ( fg * m + bg * (255 - m) ) div 255;
        bb := ( fb * m + bb * (255 - m) ) div 255;

        LDstRow[LPaintX] := (ba shl 24) or (br shl 16) or (bg shl 8) or bb;
      end
      else // if paint on transparent area...
      begin
        fa := FOpacity * m div 255;
        LDstRow[LPaintX] := (fa shl 24) or (FColor and $FFFFFF);
      end;
    end;
  end;

{$RANGECHECKS ON}
end;


end.
