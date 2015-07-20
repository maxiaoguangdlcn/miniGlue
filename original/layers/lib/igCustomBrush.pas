unit igCustomBrush;

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
  SysUtils, Classes, Controls,
{ Graphics32 }
  GR32,
{ externals\Graphics32_add_ons }
  GR32_Add_BlendModes,
{ miniGlue }
  igTool;

type
  { TigCustomBrush }
  TigBrushPaintEvent = procedure (ASender: TObject; const APaintRect: TRect) of object;

  TigCustomBrush = class(TigCustomTool)
  private
    FOnBrushPaintEvent : TigBrushPaintEvent;

    // brush line related fields by Zoltan Komaromy
    Felozox            : Integer;
    Felozoy            : Integer;
    Ftavolsag          : Double;
    FPrevStrokePoint   : TPoint;

    // brush line by Zoltan Komaromy
    procedure BrushLine(const xStart, yStart, xEnd, yEnd, distance: Integer;
      ToBitmap: TCustomBitmap32);
  protected
    FSourceBitmap   : TBitmap32;
    FStrokeMask     : TBitmap32;
    FBlendMode      : TBlendMode32;
    FOpacity        : Byte;         // 0..255
    FStrokeInterval : Integer;

    function GetPaintRect(const AX, AY: Integer): TRect;
    procedure Paint(ADestBmp: TCustomBitmap32; const AX, AY: Integer); virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetSourceBitmap(ABitmap: TCustomBitmap32);
    procedure SetPaintingStroke(AStrokeMask: TCustomBitmap32);

    procedure MouseDown(ASender: TObject; AButton: TMouseButton;
      AShift: TShiftState; AX, AY: Integer; ABitmap: TCustomBitmap32); override;

    procedure MouseMove(ASender: TObject; AShift: TShiftState; AX, AY: Integer;
      ABitmap: TCustomBitmap32); override;

    procedure MouseUp(ASender: TObject; AButton: TMouseButton;
      AShift: TShiftState; AX, AY: Integer; ABitmap: TCustomBitmap32); override;

    property Opacity           : Byte               read FOpacity           write FOpacity;
    property BlendMode         : TBlendMode32       read FBlendMode         write FBlendMode;
    property OnBrushPaintEvent : TigBrushPaintEvent read FOnBrushPaintEvent write FOnBrushPaintEvent;
  end;

implementation

uses
{ miniGlue  }
  igMath;


{ TigCustomBrush }

{ Bresenham algorithm for Brush tools to get continuous brush strokes.
  Author         : Zoltan Komaromy (zoltan@komaromy-nospam.hu)
  Website        : www.mandalapainter.com
  SourceCode From: gr32PainterDemo3 }
procedure TigCustomBrush.BrushLine(
  const xStart, yStart, xEnd, yEnd, distance: Integer;
  ToBitmap: TCustomBitmap32);
var
  a,b         : Integer;  // displacements in x and y
  d           : Integer;  // decision variable
  diag_inc    : Integer;  // d's increment for diagonal steps
  dx_diag     : Integer;  // diagonal x step for next pixel
  dx_nondiag  : Integer;  // nondiagonal x step for next pixel
  dy_diag     : Integer;  // diagonal y step for next pixel
  dy_nondiag  : Integer;  // nondiagonal y step for next pixel
  i           : Integer;  // loop index
  nondiag_inc : Integer;  // d's increment for nondiagonal steps
  swap        : Integer;  // temporary variable for swap
  x,y         : Integer;  // current x and y coordinates
begin {DrawLine}
  x := xStart;              // line starting point
  y := yStart;

  // Determine drawing direction and step to the next pixel.
  a := xEnd - xStart;       // difference in x dimension
  b := yEnd - yStart;       // difference in y dimension

  // Determine whether end point lies to right or left of start point.
  if a < 0 then               // drawing towards smaller x values?
  begin
    a       := -a;            // make 'a' positive
    dx_diag := -1
  end
  else dx_diag := 1;

  // Determine whether end point lies above or below start point.
  if b < 0 then               // drawing towards smaller y values?
  begin
    b       := -b;            // make 'b' positive
    dy_diag := -1
  end
  else dy_diag := 1;

  // Identify octant containing end point.
  if a < b then
  begin
    swap       := a;
    a          := b;
    b          := swap;
    dx_nondiag := 0;
    dy_nondiag := dy_diag
  end
  else
  begin
    dx_nondiag := dx_diag;
    dy_nondiag := 0
  end;

  d           := b + b - a;  // initial value for d is 2*b - a
  nondiag_inc := b + b;      // set initial d increment values
  diag_inc    := b + b - a - a;

  for i := 0 to a do    // draw the a+1 pixels
  begin
    if Ftavolsag >= distance then
    begin
      Paint(ToBitmap, x, y);
      Ftavolsag := 0;
      Felozox   := x;
      Felozoy   := y;
    end;

    if d < 0 then              // is midpoint above the line?
    begin                      // step nondiagonally
      x := x + dx_nondiag;
      y := y + dy_nondiag;
      d := d + nondiag_inc   // update decision variable
    end
    else
    begin                    // midpoint is above the line; step diagonally
      x := x + dx_diag;
      y := y + dy_diag;
      d := d + diag_inc
    end;

    Ftavolsag := (  sqrt( sqr(x - Felozox) + sqr(y - Felozoy) )  );
  end; //for
