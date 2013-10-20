unit MainForm;

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
 *   Ma Xiaoguang and Ma Xiaoming < gmbros[at]hotmail[dot]com >
 *
 *
 * Contributor(s):
 *
 *
 * ***** END LICENSE BLOCK ***** *)

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  GR32_Image, GR32,
  igBase;

type
  TfrmMain = class(TForm)
    pntbxDrawingArea: TigPaintBox;
    Panel1: TPanel;
    lblBrushSize: TLabel;
    imgStrokePreview: TImage32;
    scrlbrBrushSize: TScrollBar;
    btnResetBackground: TButton;
    lblBrushOpacity: TLabel;
    scrlbrBrushOpacity: TScrollBar;
    lblBrushColor: TLabel;
    shpBrushColor: TShape;
    ColorDialog: TColorDialog;
    lblBlendMode: TLabel;
    cmbbxBlendMode: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure scrlbrBrushSizeChange(Sender: TObject);
    procedure scrlbrBrushOpacityChange(Sender: TObject);
    procedure shpBrushColorMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cmbbxBlendModeChange(Sender: TObject);
    procedure btnResetBackgroundClick(Sender: TObject);
  private
    procedure SetPaintingStroke;
    procedure SetPaintingOpacity;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  Math,
  GR32_Add_BlendModes,
  igTool_PaintBrush;

{$R *.dfm}

{$RANGECHECKS OFF}
//This method is written by Zoltan Komaromy.
//Ezt csak a prevjúra használjuk!!, mert a végso intensityt majd nem itt, hanem a layer intensitynél szabályozzuk!!!
procedure MyFeatheredCircle(Bitmap32: TBitmap32; CenterX, CenterY, Radius, Feather: single; intensity:byte);
//modified by zoltan!
// Draw a disk on Bitmap. Bitmap must be a 256 color (pf8bit) palette bitmap,
// and parts outside the disk will get palette index 0, parts inside will get
// palette index 255, and in the antialiased area (feather), the pixels will
// get values inbetween.
// ***Parameters***
// Bitmap:
//   The bitmap to draw on
// CenterX, CenterY:
//   The center of the disk (float precision). Note that [0, 0] would be the
//   center of the first pixel. To draw in the exact middle of a 100x100 bitmap,
//   use CenterX = 49.5 and CenterY = 49.5
// Radius:
//   The radius of the drawn disk in pixels (float precision)
// Feather:
//   The feather area. Use 1 pixel for a 1-pixel antialiased area. Pixel centers
//   outside 'Radius + Feather / 2' become 0, pixel centers inside 'Radius - Feather/2'
//   become 255. Using a value of 0 will yield a bilevel image.
// Copyright (c) 2003 Nils Haeck M.Sc. www.simdesign.nl
var
  x, y: integer;
  LX, RX, LY, RY: integer;
  Fact: integer;
  RPF2, RMF2: single;
//  P: PByteArray;  //zoltan
  P: PColor32Array;
  SqY, SqDist: single;
  sqX: array of single;
  b:byte;
begin
  // Determine some helpful values (singles)
  RPF2 := sqr(Radius + Feather/2);
  RMF2 := sqr(Radius - Feather/2);

  // Determine bounds:
  LX := Max(floor(CenterX - RPF2), 0);
  RX := Min(ceil (CenterX + RPF2), Bitmap32.Width - 1);
  LY := Max(floor(CenterY - RPF2), 0);
  RY := Min(ceil (CenterY + RPF2), Bitmap32.Height - 1);

  if intensity=0 then
  begin
    //elméletileg elozoleg clearezve lett a kép, úgyhogy nem kéne csinálunk semmit se, de azért így tuti!
    for y := LY to RY do
    begin
      P := Bitmap32.Scanline[y];
      for x := LX to RX do
      begin
        P[x] := color32(255,255,255,255);
      end
    end;
  end
  else
  begin
    // Optimization run: find squares of X first
    SetLength(SqX, RX - LX + 1);
    for x := LX to RX do
      SqX[x - LX] := sqr(x - CenterX);

    // Loop through Y values
    for y := LY to RY do
    begin
      P := Bitmap32.Scanline[y];    //zoltan!!!
//       p :=  bitmap32.pixelptr[x,y];
      SqY := Sqr(y - CenterY);
      // Loop through X values
      for x := LX to RX do
      begin

        // determine squared distance from center for this pixel
        SqDist := SqY + SqX[x - LX];

        // inside inner circle? Most often..
        if sqdist < RMF2 then
        begin
        // inside the inner circle.. just give the scanline the new color
