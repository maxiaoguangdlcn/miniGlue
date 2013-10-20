program PaintBrushDemo;

uses
  Forms,
  MainForm in 'MainForm.pas' {frmMain},
  igTool_CustomBrush in '..\..\lib\igTool_CustomBrush.pas',
  igTool_PaintBrush in '..\..\lib\igTool_PaintBrush.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
