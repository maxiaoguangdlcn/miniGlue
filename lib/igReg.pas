unit igReg;

interface
uses
  Classes;

procedure Register;

implementation
uses
  igBase, igLayersListBox, igComboboxBlendModes;

procedure Register();
begin
  registerComponents('miniGlue',[TigPaintBox, TigLayersListBox, TigComboBoxBlendMode]);
end;

end.
