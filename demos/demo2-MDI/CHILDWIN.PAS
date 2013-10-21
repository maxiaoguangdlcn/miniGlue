unit CHILDWIN;

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls, GR32_Image,
  igBase;

type
  TMDIChild = class(TForm)
    img1: TigPaintBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TMDIChild.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TMDIChild.FormActivate(Sender: TObject);
begin
  img1.SetFocus(); //I dont know how to delete this line :(
end;

end.
