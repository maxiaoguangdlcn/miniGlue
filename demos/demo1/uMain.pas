unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, igBase, StdCtrls, GR32_Image;

type
  TForm1 = class(TForm)
    imgWorkArea: TigPaintBox;
    Memo1: TMemo;
    lbl1: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation
uses
  igTool_BrushSimple;
{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  //set a drawing tool for mouse operation's response.
  GIntegrator.ActivateTool(TigToolBrushSimple);
end;

end.
