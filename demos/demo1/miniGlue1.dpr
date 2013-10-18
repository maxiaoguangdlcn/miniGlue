program miniGlue1;

uses
  Forms,
  uMain in 'uMain.pas' {Form1},
  igTool_BrushSimple in '..\..\lib\igTool_BrushSimple.pas',
  GR32_Add_BlendModes in '..\..\externals\Graphics32_add_ons\GR32_Add_BlendModes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
