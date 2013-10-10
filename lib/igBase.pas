unit igBase;

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

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

(* ***** BEGIN NOTICE BLOCK *****
 *
 * I decide to combine Tools, PaintViewer & PaintAgent into this single file
 * for increase readability and easier to integrate those objects.
 *
 * ***** END NOTICE BLOCK *****)

uses
  SysUtils, Classes,IniFiles, Controls,
{$IFDEF FPC}
  LCLIntf, LCLType, LMessages, Types,
 {$ELSE}
  Windows, Messages,
{$ENDIF}
  Forms,
  GR32, GR32_Image, GR32_Layers;

type
  TigDebugLog = procedure(Sender : TObject; const Msg : string; ident: Integer = 0) of object;

  TigChangingEvent = procedure(Sender: TObject; const Info : string) of object;


  { far definitions }
  TigPaintBox = class;                  // drawing canvas
  TigTool = class;                      // drawing tool
  TigToolClass = class of TigTool;
  TigIntegrator = class;
  TigAgent = class;                     // bridge for link-unlink, avoid error
  TigTheme = class;


  TigIntegrator = class(TComponent)     // Event Organizer. hidden component
  {   An Integrator is a hidden component responsible for managing traffic
      (integration) behind all objects linked to it including (but not limited):
      * the drawing canvas,
      * corresponding active drawing tool,
      * switching between layers / picking the real bitmap of paint operation
      * switching between drawing canvas (in MDI mode)
      * undo / redo
      * debug log
  }
  private
    FListeners: TList;
    FInstancesList : TList;
    FActiveTool: TigTool;
  protected
    procedure DoMouseDown(Sender: TigPaintBox; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure DoMouseMove(Sender: TigPaintBox; Shift: TShiftState; X,
      Y: Integer; Layer: TCustomLayer);
    procedure DoMouseUp(Sender: TigPaintBox; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
  end;

  TigAgent = class(TComponent)
  { the event listener of drawing-canvas
    or redirection for such arranging layers 
  }
  end;


  TigPaintBox = class(TCustomImage32)
  { the drawing-canvas object
  }
  private
    FAgent : TigAgent;    
  public
    constructor Create(AOwner : TComponent); override;
  end;

  TigTool = class(TComponent)
  private
    FCursor: TCursor;
    FImage32: TCustomImage32;
    FOnAfterDblClick: TNotifyEvent;
    FOnBeforeDblClick: TNotifyEvent;
    FOnFinalEdit: TNotifyEvent;
    FOnChanging: TigChangingEvent;
    //function GetToolInstance(index: TgmToolClass): TgmTool;
  protected
    FModified: Boolean; //wether this tool has success or canceled to made a modification of target.
    FOnAfterMouseDown: TImgMouseEvent;
    FOnBeforeMouseUp: TImgMouseEvent;
    FOnAfterMouseUp: TImgMouseEvent;
    FOnBeforeMouseDown: TImgMouseEvent;
    FOnBeforeMouseMove: TImgMouseMoveEvent;
    FOnAfterMouseMove: TImgMouseMoveEvent;
    //Events. Descendant may inherited. Polymorpism.
    procedure MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer); virtual;
    procedure MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer; Layer: TCustomLayer); virtual;
    procedure MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer); virtual;
    procedure KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure KeyPress(Sender: TObject; var Key: Char); virtual;
    procedure KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure DblClick(Sender: TObject); virtual;
    procedure FinalEdit;virtual;


    //Internal use Events. Descendant may NOT inherits. call by integrator
    procedure DoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer); //virtual;
    procedure DoMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer; Layer: TCustomLayer); //virtual;
    procedure DoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer); //virtual;
    procedure DoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); //virtual;
    procedure DoKeyPress(Sender: TObject; var Key: Char); //virtual;
    procedure DoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); //virtual;
    procedure DoDblClick(Sender: TObject);
    procedure DoChanging(const Info : string);
  published
    property Cursor : TCursor read FCursor write FCursor; //default cursor when activated.
    property OnBeforeMouseDown : TImgMouseEvent read FOnBeforeMouseDown write FOnBeforeMouseDown; 
    property OnAfterMouseDown : TImgMouseEvent read FOnAfterMouseDown write FOnAfterMouseDown;
    property OnBeforeMouseUp : TImgMouseEvent read FOnBeforeMouseUp write FOnBeforeMouseUp;
    property OnAfterMouseUp : TImgMouseEvent read FOnAfterMouseUp write FOnAfterMouseUp;
    property OnBeforeMouseMove : TImgMouseMoveEvent read FOnBeforeMouseMove write FOnBeforeMouseMove;
    property OnAfterMouseMove : TImgMouseMoveEvent read FOnAfterMouseMove write FOnAfterMouseMove;
    property OnBeforeDblClick : TNotifyEvent read FOnBeforeDblClick write FOnBeforeDblClick;
    property OnAfterDblClick : TNotifyEvent read FOnAfterDblClick write FOnAfterDblClick;
    property OnChanging  : TigChangingEvent read FOnChanging write FOnChanging; //prepare undo signal
    property OnFinalEdit : TNotifyEvent read FOnFinalEdit write FOnFinalEdit; 
  end;

  TigTheme = class(TComponent)
  end;

