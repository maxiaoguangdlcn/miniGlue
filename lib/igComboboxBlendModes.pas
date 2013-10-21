unit igComboboxBlendModes;

interface

uses
  SysUtils, Classes, Controls, StdCtrls,
  igBase;

type
  TigComboBoxBlendMode = class(TComboBox)
  private
    FAgent: TigAgent;
    { Private declarations }
  protected
    { Protected declarations }
    procedure Change; override;
    property Agent: TigAgent read FAgent; //read only. for internal access
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  published
    { Published declarations }
  end;


implementation

uses
  GR32_Add_BlendModes;


{ TigComboBoxBlendMode }

procedure TigComboBoxBlendMode.Change;
var TempNotifyEvent : TNotifyEvent;
begin
  //we need OnChange triggered at the last chance.
  TempNotifyEvent := OnChange;
  try
    OnChange := nil;
    inherited; //without OnChange triggered
    if GIntegrator.ActivePaintBox <> nil then
      GIntegrator.ActivePaintBox.LayerList.SelectedPanel.LayerBlendMode := TBlendMode32(ItemIndex);

    if Assigned(TempNotifyEvent) then
      TempNotifyEvent(Self);
  finally
    OnChange := TempNotifyEvent;
  end;


end;

constructor TigComboBoxBlendMode.Create(AOwner: TComponent);
begin
  inherited;
  FAgent := TigAgent.Create(Self); //autodestroy
  GetBlendModeList(Self.Items); //fill items
  ItemIndex := 0;

end;

end.