end;

constructor TigCustomBrush.Create;
begin
  inherited;

  FBlendMode         := bbmNormal32;
  FOpacity           := 255;
  FStrokeInterval    := 1;
  FOnBrushPaintEvent := nil;

  FSourceBitmap := nil;
  FStrokeMask   := nil;
end;

destructor TigCustomBrush.Destroy;
begin
  FSourceBitmap.Free;
  FStrokeMask.Free;

  inherited;
end;

function TigCustomBrush.GetPaintRect(const AX, AY: Integer): TRect;
begin
  Result := Rect(0, 0, 0, 0);
  
  if Assigned(FStrokeMask) then
  begin
    with Result do
    begin
      Left   := AX - FStrokeMask.Width div 2;
      Top    := AY - FStrokeMask.Height div 2;
      Right  := Left + FStrokeMask.Width;
      Bottom := Top + FStrokeMask.Height;
    end;
  end;
end;

procedure TigCustomBrush.SetPaintingStroke(AStrokeMask: TCustomBitmap32);
begin
  if Assigned(AStrokeMask) then
  begin
    if Assigned(FStrokeMask) then
    begin
      FreeAndNil(FSourceBitmap);
    end;

    FStrokeMask := TBitmap32.Create;
    FStrokeMask.Assign(AStrokeMask);
  end;
end;

procedure TigCustomBrush.SetSourceBitmap(ABitmap: TCustomBitmap32);
begin
  if Assigned(ABitmap) then
  begin
    if Assigned(FSourceBitmap) then
    begin
      FreeAndNil(FSourceBitmap);
    end;

    FSourceBitmap := TBitmap32.Create;
    FSourceBitmap.Assign(ABitmap);
  end;
end;

procedure TigCustomBrush.MouseDown(ASender: TObject; AButton: TMouseButton;
  AShift: TShiftState; AX, AY: Integer; ABitmap: TCustomBitmap32);
var
  LRect : TRect;
begin
{ Mouse left button down }

  if AButton = mbLeft then
  begin
    Felozox          := AX;
    Felozoy          := AY;
    FPrevStrokePoint := Point(AX, AY);
    Ftavolsag        := 0; // For BrushLine() function

    SetSourceBitmap(ABitmap);
    Paint(ABitmap, AX, AY);

    LRect := GetPaintRect(AX, AY);

    if Assigned(FOnBrushPaintEvent) then
    begin
      FOnBrushPaintEvent(Self, LRect);
    end;

    FMouseLeftButtonDown := True;
  end;
end;

procedure TigCustomBrush.MouseMove(ASender: TObject; AShift: TShiftState;
  AX, AY: Integer; ABitmap: TCustomBitmap32);
var
  LLastStrokeArea : TRect;
  LBrushArea      : TRect;
begin
  if FMouseLeftButtonDown then
  begin
    // get refresh area
    LLastStrokeArea := GetPaintRect(FPrevStrokePoint.X, FPrevStrokePoint.Y);
    LBrushArea      := GetPaintRect(AX, AY);
    LBrushArea      := AddRects(LLastStrokeArea, LBrushArea);

    BrushLine(FPrevStrokePoint.X, FPrevStrokePoint.Y, AX, AY,
              FStrokeInterval, ABitmap);


    if Assigned(FOnBrushPaintEvent) then
    begin
      FOnBrushPaintEvent(Self, LBrushArea);
    end;

    FPrevStrokePoint := Point(AX, AY);
  end;
end;

procedure TigCustomBrush.MouseUp(ASender: TObject; AButton: TMouseButton;
  AShift: TShiftState; AX, AY: Integer; ABitmap: TCustomBitmap32);
begin
  if FMouseLeftButtonDown then
  begin
    FMouseLeftButtonDown := False;

    if Assigned(FOnBrushPaintEvent) then
    begin
      // TODO:
      // Don't know why we need to refresh all the screen,
      // otherwise, when a child form getting focus again,
      // the viewport rendered incorrectly ...
      FOnBrushPaintEvent(Self, ABitmap.ClipRect);
    end;
  end;
end;

end.
