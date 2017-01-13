unit MainForm_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DlgMessagesRU, CoolTrayIcon, ScktComp, StdCtrls, Speacker, ExtCtrls, ToolWin,
  ComCtrls, Buttons, ImgList, Menus, ShellApi, IdBaseComponent,
  IdComponent, IdTCPServer, IdCustomHTTPServer, IdHTTPServer,
  IdServerIOHandler, IdServerIOHandlerSocket, IdGlobal;

type
   TDataRec = array of array of string;

   TItemListItem = class
      id:integer;
      name:string;
      comm:string;
      typ:integer;
      value: Double;
   end;

   TMediaListItem = class
      id:integer;
      app_id:integer;
      title:string;
      file_name:string;
   end;

   TSoundSocket = class (TThread)
   private
      fSoundSocket: TClientSocket;
   protected
      fHost: string;
      fPort: integer;
      procedure Execute; override;
   public
      fSpeaker: TSpeakerThread;
      constructor Create(host:string; port:integer);
      destructor Destroy; override;
   end;

  TMainForm = class(TForm)
    CoolTrayIcon1: TCoolTrayIcon;
    Timer1: TTimer;
    Panel2: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SocketMeta: TClientSocket;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    SpeedButton9: TSpeedButton;
    Panel1: TPanel;
    Panel4: TPanel;
    SpeedButton10: TSpeedButton;
    VolumePanel: TPanel;
    VolumeShape: TShape;
    MediaPanel: TPanel;
    Panel5: TPanel;
    PlayButton: TSpeedButton;
    StopButton: TSpeedButton;
    Bevel1: TBevel;
    FilterEdit: TEdit;
    VarList: TListBox;
    MediaList: TListBox;
    InfoPanel: TPanel;
    InfoLabel: TLabel;
    Panel6: TPanel;
    ComboBox1: TComboBox;
    ImageList2: TImageList;
    PauseButton: TSpeedButton;
    IdHTTPServer1: TIdHTTPServer;
    IdServerIOHandlerSocket1: TIdServerIOHandlerSocket;
    TimePanel: TPanel;
    TimeShape: TShape;
    N4: TMenuItem;
    TimeLabel: TLabel;
    Panel3: TPanel;
    SpeedButton6: TSpeedButton;
    VlcVolPanel: TPanel;
    VlcVolShape: TShape;
    PlayLoopButton: TSpeedButton;
    N5: TMenuItem;
    N6: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure SocketMetaConnecting(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure SocketMetaDisconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure SocketMetaError(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SocketMetaConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure VarListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure VarListMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure VolumePanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure VolumePanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure VolumePanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SpeedButton10Click(Sender: TObject);
    procedure VarListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure N3Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure Panel5Resize(Sender: TObject);
    procedure InfoPanelResize(Sender: TObject);
    procedure FilterEditChange(Sender: TObject);
    procedure MediaListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure CoolTrayIcon1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel6Resize(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure IdHTTPServer1CommandGet(AThread: TIdPeerThread;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure N4Click(Sender: TObject);
    procedure TimePanelResize(Sender: TObject);
    procedure TimePanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TimePanelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TimePanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure VlcVolPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure VlcVolPanelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure VlcVolPanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SpeedButton6Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure StopButtonClick(Sender: TObject);
    procedure PauseButtonClick(Sender: TObject);
    procedure PlayButtonClick(Sender: TObject);
    procedure MediaListDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PlayLoopButtonClick(Sender: TObject);
    procedure MediaListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    fSoundSocket: TSoundSocket;
    fSocketMetaBufer: string;
    fTimePanelDown: Boolean;

    fSessionVlcState: integer;
    fSessionVlcID: integer;

    procedure itemListClear;
    procedure mediaListClear;
    procedure setStatusText(text:String);
    procedure refreshItemList();
    procedure refreshMediaList();
    function currView:integer;
    procedure sendVarValue(id:integer; val:Double);
    procedure setVolume();
    procedure setVlcVolume();
    function getMediaAtId(id: integer): TMediaListItem;
    procedure timeSeek;
    function checkAppatId(id: integer):Boolean;
    procedure transferMedia(Sender:TObject);
    procedure startVlcPlay(id: integer; withPause: boolean; seek: integer; blockWarning: boolean = false);
    procedure vlcOnChange(sender:TObject);
    procedure vlcOnPlayPosEvent(sender:TObject; pos, len: integer);
    procedure updateTimePanel();
    procedure updateVlcVolume();
    procedure playMediaNextItem();
    procedure playStopEvent(Sender: TObject);

    procedure startLoad();
    procedure syncLoad();
    procedure syncPack(res: TDataRec);
    procedure firstRun();
  public
    fAppID: integer;
    fItemList: TList;
    fMediaList: TList;
    fSessions:TDataRec;
    function metaQuery(pack_name, pack_data: string): TDataRec;
    
    procedure sendMediaState(state: string; id, time: integer);
    procedure playMediaPlayAt(index: integer; blockWarning: boolean = false);
  end;

var
  MainForm: TMainForm;

implementation

uses StrUtils, PropertysForm_Unit, Mcs_Unit, RegForm_Unit,
  TerminalForm_Unit, Types, Vlc_Unit;

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
var
   s: string;
   b: boolean;
begin
   //saveProp('ID', '');
   InfoPanel.Align := alClient;
   MediaPanel.Align := alClient;
   VarList.Align := alClient;

   ComboBox1.AddItem('Вся медия', nil);
   ComboBox1.AddItem('Только видео', nil);
   ComboBox1.AddItem('Только аудио', nil);
   ComboBox1.ItemIndex := 0;
   
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
      VolumeShape.Width := (VolumePanel.ClientWidth) * StrToInt(loadProp('Volume')) div 100;
   except
   end;

   PlayLoopButton.Down := (loadProp('VlcPlayLoop') = 'loop');

   fItemList := TList.Create;
   fMediaList := TList.Create;

   SocketMeta.Host := loadProp('IP');

   Timer1.Enabled := true;

   setStatusText('Запуск');

   updateTimePanel;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
   SocketMeta.Close;

   saveProp('Left', IntToStr(Left));
   saveProp('Top', IntToStr(Top));
   saveProp('Width', IntToStr(Width));
   saveProp('Height', IntToStr(Height));
   saveProp('Volume', IntToStr(fSoundSocket.fSpeaker.fVolume));
   if (not SpeedButton6.Down) then
      setVlcVolume();

   try
      fSoundSocket.Terminate;
      fSoundSocket.Free;
   except
   end;

   mediaListClear;
   fMediaList.Free;

   itemListClear;
   fItemList.Free;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
   if Timer1.Tag = 0 then
   begin
      Timer1.Enabled := false;
      CoolTrayIcon1.HideMainForm;
      firstRun();
      Timer1.Tag := 1;
      Timer1.Enabled := true;
   end;

   if (not SocketMeta.Active) then
   begin
      SocketMeta.Close;
      SocketMeta.Open;
   end
   else
      if not InfoPanel.Visible then
      begin
         syncLoad();
      end;
end;

procedure TMainForm.setStatusText(text: String);
begin
   InfoLabel.Caption := text;
   CoolTrayIcon1.Hint := 'lan control [' + text + ']';
   SpeedButton1Click(nil);
end;

procedure TMainForm.SocketMetaConnecting(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   setStatusText('Выполняется подключение к серверу...');
end;

procedure TMainForm.SocketMetaDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   if (RegForm.Visible) then
      Application.Terminate;
   setStatusText('Соединение с сервером утеряно');
   SocketMeta.Close;
end;

procedure TMainForm.SocketMetaError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   ErrorCode := 0;
   setStatusText('Ошибка подключения к серверу');
   SocketMeta.Close;
end;

procedure TMainForm.refreshItemList;
var
   k, t, i: integer;
   lb: string;
   o:TItemListItem;
begin
   t := currView();

   VarList.Items.BeginUpdate;
   i := 0;
   for k:= 0 to fItemList.Count - 1 do
   begin
      o := TItemListItem(fItemList[k]);
      lb := o.comm + ' [' + FloatToStr(o.value) + ']';

      if (o.typ = t) then
      begin
         if (i < VarList.Items.Count) then
         begin
            VarList.Items[i] := lb;
            VarList.Items.Objects[i] := o;
         end
         else
            VarList.AddItem(lb, o);
         inc(i);
      end;
   end;
   for k:= VarList.Items.Count - 1 downto i do
      VarList.Items.Delete(k);

   VarList.Items.EndUpdate;
end;

procedure TMainForm.SpeedButton1Click(Sender: TObject);
var
   t:integer;
   k: integer;
begin
   t := 0;
   case currView of
      100: t := 1;
   end;

   if (InfoLabel.Caption <> '') then
      t := -1;

   InfoPanel.Visible := t = -1;
   VarList.Visible := t = 0;
   Panel5.Visible := t = 1;

   case t of
      0:
      begin
         refreshItemList();
         if (MainForm.Visible) then
            VarList.SetFocus;
      end;
      1:
      begin
         if (MainForm.Visible) then
            MediaList.SetFocus;
      end;
   end;
end;

procedure TMainForm.SocketMetaConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
   try
      fAppID := StrToInt(loadProp('ID'));
   except
      fAppID := -1;
   end;
   if (fAppID = -1) then
   begin
      RegForm.Show;
      setStatusText('Запрос регистрации приложения');
   end
   else
   begin
      RegForm.Hide;
      startLoad;
   end;
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
var
   p: string;
begin
   p := IntToStr(id) + chr(1) + StringReplace(floatToStr(val), ',', '.', [rfReplaceAll]);
   syncPack(metaQuery('setvar', p));
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

procedure TMainForm.VarListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
   o: TItemListItem;
   itemBmp, bmp:TBitmap;
   v: string;
begin
   o := TItemListItem(VarList.Items.Objects[index]);

   itemBmp := TBitmap.Create;
   try
      itemBmp.Width := Rect.Right - Rect.Left;
      itemBmp.Height := Rect.Bottom - Rect.Top;
      with itemBmp.Canvas do
      begin
         if (odSelected in State) then
         begin
            Brush.Color := $00777777;
            Font.Color := clWhite;
         end
         else
         begin
            Brush.Color := clWhite;
            Font.Color := clBlack;
         end;
         Pen.Color := Brush.Color;
         Rectangle(0, 0, itemBmp.Width, itemBmp.Height);

         Font.Size := 8;
         Font.Style := [];
         TextOut(5, 5, o.comm);

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
                  Draw(itemBmp.Width - 5 - 26, 5, bmp);
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
                  if (o.typ = 4) then
                  begin
                     v := IntToStr(round(o.value * 10));
                     if (abs(o.value) >= 1) then
                        insert('.', v, Length(v))
                     else
                        insert('0.', v, Length(v));
                     v := v + '°C';
                  end
                  else
                     v := IntToStr(trunc(o.value)) + '°C';
                  if (o.typ = 5) then
                     v := '<' + v + '>';
                  TextOut(itemBmp.Width - 5 - TextWidth(v), 3, v);
               end;
            end;

            7:
            begin
               bmp:= TBitmap.Create;
               try
                  bmp.TransparentColor := clWhite;
                  bmp.Transparent := True;
                  bmp.Width := 30;
                  bmp.Height := 11;
                  ImageList1.Draw(bmp.Canvas, 0, -round(11 * (o.value / 2)), 1);
                  Draw(itemBmp.Width - 5 - 29, 6, bmp);
               finally
                  bmp.Free;
               end;
            end;
         end;
      end;

      VarList.Canvas.Draw(Rect.Left, Rect.Top, itemBmp);
   finally
      itemBmp.Free;
   end;
end;

procedure TMainForm.VarListMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   i: integer;
   o: TItemListItem;
   r: TRect;
   v: Double;
begin
   i := VarList.ItemAtPos(Point(X, Y), True);
   if (i > -1) then
   begin
      r := VarList.ItemRect(i);
      o := TItemListItem(VarList.Items.Objects[i]);
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
   VarList.Repaint;
   MediaList.Repaint;
end;

procedure TMainForm.VolumePanelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if (Sender = VolumeShape) then
      inc(x, 2);

   if (ssLeft in Shift) then
   begin
      VolumeShape.Width := x;
      setVolume;
   end;
end;

procedure TMainForm.VolumePanelMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   if (Sender = VolumeShape) then
      inc(x, 2);

   if (ssLeft in Shift) then
   begin
      VolumeShape.Width := x;
      setVolume;
   end;
end;

procedure TMainForm.VolumePanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if (Sender = VolumeShape) then
      inc(x, 2);

   if (ssLeft in Shift) then
   begin
      VolumeShape.Width := x;
      setVolume;
   end;
end;

procedure TMainForm.setVolume;
var
   v: integer;
begin
   if (VolumeShape.Width > VolumePanel.ClientWidth) then
      VolumeShape.Width := VolumePanel.ClientWidth;

   v := round(VolumeShape.Width * 100 / VolumePanel.ClientWidth);
   if (v < 1) then v := 1;
   if (v > 100) then v := 100;
   fSoundSocket.fSpeaker.fVolume := v;
end;

procedure TMainForm.SpeedButton10Click(Sender: TObject);
begin
   fSoundSocket.fSpeaker.fMute := not SpeedButton10.Down;
end;

procedure TMainForm.VarListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
   o: TItemListItem;
   v: integer;
begin
   // 39 - Right
   // 37 - Left

   if (VarList.ItemIndex > -1) then
   begin
      o := TItemListItem(VarList.Items.Objects[VarList.ItemIndex]);
      case o.typ of
         1, 3:
         begin
            if ((Key = 37) or (Key = 39)) then
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

   if ((Key = 37) or (Key = 39)) then Key := 0;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   CanClose := ((fAppID = -1) or (MessageDlg('Вы хотите выйти из програмы и потерять контроль над домом?', mtConfirmation, [mbYes, mbNo], 0) = mrYes));
end;

procedure TMainForm.N3Click(Sender: TObject);
begin
   Close;
end;

procedure TMainForm.N1Click(Sender: TObject);
begin
   PropertysForm.Show;
end;

procedure TMainForm.Panel5Resize(Sender: TObject);
begin
   FilterEdit.Width := Panel5.ClientWidth;
   TimePanel.Width := Panel5.ClientWidth - (TimePanel.Left * 2);
   Panel3.Left := Panel5.ClientWidth - Panel3.Width;
   updateTimePanel; 
end;

procedure TMainForm.mediaListClear;
var
   k: integer;
begin
   for k:= 0 to fMediaList.Count - 1 do
   begin
      TObject(fMediaList[k]).Free;
      fMediaList[k] := nil;
   end;
   fMediaList.Clear;
end;

procedure TMainForm.InfoPanelResize(Sender: TObject);
begin
   InfoLabel.Height := InfoPanel.Height div 2;
end;

procedure TMainForm.refreshMediaList;
var
   k: integer;
   om: TMediaListItem;
   sl:TStringList;
   c, i: integer;
begin
   i := 0;
   MediaList.Items.BeginUpdate;
   sl := TStringList.Create;
   try
      sl.Delimiter := ';';
      case ComboBox1.ItemIndex of
         0: sl.DelimitedText := extVideo + ';' + extAudio;
         1: sl.DelimitedText := extVideo;
         2: sl.DelimitedText := extAudio;
      end;
      MediaList.Items.Clear;
      for k:= 0 to fMediaList.Count - 1 do
      begin
         om := TMediaListItem(fMediaList[k]);

         if ((sl.IndexOf(ExtractFileExt(WideUpperCase(om.file_name))) > -1) and ((FilterEdit.Text = '') or (Pos(WideUpperCase(FilterEdit.Text), WideUpperCase(om.title)) > 0))) then
            MediaList.AddItem(om.title, om);
      end;
      MediaList.Sorted := true;
   finally
      sl.Free;
      MediaList.Items.EndUpdate;
   end;

   if (VlcForm.playFileName <> '') then
   begin
      for k := 0 to MediaList.Count - 1 do
      begin
         om := TMediaListItem(MediaList.Items.Objects[k]);
         if (om.id = VlcForm.playFileID) then
         begin
            i := k;
            break;
         end;
      end;

      c := MediaList.ClientHeight div MediaList.ItemHeight;
      if (i > c - 1) then
      begin
         i := i - c + 1;
         MediaList.TopIndex := i;
      end;
   end;
end;

procedure TMainForm.FilterEditChange(Sender: TObject);
begin
   refreshMediaList;
end;

procedure TMainForm.MediaListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);

   function trimText(canvas: TCanvas; w:integer; s: string):string;
   var
      w_points: integer;
      k: integer;
   begin
      Result := s;
      if (canvas.TextWidth(s) <= w) then exit;

      w_points := canvas.TextWidth('...');
      for k:= Length(s) downto 1 do
      begin
         if (canvas.TextWidth(Result) + w_points <= w) then
         begin
            Result := Result + '...';
            exit;
         end;
         delete(Result, k, 1);
      end;
   end;

   procedure drawIcon(canvas:TCanvas; x, y, index:integer; color_no_sel:integer = -1; color_sel:integer = -1);
   var
      icoInv: TBitmap;
      kx, ky: integer;
      c: integer;
   begin
      c := color_no_sel;
      if (odSelected in State) then
      begin
         c := $00feffff;
         if (color_sel > -1) then
            c := color_sel;
      end;

      icoInv := TBitmap.Create;
      try
         icoInv.Transparent := true;
         ImageList2.GetBitmap(index, icoInv);
         if (c > -1) then
         begin
            for ky:= 1 to icoInv.Height do
               for kx:= 1 to icoInv.Width do
                  if (icoInv.Canvas.Pixels[kx, ky] = 0) then
                     icoInv.Canvas.Pixels[kx, ky] := c;
         end;
         canvas.Draw(x, y, icoInv);
      finally
         icoInv.Free;
      end;
   end;

var
   om: TMediaListItem;
   itemBmp: TBitmap;
   k: integer;
   b: boolean;
   tl, tw: integer;
begin
   om := TMediaListItem(MediaList.Items.Objects[index]);

   itemBmp:= TBitmap.Create;
   try
      itemBmp.Width := Rect.Right - Rect.Left;
      itemBmp.Height := Rect.Bottom - Rect.Top;
      with itemBmp.Canvas do
      begin
         if (odSelected in State) then
         begin
            Brush.Color := $00777777;
            Font.Color := clWhite;
         end
         else
         begin
            Brush.Color := clWhite;
            Font.Color := clBlack;
         end;

         Pen.Color := Brush.Color;
         Rectangle(0, 0, itemBmp.Width, itemBmp.Height);

         if (om.app_id <> fAppID) then
         begin
            if not checkAppatId(om.app_id) then
            begin
               if (odSelected in State) then
                  Font.Color := $00eeeeee
               else
                  Font.Color := $00999999;
               drawIcon(itemBmp.Canvas, itemBmp.Width - 16 - 3, 4, 0, $00999999, $00eeeeee);
            end
            else
            begin
               drawIcon(itemBmp.Canvas, itemBmp.Width - 16 - 3, 4, 0);
            end;
         end;

         Font.Size := 8;
         if ((VlcForm.playFileName <> '') and (om.id = VlcForm.playFileID)) then
         begin
            Font.Style := [fsBold];
            tl := 5;
            if (VlcForm.playState in [2, 3]) then
            begin
               drawIcon(itemBmp.Canvas, 1, 4, VlcForm.playState - 1);
               tl := 5 + 14;
            end;
         end
         else
         begin
            Font.Style := [];
            tl := 5;
         end;

         tw := itemBmp.Width - tl - 3;

         if (om.app_id <> fAppID) then
         begin
            TextOut(tl, 5, trimText(itemBmp.Canvas, tw - 16, om.title));
         end
         else
         begin
            TextOut(tl, 5, trimText(itemBmp.Canvas, tw, om.title));
         end;
      end;
      MediaList.Canvas.Draw(Rect.Left, Rect.Top, itemBmp);
   finally
      itemBmp.Free;
   end;
end;

procedure TMainForm.CoolTrayIcon1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   i: integer;
begin
   if(Button = mbLeft) then
   begin
      if (MainForm.Visible) then
      begin
         CoolTrayIcon1.HideMainForm;
      end
      else
      begin
         CoolTrayIcon1.ShowMainForm;
      end;
   end;
end;

procedure TMainForm.Panel6Resize(Sender: TObject);
begin
   ComboBox1.Width := Panel6.ClientWidth;
end;

procedure TMainForm.ComboBox1Change(Sender: TObject);
begin
   FilterEdit.Text := '';
   refreshMediaList;
   SpeedButton1Click(nil);
end;

{ TSoundSocket }

constructor TSoundSocket.Create(host:string; port:integer);
begin
   Inherited Create(True);
   fHost := host;
   fPOrt := port;
   fSpeaker:= TSpeakerThread.Create(0);
   FreeOnTerminate := False;
   Resume;
end;

destructor TSoundSocket.Destroy;
begin
   fSpeaker.Free;
   inherited;
end;

procedure TSoundSocket.Execute;

   function checkZerro(Buffer: Pointer; samples:integer):boolean;
   var
      k: integer;
      bb: PBuff;
   begin
      bb := Buffer;
      Result := true;
      for k:= 1 to samples div 2 do
      begin
         if (bb[k] <> 0) then
         begin
            Result := false;
            exit;
         end;
      end;
   end;

var
   b: TBuff;
   i, k: integer;
begin
   fSoundSocket := TClientSocket.Create(nil);
   try
      fSoundSocket.Host := fHost;
      fSoundSocket.Port := fPort;
      fSoundSocket.ClientType := ctBlocking;
      while True do
      begin
         try
            fSoundSocket.Open;
            while fSoundSocket.Active do
            begin
               fSoundSocket.Socket.SendText('ping');
               i := fSoundSocket.Socket.ReceiveBuf(b, SizeOf(TBuff));
               if (Application.Terminated) then
                  break;
                  
               if (i > 0) then
                  while (not fSpeaker.Play(@b, i)) do
                  begin
                     if (checkZerro(@b, i) or Application.Terminated) then
                        break;
                     sleep(1);
                  end;
            end;
         except
         end;
         fSoundSocket.Close;
         if (Application.Terminated) then break;
      end;
   finally
      fSoundSocket.Free;
   end;
end;

procedure TMainForm.IdHTTPServer1CommandGet(AThread: TIdPeerThread;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
   id: integer;
   om: TMediaListItem;
   FileStream: TFileStream;
   IdMimeTable: TIdMimeTable;
begin
   try
      id := StrToInt(copy(ARequestInfo.Document, 2, Length(ARequestInfo.Document)));
      om := getMediaAtId(id);

      FileStream:= TFileStream.Create(om.file_name, fmOpenRead or fmShareDenyWrite);
      IdMimeTable:= TIdMimeTable.Create(true);
      try
         try
            FileStream.Position := ARequestInfo.ContentRangeStart;
         except
            on ERangeError do
            begin
               ARequestInfo.ContentRangeStart := FileStream.Position;
               ARequestInfo.ContentRangeEnd := 0;
            end;
         end;
         if ARequestInfo.ContentRangeEnd = 0 then
            ARequestInfo.ContentRangeEnd := FileStream.Size;
         ARequestInfo.ContentLength := ARequestInfo.ContentRangeEnd - ARequestInfo.ContentRangeStart;
         if FileStream.Size = ARequestInfo.ContentLength then
            AResponseInfo.ResponseNo := 200
         else
            AResponseInfo.ResponseNo := 206;

         AResponseInfo.ContentType := IdMimeTable.GetFileMIMEType(ExtractFileName(om.file_name));
         AResponseInfo.ContentLength := ARequestInfo.ContentLength;
         AResponseInfo.CustomHeaders.Clear;
         AResponseInfo.CustomHeaders.Values['Accept-Ranges'] := 'bytes';
         AResponseInfo.CustomHeaders.Values['Content-Disposition'] := 'filename="' + om.title + '"';

         AResponseInfo.WriteHeader;
         if not AnsiSameText(ARequestInfo.Command, 'HEAD') then
         begin
            AThread.Connection.WriteStream(FileStream, false, false, AResponseInfo.ContentLength);
         end;
      finally
         IdMimeTable.Free;
         FileStream.Free;
      end;
   except
      AResponseInfo.ResponseNo := 206;
   end;
end;

function TMainForm.getMediaAtId(id: integer): TMediaListItem;
var
   k: integer;
   om: TMediaListItem;
begin
   for k:= 0 to fMediaList.Count - 1 do
   begin
      om:= TMediaListItem(fMediaList[k]);
      if (om.id = id) then
      begin
         Result := om;
         break;
      end;
   end;
end;

procedure TMainForm.updateTimePanel;
var
   ts1, ts2:TTimeStamp;
begin
   if (VlcForm = nil) then exit;
   
   if (not fTimePanelDown) then
   begin
      if (VlcForm.playLen > 0) then
      begin
         TimeShape.Width := round(VlcForm.playPos * (TimePanel.ClientWidth - 2) / VlcForm.playLen);
      end
      else
         TimeShape.Width := 0;
   end;

   ts1 := DateTimeToTimeStamp(Now());
   ts2 := ts1;

   ts1.Time := VlcForm.playPos * 1000;
   ts2.Time := VlcForm.playLen * 1000;
   TimeLabel.Caption := TimeToStr(TimeStampToDateTime(ts1)) + ' / ' + TimeToStr(TimeStampToDateTime(ts2));
end;

procedure TMainForm.N4Click(Sender: TObject);
begin
   VlcForm.Show;
end;

procedure TMainForm.TimePanelResize(Sender: TObject);
begin
   TimeLabel.Left := (TimePanel.ClientWidth - TimeLabel.Width) div 2;
end;

procedure TMainForm.TimePanelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   mx: integer;
begin
   if ((Button = mbLeft) and (VlcForm.playState in [2, 3])) then
   begin
      mx := x;
      if ((Sender = TimeShape) or (Sender = TimeLabel)) then
         mx := mx + TControl(Sender).Left + TimePanel.BorderWidth; 

      fTimePanelDown := true;
      TimeShape.Width := mx;
      updateTimePanel;
      timeSeek();
   end;
end;

procedure TMainForm.TimePanelMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
   mx: integer;
begin
   if (fTimePanelDown) then
   begin
      mx := x;
      if ((Sender = TimeShape) or (Sender = TimeLabel)) then
         mx := mx + TControl(Sender).Left + TimePanel.BorderWidth;
      TimeShape.Width := mx;
      updateTimePanel;
      //timeSeek();
   end;
end;

procedure TMainForm.TimePanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
   mx: integer;
begin
   if (fTimePanelDown) then
   begin
      mx := x;
      if ((Sender = TimeShape) or (Sender = TimeLabel)) then
         mx := mx + TControl(Sender).Left + TimePanel.BorderWidth;
      TimeShape.Width := mx;
      updateTimePanel;
      timeSeek();
      fTimePanelDown := false;
   end;
end;

procedure TMainForm.timeSeek;
begin
   VlcForm.playPos := round((VlcForm.playLen * TimeShape.Width) / (TimePanel.ClientWidth - 2));
end;

procedure TMainForm.VlcVolPanelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if (Sender = VlcVolShape) then
      inc(x, 2);

   if (ssLeft in Shift) then
   begin
      VlcVolShape.Width := x;
      setVlcVolume;
   end;
end;

procedure TMainForm.VlcVolPanelMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
   if (Sender = VlcVolShape) then
      inc(x, 2);

   if (ssLeft in Shift) then
   begin
      VlcVolShape.Width := x;
      setVlcVolume;
   end;
end;

procedure TMainForm.VlcVolPanelMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if (Sender = VlcVolShape) then
      inc(x, 2);

   if (ssLeft in Shift) then
   begin
      VlcVolShape.Width := x;
      setVlcVolume;
   end;
end;

procedure TMainForm.setVlcVolume;
var
   v: integer;
begin
   if (VlcVolShape.Width > VlcVolPanel.ClientWidth) then
      VlcVolShape.Width := VlcVolPanel.ClientWidth;

   v := round(VlcVolShape.Width * 320 / VlcVolPanel.ClientWidth);
   if (v < 1) then v := 1;
   if (v > 320) then v := 320;

   VlcForm.volume := v;
   SpeedButton6.Down := true;

   saveProp('VlcVolume', IntToStr(VlcForm.volume));
end;

procedure TMainForm.SpeedButton6Click(Sender: TObject);
begin
   if (not SpeedButton6.Down) then
      VlcForm.volume := 0
   else
      setVlcVolume();
end;

function TMainForm.checkAppatId(id: integer): Boolean;
var
   k: integer;
   s_id: string;
begin
   Result := False;
   s_id := IntToStr(id);
   for k:= 0 to Length(fSessions) - 1 do
   begin
      if (fSessions[k][0] = s_id) then
      begin
         if (fSessions[k][2] <> '') then
            Result := true;
         break;
      end;
   end;
end;

function TMainForm.metaQuery(pack_name, pack_data: string): TDataRec;

   function parceTable(data:string):TDataRec;
   var
      F:integer;
      i: integer;
      cols:integer;
   begin
      i := Pos(chr(1), data);
      cols := StrToInt(copy(data, 1, i - 1));
      Delete(data, 1, i);
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

var
   s, b: string;
   k: integer;
begin
   Application.ProcessMessages;
   SocketMeta.Socket.SendText(pack_name + chr(1) + pack_data + chr(2));
   s := '';
   for k:= 1 to 10000 do
   begin
      b := SocketMeta.Socket.ReceiveText();
      s := s + b;
      if (Pos(chr(2), b) > 0) then
      begin
         Result := parceTable(s);
         break;
      end;
   end;
   Application.ProcessMessages;
end;

procedure TMainForm.PopupMenu1Popup(Sender: TObject);
var
   k: integer;
   mi: TMenuItem;
begin
   N6.Clear;
   for k:= 0 to Length(fSessions) - 1 do
   begin
      if ((fSessions[k][2] <> 'None') and (fSessions[k][0] <> IntToStr(fAppID))) then
      begin
         mi:= TMenuItem.Create(nil);
         mi.Caption := fSessions[k][1];
         mi.Tag := StrToInt(fSessions[k][0]);
         mi.OnClick := transferMedia;
         N6.Add(mi);
      end;
   end;

   if (N6.Count = 0) then
   begin
      mi:= TMenuItem.Create(nil);
      mi.Caption := 'Пусто';
      mi.Enabled := false;
      N6.Add(mi);
   end;
end;

procedure TMainForm.transferMedia(Sender: TObject);
var
   s: string;
begin
   if (not (VlcForm.playState in [2, 3])) then
   begin
      MessageDlg('У вас не запущено проигрывание. Переводить нечего.', mtWarning, [mbOk], 0);
      exit;
   end;
   
   s := IntToStr(VlcForm.playFileID) + chr(1) + IntToStr(VlcForm.playPos);
   metaQuery('media transfer', IntToStr(TMenuItem(Sender).Tag) + chr(1) + s);
   if (VlcForm.playState = 2) then
      PauseButtonClick(nil);
end;

procedure TMainForm.sendMediaState(state: string; id, time: integer);
begin
   metaQuery('media state', state + ';' + IntToStr(id) + ';' + IntToSTr(time));
end;

procedure TMainForm.StopButtonClick(Sender: TObject);
begin
   StopButton.Tag := 1;
   VlcForm.stop;
end;

procedure TMainForm.PauseButtonClick(Sender: TObject);
begin
   VlcForm.pause;
end;

procedure TMainForm.PlayButtonClick(Sender: TObject);
begin
   StopButton.Tag := 1;
   playMediaPlayAt(MediaList.ItemIndex);
end;

procedure TMainForm.playMediaPlayAt(index: integer; blockWarning: boolean = false);
var
   id: integer;
begin
   if ((index > -1) and (index < MediaList.Count)) then
   begin
      TimeShape.Tag := 0;   
      id := TMediaListItem(MediaList.Items.Objects[index]).id;
      startVlcPlay(id, false, 0, blockWarning);
   end;
end;

procedure TMainForm.startVlcPlay(id: integer; withPause: boolean; seek: integer; blockWarning: boolean = false);
var
   fileName: string;
   om: TMediaListItem;
   k: integer;
   ip: string;
   comm: string;
begin
   om := getMediaAtId(id);
   if (om <> nil) then
   begin
      for k:= 0 to Length(fSessions) - 1 do
      begin
         if (StrToInt(fSessions[k][0]) = om.app_id) then
         begin
            comm := fSessions[k][1];
            ip := fSessions[k][2];
            break;
         end;
      end;
      
      if (ip <> '') then
      begin
         fileName := 'http://' + ip + ':' + IntToStr(IdHTTPServer1.DefaultPort) + '/' + IntToStr(id);
         VlcForm.play(id, fileName, om.title, withPause, seek);
      end
      else
         if (not blockWarning) then
            MessageDlg('Источник "' + comm + '" не включен. Включите источник "' + comm + '" и повторите операцию.', mtWarning, [mbOk], 0);
   end;
end;

procedure TMainForm.MediaListDblClick(Sender: TObject);
begin
   PlayButtonClick(nil);
end;

procedure TMainForm.vlcOnChange(sender: TObject);
begin
   MediaList.Repaint;
   updateVlcVolume;
   if (VlcForm.playState = 2) then
      StopButton.Tag := 0;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
   VlcForm.onChange := vlcOnChange;
   VlcForm.onPlayPosEvent := vlcOnPlayPosEvent;
   VlcForm.onStopEvent := playStopEvent;
   VlcForm.fVlcExe := PropertysForm.Edit1.Text;
   updateTimePanel();
   try
      VlcForm.volume := StrToInt(loadProp('VlcVolume'));
   except
      VlcForm.volume := 160;
   end;
   updateVlcVolume();

   SpeedButton1Click(nil);
end;

procedure TMainForm.vlcOnPlayPosEvent(sender: TObject; pos, len: integer);
begin
   updateTimePanel();
   if ((PlayLoopButton.Down) and (len > 0) and (pos = len - 1)) then
      playMediaNextItem;
end;

procedure TMainForm.playMediaNextItem;
var
   k: integer;
   ind: integer;
begin
   if (MediaList.Count > 0) then
   begin
      ind := 0;
      for k:= 0 to MediaList.Count - 1 do
      begin
         if (TMediaListItem(MediaList.Items.Objects[k]).id = VlcForm.playFileID) then
         begin
            ind := k + 1;
            break;
         end;
      end;

      if (ind > MediaList.Count - 1) then
         ind := 0;

      playMediaPlayAt(ind, true);
   end;
end;

procedure TMainForm.PlayLoopButtonClick(Sender: TObject);
begin
   if (PlayLoopButton.Down) then
      saveProp('VlcPlayLoop', 'loop')
   else
      saveProp('VlcPlayLoop', '');
end;

procedure TMainForm.playStopEvent(Sender: TObject);
begin
{   if ((StopButton.Tag = 0) and (PlayLoopButton.Down)) then
      playMediaNextItem;}
end;

procedure TMainForm.MediaListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if (Key = 32) then
      PauseButtonClick(nil);
end;

procedure TMainForm.updateVlcVolume;
begin
   VlcVolShape.Width := round(VlcForm.volume * VlcVolPanel.ClientWidth / 320);
end;

procedure TMainForm.startLoad;
var
   res: TDataRec;
   k: integer;
   o: TItemListItem;
   om: TMediaListItem;
begin
   addToMetaLog('start LOAD');
   itemListClear;

   res := metaQuery('load variables', IntToStr(fAppID));
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
   addToMetaLog('finish LOAD');

   // ------------------------------------------
   setLength(res, 0);
   res := metaQuery('get media folders', '');
   if (length(res) > 0) then
      PropertysForm.ListBox1.Items.Text := res[0][0];
   setStatusText('Загрузка списка медиафайлов');

   // ------------------------------------------

   addToMetaLog('start MEDIA PACK');
   mediaListClear;
   setLength(res, 0);   
   res := metaQuery('get media list', '');
   for k := 0 to Length(res) - 1 do
   begin
      om:= TMediaListItem.Create;
      om.id := StrToInt(res[k][0]);
      om.app_id := StrToInt(res[k][1]);
      om.title := res[k][2];
      om.file_name := res[k][3];
      fMediaList.Add(om);
   end;
   refreshMediaList();
   addToMetaLog('finish MEDIA PACK');
   setStatusText('Сканирование медиафайлов');
   PropertysForm.scanMediaLib;
   addToMetaLog('finish SCAN MEDIA LIB');
   setStatusText('');
end;

procedure TMainForm.syncLoad;
var
   res: TDataRec;
   k, i: integer;
   om: TMediaListItem;
begin
   syncPack(metaQuery('sync', ''));

   // --------------------------------------------

   fSessions := metaQuery('sessions', '');
   MediaList.Repaint;

   // --------------------------------------------

   res := metaQuery('media queue', '');
   if (Length(res) > 0) then
   begin
      for k:= 0 to Length(res) - 1 do
      begin
         case StrToInt(res[k][1]) of
            0:
            begin
               om:= TMediaListItem.Create;
               om.id := StrToInt(res[k][2]);
               om.app_id := StrToInt(res[k][4]);
               om.title := res[k][5];
               om.file_name := res[k][6];
               fMediaList.Add(om);
            end;
            1:
            begin
               for i:= 0 to fMediaList.Count - 1 do
               begin
                  om:= TMediaListItem(fMediaList[i]);
                  if (om.id = StrToInt(res[k][2])) then
                  begin
                     om.id := StrToInt(res[k][2]);
                     om.app_id := StrToInt(res[k][4]);
                     om.title := res[k][5];
                     om.file_name := res[k][6];
                     break;
                  end;
               end;
            end;
            2:
            begin
               for i:= 0 to fMediaList.Count - 1 do
               begin
                  om:= TMediaListItem(fMediaList[i]);
                  if (om.id = StrToInt(res[k][2])) then
                  begin
                     fMediaList.Delete(i);
                     break;
                  end;
               end;
            end;

            10: // Transfer media
            begin
               StopButton.Tag := 1;
               startVlcPlay(StrToInt(res[k][2]), true, StrToInt(res[k][3]));
            end;
         end;
      end;
      refreshMediaList();
   end;
end;

procedure TMainForm.syncPack(res: TDataRec);
var
   k, i: integer;
begin
   for k := 0 to Length(res) - 1 do
   begin
      for i:= 0 to fItemList.Count - 1 do
      begin
         if (TItemListItem(fItemList[i]).id = StrToInt(res[k][1])) then
         begin
            if (res[k][2] = 'None') then
               res[k][2] := '-9999';
            TItemListItem(fItemList[i]).value := StrToFloat(StringReplace(res[k][2], '.', ',', [rfReplaceAll]));
         end;
      end;
   end;
   if (Length(res) > 0) then
      refreshItemList();
end;

procedure TMainForm.firstRun;
var
   b: boolean;
   s: string;
begin
   b := true;
   while b do
   begin
      try
         SocketMeta.Open;
         saveProp('IP', SocketMeta.Host);
         b := false; 
      except
         s := '';
         if not InputQuery('Введите IP сервера', 'IP', s) then
         begin
            Application.Terminate;
            exit;
         end;
         SocketMeta.Host := s;
      end;
   end;

   fSoundSocket:= TSoundSocket.Create(SocketMeta.Host, SocketMeta.Port + 1);
   setVolume();

   IdHTTPServer1.Active := true;
end;

end.