//        P[x] := 255;                       //orig
          P[x] := color32(255-intensity,255-intensity,255-intensity,255); //works ok!
//        P[x]:=SetAlpha(P[x], 255);
        end
        else
        begin
          // inside outer circle?
          if sqdist < RPF2 then
          begin
            // We are inbetween the inner and outer bound, now mix the color
            Fact := round(((Radius - sqrt(sqdist)) * 2 / Feather) * 127.5 + 127.5);
//          P[x] := Max(0, Min(Fact, 255)); // just in case limit to [0, 255]   //orig
            b:=Max(0, Min(Fact, 255)); // just in case limit to [0, 255]
            b:=255-round(b/(255/intensity));
            P[x] := color32(b,b,b,255);  //works ok!
//          P[x]:=SetAlpha(P[x], b);
          end
          else
          begin
            //P[x] := 0;
            P[x] := color32(255,255,255,255);   //works ok!           külso fehér
//          P[x]:=SetAlpha(P[x], 0);
          end;
        end;
      end;
    end;
  end;
end;
{$RANGECHECKS ON}

procedure InvertBitamp(ABitmap: TBitmap32);
var
  i       : Integer;
  p       : PColor32;
  r, g, b : Cardinal;
begin
  p := @ABitmap.Bits[0];

  for i := 1 to (ABitmap.Width * ABitmap.Height) do
  begin
    r := 255 - (p^ shr 16 and $FF);
    g := 255 - (p^ shr 8 and $FF);
    b := 255 - (P^ and $FF);

    p^ := (p^ and $FF000000) or (r shl 16) or (g shl 8) or b;
    
    Inc(p);
  end;
end;

procedure TfrmMain.SetPaintingStroke;
var
  LBrush : TigPaintBrush;
  LBmp   : TBitmap32;
begin
  LBrush := TigPaintBrush( GIntegrator.ActiveTool );

  LBmp := TBitmap32.Create;
  try
    LBmp.SetSize(scrlbrBrushSize.Position * 2 + 1, scrlbrBrushSize.Position * 2 + 1);
    LBmp.Clear(clBlack32);

    MyFeatheredCircle(LBmp, LBmp.Width div 2, LBmp.Height div 2, scrlbrBrushSize.Position div 2, 12, 255);
    imgStrokePreview.Bitmap.Assign(LBmp);

    InvertBitamp(LBmp);
    LBrush.SetPaintingStroke(LBmp);
  finally
    LBmp.Free;
  end;
end;

procedure TfrmMain.SetPaintingOpacity;
var
  LBrush : TigPaintBrush;
begin
  LBrush         := TigPaintBrush( GIntegrator.ActiveTool );
  LBrush.Opacity := scrlbrBrushOpacity.Position;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  //set a drawing tool for mouse operation's response.
  GIntegrator.ActivateTool(TigPaintBrush);

  SetPaintingStroke;

  cmbbxBlendMode.Items     := BlendModeList;
  cmbbxBlendMode.ItemIndex := 0;
end;

procedure TfrmMain.scrlbrBrushSizeChange(Sender: TObject);
begin
  lblBrushSize.Caption := 'Brush Size: ' + IntToStr(scrlbrBrushSize.Position) + 'px';
  SetPaintingStroke;
end;

procedure TfrmMain.scrlbrBrushOpacityChange(Sender: TObject);
begin
  lblBrushOpacity.Caption := 'Brush Opacity: ' + IntToStr(scrlbrBrushOpacity.Position * 100 div 255) + '%';
  SetPaintingOpacity;
end;

procedure TfrmMain.shpBrushColorMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  LBrush : TigPaintBrush;
begin
  LBrush := TigPaintBrush( GIntegrator.ActiveTool );

  ColorDialog.Color := shpBrushColor.Brush.Color;

  if ColorDialog.Execute then
  begin
    shpBrushColor.Brush.Color := ColorDialog.Color;
    LBrush.Color              := Color32(ColorDialog.Color);
  end;
end;

procedure TfrmMain.cmbbxBlendModeChange(Sender: TObject);
var
  LBrush : TigPaintBrush;
begin
  LBrush           := TigPaintBrush( GIntegrator.ActiveTool );
  LBrush.BlendMode := TBlendMode32(cmbbxBlendMode.ItemIndex);
end;

procedure TfrmMain.btnResetBackgroundClick(Sender: TObject);
begin
  pntbxDrawingArea.LayerList.SelectedPanel.LayerBitmap.Clear(clWhite32);
  pntbxDrawingArea.LayerList.SelectedPanel.Changed;
end;

end.
