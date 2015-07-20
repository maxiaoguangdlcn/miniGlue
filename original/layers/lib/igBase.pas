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
 * Update Date: November 11th, 2014
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
  Forms, Contnrs,
  GR32, GR32_Image, GR32_Layers,
  igLayers;

type

  { far definitions }
  TigPaintBox = class;                  // drawing canvas
  TigTool = class;                      // drawing tool
  TigToolClass = class of TigTool;
  TigIntegrator = class;
  TigAgent = class;                     // bridge for link-unlink, avoid error
  TigTheme = class;

  TigDebugLog = procedure(Sender : TObject; const Msg : string; ident: Integer = 0) of object;

  TigChangingEvent = procedure(Sender: TObject; const Info : string) of object;
  TigMouseEvent = procedure(Sender: TigPaintBox; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer; Layer: TigCustomLayer) of object;
  TigMouseMoveEvent = procedure(Sender: TigPaintBox; Shift: TShiftState;
    X, Y: Integer; Layer: TigCustomLayer) of object;


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
    function LoadTool(AToolClass: TigToolClass): TigTool;
    function ReadyToSwitchTool : Boolean;
    function IsToolSwitched(ATool: TigTool):Boolean;
  protected
    procedure DoMouseDown(Sender: TigPaintBox; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TigCustomLayer);
    procedure DoMouseMove(Sender: TigPaintBox; Shift: TShiftState; X,
      Y: Integer; Layer: TigCustomLayer);
    procedure DoMouseUp(Sender: TigPaintBox; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TigCustomLayer);
  public
    constructor Create(AOwner: TComponent); override;
    function ActivateTool(ATool: TigToolClass):Boolean;
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
    FLayerList: TigLayerList;
    procedure AfterLayerCombined(ASender: TObject; const ARect: TRect);

  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    property LayerList : TigLayerList read FLayerList;
  published
    property Align;
    property TabStop default True;
    property Options default [pboAutoFocus];
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
    FOnAfterMouseDown: TigMouseEvent;
    FOnBeforeMouseUp: TigMouseEvent;
    FOnAfterMouseUp: TigMouseEvent;
    FOnBeforeMouseDown: TigMouseEvent;
    FOnBeforeMouseMove: TigMouseMoveEvent;
    FOnAfterMouseMove: TigMouseMoveEvent;

    //Events. Descendant may inherited. Polymorpism.
    function CanBeSwitched: Boolean; virtual;
    procedure MouseDown(Sender: TigPaintBox; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TigCustomLayer); virtual;
    procedure MouseMove(Sender: TigPaintBox; Shift: TShiftState; X,
      Y: Integer; Layer: TigCustomLayer); virtual;
    procedure MouseUp(Sender: TigPaintBox; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TigCustomLayer); virtual;
    procedure KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure KeyPress(Sender: TObject; var Key: Char); virtual;
    procedure KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); virtual;
    procedure DblClick(Sender: TObject); virtual;
    procedure FinalEdit;virtual;


    //Events used internally. Descendant may NOT inherits. call by integrator
    procedure DoMouseDown(Sender: TigPaintBox; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TigCustomLayer); //virtual;
    procedure DoMouseMove(Sender: TigPaintBox; Shift: TShiftState; X,
      Y: Integer; Layer: TigCustomLayer); //virtual;
    procedure DoMouseUp(Sender: TigPaintBox; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TigCustomLayer); //virtual;
    procedure DoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState); //virtual;
    procedure DoKeyPress(Sender: TObject; var Key: Char); //virtual;
    procedure DoKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState); //virtual;
    procedure DoDblClick(Sender: TObject);
    procedure DoChanging(const Info : string);
  published
    property Cursor : TCursor read FCursor write FCursor; //default cursor when activated.
    property OnBeforeMouseDown : TigMouseEvent read FOnBeforeMouseDown write FOnBeforeMouseDown; 
    property OnAfterMouseDown : TigMouseEvent read FOnAfterMouseDown write FOnAfterMouseDown;
    property OnBeforeMouseUp : TigMouseEvent read FOnBeforeMouseUp write FOnBeforeMouseUp;
    property OnAfterMouseUp : TigMouseEvent read FOnAfterMouseUp write FOnAfterMouseUp;
    property OnBeforeMouseMove : TigMouseMoveEvent read FOnBeforeMouseMove write FOnBeforeMouseMove;
    property OnAfterMouseMove : TigMouseMoveEvent read FOnAfterMouseMove write FOnAfterMouseMove;
    property OnBeforeDblClick : TNotifyEvent read FOnBeforeDblClick write FOnBeforeDblClick;
    property OnAfterDblClick : TNotifyEvent read FOnAfterDblClick write FOnAfterDblClick;
    property OnChanging  : TigChangingEvent read FOnChanging write FOnChanging; //prepare undo signal
    property OnFinalEdit : TNotifyEvent read FOnFinalEdit write FOnFinalEdit; 
  end;

  TigTheme = class(TComponent)
  end;

