unit igPaintFuncs;

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
  Classes,
{ Graphics32 }
  GR32;

procedure DrawCheckerboardPattern(const ADestBmp: TBitmap32;
  const ASmallPattern: Boolean = False); overload;

procedure DrawCheckerboardPattern(const ADestBmp: TBitmap32;
  const ARect: TRect; const ASmallPattern: Boolean = False); overload;

implementation

uses
{ Graphics32 }
  GR32_LowLevel;


// This procedure is got from example PixelF of Graphics32.
procedure DrawCheckerboardPattern(const ADestBmp: TBitmap32;
  const ASmallPattern: Boolean = False);
const
  Colors : array [0..1] of TColor32 = ($FFFFFFFF, $FFB0B0B0);
var
  i, LParity     : Integer;
  LLine1, LLine2 : TArrayOfColor32; // a buffer for a couple of scanlines
begin
  with ADestBmp do
  begin
    SetLength(LLine1, Width);
    SetLength(LLine2, Width);
    
    for i := 0 to (Width - 1) do
    begin
      if ASmallPattern then
      begin
        LParity := i shr 2 and $1;
      end
      else
      begin
        LParity := i shr 3 and $1;
      end;

      LLine1[i] := Colors[LParity];
      LLine2[i] := Colors[1 - LParity];
    end;
    
    for i := 0 to (Height - 1) do
    begin
      if ASmallPattern then
      begin
        LParity := i shr 2 and $1;
      end
      else
      begin
        LParity := i shr 3 and $1;
      end;
      
      if Boolean(LParity) then
      begin
        MoveLongword(LLine1[0], ScanLine[i]^, Width);
      end
      else
      begin
        MoveLongword(LLine2[0], ScanLine[i]^, Width);
      end;
    end;
  end;
end;

// This procedure is got from example PixelF of Graphics32.
procedure DrawCheckerboardPattern(const ADestBmp: TBitmap32; const ARect: TRect;
  const ASmallPattern: Boolean = False);
const
  Colors: array [0..1] of TColor32 = ($FFFFFFFF, $FFB0B0B0);
var
  w, h, i, j    : Integer;
  x, y, LParity : Integer;
  LLine1, LLine2: TArrayOfColor32; // a buffer for a couple of scanlines
  LDestRow      : PColor32Array;
  LRect         : TRect;
begin
{$RANGECHECKS OFF}

  if not Assigned(ADestBmp) then
  begin
    Exit;
  end;

  LRect.Left   := Clamp(ARect.Left,   0, ADestBmp.Width);
  LRect.Right  := Clamp(ARect.Right,  0, ADestBmp.Width);
  LRect.Top    := Clamp(ARect.Top,    0, ADestBmp.Height);
  LRect.Bottom := Clamp(ARect.Bottom, 0, ADestBmp.Height);

  if (LRect.Left >= LRect.Right) or
     (LRect.Top  >= LRect.Bottom) then
  begin
    Exit;
  end;

  w := LRect.Right  - LRect.Left;
  h := LRect.Bottom - LRect.Top;

  SetLength(LLine1, w);
  SetLength(LLine2, w);

  for i := 0 to (w - 1) do
  begin
    if ASmallPattern then
    begin
      LParity := i shr 2 and $1;
    end
    else
    begin
      LParity := i shr 3 and $1;
    end;

    LLine1[i] := Colors[LParity];
    LLine2[i] := Colors[1 - LParity];
  end;
    
  for j := 0 to (h - 1) do
  begin
    y        := j + LRect.Top;
    LDestRow := ADestBmp.Scanline[y];

    if ASmallPattern then
    begin
      LParity := j shr 2 and $1;
    end
    else
    begin
      LParity := j shr 3 and $1;
    end;

    for i := 0 to (w - 1) do
    begin
      x := i + LRect.Left;

      if Boolean(LParity) then
      begin
        LDestRow[x] := LLine1[i];
      end
      else
      begin
        LDestRow[x] := LLine2[i];
      end;
    end;
  end;

{$RANGECHECKS ON}
end;

end.
