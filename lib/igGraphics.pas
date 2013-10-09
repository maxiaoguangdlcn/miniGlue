unit igGraphics;

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
{ Graphics32 }
  GR32;

type
  { Forward Declarations }
  
  TigGraphicsReader = class;
  TigGraphicsReaderClass = class of TigGraphicsReader;

  { TigGraphicsReaderRegistration }

  TigGraphicsReaderRegistration = class(TObject)
  private
    FReaderClass : TigGraphicsReaderClass;
    FExtension   : string;
    FDescription : string;
  public
    property ReaderClass : TigGraphicsReaderClass read FReaderClass write FReaderClass;
    property Extension   : string                 read FExtension   write FExtension;
    property Description : string                 read FDescription write FDescription;
  end;

  { TigGraphcisReader }
  
  TigGraphicsReader = class(TObject)
  public
    class function IsValidFormat(AStream: TStream): Boolean; virtual; abstract;
    function LoadFromFile(const AFileName: TFileName): TBitmap32; virtual;
    function LoadFromStream(AStream: TStream): TBitmap32; virtual; abstract;
  end;

  { TigGraphicsReaders }

  TigGraphicsReaders = class(TObject)
  private
    FReaderRegistrations : TObjectList;
    FAllSupportedFiles   : string;

    procedure AppendFileFilter(var AFilter: string; const ADesc, AExt: string);

    function IsValidIndex(const AIndex: Integer): Boolean;
    function GetReaderCount: Integer;
    function GetReaderRegistration(AIndex: Integer): TigGraphicsReaderRegistration;
    function GetGraphicsFileFilter: string;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Add(const AExt, ADesc: string; AClass: TigGraphicsReaderClass);

    function LoadFromFile(const AFileName: TFileName): TBitmap32;
    function LoadFromStream(AStream: TStream): TBitmap32;
    function IsValidFormat(AStream: TStream): Boolean;

    property Count                     : Integer                       read GetReaderCount;
    property ReaderReg[index: Integer] : TigGraphicsReaderRegistration read GetReaderRegistration;
    property Filter                    : string                        read GetGraphicsFileFilter;
  end;

var
  // May contains registered graphics file readers, such BMP reader,
  // JPEG reader, PNG reader, etc. 
  gGraphicsReaders : TigGraphicsReaders;


// called by other unit for registering variety of graphics file readers
procedure RegisterGraphicsFileReader(const AExtension, ADescription: string;
  AReaderClass: TigGraphicsReaderClass);



implementation


// called by other unit for registering variety of graphics file readers
procedure RegisterGraphicsFileReader(const AExtension, ADescription: string;
  AReaderClass: TigGraphicsReaderClass);
begin
  if Assigned(gGraphicsReaders) then
  begin
    gGraphicsReaders.Add(AExtension, ADescription, AReaderClass);
  end;
end;

{ TigGraphcisReader }

function TigGraphicsReader.LoadFromFile(const AFileName: TFileName): TBitmap32;
var
  LStream : TStream;
begin
  Result := nil;

  if not FileExists(AFileName) then
  begin
    Exit;
  end;

  LStream := TFileStream.Create(AFileName, fmOpenRead	or fmShareDenyNone);
  try
    Result := Self.LoadFromStream(LStream);
  finally
    LStream.Free;
  end;
end;

{ TigGraphicsReaders }

constructor TigGraphicsReaders.Create;
begin
  inherited;

  FAllSupportedFiles   := 'All Formats';
  FReaderRegistrations := TObjectList.Create;
end;

destructor TigGraphicsReaders.Destroy;
begin
  FReaderRegistrations.Clear;
  FReaderRegistrations.Free;

  inherited;
end;

procedure TigGraphicsReaders.AppendFileFilter(var AFilter: string;
  const ADesc, AExt: string);
var
  LStrIndex    : Integer;
  LStrLength   : Integer;
  LStr1, LStr2 : string;
  LFilter      : string;
begin
  if AFilter = '' then
  begin
    LFilter := Format('%s|*.%2:s|%1:s|*.%2:s',
      [FAllSupportedFiles, ADesc, AExt]);
  end
  else
  begin
    LStrLength := Length(AFilter);
    LFilter    := '';

    // Copy the characters from first to the one at the position of
    // the first '|' in string AFilter to LFilter.
    LStrIndex := Pos('|', AFilter);
    LStr1     := Copy(AFilter, 1, LStrIndex);
    LFilter   := LStr1;

    // Save all the characters that after the position of the
    // first '|' in string AFilter with LStr2.
    LStr2 := Copy(AFilter, LStrIndex + 1, LStrLength);

    // Find the first '|' in LStr2 and appending the characters
    // that before the position of the '|' character to LFilter.
    LStrIndex := Pos('|', LStr2);
    LFilter   := LFilter + Copy(LStr2, 1, LStrIndex - 1);

    // Save the remaining characters that after the string LFilter in
    // string AFilter to LStr1
    LStr1 := Copy( AFilter, Length(LFilter) + 1, LStrLength );

    // Adding new file filter.
    LFilter := Format('%s;*.%s', [LFilter, AExt]);
    LFilter := LFilter + LStr1;
    LFilter := Format('%s|%s|*.%s', [LFilter, ADesc, AExt]);
  end;

  AFilter := LFilter;
