unit SchedDialog_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DlgMessagesRU, StdCtrls, Buttons, MainForm_Unit;

type
  TSchedDialog = class(TForm)
    Memo1: TMemo;
    Memo2: TMemo;
    ComboBox1: TComboBox;
    Memo3: TMemo;
    Memo4: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    SpeedButton1: TSpeedButton;
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    fTempVariableID: integer;
    function showDialog(item: TSchedListItem): boolean;
    procedure fastInsert(comm, action: string; date: TDateTime; variable: integer);
  end;

var
  SchedDialog: TSchedDialog;

implementation

{$R *.dfm}

{ TSchedDialog }

function TSchedDialog.showDialog(item: TSchedListItem): boolean;
begin
   if (item <> nil) then
   begin
      Tag := item.id;
      Memo1.Text := item.comm;
      Memo2.Text := item.action;
      ComboBox1.ItemIndex := item.typ;
      Memo3.Text := item.timeOfDay;
      Memo4.Text := item.dayOfType;
      fTempVariableID := item.variable;
   end
   else
   begin
      Tag := -1;
      Memo1.Text := '';
      Memo2.Text := '';
      ComboBox1.ItemIndex := 0;
      Memo3.Text := '';
      Memo4.Text := '';
      fTempVariableID := 0;
   end;
   ComboBox1Change(nil);
   Result := (ShowModal = mrOk);
end;

procedure TSchedDialog.Button2Click(Sender: TObject);
var
   s: string;
begin
   if (Memo3.Text = '') then
   begin
      MessageDlg('Поле "Время дня" должно быть указано обязательно.', mtWarning, [mbOk], 0);
      exit;
   end;

   if ((Label5.Caption <> '') and (Memo4.Text = '')) then
   begin
      MessageDlg('Поле "' + Copy(Label5.Caption, 1, Length(Label5.Caption) - 1) + '" должно быть заполнено.', mtWarning, [mbOk], 0);
      exit;
   end;

   s := IntToStr(Tag) + chr(1);
   s := s + Memo1.Text + chr(1);
   s := s + Memo2.Text + chr(1);
   s := s + IntToSTr(ComboBox1.ItemIndex) + chr(1);
   s := s + Memo3.Text + chr(1);
   s := s + Memo4.Text + chr(1);
   s := s + IntToStr(fTempVariableID);
   MainForm.metaQuery('edit scheduler', s);
   if (Visible) then
      ModalResult := mrOk;
end;

procedure TSchedDialog.Button1Click(Sender: TObject);
begin
   if (MessageDlg('Удалить запись из расписания?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
   begin
      MainForm.metaQuery('del scheduler', IntToStr(Tag));
      if (Visible) then
         ModalResult := mrCancel;
      MainForm.schedLoad;
   end;
end;

procedure TSchedDialog.SpeedButton1Click(Sender: TObject);
begin
   if (MessageDlg('Выполнить немедленно действие из расписания?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
   begin
      MainForm.metaQuery('execute', Memo2.Text);
   end;
end;

procedure TSchedDialog.ComboBox1Change(Sender: TObject);
begin
   case ComboBox1.ItemIndex of
      0: Label5.Caption := '';
      1: Label5.Caption := 'Дни недели:';
      2: Label5.Caption := 'Дни месяца';
      3, 4: Label5.Caption := 'Дни года:';
   end;

   Memo4.Visible := Label5.Caption <> '';

   if ((ComboBox1.ItemIndex = 4) and (Tag = -1)) then
   begin
      MessageDlg('Одноразовые задания доступны только из меню переменных', mtWarning, [mbOk], 0);
      ComboBox1.ItemIndex := 3;
   end;
end;

procedure TSchedDialog.fastInsert(comm, action: string; date: TDateTime; variable: integer);
begin
   Tag := -1;
   Memo1.Text := comm;
   Memo2.Text := action;
   ComboBox1.ItemIndex := 4;
   Memo3.Text := FormatDateTime('hh:nn', date);
   Memo4.Text := FormatDateTime('dd-mm', date);
   fTempVariableID := variable;
   Button2Click(nil);
end;

end.
