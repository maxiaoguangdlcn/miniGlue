unit igPaintBrush;

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
{ Graphics32 }
  GR32,
{ miniGlue lib }
  igCustomBrush;

type
  { TigPaintBrush }
  
  TigPaintBrush = class(TigCustomBrush)
  private
    FColor : TColor32;
  protected
//    procedure Paint(ADestBmp: TBitmap32; const AX, AY: Integer); override;
  public
    constructor Create;

    procedure Paint(ADestBmp: TCustomBitmap32; const AX, AY: Integer); override;

    property Color : TColor32 read FColor write FColor;
  end;

implementation

uses
{ externals\Graphics32_add_ons }
  GR32_Add_BlendModes;

{ TigPaintBrush }

constructor TigPaintBrush.Create;
begin
  inherited;

  FColor := clRed32;
  FOpacity := 128;
end;

procedure TigPaintBrush.Paint(ADestBmp: TCustomBitmap32; const AX, AY: Integer);
var
  i, j                       : Integer;
  CurPaintX, CurPaintY       : Integer;
  LHalfWidth                 : Integer;
  LHalfHeight                : Integer;
  MaskIntensity              : Byte;
  fa, fr, fg, fb             : Byte;
  ba, br, bg, bb             : Byte;
  BlendColor                 : TColor32;
  SourceRow, MaskRow, DestRow: PColor32Array;
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
    CurPaintY := AY - LHalfHeight + j;

    if (CurPaintY < 0) or (CurPaintY >= ADestBmp.Height) then
    begin
      Continue;
    end;

    SourceRow := FSourceBitmap.ScanLine[CurPaintY];
    MaskRow   := FStrokeMask.ScanLine[j];
    DestRow   := ADestBmp.ScanLine[CurPaintY];

    for i := 0 to (FStrokeMask.Width - 1) do
    begin
      CurPaintX := AX - LHalfWidth + i;

      if (CurPaintX < 0) or (CurPaintX >= ADestBmp.Width) then
      begin
        Continue;
      end;

      MaskIntensity := MaskRow[i] and $FF;

      if MaskIntensity = 0 then
      begin
        Continue;
      end;

      ba := DestRow[CurPaintX] shr 24 and $FF;

      if ba > 0 then
      begin
        // blend color with blend mode
        BlendColor := ARGBBlendByMode(FColor, SourceRow[CurPaintX], FOpacity, FBlendMode);

        // blend alpha by brush shape
        fa := BlendColor shr 24 and $FF;
        ba := (fa * MaskIntensity + ba * (255 - MaskIntensity)) div 255;

        br := DestRow[CurPaintX] shr 16 and $FF;
        bg := DestRow[CurPaintX] shr  8 and $FF;
        bb := DestRow[CurPaintX]        and $FF;

        fr := BlendColor shr 16 and $FF;
        br := ( fr * MaskIntensity + br * (255 - MaskIntensity) ) div 255;

        fg := BlendColor shr  8 and $FF;
        bg := ( fg * MaskIntensity + bg * (255 - MaskIntensity) ) div 255;

        fb := BlendColor and $FF;
        bb := ( fb * MaskIntensity + bb * (255 - MaskIntensity) ) div 255;

        DestRow[CurPaintX] := (ba shl 24) or (br shl 16) or (bg shl 8) or bb;
      end
      else // if paint on transparent area...
      begin
        fa := FOpacity * MaskIntensity div 255;
        DestRow[CurPaintX] := (fa shl 24) or (FColor and $FFFFFF);
      end;
    end;
  end;

{$RANGECHECKS ON}
end;

end.
