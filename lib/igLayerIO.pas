unit igLayerIO;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

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

(* ***** BEGIN NOTICE BLOCK *****
 *
 * For using this unit, please always add it into the project,
 * not just reference it by Search Path settings. Adding unit to
 * project will make the code in Initialization/Finalization part
 * of the unit be invoked. Please check out the code at the end
 * of this unit for details.
 *
 * ***** END NOTIC BLOCK *****)

uses
{ Delphi }
  SysUtils, Classes, Contnrs,
{ miniGlue lib }
  igLayers;

type
  { Forward Declarations }
  
  TigLayerReader = class;
  TigLayerReaderClass = class of TigLayerReader;

  
  { TigLayerReaderRegistration }

  TigLayerReaderRegistration = class(TObject)
  protected
    FReaderClass  : TigLayerReaderClass;
    FExtensionStr : string;   // for example: '*.bmp;*.jpg'
    FFilterStr    : string;   // for example: 'Bitmap|*.bmp|JPEG|*.jpg';
  public
    property ReaderClass  : TigLayerReaderClass read FReaderClass  write FReaderClass;
    property ExtensionStr : string              read FExtensionStr write FExtensionStr;
    property FilterStr    : string              read FFilterStr    write FFilterStr;
  end;

  { TigLayerReader }
   
  TigLayerReader = class(TObject)
  public
    class function IsValidFormat(AStream: TStream): Boolean; virtual; abstract;
    class function GetFileExtensions: string; virtual; abstract;
    class function GetFileFilters: string; virtual; abstract;

    procedure LoadFromFile(const AFileName: TFileName; ALayerPanelList: TigLayerPanelList); virtual;
    procedure LoadFromStream(AStream: TStream; ALayerPanelList: TigLayerPanelList); virtual; abstract;
  end;

  { TigLayerReaders }

  TigLayerReaders = class(TObject)
  private
    FReaderRegistrations : TObjectList;
    FAllSupportedFiles   : string;

    function IsValidIndex(const AIndex: Integer): Boolean;
    function GetReaderCount: Integer;
    function GetFileFilter: string;
    function GetReaderReg(AIndex: Integer): TigLayerReaderRegistration;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(AClass: TigLayerReaderClass);
    procedure LoadFromFile(const AFileName: TFileName; ALayerPanelList: TigLayerPanelList);
    procedure LoadFromStream(AStream: TStream; ALayerPanelList: TigLayerPanelList);

    property Count                     : Integer                    read GetReaderCount;
    property ReaderReg[index: Integer] : TigLayerReaderRegistration read GetReaderReg;
    property Filter                    : string read GetFileFilter;
  end;


var
  // May contains registered layer readers, such PSD layer reader,
  // Graphics layer reader for load in JPEG, PNG, etc. 
  gLayerReaders : TigLayerReaders;


// called by other unit for registering variety of layer readers
procedure RegisterLayerReader(AReaderClass: TigLayerReaderClass);
  

implementation


// called by other unit for registering variety of layer readers
procedure RegisterLayerReader(AReaderClass: TigLayerReaderClass);
begin
  if Assigned(gLayerReaders) then
  begin
    gLayerReaders.Add(AReaderClass);
  end;
end;

{ TigLayerReader }

procedure TigLayerReader.LoadFromFile(const AFileName: TFileName;
  ALayerPanelList: TigLayerPanelList);
var
  LStream : TStream;
begin
  //x2nie if FileExistsUTF8(AFileName) { *Converted from FileExists*  } and Assigned(ALayerPanelList) then
  if FileExists(AFileName) { *Converted from FileExists*  } and Assigned(ALayerPanelList) then
  begin
    LStream := TFileStream.Create(AFileName, fmOpenRead	or fmShareDenyNone);
    try
      Self.LoadFromStream(LStream, ALayerPanelList);
    finally
      LStream.Free;
    end;
  end;
end;


{ TigLayerReaders }

constructor TigLayerReaders.Create;
begin
  inherited;

  FAllSupportedFiles   := 'All Formats';
  FReaderRegistrations := TObjectList.Create;
