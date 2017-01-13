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
    procedure Button2Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
  end;

var
  TerminalForm: TTerminalForm;

procedure addTextToTerminal(text: string);

implementation

uses MainForm_Unit;

{$R *.dfm}

procedure addTextToTerminal(text: string);
begin
   if (TerminalForm <> nil) then
      TerminalForm.Memo1.Lines.Add(text);
end;

procedure TTerminalForm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
{   if (Key = chr(13)) then
   begin
      Button1Click(nil);
   end;}
end;

procedure TTerminalForm.Button2Click(Sender: TObject);
begin
   Memo1.Clear;
end;

procedure TTerminalForm.FormDestroy(Sender: TObject);
begin
   TerminalForm := nil;
end;

end.
