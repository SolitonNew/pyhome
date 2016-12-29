unit MainForm_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CoolTrayIcon, ScktComp, StdCtrls, Speacker, ExtCtrls, ToolWin,
  ComCtrls, Buttons, ImgList, Registry;

type
   TItemListItem = class
      id:integer;
      name:string;
      comm:string;
      typ:integer;
      value: Double;
   end;

  TMainForm = class(TForm)
    SocketSound: TClientSocket;
    CoolTrayIcon1: TCoolTrayIcon;
    Timer1: TTimer;
    Panel1: TPanel;
    Panel2: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    ListBox1: TListBox;
    SocketMeta: TClientSocket;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    ImageList1: TImageList;
    Panel4: TPanel;
    SpeedButton10: TSpeedButton;
    Panel3: TPanel;
    Shape1: TShape;
    procedure CoolTrayIcon1Click(Sender: TObject);
    procedure SocketSoundRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure SocketMetaConnecting(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure SocketMetaDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure SocketMetaError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure SocketMetaRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SocketMetaConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure Panel3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel3MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Panel3MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SpeedButton10Click(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    fSpeaker: TSpeakerThread;

    fItemList: TList;
    procedure itemListClear;
    
    procedure loadItemList();
    procedure setStatusText(text:String);
    procedure refreshItemList();
    function currView:integer;
    procedure sendVarValue(id:integer; val:Double);
    procedure setVolume();

    function loadProp(name:string):string;
    procedure saveProp(name, value:string);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses StrUtils;

{$R *.dfm}

procedure TMainForm.CoolTrayIcon1Click(Sender: TObject);
begin
   if (MainForm.Visible) then
      CoolTrayIcon1.HideMainForm
   else
      CoolTrayIcon1.ShowMainForm;
end;

procedure TMainForm.SocketSoundRead(Sender: TObject;
  Socket: TCustomWinSocket);
var
   b: TBuff;
   i: integer;
begin
   Socket.SendText('ping');
   i := Socket.ReceiveBuf(b, SizeOf(TBuff));
   fSpeaker.Play(@b, i);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
   try
      Left := StrToInt(loadProp('Left'));
   except
      Left := (Screen.Width - Width) div 2;
   end;

   try
      Top := StrToInt(loadProp('Top'));
   except
      Top := (Screen.Height - Height) div 2;
   end;

   try
      Width := StrToInt(loadProp('Width'));
   except
   end;

   try
      Height := StrToInt(loadProp('Height'));
   except
   end;

   try
      Shape1.Width := (Panel3.Width - 2) * StrToInt(loadProp('Volume')) div 100;
   except
   end;

   setStatusText('START');
   fItemList := TList.Create;
   fSpeaker:= TSpeakerThread.Create(0);
   setVolume();
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
   saveProp('Left', IntToStr(Left));
   saveProp('Top', IntToStr(Top));
   saveProp('Width', IntToStr(Width));
   saveProp('Height', IntToStr(Height));
   saveProp('Volume', IntToStr(fSpeaker.fVolume));

   fSpeaker.Free;
   itemListClear;
   fItemList.Free;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
   if Timer1.Tag = 0 then
   begin
      //CoolTrayIcon1.HideMainForm;
      Timer1.Tag := 1;
   end;

   if (not SocketMeta.Active) then
   begin
      SocketMeta.Close;
      SocketMeta.Open;
   end;

   if (not SocketSound.Active) then
   begin
      SocketSound.Close;
      SocketSound.Open;   
   end;
end;

procedure TMainForm.setStatusText(text: String);
begin
   if (text = 'ERROR') then
   begin
      Panel1.Font.Color := clRed;
   end
   else
   begin
      Panel1.Font.Color := clBlack;
   end;
   Panel1.Caption := ' ' + text;
end;

procedure TMainForm.SocketMetaConnecting(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   setStatusText('CONNECTING');
end;

procedure TMainForm.SocketMetaDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   setStatusText('DISCONNECT');
   SocketMeta.Close;
end;

procedure TMainForm.SocketMetaError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   ErrorCode := 0;
   setStatusText('ERROR');
   SocketMeta.Close;
end;

var
   SocketMetaBufer: string;

procedure TMainForm.SocketMetaRead(Sender: TObject; Socket: TCustomWinSocket);
type
   TDataRec = array of array of string;

   function parceTable(data:string; cols:integer):TDataRec;
   var
      F:integer;
      i: integer;
   begin
      F := cols - 1;
      repeat
         i := Pos(chr(1), data);
         if (i > 0) then
         begin
            inc(F);
            if F > cols - 1 then
            begin
               SetLength(Result, Length(Result) + 1);
               SetLength(Result[Length(Result) - 1], F);
               F := 0;
            end;
            Result[Length(Result) - 1][F] := copy(data, 1, i - 1);
            Delete(data, 1, i);
         end;
      until i < 1;
   end;

   procedure packProcessed(data:string);
   var
      pack_type:string;
      o:TItemListItem;
      res: TDataRec;
      k, i: integer;
   begin
      pack_type := copy(data, 1, 4);
      if (pack_type = 'load') then
      begin
         itemListClear;

         res := parceTable(copy(data, 5, Length(data)), 5);
         for k := 0 to Length(res) - 1 do
         begin
            o:= TItemListItem.Create;
            o.id := StrToInt(res[k][0]);
            o.name := res[k][1];
            o.comm := res[k][2];
            o.typ := StrToInt(res[k][3]);
            if (res[k][4] = 'None') then
               res[k][4] := '-9999';
            o.value := StrToFloat(StringReplace(res[k][4], '.', ',', [rfReplaceAll]));
            fItemList.Add(o);
         end;
         refreshItemList();
      end
      else
      if (pack_type = 'synk') then
      begin
         res := parceTable(copy(data, 5, Length(data)), 2);
         for k := 0 to Length(res) - 1 do
         begin
            for i:= 0 to fItemList.Count - 1 do
            begin
               if (TItemListItem(fItemList[i]).id = StrToInt(res[k][0])) then
               begin
                  if (res[k][1] = 'None') then
                     res[k][1] := '-9999';
                  TItemListItem(fItemList[i]).value := StrToFloat(StringReplace(res[k][1], '.', ',', [rfReplaceAll]));
               end;
            end;
         end;
         refreshItemList();
      end
      else
      if (pack_type = 'play') then
      begin
         //
      end
      else
      if (pack_type = 'stop') then
      begin
         //
      end;
   end;

var
   k: integer;
begin
   SocketMetaBufer := SocketMetaBufer + Socket.ReceiveText();
   for k:= 1 to Length(SocketMetaBufer) do
   begin
      if (SocketMetaBufer[k] = chr(2)) then
      begin
         packProcessed(Copy(SocketMetaBufer, 1, k));
         delete(SocketMetaBufer, 1, k);
      end;
   end;
end;

procedure TMainForm.loadItemList;
begin
   SocketMeta.Socket.SendText('load' + chr(2));
end;

procedure TMainForm.refreshItemList;
const
   lb_types: array[1..7] of string = ('ÑÂÅÒ.', '', 'ÐÎÇ.', 'ÒÅÐÌ.', 'Ò-ÑÒÀÒ.', 'ÊÀÌ.', 'ÂÅÍÒ.');
var
   k, t, i: integer;
   lb: string;
   o:TItemListItem;
begin
   t := currView();

   ListBox1.Items.BeginUpdate;
   i := 0;
   for k:= 0 to fItemList.Count - 1 do
   begin
      o := TItemListItem(fItemList[k]);
      lb := o.comm + ' [' + FloatToStr(o.value) + ']';

      if (o.typ = t) then
      begin
         if (i < ListBox1.Items.Count) then
         begin
            ListBox1.Items[i] := lb;
            ListBox1.Items.Objects[i] := o;
         end
         else
            ListBox1.AddItem(lb, o);
         inc(i);
      end;
   end;
   for k:= ListBox1.Items.Count - 1 downto i do
      ListBox1.Items.Delete(k);

   ListBox1.Items.EndUpdate;
end;

procedure TMainForm.SpeedButton1Click(Sender: TObject);
begin
   refreshItemList();
end;

procedure TMainForm.SpeedButton2Click(Sender: TObject);
begin
   refreshItemList();
end;

procedure TMainForm.SocketMetaConnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   setStatusText('CONNECT');
   loadItemList();
end;

function TMainForm.currView: integer;
var
   k: integer;
begin
   Result := -1;
   for k:= 0 to Panel2.ControlCount - 1 do
   begin
      if (TSpeedButton(Panel2.Controls[k]).Down) then
      begin
         Result := TSpeedButton(Panel2.Controls[k]).Tag;
         break;
      end;
   end;
end;

procedure TMainForm.sendVarValue(id: integer; val: Double);
begin
   SocketMeta.Socket.SendText('setvar;' + IntToStr(id) + ';' + StringReplace(floatToStr(val), ',', '.', [rfReplaceAll]) + chr(2));
end;

procedure TMainForm.itemListClear;
var
   k: integer;
begin
   for k:= 0 to fItemList.Count - 1 do
   begin
      TObject(fItemList[k]).Free;
      fItemList[k] := nil;
   end;
   fItemList.Clear;
end;

procedure TMainForm.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
   o: TItemListItem;
   bmp:TBitmap;
   v: string;
begin
   o := TItemListItem(ListBox1.Items.Objects[index]);

   with ListBox1.Canvas do
   begin
      if (odSelected in State) then
      begin
         Brush.Color := $00aaaaaa;
      end
      else
      begin
         Brush.Color := clWhite;
      end;
      Pen.Color := Brush.Color;
      Rectangle(Rect);

      Font.Size := 8;
      Font.Style := [];
      TextOut(Rect.Left + 5, Rect.Top + 5, o.comm);

      case o.typ of
         1, 3:
         begin
            bmp:= TBitmap.Create;
            try
               bmp.Transparent := True;
               bmp.Width := 26;
               bmp.Height := 12;
               if (o.value = 0) then
                  ImageList1.Draw(bmp.Canvas, 0, 0, 0)
               else
                  ImageList1.Draw(bmp.Canvas, 0, -13, 0);
               Draw(Rect.Right - 5 - 26, Rect.Top + 5, bmp);
            finally
               bmp.Free;
            end;
         end;

         4, 5:
         begin
            if (o.value <> -9999) then
            begin
               Font.Style := [fsBold];
               Font.Size := 11;
               v := FloatToStr(o.value) + '°C';
               TextOut(Rect.Right - 5 - TextWidth(v), Rect.Top + 3, v);
            end;
         end;

         7:
         begin
            bmp:= TBitmap.Create;
            try
               bmp.Transparent := True;
               bmp.Width := 30;
               bmp.Height := 9;
               ImageList1.Draw(bmp.Canvas, 0, -round(8 * (o.value / 2)), 1);
               Draw(Rect.Right - 5 - 29, Rect.Top + 6, bmp);
            finally
               bmp.Free;
            end;
         end;
      end;
   end;
end;

procedure TMainForm.ListBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   i: integer;
   o: TItemListItem;
   r: TRect;
   v: Double;
begin
   i := ListBox1.ItemAtPos(Point(X, Y), True);
   if (i > -1) then
   begin
      r := ListBox1.ItemRect(i);
      o := TItemListItem(ListBox1.Items.Objects[i]);
      case o.typ of
         1, 3:
         begin
            if ((x > r.Right - 26 - 5) and (x < r.Right - 5)) then
            begin
               if (o.value > 0) then
                  sendVarValue(o.id, 0)
               else
                  sendVarValue(o.id, 1);
            end;
         end;

         7:
         begin
            if ((x > r.Right - 40 - 5) and (x < r.Right - 1)) then
            begin
               v := (x - (r.Right - 29 - 5) + 6) div 6 * 2;
               if (v < 0) then v := 0;
               if (v > 10) then v := 10;
               sendVarValue(o.id, v);
            end;
         end;
      end;
   end;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
   ListBox1.Repaint;
end;

procedure TMainForm.Panel3MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if (Sender = Shape1) then
      inc(x, 2);

   if (ssLeft in Shift) then
   begin
      Shape1.Width := x;
      setVolume;
   end;
end;

procedure TMainForm.Panel3MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   if (Sender = Shape1) then
      inc(x, 2);

   if (ssLeft in Shift) then
   begin
      Shape1.Width := x;
      setVolume;
   end;
end;

procedure TMainForm.Panel3MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if (Sender = Shape1) then
      inc(x, 2);

   if (ssLeft in Shift) then
   begin
      Shape1.Width := x;
      setVolume;
   end;
end;

procedure TMainForm.setVolume;
var
   v: integer;
begin
   if (Shape1.Width > Panel3.Width - 4) then
      Shape1.Width := Panel3.Width - 4;

   v := round(Shape1.Width * 100 / Panel3.Width - 2);
   if (v < 1) then v := 1;
   if (v > 100) then v := 100;
   fSpeaker.fVolume := v;
end;

procedure TMainForm.SpeedButton10Click(Sender: TObject);
begin
   fSpeaker.fMute := not SpeedButton10.Down;
end;

function TMainForm.loadProp(name: string): string;
var
   Registry: TRegistry;
begin
   Result := '';
   Registry:= TRegistry.Create(KEY_ALL_ACCESS);
   try
      Registry.RootKey:= HKEY_LOCAL_MACHINE;
      Registry.OpenKey('SOFTWARE\WhiseHouse\APP\Propertys', True);
      Result := Registry.ReadString(name);
   finally
      Registry.Free;
   end;
end;

procedure TMainForm.saveProp(name, value: string);
var
   Registry: TRegistry;
begin
   Registry:= TRegistry.Create(KEY_ALL_ACCESS);
   try
      Registry.RootKey:= HKEY_LOCAL_MACHINE;
      Registry.OpenKey('SOFTWARE\WhiseHouse\APP\Propertys', True);
      Registry.WriteString(name, value);
   finally
      Registry.Free;
   end;
end;

procedure TMainForm.ListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
   o: TItemListItem;
   v: integer;
begin
   // 39 - Right
   // 37 - Left

   if (ListBox1.ItemIndex > -1) then
   begin
      o := TItemListItem(ListBox1.Items.Objects[ListBox1.ItemIndex]);
      case o.typ of
         1, 3:
         begin
            if ((Key = 32) or (Key = 37) or (Key = 39)) then
            begin
               v := trunc(o.value);
               if (Key = 37) then
                  dec(v);
               if (Key = 39) then
                  inc(v);
               if (v < 0) then
                  v := 0;
               if (v > 1) then
                  v := 1;
               sendVarValue(o.id, v);
            end;
         end;
         4:
         begin
         end;
         5:
         begin
            v := trunc(o.value);
            if (Key = 37) then
               dec(v);
            if (Key = 39) then
               inc(v);
            if (v < 10) then
               v := 10;
            if (v > 40) then
               v := 40;
            sendVarValue(o.id, v);
         end;

         7:
         begin
            v := trunc(o.value);
            if (Key = 37) then
               dec(v, 2);
            if (Key = 39) then
               inc(v, 2);
            if (v < 0) then
               v := 0;
            if (v > 10) then
               v := 10;
            sendVarValue(o.id, v);
         end;
      end;
   end;

   if ((Key = 32) or (Key = 37) or (Key = 39)) then Key := 0;
end;

end.
