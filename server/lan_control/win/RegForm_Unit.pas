unit RegForm_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  DataRec_Unit, Dialogs, StdCtrls;

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
    procedure appsLoad();
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
   appsLoad();
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
var
   res: TDataRec;
begin
   if (RegForm.ComboBox1.Text = '') then
   begin
      MessageDlg('Описание должно быть содержательным.', mtWarning, [mbOk], 0);
      exit;
   end;
   if (ComboBox1.ItemIndex = -1) then
   begin
      res := MainForm.metaQuery('registration', ComboBox1.Text);
      try
         saveProp('ID', res.val(0, 0));
      finally
         res.Free;
      end;
   end
   else
   begin
      saveProp('ID', fIDs[ComboBox1.ItemIndex]);
      MainForm.SocketMetaConnect(nil, nil);
   end;
   //Application.Terminate
end;

procedure TRegForm.appsLoad;
var
   res: TDataRec;
   k: integer;
begin
   RegForm.ComboBox1.Items.Clear;
   res := MainForm.metaQuery('apps list', '');
   try
      SetLength(RegForm.fIDs, res.Count);
      for k := 0 to res.Count - 1 do
      begin
         RegForm.ComboBox1.Items.Add(res.val(k, 1));
         RegForm.fIDs[k] := res.val(k, 0);
      end;
   finally
      res.Free;
   end;
end;

end.
