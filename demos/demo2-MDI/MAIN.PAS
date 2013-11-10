unit MAIN;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, ComCtrls, StdActns,
  ActnList, ToolWin, ImgList, GR32_Image, igLayerPanelManager,
  igLayersListBox, GR32_RangeBars;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    FileCloseItem: TMenuItem;
    Window1: TMenuItem;
    Help1: TMenuItem;
    N1: TMenuItem;
    FileExitItem: TMenuItem;
    WindowCascadeItem: TMenuItem;
    WindowTileItem: TMenuItem;
    WindowArrangeItem: TMenuItem;
    HelpAboutItem: TMenuItem;
    OpenDialog: TOpenDialog;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    Edit1: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    WindowMinimizeItem: TMenuItem;
    StatusBar: TStatusBar;
    ActionList1: TActionList;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    FileNew1: TAction;
    FileSave1: TAction;
    FileExit1: TAction;
    FileOpen1: TAction;
    FileSaveAs1: TAction;
    WindowCascade1: TWindowCascade;
    WindowTileHorizontal1: TWindowTileHorizontal;
    WindowArrangeAll1: TWindowArrange;
    WindowMinimizeAll1: TWindowMinimizeAll;
    HelpAbout1: TAction;
    FileClose1: TWindowClose;
    WindowTileVertical1: TWindowTileVertical;
    WindowTileItem2: TMenuItem;
    ToolBar2: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton9: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ImageList1: TImageList;
    pnlLayer: TPanel;
    tlbrLayers: TToolBar;
    tlbnSeparator1: TToolButton;
    tlbtnNewFillAdjustmentLayer: TToolButton;
    tlbrAddMask: TToolButton;
    btnLayer_New: TToolButton;
    btnLayer_Delete: TToolButton;
    lyrs1: TigLayersListBox;
    actTool_Brush: TAction;
    actTool_Pencil: TAction;
    ToolButton13: TToolButton;
    btnTool_Brush: TToolButton;
    btnTool_Pencil: TToolButton;
    actLayer_New: TAction;
    actLayer_Delete: TAction;
    tlbrBlendModes: TToolBar;
    tlbnSeparator2: TToolButton;
    cmbbxBlendModes: TComboBox;
    tlbrLayerOpacity: TToolBar;
    ToolButton12: TToolButton;
    ggbrLayerOpacity: TGaugeBar;
    edtLayerOpacity: TEdit;
    lblLayerOpacity: TLabel;
    procedure FileNew1Execute(Sender: TObject);
    procedure FileOpen1Execute(Sender: TObject);
    procedure HelpAbout1Execute(Sender: TObject);
    procedure FileExit1Execute(Sender: TObject);
    procedure btnLayer_NewClick(Sender: TObject);
    procedure actTool_BrushExecute(Sender: TObject);
    procedure actTool_PencilExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EnabledWhenMDIavailabled(Sender: TObject);
    procedure actLayer_DeleteExecute(Sender: TObject);
    procedure lyrs1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    procedure CreateMDIChild(const Name: string);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses CHILDWIN, about,
  GR32_Add_BlendModes,
  igBase, igComboboxBlendModes, igLayers,
  igTool_BrushSimple,
  igTool_PencilSimple;

procedure TMainForm.CreateMDIChild(const Name: string);
var
  Child: TMDIChild;
begin
  { create a new MDI child window }
  Child := TMDIChild.Create(Application);
  Child.Caption := Name;
  //if FileExists(Name) then Child.Memo1.Lines.LoadFromFile(Name);
end;

procedure TMainForm.FileNew1Execute(Sender: TObject);
begin
  CreateMDIChild('NONAME' + IntToStr(MDIChildCount + 1));
end;

procedure TMainForm.FileOpen1Execute(Sender: TObject);
begin
  if OpenDialog.Execute then
    CreateMDIChild(OpenDialog.FileName);
end;

procedure TMainForm.HelpAbout1Execute(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TMainForm.FileExit1Execute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.btnLayer_NewClick(Sender: TObject);
var
  LLayerPanel : TigCustomLayerPanel;
  LPanelIndex : Integer;
begin
  if not Assigned(GIntegrator.ActivePaintBox) then
    Exit;
    
  Screen.Cursor := crHourGlass;
  try
    //with gActiveChildForm do
    begin
      Randomize;

      //LLayerPanel := CreateNormalLayer( $FF000000 or Cardinal(Random($FFFFFF)), False );
      LLayerPanel := TigNormalLayerPanel.Create(lyrs1.PanelList,
        300,300,
        $FF000000 or Cardinal(Random($FFFFFF)));

      LPanelIndex := lyrs1.PanelList.SelectedIndex + 1;

      lyrs1.PanelList.Insert(LPanelIndex, LLayerPanel);
    end;
  finally
    Screen.Cursor := crDefault;
  end;

end;

procedure TMainForm.actTool_BrushExecute(Sender: TObject);
begin
  //set a drawing tool for mouse operation's response.
  actTool_Brush.Checked := GIntegrator.ActivateTool(TigToolBrushSimple);
end;

procedure TMainForm.actTool_PencilExecute(Sender: TObject);
begin
  actTool_Pencil.Checked := GIntegrator.ActivateTool(TigToolPencilSimple);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  //actTool_Pencil.Execute(); failed
  GetBlendModeList(cmbbxBlendModes.Items);
  self.actTool_PencilExecute(self);
end;

procedure TMainForm.EnabledWhenMDIavailabled(Sender: TObject);
begin
  TAction(Sender).Enabled := MDIChildCount > 0;
end;

procedure TMainForm.actLayer_DeleteExecute(Sender: TObject);
begin
//
end;

procedure TMainForm.lyrs1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  // TODO: we have to refresh the layers list box on each mouse up,
  // if not, after we switched to an unselected layer with mouse click,
  // the layers list box will not showing the changes up.
  // Should we do the refreshing at here?
  lyrs1.Invalidate;
end;

end.
