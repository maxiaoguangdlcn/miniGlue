unit igGraphicsLayerIO;

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
 * The Original Code is gmFileFormatList.pas
 * This unit is based on the Original Code
 *
 * The Initial Developer of the Original Code is
 *   x2nie < x2nie[at]yahoo[dot]com >
 *
 * The Initial Developer of this unit are
 *   Ma Xiaoguang and Ma Xiaoming < gmbros[at]hotmail[dot]com >
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
 * For using this unit, please always add it into the project,
 * not just reference it by Search Path settings. Adding unit to
 * project will make the code in Initialization/Finalization part
 * of the unit be invoked.
 *
 * And also notice that, the unit igGraphics.pas and igLayerIO.pas
 * should both be added to a project before this unit.
 *
 *   igGraphics.pas
 *   --------------
 *     The Graphics Layer Reader opens a graphics file with the
 *   registered Graphics Loaders in igGraphics.pas for building
 *   a layer panel.
 *
 *   igLayerIO.pas
 *   -------------
 *     We register this Graphics Layer Reader to a global list
 *   in igLayerIO.pas. 
 *
 * ***** END NOTIC BLOCK *****)

uses
{ Delphi }
  SysUtils, Classes,
{ miniGlue lib }
  igGraphics,
  igLayers,
  igLayerIO;

type
  { TigGraphicsLayerReader }
   
  TigGraphicsLayerReader = class(TigLayerReader)
  public
    class function IsValidFormat(AStream: TStream): Boolean; override;
    class function GetFileExtensions: string; override;
    class function GetFileFilters: string; override;

    procedure LoadFromStream(AStream: TStream; ALayerPanelList: TigLayerPanelList); override;
  end;

implementation

uses
{ Graphics32 }
  GR32;
  

{ TigGraphicsLayerReader }

class function TigGraphicsLayerReader.IsValidFormat(AStream: TStream): Boolean;
begin
  Result := Assigned(igGraphics.gGraphicsReaders) and
            igGraphics.gGraphicsReaders.IsValidFormat(AStream);
end;

class function TigGraphicsLayerReader.GetFileExtensions: string;
var
  i          : Integer;
  LExtStr    : string;
  LReaderReg : TigGraphicsReaderRegistration;
begin
  // NOTICE
  // The format of extension string is:
  // *.bmp;*.jpg

  LExtStr := '';

  if Assigned(igGraphics.gGraphicsReaders) and
     (igGraphics.gGraphicsReaders.Count > 0) then
  begin
    for i := 0 to (igGraphics.gGraphicsReaders.Count - 1) do
    begin
      LReaderReg := igGraphics.gGraphicsReaders.ReaderReg[i];

      if Assigned(LReaderReg) then
      begin
        if i > 0 then
        begin
          LExtStr := LExtStr + ';';
        end;

        LExtStr := LExtStr + '*.' + AnsiLowerCase(LReaderReg.Extension);
      end;
    end;
  end;

  Result := LExtStr;
end;

class function TigGraphicsLayerReader.GetFileFilters: string;
var
  i          : Integer;
  LExtStr    : string;
  LFilterStr : string;
  LReaderReg : TigGraphicsReaderRegistration;
begin
  // NOTICE
  // The format of filter string is:
  // BMP|*.bmp|JPG|*.jpg

  LFilterStr := '';

  if Assigned(igGraphics.gGraphicsReaders) and
     (igGraphics.gGraphicsReaders.Count > 0) then
  begin
    for i := 0 to (igGraphics.gGraphicsReaders.Count - 1) do
    begin
      LReaderReg := igGraphics.gGraphicsReaders.ReaderReg[i];

      if Assigned(LReaderReg) then
      begin
        if i > 0 then
        begin
          LFilterStr := LFilterStr + '|';
        end;

        LExtStr    := '*.' + AnsiLowerCase(LReaderReg.Extension);
        LFilterStr := LFilterStr + Format('%s|%s', [LReaderReg.Description, LExtStr]);
      end;
    end;
  end;

  Result := LFilterStr;
end;

procedure TigGraphicsLayerReader.LoadFromStream(AStream: TStream;
  ALayerPanelList: TigLayerPanelList);
var
  LBmp        : TBitmap32;
  LLayerPanel : TigNormalLayerPanel;
begin
  if Assigned(AStream) and Assigned(igGraphics.gGraphicsReaders) then
  begin
    LBmp := igGraphics.gGraphicsReaders.LoadFromStream(AStream);

    if Assigned(LBmp) then
    begin
      if LBmp.DrawMode <> dmBlend then
      begin
        LBmp.DrawMode := dmBlend;
      end;

      if LBmp.CombineMode <> cmMerge then
      begin
        LBmp.CombineMode := cmMerge;
      end;

      LLayerPanel := TigNormalLayerPanel.Create(ALayerPanelList,
        LBmp.Width, LBmp.Height, $00000000, ALayerPanelList.Count = 0);

      LLayerPanel.LayerBitmap.Assign(LBmp);
      LLayerPanel.UpdateLayerThumbnail;

      // The SimpleAdd() will simply add a panel to a layer panel list,
      // but won't calling any other functions, such as functions for
      // blending layers, callbacks, etc.
      ALayerPanelList.SimpleAdd(LLayerPanel);
    end;
  end;
end;


initialization
  igLayerIO.RegisterLayerReader(TigGraphicsLayerReader);


end.
