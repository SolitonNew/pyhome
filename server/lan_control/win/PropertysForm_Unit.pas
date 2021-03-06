unit PropertysForm_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  DataRec_Unit, Dialogs, DlgMessagesRU, ExtCtrls, ComCtrls, StdCtrls, Registry, FileCtrl, Buttons;

type
  TPropertysForm = class(TForm)
    PageControl1: TPageControl;
    TabSheet2: TTabSheet;
    GroupBox1: TGroupBox;
    ListBox1: TListBox;
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    TabSheet3: TTabSheet;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Edit2: TEdit;
    SpeedButton2: TSpeedButton;
    Edit3: TEdit;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    TabSheet4: TTabSheet;
    ListBox2: TListBox;
    Label1: TLabel;
    SpeedButton7: TSpeedButton;
    CheckBox1: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  private
    fScanList:TList;
    fAddCount, fDelCount: integer;
    procedure saveMediaListToBd;
    procedure scanListClear;
    procedure compareMediaLists;    
  public
    procedure scanMediaLib;
    procedure updateStatistics();
  end;

var
   PropertysForm: TPropertysForm;
   MediaExts: string;

procedure addToMetaLog(s: string);
function loadProp(name:string; def: string = ''):string;
procedure saveProp(name, value:string);

implementation

uses MainForm_Unit;

{$R *.dfm}

function loadProp(name: string; def: string = ''): string;
var
   Registry: TRegistry;
begin
   Result := '';
   Registry:= TRegistry.Create(KEY_ALL_ACCESS);
   try
      Registry.RootKey:= HKEY_CURRENT_USER;
      Registry.OpenKey('SOFTWARE\WiseHouse\APP\Propertys', True);
      Result := Registry.ReadString(name);
   finally
      Registry.Free;
   end;

   if (Result = '') then Result := def;
end;

procedure saveProp(name, value: string);
var
   Registry: TRegistry;
begin
   Registry:= TRegistry.Create(KEY_ALL_ACCESS);
   try
      Registry.RootKey:= HKEY_CURRENT_USER;
      Registry.OpenKey('SOFTWARE\WiseHouse\APP\Propertys', True);
      Registry.WriteString(name, value);
   finally
      Registry.Free;
   end;
end;

procedure addToMetaLog(s: string);
begin
   if (PropertysForm <> nil) then
   begin
      s := '[' + TimeToStr(Now()) + '] ' + s;
      PropertysForm.ListBox2.Items.Insert(0, s);
   end;
end;

{ TPropertysForm }

procedure TPropertysForm.Button1Click(Sender: TObject);
begin
   Hide;
end;

