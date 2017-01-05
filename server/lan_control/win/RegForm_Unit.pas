unit RegForm_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TRegForm = class(TForm)
    ComboBox1: TComboBox;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    fIDs:array of string;
  end;

var
  RegForm: TRegForm;

implementation

uses MainForm_Unit, PropertysForm_Unit;

{$R *.dfm}

procedure TRegForm.FormActivate(Sender: TObject);
begin
   MainForm.SocketMeta.Socket.SendText('apps' + chr(2));
end;

procedure TRegForm.Button2Click(Sender: TObject);
begin
   Application.Terminate
end;

procedure TRegForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   Application.Terminate;
end;

procedure TRegForm.Button1Click(Sender: TObject);
begin
   if (RegForm.ComboBox1.Text = '') then
   begin
      MessageDlg('Описание должно быть содержательным.', mtWarning, [mbOk], 0);
      exit;
   end;
   if (ComboBox1.ItemIndex = -1) then
      MainForm.SocketMeta.Socket.SendText('regi' + chr(1) + ComboBox1.Text + chr(2))
   else
   begin
      saveProp('ID', fIDs[ComboBox1.ItemIndex]);
      MainForm.SocketMetaConnect(nil, nil);
   end;
   //Application.Terminate
end;

end.
