unit igReg;

interface
uses
  Classes;

procedure Register;

implementation
uses
  igBase;

procedure Register();
begin
  registerComponents('miniGlue',[TigPaintBox]);
end;

end.
