unit MediaInfoDialog_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst;

type
  TMediaInfoDialog = class(TForm)
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Edit1: TEdit;
    Label3: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MediaInfoDialog: TMediaInfoDialog;

implementation

uses MainForm_Unit;

{$R *.dfm}

procedure TMediaInfoDialog.Button1Click(Sender: TObject);
begin
   MainForm.metaQuery('edit media file', IntToStr(Tag) + chr(1) + Edit1.Text);
   ModalResult := mrOk;
end;

end.