implementation

{ TigIntegrator }

procedure TigIntegrator.DoMouseDown(Sender: TigPaintBox;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin

end;

procedure TigIntegrator.DoMouseMove(Sender: TigPaintBox;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
begin
  if Assigned(FActiveTool) then
    FActiveTool.DoMouseMove(Sender, Shift, X,Y, Layer);
end;

procedure TigIntegrator.DoMouseUp(Sender: TigPaintBox;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
begin
  if Assigned(FActiveTool) then
    FActiveTool.DoMouseUp(Sender, Button, Shift, X,Y, Layer);
end;

{ TigTool }

procedure TigTool.DblClick(Sender: TObject);
begin
  if Assigned(FOnBeforeDblClick) then
    FOnBeforeDblClick(Sender);

  DblClick(Sender);

  if Assigned(FOnAfterDblClick) then
    FOnAfterDblClick(Sender);
end;

procedure TigTool.DoChanging(const Info: string);
begin
  if Assigned(FOnChanging) then
    FOnChanging(Self, Info);
end;

procedure TigTool.DoDblClick(Sender: TObject);
begin
  if Assigned(FOnBeforeDblClick) then
    FOnBeforeDblClick(Sender);

  DblClick(Sender);

  if Assigned(FOnAfterDblClick) then
    FOnAfterDblClick(Sender);
end;

procedure TigTool.DoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  KeyDown(Sender, Key, Shift);
end;

procedure TigTool.DoKeyPress(Sender: TObject; var Key: Char);
begin
  KeyPress(Sender, Key);
end;

procedure TigTool.DoKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  KeyUp(Sender, Key, Shift);
end;

procedure TigTool.DoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
begin
  if Assigned(FOnBeforeMouseDown) then
    FOnBeforeMouseDown(Sender, Button, Shift, X, Y, Layer);

  MouseDown(Sender, Button, Shift, X, Y, Layer);

  if Assigned(FOnAfterMouseDown) then
    FOnAfterMouseDown(Sender, Button, Shift, X, Y, Layer);
end;

procedure TigTool.DoMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer; Layer: TCustomLayer);
begin
  if Assigned(FOnBeforeMouseMove) then
    FOnBeforeMouseMove(Sender, Shift, X, Y, Layer);

  MouseMove(Sender, Shift, X, Y, Layer);

  if Assigned(FOnAfterMouseMove) then
    FOnAfterMouseMove(Sender, Shift, X, Y, Layer);
end;

procedure TigTool.DoMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
begin
  if Assigned(FOnBeforeMouseUp) then
    FOnBeforeMouseUp(Sender, Button, Shift, X, Y, Layer);

  MouseUp(Sender, Button, Shift, X, Y, Layer);

  if Assigned(FOnAfterMouseUp) then
    FOnAfterMouseUp(Sender, Button, Shift, X, Y, Layer);
end;

procedure TigTool.FinalEdit;
begin
  if Assigned(FOnFinalEdit) then
    FOnFinalEdit(Self);
end;

procedure TigTool.KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //descendant may do something
end;

procedure TigTool.KeyPress(Sender: TObject; var Key: Char);
begin
  //descendant may do something
end;

procedure TigTool.KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //descendant may do something
end;

procedure TigTool.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
begin
  //descendant may do something
end;

procedure TigTool.MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer; Layer: TCustomLayer);
begin
  //descendant may do something
end;

procedure TigTool.MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
begin
  //descendant may do something
end;

{ TigPaintBox }

constructor TigPaintBox.Create(AOwner: TComponent);
begin
  inherited;
  FAgent := TigAgent.Create(self); //autodestroy
end;

end.
