program miniGlue;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

  //note for delphi, when error add uses: {$ifdef FPC}Interfaces,{$endif}
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
  igPng in '..\lib\igPng.pas',
  igBmp in '..\lib\igBmp.pas',
  igLayerIO in '..\lib\igLayerIO.pas',
  igGraphicsLayerIO in '..\lib\igGraphicsLayerIO.pas',
  igBase in '..\lib\igBase.pas',
  LayerBrightContrastForm in 'LayerBrightContrastForm.pas' {frmLayerBrightContrast},
  igBrightContrastLayer in '..\lib\igBrightContrastLayer.pas';

begin
  Application.Initialize;
  Application.CreateForm(TdmMain, dmMain);
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmLayers, frmLayers);
  Application.CreateForm(TfrmLayerBrightContrast, frmLayerBrightContrast);
  Application.Run;
end.