end;

destructor TigLayerReaders.Destroy;
begin
  FReaderRegistrations.Clear;
  FReaderRegistrations.Free;

  inherited;
end;

function TigLayerReaders.IsValidIndex(const AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex < FReaderRegistrations.Count);
end;

function TigLayerReaders.GetReaderCount: Integer;
begin
  Result := FReaderRegistrations.Count;
end;

function TigLayerReaders.GetFileFilter: string;
var
  i          : Integer;
  LExtStr    : string;
  LFilterStr : string;
  LReaderReg : TigLayerReaderRegistration;
begin
  Result := '';

  if FReaderRegistrations.Count > 0 then
  begin
    LExtStr    := '';
    LFilterStr := '';
    
    for i := 0 to (FReaderRegistrations.Count - 1) do
    begin
      LReaderReg := Self.ReaderReg[i];

      // LExtStr should be be something like this:
      // *.bmp;*.jpg
      LExtStr := LExtStr + LReaderReg.ExtensionStr;

      // LFilterStr should be be something like this:
      // BMP|*.bmp|JPEG|*.jpg
      LFilterStr := LFilterStr + LReaderReg.FilterStr;
    end;

    // The result should be something like this:
    // All Formats|*.bmp;*.jpg|BMP|*.bmp|JPEG|*.jpg
    Result := Format('%s|%s|%s', [FAllSupportedFiles, LExtStr, LFilterStr]);
  end;
end;

function TigLayerReaders.GetReaderReg(
  AIndex: Integer): TigLayerReaderRegistration;
begin
  Result := nil;

  if Self.IsValidIndex(AIndex) then
  begin
    Result := TigLayerReaderRegistration(FReaderRegistrations.Items[AIndex]);
  end;
end;

procedure TigLayerReaders.Add(AClass: TigLayerReaderClass);
var
  LReaderReg : TigLayerReaderRegistration;
begin
  LReaderReg := TigLayerReaderRegistration.Create;

  with LReaderReg do
  begin
    ReaderClass   := AClass;
    FExtensionStr := ReaderClass.GetFileExtensions();
    FFilterStr    := ReaderClass.GetFileFilters();
  end;

  FReaderRegistrations.Add(LReaderReg);
end;

procedure TigLayerReaders.LoadFromFile(const AFileName: TFileName;
  ALayerPanelList: TigLayerPanelList);
var
  LStream : TStream;
begin
  //x2nie if not FileExistsUTF8(AFileName) { *Converted from FileExists*  } then
  if not FileExists(AFileName) { *Converted from FileExists*  } then
  begin
    Exit;
  end;

  LStream := TFileStream.Create(AFileName, fmOpenRead	or fmShareDenyNone);
  try
    Self.LoadFromStream(LStream, ALayerPanelList);
  finally
    LStream.Free;
  end;
end;

procedure TigLayerReaders.LoadFromStream(AStream: TStream;
  ALayerPanelList: TigLayerPanelList);
var
  i          : Integer;
  LReaderReg : TigLayerReaderRegistration;
  LReader    : TigLayerReader;
begin
  if (not Assigned(AStream)) or (AStream.Size = 0) then
  begin
    Exit;
  end;

  if FReaderRegistrations.Count > 0 then
  begin
    for i := 0 to (FReaderRegistrations.Count - 1) do
    begin
      AStream.Position := 0;
      LReaderReg       := TigLayerReaderRegistration(FReaderRegistrations.Items[i]);

      if LReaderReg.ReaderClass.IsValidFormat(AStream) then
      begin
        AStream.Position := 0;
        LReader          := LReaderReg.ReaderClass.Create;

        LReader.LoadFromStream(AStream, ALayerPanelList);

        Break;
      end;
    end;
  end;
end;


//****************************************************************************//

procedure UnitInit;
begin
  if not Assigned(gLayerReaders) then
  begin
    gLayerReaders := TigLayerReaders.Create;
  end;
end;

procedure UnitDestroy;
begin
  gLayerReaders.Free;
end;


initialization
  UnitInit;

finalization
  UnitDestroy;


end.
