unit igTool_BrushSimple;

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
 *   x2nie  < x2nie[at]yahoo[dot]com >
 *
 *
 * Contributor(s):
 *
 *
 * ***** END LICENSE BLOCK ***** *)

interface

uses
  Classes, Controls, SysUtils,
  GR32,
  igBase, igLayers;

type
  TigToolBrushSimple = class(TigTool)
  private
    FLeftButtonDown : Boolean;

  protected
    //Events. Polymorpism.
    procedure MouseDown(Sender: TigPaintBox; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TigCustomLayerPanel); override;
    procedure MouseMove(Sender: TigPaintBox; Shift: TShiftState; X,
      Y: Integer; Layer: TigCustomLayerPanel); override;
    procedure MouseUp(Sender: TigPaintBox; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TigCustomLayerPanel); override;
  public

  published 

  end;



implementation

{ TigToolBrushSimple }

procedure TigToolBrushSimple.MouseDown(Sender: TigPaintBox;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TigCustomLayerPanel);
var
  LRect  : TRect;
  LPoint : TPoint;
begin
  if Button = mbLeft then
  begin
    FLeftButtonDown := True;
    LPoint := Sender.ControlToBitmap( Point(X, Y) );

    LRect.Left   := LPoint.X - 10;
    LRect.Top    := LPoint.Y - 10;
    LRect.Right  := LPoint.X + 10;
    LRect.Bottom := LPoint.Y + 10;

    Layer.LayerBitmap.FillRectS(LRect, $7F000000);
    Layer.Changed(LRect);

  end;
end;

procedure TigToolBrushSimple.MouseMove(Sender: TigPaintBox; Shift: TShiftState;
  X, Y: Integer; Layer: TigCustomLayerPanel);
var
  LRect  : TRect;
  LPoint : TPoint;
begin
  LPoint := Sender.ControlToBitmap( Point(X, Y) );

  if FLeftButtonDown then
  begin
    LRect.Left   := LPoint.X - 10;
    LRect.Top    := LPoint.Y - 10;
    LRect.Right  := LPoint.X + 10;
    LRect.Bottom := LPoint.Y + 10;

    Layer.LayerBitmap.FillRectS(LRect, $7F000000);
    Layer.Changed(LRect);
  end;


end;

procedure TigToolBrushSimple.MouseUp(Sender: TigPaintBox; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; Layer: TigCustomLayerPanel);
begin
  if FLeftButtonDown then
  begin
    FLeftButtonDown := False;

    Layer.UpdateLayerThumbnail;
  end;
end;

end.