end;

function TigGraphicsReaders.IsValidIndex(const AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex < FReaderRegistrations.Count);
end;

function TigGraphicsReaders.GetReaderCount: Integer;
begin
  Result := FReaderRegistrations.Count;
end;

function TigGraphicsReaders.GetReaderRegistration(
  AIndex: Integer): TigGraphicsReaderRegistration;
begin
  Result := nil;

  if IsValidIndex(AIndex) then
  begin
    Result := TigGraphicsReaderRegistration(FReaderRegistrations.Items[AIndex]);
  end;
end;

function TigGraphicsReaders.GetGraphicsFileFilter: string;
var
  i          : Integer;
  LReaderReg : TigGraphicsReaderRegistration;
  LExts      : TStringList;
begin
  Result := '';

  if FReaderRegistrations.Count > 0 then
  begin
    LExts := TStringList.Create;
    try
      for i := 0 to (Count - 1) do
      begin
        LReaderReg := TigGraphicsReaderRegistration(FReaderRegistrations.Items[i]);

        with LReaderReg do
        begin
          if Extension <> '' then
          begin
            // If the file extension is not in the list, then add it
            // to the list.
            if LExts.IndexOf(Extension) < 0 then
            begin
              AppendFileFilter(Result, Description, Extension);

              // This line of code is used for preventing from adding
              // duplicated file extensions. 
              LExts.Add(Extension);
            end;
          end;
        end;
      end;

    finally
      LExts.Free;
    end;
  end;
end;

procedure TigGraphicsReaders.Add(const AExt, ADesc: string;
  AClass: TigGraphicsReaderClass);
var
  LReaderReg : TigGraphicsReaderRegistration;
begin
  LReaderReg := TigGraphicsReaderRegistration.Create;

  with LReaderReg do
  begin
    ReaderClass := AClass;
    Extension   := AnsiLowerCase(AExt);
    Description := ADesc;
  end;

  FReaderRegistrations.Add(LReaderReg);
end;

function TigGraphicsReaders.LoadFromFile(const AFileName: TFileName): TBitmap32;
var
  LStream : TStream;
begin
  Result := nil;

  if not FileExists(AFileName) then
  begin
    Exit;
  end;

  LStream := TFileStream.Create(AFileName, fmOpenRead	or fmShareDenyNone);
  try
    Result := Self.LoadFromStream(LStream);
  finally
    LStream.Free;
  end;
end;

function TigGraphicsReaders.LoadFromStream(AStream: TStream): TBitmap32;
var
  i          : Integer;
  LReaderReg : TigGraphicsReaderRegistration;
  LReader    : TigGraphicsReader;
begin
  Result := nil;

  if (not Assigned(AStream)) or (AStream.Size = 0) then
  begin
    Exit;
  end;

  if FReaderRegistrations.Count > 0 then
  begin
    for i := 0 to (FReaderRegistrations.Count - 1) do
    begin
      AStream.Position := 0;
      LReaderReg       := TigGraphicsReaderRegistration(FReaderRegistrations.Items[i]);

      if LReaderReg.ReaderClass.IsValidFormat(AStream) then
      begin
        AStream.Position := 0;
        LReader          := LReaderReg.ReaderClass.Create;
        Result           := LReader.LoadFromStream(AStream);

        with Result do
        begin
          DrawMode    := dmBlend;
          CombineMode := cmMerge;
        end;

        Break;
      end;
    end;
  end;
end;

function TigGraphicsReaders.IsValidFormat(AStream: TStream): Boolean;
var
  LDataPos   : Int64;
  i          : Integer;
  LReaderReg : TigGraphicsReaderRegistration;
begin
  Result := False;

  if Assigned(AStream) and (FReaderRegistrations.Count > 0) then
  begin
    LDataPos := AStream.Position;

    for i := 0 to (FReaderRegistrations.Count - 1) do
    begin
      LReaderReg := TigGraphicsReaderRegistration(FReaderRegistrations.Items[i]);

      if LReaderReg.ReaderClass.IsValidFormat(AStream) then
      begin
        Result := True;
        Break;
      end;

      AStream.Position := LDataPos;
    end;

    AStream.Position := LDataPos;
  end;
end;


//****************************************************************************//

procedure UnitInit;
begin
  if not Assigned(gGraphicsReaders) then
  begin
    gGraphicsReaders := TigGraphicsReaders.Create;
  end;
end;

procedure UnitDestroy;
begin
  gGraphicsReaders.Free;
end;


initialization
  UnitInit;

finalization
  UnitDestroy;


end.