procedure TPropertysForm.saveMediaListToBd;
begin
   MainForm.metaQuery('set media folders', StringReplace(ListBox1.Items.Text, '\', '\\', [rfReplaceAll]));
end;

procedure TPropertysForm.scanMediaLib;
var
   exts:TStringList;

   procedure FindChild(S: string);
   var
      SR: TSearchRec;
      T: string;
      o: TMediaListItem;
   begin
      if (FindFirst(S + '*.*', faAnyFile, SR) = 0) then
      begin
         repeat
            T:= S + SR.Name;
            if DirectoryExists(T) then
            begin
               if (SR.Name <> '.') and (SR.Name <> '..') then
               begin
                  FindChild(T + '\');
               end;
            end
            else
            if FileExists(T) then
            begin
               if (exts.IndexOf(UpperCase(ExtractFileExt(T))) > -1) then
               begin
                  o:= TMediaListItem.Create;
                  o.file_name := T;
                  fScanList.Add(o);
               end;
            end;
         until (FindNext(SR) <> 0);
      end;
      FindClose(SR);
   end;

var
   k: integer;
   s: string;
begin
   scanListClear;
   exts := TStringList.Create;
   try
      exts.Delimiter := ';';
      exts.DelimitedText := MediaExts;
      for k:= 0 to exts.Count - 1 do
         exts[k] := '.' + exts[k];

      for k:= 0 to ListBox1.Count - 1 do
      begin
         s := ListBox1.Items[k];
         if (s[Length(s)] <> '\') then
            s := s + '\';
         FindChild(s);
      end;
   finally
      exts.Free;
   end;
   compareMediaLists;
end;

procedure TPropertysForm.compareMediaLists;
var
   k1, k2: integer;
   o1, o2: TMediaListItem;
   s_add, s_del: string;
begin
   fAddCount := 0;
   fDelCount := 0;

   // ��������� �����
   s_del := '';
   for k1:= 0 to MainForm.fMediaList.Count - 1 do
   begin
      o1 := TMediaListItem(MainForm.fMediaList[k1]);
      if (o1.app_id = MainForm.fAppID) then
      begin
         for k2 := 0 to fScanList.Count - 1 do
         begin
            o2 := TMediaListItem(fScanList[k2]);
            if (o2.file_name = o1.file_name) then
            begin
               o1 := nil;
               break;
            end;
         end;
         if (o1 <> nil) then
         begin
            //del
            s_del := s_del + IntToStr(o1.id) + ',';
            inc(fDelCount);
         end;
      end;
      Application.ProcessMessages();
   end;
   s_del := s_del + '0';

   // ���������� �����
   s_add := '';
   for k1:= 0 to fScanList.Count - 1 do
   begin
      o1 := TMediaListItem(fScanList[k1]);
      for k2 := 0 to MainForm.fMediaList.Count - 1 do
      begin
         o2 := TMediaListItem(MainForm.fMediaList[k2]);
         if ((o2.app_id = MainForm.fAppID) and (o2.file_name = o1.file_name)) then
         begin
            o1 := nil;
            break;
         end;
      end;
      if (o1 <> nil) then
      begin
         //add
         //s_add := s_add + StringReplace(o1.file_name, '\', '\\', [rfReplaceAll]) + chr(1);
         s_add := s_add + o1.file_name + chr(1);
         inc(fAddCount);
      end;
      Application.ProcessMessages();
   end;

   MainForm.metaQuery('del media files', s_del).Free;
   MainForm.metaQuery('add media files', s_add).Free;
end;

procedure TPropertysForm.FormCreate(Sender: TObject);
begin
   fScanList := TList.Create;
end;

procedure TPropertysForm.FormDestroy(Sender: TObject);
begin
   scanListClear;
   fScanList.Free;
end;

procedure TPropertysForm.scanListClear;
var
   k: integer;
begin
   for k:= 0 to fScanList.Count - 1 do
   begin
      TObject(fScanList[k]).Free;
      fScanList[k] := nil;
   end;
   fScanList.Clear;
end;

procedure TPropertysForm.FormShow(Sender: TObject);
var
   k: integer;
begin
   CheckBox1.Checked := MainForm.fPlayOnlyVLC;

   PageControl1.ActivePageIndex := 0;
   for k:= 0 to MainForm.fSessions.Count - 1 do
   begin
      if (MainForm.fSessions.val(k, 0) = IntToStr(MainForm.fAppID)) then
      begin
         Edit2.Text := MainForm.fSessions.val(k, 1);
         break;
      end;
   end;

   Edit3.Text := loadProp('IP');
   updateStatistics();
end;

procedure TPropertysForm.SpeedButton4Click(Sender: TObject);
var
   tmpDir: string;
begin
   tmpDir := '';
   if SelectDirectory('����� ����� �����', '', tmpDir) then
   begin
      if (ListBox1.Items.IndexOf(tmpDir) = -1) then
      begin
         ListBox1.Items.Add(tmpDir);
         saveMediaListToBd;
      end;
   end;
end;

procedure TPropertysForm.SpeedButton5Click(Sender: TObject);
begin
   if (ListBox1.ItemIndex > -1) then
   begin
      ListBox1.DeleteSelected;
      saveMediaListToBd;
   end;
end;

procedure TPropertysForm.SpeedButton6Click(Sender: TObject);
var
   s: string;
begin
   scanMediaLib;

   s := '������������ ��������.' + chr(13);
   s := s + chr(13);
   s := s + '����� ������� ������: ' + IntToStr(fScanList.Count) + chr(13);
   s := s + '��������� � ����������: ' + IntToStr(fAddCount) + chr(13);
   s := s + '������� �� ����������: ' + IntToStr(fDelCount) + chr(13);

   updateStatistics();

   MessageDlg(s, mtInformation, [mbOk], 0);
end;

procedure TPropertysForm.SpeedButton3Click(Sender: TObject);
begin
   saveProp('IP', Edit3.Text);
   saveProp('ID', '');

   MessageDlg('��������� ������� � ���� ������ ����� ����������� ����������.', mtWarning, [mbOk], 0);
end;

procedure TPropertysForm.SpeedButton2Click(Sender: TObject);
begin
   MainForm.metaQuery('name', Edit2.Text);
end;

procedure TPropertysForm.updateStatistics;
var
   k, n: integer;
begin
   n := 0;
   for k:= 0 to MainForm.fMediaList.Count - 1 do
   begin
      if (TMediaListItem(MainForm.fMediaList[k]).app_id = MainForm.fAppID) then
         inc(n);
   end;
   Label1.Caption := '����� � ���������� ' + IntToStr(MainForm.fMediaList.Count) + ' �������.' + chr(13) + '�� ��� � ����� ������� ' + IntToStr(n) + '.';
end;

procedure TPropertysForm.SpeedButton7Click(Sender: TObject);
begin
   ListBox2.Clear;
end;

procedure TPropertysForm.CheckBox1Click(Sender: TObject);
begin
   MainForm.fPlayOnlyVLC := CheckBox1.Checked;
end;

end.