{GLOBAL}
var
  GIntegrator : TigIntegrator = nil;


implementation


{ TigIntegrator }

constructor TigIntegrator.Create(AOwner: TComponent);
var
  i : Integer;
const
  dont_manual = 'Dont create manually, it will be created automatically';
begin
  Assert(AOwner is TApplication, dont_manual);
  for i := 0 to Application.ComponentCount-1 do
  begin
    if Application.Components[i] is TigIntegrator then
    raise Exception.Create(dont_manual);
  end;

  inherited;
  FInstancesList := TList.Create;

end;

procedure TigIntegrator.DoMouseDown(Sender: TigPaintBox;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TigCustomLayer);
begin
  if Assigned(FActiveTool) then
    FActiveTool.DoMouseDown(Sender, Button, Shift, X,Y, Layer);
end;

procedure TigIntegrator.DoMouseMove(Sender: TigPaintBox;
  Shift: TShiftState; X, Y: Integer; Layer: TigCustomLayer);
begin
  if Assigned(FActiveTool) then
    FActiveTool.DoMouseMove(Sender, Shift, X,Y, Layer);
end;

procedure TigIntegrator.DoMouseUp(Sender: TigPaintBox;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TigCustomLayer);
begin
  if Assigned(FActiveTool) then
    FActiveTool.DoMouseUp(Sender, Button, Shift, X,Y, Layer);
end;

// Find a tool instance, create one if not found
function TigIntegrator.LoadTool(AToolClass: TigToolClass): TigTool;
var i : Integer;
  //LTool : TgmTool;
begin
  Result := nil;
  for i := 0 to FInstancesList.Count -1 do
  begin
    if TigTool(FInstancesList[i]) is AToolClass then
    begin
      Result := TigTool(FInstancesList[i]);
      Break;
    end;
  end;

  if not Assigned(Result) then
  begin
    Result := AToolClass.Create(Application); //it must by owned by something.
    FInstancesList.Add(Result);
  end;

end;

function TigIntegrator.ReadyToSwitchTool: Boolean;
begin
  Result := True;
  if (FActiveTool <> nil) then
    Result := FActiveTool.CanBeSwitched;
end;

{ TigTool }

//sometime a tool can't be switched automatically.
//such while working in progress or need to be approved or discharged.
function TigTool.CanBeSwitched: Boolean;
begin
  Result := True;
end;

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

procedure TigTool.DoMouseDown(Sender: TigPaintBox; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; Layer: TigCustomLayer);
begin
  if Assigned(FOnBeforeMouseDown) then
    FOnBeforeMouseDown(Sender, Button, Shift, X, Y, Layer);

  MouseDown(Sender, Button, Shift, X, Y, Layer);

  if Assigned(FOnAfterMouseDown) then
    FOnAfterMouseDown(Sender, Button, Shift, X, Y, Layer);
