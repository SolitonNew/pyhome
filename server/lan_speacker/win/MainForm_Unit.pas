unit MainForm_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CoolTrayIcon, ScktComp;

type
  TMainForm = class(TForm)
    ClientSocket1: TClientSocket;
    CoolTrayIcon1: TCoolTrayIcon;
    procedure CoolTrayIcon1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.CoolTrayIcon1Click(Sender: TObject);
begin
   if (MainForm.Visible) then
      CoolTrayIcon1.HideMainForm
   else
      CoolTrayIcon1.ShowMainForm;
end;

end.
