program miniGlue;

uses
  Forms,
  MainForm in 'MainForm.pas' {frmMain},
  MainDataModule in 'MainDataModule.pas' {dmMain: TDataModule},
  ChildForm in 'ChildForm.pas' {frmChild},
  igPaintFuncs in '..\lib\igPaintFuncs.pas',
  NewFileForm in 'NewFileForm.pas' {frmNewFile},
  LayerForm in 'LayerForm.pas' {frmLayers},
  igLayers in '..\lib\igLayers.pas',
  igMath in '..\lib\igMath.pas',
  igLayerPanelManager in '..\lib\igLayerPanelManager.pas',
  igGraphics in '..\lib\igGraphics.pas',
  igPng in '..\lib\igPng.pas',
  igJpg in '..\lib\igJpg.pas',
  igBmp in '..\lib\igBmp.pas',
  igLayerIO in '..\lib\igLayerIO.pas',
  igGraphicsLayerIO in '..\lib\igGraphicsLayerIO.pas',
  igBrightContrastLayer in '..\lib\igBrightContrastLayer.pas',
  LayerBrightContrastForm in 'LayerBrightContrastForm.pas' {frmLayerBrightContrast},
  igCustomBrush in '..\lib\igCustomBrush.pas',
  igPaintBrush in '..\lib\igPaintBrush.pas',
  igTool in '..\lib\igTool.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmLayers, frmLayers);
  Application.Run;
end.