end;

procedure TigTool.DoMouseMove(Sender: TigPaintBox; Shift: TShiftState; X,
  Y: Integer; Layer: TigCustomLayer);
begin
  if Assigned(FOnBeforeMouseMove) then
    FOnBeforeMouseMove(Sender, Shift, X, Y, Layer);

  MouseMove(Sender, Shift, X, Y, Layer);

  if Assigned(FOnAfterMouseMove) then
    FOnAfterMouseMove(Sender, Shift, X, Y, Layer);
end;

procedure TigTool.DoMouseUp(Sender: TigPaintBox; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; Layer: TigCustomLayer);
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

procedure TigTool.MouseDown(Sender: TigPaintBox; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; Layer: TigCustomLayer);
begin
  //descendant may do something
end;

procedure TigTool.MouseMove(Sender: TigPaintBox; Shift: TShiftState; X,
  Y: Integer; Layer: TigCustomLayer);
begin
  //descendant may do something
end;

procedure TigTool.MouseUp(Sender: TigPaintBox; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer; Layer: TigCustomLayer);
begin
  //descendant may do something
end;

function TigIntegrator.ActivateTool(ATool: TigToolClass): Boolean;
var
  LTool : TigTool;
begin
  Result := Self.ReadyToSwitchTool; //ask wether current active tool is not working in progress.

  if Result then
  begin
    LTool := GIntegrator.LoadTool(ATool);
    Assert(Assigned(LTool)); //error should be a programatic wrong logic.

    result := Self.IsToolSwitched(LTool); //ask the new tool to be active
  end;
end;

function TigIntegrator.IsToolSwitched(ATool: TigTool): Boolean;
begin
  //todo: ask the new tool wether all requirement is available 
  Result := True;
  FActiveTool := ATool;
  {begin
    ///dont use FLastTool := atool  <--- we need integrated properly
    //SetLastTool(ATool); //Explicit Update Integrator's Events
    // a line above may also be replaced by using property: LastTool := ATool;
  end;}
  
end;

{ TigPaintBox }

procedure TigPaintBox.AfterLayerCombined(ASender: TObject;
  const ARect: TRect);
begin
  Bitmap.FillRectS(ARect, $00FFFFFF);  // must be transparent white
  Bitmap.Draw(ARect, ARect, FLayerList.CombineResult);
  Bitmap.Changed(ARect);
end;

constructor TigPaintBox.Create(AOwner: TComponent);
var
  LLayer : TigCustomLayer;
begin
  inherited;
  Options := [pboAutoFocus];
  TabStop := True;
  //FAgent := TigAgent.Create(self); //autodestroy. //maybe better to use integrator directly.
  FLayerList := TigLayerList.Create; //TPersistent is not autodestroy
  FLayerList.OnLayerCombined := AfterLayerCombined;

  if not (csDesigning in self.ComponentState) then
  begin
    // set background size before create background layer
    Bitmap.SetSize(300,300);
    Bitmap.Clear($00000000);

    // create background layer
    LLayer :=  TigNormalLayer.Create(FLayerList,
      Bitmap.Width, Bitmap.Height, clWhite32, True);

    FLayerList.Add(LLayer);
  end;  
end;

destructor TigPaintBox.Destroy;
begin
  FLayerList.Free;
  inherited;
end;

procedure TigPaintBox.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  GIntegrator.DoMouseDown(Self, Button, Shift, X, Y, FLayerList.SelectedLayer);
end;

procedure TigPaintBox.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  GIntegrator.DoMouseMove(Self, Shift, X, Y, FLayerList.SelectedLayer);
end;

procedure TigPaintBox.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  GIntegrator.DoMouseUp(Self, Button, Shift, X, Y, FLayerList.SelectedLayer);
end;

initialization
  GIntegrator := TigIntegrator.Create(Application);

end.
