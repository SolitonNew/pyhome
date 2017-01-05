unit TerminalForm_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ScktComp;

type
  TTerminalForm = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure addText(text: string);
  end;

var
  TerminalForm: TTerminalForm;

implementation

uses MainForm_Unit;

{$R *.dfm}

procedure TTerminalForm.addText(text: string);
begin
   Memo1.Lines.Add(text);
end;

procedure TTerminalForm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
   if (Key = chr(13)) then
   begin
      Button1Click(nil);
   end;
end;

procedure TTerminalForm.Button1Click(Sender: TObject);
begin
   MainForm.VlcCommand(Edit1.Text);
end;

procedure TTerminalForm.Button2Click(Sender: TObject);
begin
   Memo1.Clear;
end;

end.
