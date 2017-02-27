unit MainForm_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DlgMessagesRU, CoolTrayIcon, ScktComp, StdCtrls, Speacker, ExtCtrls, ToolWin,
  ComCtrls, Buttons, ImgList, Menus, ShellApi, IdBaseComponent,
  IdComponent, IdTCPServer, IdCustomHTTPServer, IdHTTPServer,
  IdServerIOHandler, IdServerIOHandlerSocket, IdGlobal, ActnList;

type
   TDataRec = array of array of string;

   TVarListItem = class
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
      file_type: integer;
   end;

   TMediaGroupItem = class
      id: integer;
      typ: integer;
      comm: string;
   end;

   TSchedListItem = class
      id: integer;
      comm: string;
      action: string;
      datetime: TDateTime;
      timeOfDay: string;
      dayOfType: string;
      typ: integer;
      variable: integer;
   end;

   TSoundSocket = class (TThread)
   private
      fSocket: TClientSocket;
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
    TimePanel: TPanel;
    TimeShape: TShape;
    TimeLabel: TLabel;
    Panel3: TPanel;
    SpeedButton6: TSpeedButton;
    VlcVolPanel: TPanel;
    VlcVolShape: TShape;
    PlayLoopButton: TSpeedButton;
    N5: TMenuItem;
    VarPopupMenu: TPopupMenu;
    VarPopupItem1: TMenuItem;
    VarPopupItem4: TMenuItem;
    VarPopupItem2: TMenuItem;
    VarPopupItem3: TMenuItem;
    VarPopupItem5: TMenuItem;
    VarPopupItem6: TMenuItem;
    N13: TMenuItem;
    SpeedButton7: TSpeedButton;
    SchedList: TListBox;
    ImageList3: TImageList;
    PopupMenu2: TPopupMenu;
    N7: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    Timer2: TTimer;
    N16: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    PopupMenu3: TPopupMenu;
    TransferMenu: TMenuItem;
    VLC1: TMenuItem;
    N9: TMenuItem;
    N4: TMenuItem;
    N6: TMenuItem;
    N8: TMenuItem;
    Buhfnm1: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N19: TMenuItem;
    N20: TMenuItem;
    N21: TMenuItem;
    MediaGroupAdd: TMenuItem;
    MediaGroupDel: TMenuItem;
    N2: TMenuItem;
    AddMediaListButton: TSpeedButton;
    PopupMenu4: TPopupMenu;
    N25: TMenuItem;
    N26: TMenuItem;
    N27: TMenuItem;
    N22: TMenuItem;
    N12: TMenuItem;
    ActionList1: TActionList;
    ActionSelAll: TAction;
    SpeedButton8: TSpeedButton;
    IdHTTPServer1: TIdHTTPServer;
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
    procedure Panel6Resize(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure IdHTTPServer1CommandGet(AThread: TIdPeerThread;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
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
    procedure StopButtonClick(Sender: TObject);
    procedure PauseButtonClick(Sender: TObject);
    procedure PlayButtonClick(Sender: TObject);
    procedure MediaListDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PlayLoopButtonClick(Sender: TObject);
    procedure MediaListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure VarPopupItemClick(Sender: TObject);
    procedure SchedListDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure N15Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure N18Click(Sender: TObject);
    procedure VarPopupMenuPopup(Sender: TObject);
    procedure SchedListMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MediaListMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure VLC1Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure CoolTrayIcon1Click(Sender: TObject);
    procedure PopupMenu3Popup(Sender: TObject);
    procedure AddMediaListButtonClick(Sender: TObject);
    procedure N26Click(Sender: TObject);
    procedure N27Click(Sender: TObject);
    procedure MediaGroupAddClick(Sender: TObject);
    procedure MediaGroupDelClick(Sender: TObject);
    procedure ComboBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure N12Click(Sender: TObject);
    procedure ActionSelAllExecute(Sender: TObject);
    procedure PlayLoopButtonMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SpeedButton8Click(Sender: TObject);
  private
    fSoundSocket: TSoundSocket;
    fSocketMetaBufer: string;
    fTimePanelDown: Boolean;

    fSessionVlcState: integer;
    fSessionVlcID: integer;

    fMediaGroupCross: array of integer;

    procedure setStatusText(text:String);
    procedure refreshVarList();
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

    procedure clearList(ls:TList);
    function trimText(canvas: TCanvas; w:integer; s: string):string;
    procedure drawIcon(canvas:TCanvas; imageList: TImageList; isSel:Boolean; x, y, index:integer; color_no_sel:integer = -1; color_sel:integer = -1);
    procedure inverIcon(bmp:TBitmap; toColor: integer);

    procedure loadMediaGroups(id: integer);
    procedure loadMediaCross();

    procedure updatePlayLoopButtonIcon(); 
  public
    fAppID: integer;
    fItemList: TList;
    fMediaList: TList;
    fSessions:TDataRec;
    function metaQuery(pack_name, pack_data: string; blokMessages: boolean = false): TDataRec;
    procedure freeDataRec(dr:TDataRec);

    procedure sendMediaState(state: string; id, time: integer);
    procedure playMediaPlayAt(index: integer; blockWarning: boolean = false);
    procedure schedLoad();
  end;

var
  MainForm: TMainForm;

implementation

uses StrUtils, PropertysForm_Unit, Mcs_Unit, RegForm_Unit,
  TerminalForm_Unit, Types, Vlc_Unit, DateUtils, SchedDialog_Unit,
  MediaInfoDialog_Unit;

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
var
   s: string;
   b: boolean;
begin
   Randomize;

   //saveProp('ID', '');
   InfoPanel.Align := alClient;
   
   MediaPanel.Align := alClient;
   MediaList.DoubleBuffered := true;

   VarList.Align := alClient;
   VarList.DoubleBuffered := true;

   SchedList.Align := alClient;
   SchedList.DoubleBuffered := true;
   
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

   s := loadProp('VlcPlayLoop');
   if (s = 'loop') then
      PlayLoopButton.Tag := 1
   else
   if (s = 'shufle') then
      PlayLoopButton.Tag := 2
   else
      PlayLoopButton.Tag := 0;

   fItemList := TList.Create;
   fMediaList := TList.Create;

   SocketMeta.Host := loadProp('IP');

   Timer1.Enabled := true;

   setStatusText('������');

   updateTimePanel;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
   IdHTTPServer1.Active := false;

   Timer1.Enabled := false;
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
      fSoundSocket.WaitFor;
      fSoundSocket.Free;
   except
   end;

   clearList(fMediaList);
   fMediaList.Free;
   clearList(fItemList);
   fItemList.Free;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
   Timer1.Enabled := false;
   try
      if Timer1.Tag = 0 then
      begin
         Timer1.Tag := 1;
         //CoolTrayIcon1.HideMainForm;
         firstRun();
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
   finally
      Timer1.Enabled := true;
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
   setStatusText('����������� ����������� � �������...');
end;

procedure TMainForm.SocketMetaDisconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   if (RegForm.Visible) then
      Application.Terminate;
   setStatusText('���������� � �������� �������');
   SocketMeta.Close;
end;

procedure TMainForm.SocketMetaError(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   ErrorCode := 0;
   setStatusText('������ ����������� � �������');
   SocketMeta.Close;
end;

procedure TMainForm.refreshVarList;
var
   k, t, i: integer;
   lb: string;
   o:TVarListItem;
begin
   t := currView();

   VarList.Items.BeginUpdate;
   i := 0;
   for k:= 0 to fItemList.Count - 1 do
   begin
      o := TVarListItem(fItemList[k]);
      lb := o.comm + ' [' + FloatToStr(o.value) + ']';

      if (o.typ = t) or ((t = 4) and (o.typ = 10)) or ((t = 7) and (o.typ = 11)) then
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
      10: t := 2;
   end;

   if (InfoLabel.Caption <> '') then
      t := -1;

   InfoPanel.Visible := t = -1;
   VarList.Visible := t = 0;
   Panel5.Visible := t = 1;
   SchedList.Visible := t = 2;

   case t of
      0:
      begin
         refreshVarList();
         if (MainForm.Visible) then
            VarList.SetFocus;
      end;
      1:
      begin
         if (MainForm.Visible) then
            MediaList.SetFocus;
      end;

      2:
      begin
         if (MainForm.Visible) then
            SchedList.SetFocus;         
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
      setStatusText('������ ����������� ����������');
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

procedure TMainForm.VarListDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
   o: TVarListItem;
   itemBmp, bmp:TBitmap;
   v: string;
   tl, tr, k: integer;
begin
   o := TVarListItem(VarList.Items.Objects[index]);

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

         tl := 5;
         tr := 5;

         case o.typ of
            1, 3:
            begin
               bmp:= TBitmap.Create;
               try
                  bmp.Transparent := True;
                  bmp.Width := 28;
                  bmp.Height := 14;
                  if (o.value = 0) then
                     ImageList1.Draw(bmp.Canvas, 0, 0, 0)
                  else
                     ImageList1.Draw(bmp.Canvas, 0, -13, 0);
                  {if (odSelected in State) then
                     inverIcon(bmp, $00feffff);}
                  Draw(itemBmp.Width - 5 - 28, 5, bmp);

                  tr := tr + 26;
                  for k:= 0 to SchedList.Count - 1 do
                  begin
                     if (TSchedListItem(SchedList.Items.Objects[k]).variable = o.id) then
                     begin
                        drawIcon(itemBmp.Canvas, ImageList3, (odSelected in State), 3, 4, 4);
                        tl := tl + 18;
                        break;
                     end;
                  end;
               finally
                  bmp.Free;
               end;
            end;

            4, 5, 10, 11:
            begin
               if (o.value <> -9999) then
               begin
                  Font.Style := [fsBold];
                  Font.Size := 11;
                  case o.typ of
                     4:
                     begin
                        v := IntToStr(round(o.value * 10));
                        if (abs(o.value) >= 1) then
                           insert('.', v, Length(v))
                        else
                           insert('0.', v, Length(v));
                        v := v + '�C';
                     end;
                     5:
                     begin
                        v := IntToStr(trunc(o.value)) + '�C';
                        v := '<' + v + '>';
                     end;
                     10:
                     begin
                        v := IntToStr(trunc(o.value)) + '%';
                     end;
                     11:
                     begin
                        v := IntToStr(round(o.value * 10));
                        if (abs(o.value) >= 1) then
                           insert('.', v, Length(v))
                        else
                           insert('0.', v, Length(v));
                        v := v + 'ppm';
                     end;
                  end;
                  TextOut(itemBmp.Width - 5 - TextWidth(v), 3, v);
               end;
            end;

            7:
            begin
               bmp:= TBitmap.Create;
               try
                  bmp.TransparentColor := clFuchsia;
                  bmp.Transparent := True;
                  bmp.Width := 32;
                  bmp.Height := 13;
                  ImageList1.Draw(bmp.Canvas, 0, -round(12 * (o.value / 2)), 1);
                  {if (odSelected in State) then
                     inverIcon(bmp, $00feffff);}
                  Draw(itemBmp.Width - 5 - 29, 6, bmp);
               finally
                  bmp.Free;
               end;
            end;
         end;

         Font.Size := 8;
         Font.Style := [];
         if (o.typ = 10) then
            Font.Style := [fsItalic];
         TextOut(tl, 5, trimText(itemBmp.Canvas, itemBmp.Width - tl - tr, o.comm));
         Font.Style := [];
      end;

      VarList.Canvas.Draw(Rect.Left, Rect.Top, itemBmp);
      if (odFocused in State) then
         VarList.Canvas.DrawFocusRect(Rect);
   finally
      itemBmp.Free;
   end;
end;

procedure TMainForm.VarListMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   i: integer;
   o: TVarListItem;
   r: TRect;
   v: Double;
   p: TPoint;
begin
   i := VarList.ItemAtPos(Point(X, Y), True);
   if (i > -1) then
   begin
      VarList.ItemIndex := i;

      r := VarList.ItemRect(i);
      o := TVarListItem(VarList.Items.Objects[i]);
      case o.typ of
         1, 3:
         begin
            if ((x > r.Right - 26 - 5) and (x < r.Right - 5)) then
            begin
               if (o.value > 0) then
                  sendVarValue(o.id, 0)
               else
                  sendVarValue(o.id, 1);
            end
            else
            begin
               if (Button = mbRight) then
               begin
                  p := VarList.ClientToScreen(Point(X, Y));
                  VarPopupMenu.Popup(p.X, p.Y);
               end;
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
   SchedList.Repaint;
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
   o: TVarListItem;
   v: integer;
begin
   // 39 - Right
   // 37 - Left

   if (VarList.ItemIndex > -1) then
   begin
      o := TVarListItem(VarList.Items.Objects[VarList.ItemIndex]);
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
               if (v <> trunc(o.value)) then
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
            if (v <> trunc(o.value)) then
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
            if (v <> trunc(o.value)) then
               sendVarValue(o.id, v);
         end;
      end;
   end;

   if ((Key = 37) or (Key = 39)) then Key := 0;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
   CanClose := ((fAppID = -1) or (MessageDlg('�� ������ ����� �� �������� � �������� �������� ��� �����?', mtConfirmation, [mbYes, mbNo], 0) = mrYes));
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

procedure TMainForm.InfoPanelResize(Sender: TObject);
begin
   InfoLabel.Height := InfoPanel.Height div 2;
end;

procedure TMainForm.refreshMediaList;

   function checkMediaInGroup(id: integer): boolean;
   var
      k: integer;
   begin
      for k:= 0 to Length(fMediaGroupCross) - 1 do
      begin
         if (fMediaGroupCross[k] = id) then
         begin
            Result := true;
            exit;
         end;
      end;
      Result := false;
   end;

var
   k: integer;
   om: TMediaListItem;
   c, i: integer;
   mg: TMediaGroupItem;
begin
   i := 0;
   MediaList.Items.BeginUpdate;
   try
      MediaList.Items.Clear;

      if (ComboBox1.ItemIndex <> -1) then
      begin
         if (ComboBox1.Items.Objects[ComboBox1.ItemIndex] = nil) then
         begin
            case ComboBox1.ItemIndex of
               0:
               begin
                  for k:= 0 to fMediaList.Count - 1 do
                  begin
                     om := TMediaListItem(fMediaList[k]);
                     if ((FilterEdit.Text = '') or (Pos(WideUpperCase(FilterEdit.Text), WideUpperCase(om.title)) > 0)) then
                        MediaList.AddItem(om.title, om);
                  end;
               end
               else
               begin
                  for k:= 0 to fMediaList.Count - 1 do
                  begin
                     om := TMediaListItem(fMediaList[k]);
                     if ((om.file_type = ComboBox1.ItemIndex) and ((FilterEdit.Text = '') or (Pos(WideUpperCase(FilterEdit.Text), WideUpperCase(om.title)) > 0))) then
                        MediaList.AddItem(om.title, om);
                  end;
               end;
            end;
         end
         else
         begin
            for k:= 0 to fMediaList.Count - 1 do
            begin
               om := TMediaListItem(fMediaList[k]);
               if ((checkMediaInGroup(om.id)) and ((FilterEdit.Text = '') or (Pos(WideUpperCase(FilterEdit.Text), WideUpperCase(om.title)) > 0))) then
                  MediaList.AddItem(om.title, om);
            end;
         end;
      end;
      MediaList.Sorted := true;
   finally
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

procedure TMainForm.MediaListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
   om: TMediaListItem;
   itemBmp: TBitmap;
   k: integer;
   b: boolean;
   tl, tw: integer;
   title, gt: string;
   gt_len: integer;
begin
   om := TMediaListItem(MediaList.Items.Objects[index]);
   gt := ComboBox1.Text;
   gt_len := Length(gt);

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
               drawIcon(itemBmp.Canvas, ImageList2, (odSelected in State), itemBmp.Width - 16 - 3, 4, 0, $00999999, $00eeeeee);
            end
            else
            begin
               drawIcon(itemBmp.Canvas, ImageList2, (odSelected in State), itemBmp.Width - 16 - 3, 4, 0);
            end;
         end;

         Font.Size := 8;
         if ((VlcForm.playFileName <> '') and (om.id = VlcForm.playFileID)) then
         begin
            Font.Style := [fsBold];
            tl := 5;
            if (VlcForm.playState in [2, 3]) then
            begin
               drawIcon(itemBmp.Canvas, ImageList2, (odSelected in State), 1, 4, VlcForm.playState - 1);
               tl := 5 + 14;
            end;
         end
         else
         begin
            Font.Style := [];
            tl := 5;
         end;

         tw := itemBmp.Width - tl - 3;

         title := om.title;
         if (gt = Copy(title, 1, gt_len)) then
         begin
            delete(title, 1, gt_len);
            for k:= 1 to Length(title) do
            begin
               case title[k] of
                  ' ', '-':
                  else
                  begin
                     delete(title, 1, k - 1);
                     break;
                  end;
               end;
            end;
         end;

         if (om.app_id <> fAppID) then
         begin
            TextOut(tl, 5, trimText(itemBmp.Canvas, tw - 16, title));
         end
         else
         begin
            TextOut(tl, 5, trimText(itemBmp.Canvas, tw, title));
         end;
      end;
      MediaList.Canvas.Draw(Rect.Left, Rect.Top, itemBmp);
      if (odFocused in State) then
         MediaList.Canvas.DrawFocusRect(Rect);      
   finally
      itemBmp.Free;
   end;
end;

procedure TMainForm.Panel6Resize(Sender: TObject);
begin
   AddMediaListButton.Left := Panel6.ClientWidth - AddMediaListButton.Width;
   ComboBox1.Width := AddMediaListButton.Left - 1;
end;

procedure TMainForm.ComboBox1Change(Sender: TObject);
begin
   //FilterEdit.Text := '';
   loadMediaCross;
   refreshMediaList;
   SpeedButton1Click(nil);

   if (ComboBox1.ItemIndex > -1) then
   begin
      if ((ComboBox1.Items.Objects[ComboBox1.ItemIndex] = nil) or (TMediaGroupItem(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).id = -1)) then
      begin
         saveProp('selGroup', IntToStr(-ComboBox1.ItemIndex));
      end
      else
      begin
         saveProp('selGroup', IntToStr(TMediaGroupItem(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).id));
      end;
   end;
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
   fSpeaker.Terminate;
   fSpeaker.WaitFor;
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
   fSocket := TClientSocket.Create(nil);
   try
      fSocket.Host := fHost;
      fSocket.Port := fPort;
      fSocket.ClientType := ctBlocking;

      while not Terminated do
      begin
         try
            fSocket.Open;
            while (fSocket.Active and (not Terminated)) do
            begin
               fSocket.Socket.SendText('ping');
               i := fSocket.Socket.ReceiveBuf(b, SizeOf(TBuff));

               if (i > 0) then
               begin
                  while (not fSpeaker.Play(@b, i)) do
                  begin
                     if (checkZerro(@b, i) or Terminated) then
                        break;
                     sleep(1);
                  end;
               end;
            end;
         except
         end;
         fSocket.Close;
      end;
   finally
      fSocket.Close;
      fSocket.Free;
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
            try
               AThread.Connection.WriteStream(FileStream, false, false, AResponseInfo.ContentLength);
            except
            end;
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

function TMainForm.metaQuery(pack_name, pack_data: string; blokMessages: boolean = false): TDataRec;

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
   if (not blokMessages) then
      Application.ProcessMessages;
   if (not SocketMeta.Active) then exit;
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
   if (not blokMessages) then
      Application.ProcessMessages;
end;

procedure TMainForm.transferMedia(Sender: TObject);
var
   s: string;
begin
   if (not (VlcForm.playState in [2, 3])) then
   begin
      MessageDlg('� ��� �� �������� ������������. ���������� ������.', mtWarning, [mbOk], 0);
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
         VlcForm.play(id, om.file_type, fileName, om.title, withPause, seek);
      end
      else
         if (not blockWarning) then
         begin
            comm := metaQuery('get app info', IntToStr(om.app_id))[0][0];
            MessageDlg('�������� "' + comm + '" �� �������. �������� �������� "' + comm + '" � ��������� ��������.', mtWarning, [mbOk], 0);
         end;
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
   if (not Assigned(VlcForm.onChange)) then // ��� �������� ������ ������� ������� ����������. 
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
      updatePlayLoopButtonIcon;
   end;
end;

procedure TMainForm.vlcOnPlayPosEvent(sender: TObject; pos, len: integer);
begin
   updateTimePanel();
   if ((PlayLoopButton.Tag > 0) and (len > 0) and (pos >= len - 3)) then
   begin
      playMediaNextItem;
   end;
end;

procedure TMainForm.playMediaNextItem;
var
   k: integer;
   ind: integer;
   l: TList;
begin
   l := TList.Create;
   try
      for k:= 0 to MediaList.Count - 1 do
      begin
         if (TMediaListItem(MediaList.Items.Objects[k]).id = VlcForm.playFileID) then
            ind := l.Count;

         if (checkAppatId(TMediaListItem(MediaList.Items.Objects[k]).app_id)) then
         begin
            l.Add(MediaList.Items.Objects[k]);
         end;
      end;

      if (l.Count > 0) then
      begin
         case PlayLoopButton.Tag of
            0: ;
            1:
            begin
               inc(ind);
               if (ind > l.Count - 1) then
                  ind := 0;

               ind := MediaList.Items.IndexOfObject(l[ind]);
               playMediaPlayAt(ind, true);
            end;
            2:
            begin
               ind := MediaList.Items.IndexOfObject(l[round(random(l.Count - 1))]);
               playMediaPlayAt(ind, true);
            end;
         end;
      end;

   finally
      l.Free;
   end;
end;

procedure TMainForm.PlayLoopButtonClick(Sender: TObject);
var
   i: integer;
begin
   i := PlayLoopButton.Tag;
   inc(i);
   if (i > 2) then
      i := 0;
   PlayLoopButton.Tag := i;

   case i of
      0:
      begin
         saveProp('VlcPlayLoop', '')
      end;
      1:
      begin
         saveProp('VlcPlayLoop', 'loop')
      end;
      2:
      begin
         saveProp('VlcPlayLoop', 'shufle')
      end;
   end;
   updatePlayLoopButtonIcon;
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
   k, i: integer;
   o: TVarListItem;
   om: TMediaListItem;
   mg: TMediaGroupItem;
begin
   addToMetaLog('start LOAD');
   clearList(fItemList);

   res := metaQuery('load variables', IntToStr(fAppID));
   for k := 0 to Length(res) - 1 do
   begin
      o:= TVarListItem.Create;
      o.id := StrToInt(res[k][0]);
      o.name := res[k][1];
      o.comm := res[k][2];
      o.typ := StrToInt(res[k][3]);
      if (res[k][4] = 'None') then
         res[k][4] := '-9999';
      o.value := StrToFloat(StringReplace(res[k][4], '.', ',', [rfReplaceAll]));
      fItemList.Add(o);
   end;
   freeDataRec(res);
   refreshVarList();
   addToMetaLog('finish LOAD');

   // ------------------------------------------

   MediaExts := metaQuery('get media exts', '')[0][0];

   // ------------------------------------------
   setLength(res, 0);
   res := metaQuery('get media folders', '');
   if (length(res) > 0) then
      PropertysForm.ListBox1.Items.Text := res[0][0];
   setStatusText('�������� ������ �����������');

   // ------------------------------------------

   addToMetaLog('start MEDIA PACK');
   clearList(fMediaList);
   setLength(res, 0);
   res := metaQuery('get media list', '');
   for k := 0 to Length(res) - 1 do
   begin
      om:= TMediaListItem.Create;
      om.id := StrToInt(res[k][0]);
      om.app_id := StrToInt(res[k][1]);
      om.title := res[k][2];
      om.file_name := res[k][3];
      om.file_type := StrToInt(res[k][4]);
      fMediaList.Add(om);
   end;
   refreshMediaList();
   addToMetaLog('finish MEDIA PACK');
   setStatusText('������������ �����������');
   PropertysForm.scanMediaLib;
   addToMetaLog('finish SCAN MEDIA LIB');
   setStatusText('');

   // ------------------------------------

   loadMediaGroups(-1);

   i := 0;
   try
      i := StrToInt(loadProp('selGroup'));
   except
   end;
   if (i <> 0) then
   begin
      if (i < 0) then
         ComboBox1.ItemIndex := -i
      else
      begin
         for k:= 0 to ComboBox1.Items.Count - 1 do
         begin
            if ((ComboBox1.Items.Objects[k] <> nil) and (TMediaGroupItem(ComboBox1.Items.Objects[k]).id = i)) then
            begin
               ComboBox1.ItemIndex := k;
               break;
            end;
         end;
      end;
      ComboBox1Change(nil);
   end;

   // ------------------------------------

   schedLoad();
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
               om.file_type := StrToInt(res[k][7]);
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
                     om.file_type := StrToInt(res[k][7]);
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

            20: // ��������� ������ ����������
            begin
               loadMediaGroups(-1); //StrToInt(res[k][2]));
            end;

            21: // ��������� ����������� ���������
            begin
               if ((ComboBox1.ItemIndex > -1) and (ComboBox1.Items.Objects[ComboBox1.ItemIndex] <> nil)) then
                  if (TMediaGroupItem(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).id = StrToInt(res[k][2])) then
                     ComboBox1Change(nil);
            end;
         end;
      end;
      refreshMediaList();
   end;
   freeDataRec(res);
end;

procedure TMainForm.syncPack(res: TDataRec);
var
   k, i: integer;
begin
   for k := 0 to Length(res) - 1 do
   begin
      for i:= 0 to fItemList.Count - 1 do
      begin
         if (TVarListItem(fItemList[i]).id = StrToInt(res[k][1])) then
         begin
            if (res[k][2] = 'None') then
               res[k][2] := '-9999';
            TVarListItem(fItemList[i]).value := StrToFloat(StringReplace(res[k][2], '.', ',', [rfReplaceAll]));
         end;
      end;
   end;
   if (Length(res) > 0) then
      refreshVarList();
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
         if not InputQuery('������� IP �������', 'IP', s) then
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

procedure TMainForm.VarPopupItemClick(Sender: TObject);
var
   o: TVarListItem;
   s: string;
begin
   if (VarList.ItemIndex = -1) then exit;

   o:= TVarListItem(VarList.Items.Objects[VarList.ItemIndex]);

   case TMenuItem(Sender).Tag of
      10: sendVarValue(o.id, 1);
      11:
      begin
         if InputQuery('�������� �����', '����� (�����):', s) then
         begin
            if (s <> '') then
               SchedDialog.fastInsert('�������� "' + o.comm + '" ����� ' + s + ' �����', 'on("' + o.name + '")', IncMinute(Now(), StrToInt(s)), o.id)
            else
               SchedDialog.fastInsert('', '', Now(), o.id);
            schedLoad;
         end;
      end;
      12:
      begin
         if InputQuery('�������� ��������', '�� (�����):', s) then
         begin
            if (s <> '') then
            begin
               if (o.value = 0) then
                  sendVarValue(o.id, 1);
               SchedDialog.fastInsert('��������� "' + o.comm + '" ����� ' + s + ' �����', 'off("' + o.name + '")', IncMinute(Now(), StrToInt(s)), o.id);
            end
            else
               SchedDialog.fastInsert('', '', Now(), o.id);
            schedLoad;
         end;
      end;
      20: sendVarValue(o.id, 0);
      21:
      begin
         if InputQuery('��������� �����', '����� (�����):', s) then
         begin
            if (s <> '') then
            begin
               SchedDialog.fastInsert('��������� "' + o.comm + '" ����� ' + s + ' �����', 'off("' + o.name + '")', IncMinute(Now(), StrToInt(s)), o.id);
            end
            else
               SchedDialog.fastInsert('', '', Now(), o.id);
            schedLoad;
         end;
      end;
      22:
      begin
         if InputQuery('��������� ��������', '�� (�����):', s) then
         begin
            if (s <> '') then
            begin
               if (o.value = 1) then
                  sendVarValue(o.id, 0);
               SchedDialog.fastInsert('�������� "' + o.comm + '" ����� ' + s + ' �����', 'on("' + o.name + '")', IncMinute(Now(), StrToInt(s)), o.id);
            end
            else
               SchedDialog.fastInsert('', '', Now(), o.id);
            schedLoad;
         end;
      end;

      30:
      begin
         SchedDialog.fastInsert('', '', Now(), o.id);
         schedLoad;
      end;
   end;
end;

procedure TMainForm.schedLoad;

   function strToDate(s: string):TDateTime;
   var
      y, m, d, hh, mm, ss: integer; 
   begin
      if s = 'None' then
      begin
         Result := 0;
         exit;
      end;

      y := StrToInt(Copy(s, 1, 4));
      m := StrToInt(Copy(s, 6, 2));
      d := StrToInt(Copy(s, 9, 2));
      hh := StrToInt(Copy(s, 12, 2));
      mm := StrToInt(Copy(s, 15, 2));
      ss := StrToInt(Copy(s, 18, 2));

      Result := EncodeDateTime(y, m, d, hh, mm, ss, 0);
   end;

var
   res: TDataRec;
   k: integer;
   os: TSchedListItem;
   t: integer;
begin
   t := SchedList.TopIndex;
   if (SchedList.ItemIndex > -1) then
      SchedList.Tag := TSchedListItem(SchedList.Items.Objects[SchedList.ItemIndex]).id
   else
      SchedList.Tag := -1;

   SchedList.Items.BeginUpdate;
   SchedList.Clear;
   res := metaQuery('get scheduler list', '');
   for k:= 0 to Length(res) - 1 do
   begin
      os:= TSchedListItem.Create;
      os.id := StrToInt(res[k][0]);
      os.comm := res[k][1];
      os.action := res[k][2];
      os.datetime := strToDate(res[k][3]);
      os.timeOfDay := res[k][4];
      os.dayOfType := res[k][5];
      os.typ := StrToInt(res[k][6]);
      os.variable := StrToInt(res[k][7]);
      SchedList.AddItem(os.comm, os);
      if (os.id = SchedList.Tag) then
         SchedList.ItemIndex := SchedList.Count - 1;  
   end;
   freeDataRec(res);
   SchedList.TopIndex := t;
   SchedList.Items.EndUpdate;
   VarList.Repaint;   
end;

procedure TMainForm.clearList(ls: TList);
var
   k: integer;
begin
   for k:= 0 to ls.Count - 1 do
   begin
      TObject(ls[k]).Free;
      ls[k] := nil;
   end;
   ls.Clear;
end;

procedure TMainForm.SchedListDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
   os: TSchedListItem;
   itemBmp: TBitmap;
   k: integer;
   b: boolean;
   tl, tr, d_w, t_w: integer;
   d_s, t_s: string;
begin
   os := TSchedListItem(SchedList.Items.Objects[index]);

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

         tl := 5 + 18;
         tr := 5;

         Font.Name := 'Arial';
         Font.Size := 7;

         if (os.datetime > 0) then
         begin
            d_s := DateToStr(os.datetime);
            t_s := TimeToStr(os.datetime);
         end;

         d_w := TextWidth(d_s);
         t_w := TextWidth(t_s);

         tr := tr + d_w;

         TextOut(itemBmp.Width - tr, 11, d_s);
         TextOut(itemBmp.Width - tr + (d_w - t_w) div 2, 21, t_s);

         TextOut(tl, 19, trimText(itemBmp.Canvas, (itemBmp.Width - tl - tr), os.timeOfDay));
         TextOut(tl, 29, trimText(itemBmp.Canvas, (itemBmp.Width - tl - tr), os.dayOfType));

         Font.Name := 'MS Sans Serif';
         Font.Size := 8;

         tr := tr + 3;

         drawIcon(itemBmp.Canvas, ImageList3, (odSelected in State), 3, 5, os.typ);
         TextOut(tl, 5, trimText(itemBmp.Canvas, (itemBmp.Width - tl - tr), os.comm));
      end;

      SchedList.Canvas.Draw(Rect.Left, Rect.Top, itemBmp);
      if (odFocused in State) then
         SchedList.Canvas.DrawFocusRect(Rect);
   finally
      itemBmp.Free;
   end;
end;

function TMainForm.trimText(canvas: TCanvas; w: integer; s: string): string;
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

procedure TMainForm.drawIcon(canvas: TCanvas; imageList: TImageList; isSel:Boolean; x, y, index, color_no_sel, color_sel: integer);
var
   icoInv: TBitmap;
   c: integer;
begin
   c := color_no_sel;
   if isSel then
   begin
      c := $00feffff;
      if (color_sel > -1) then
         c := color_sel;
   end;

   icoInv := TBitmap.Create;
   try
      icoInv.Transparent := true;
      imageList.GetBitmap(index, icoInv);
      if (c > -1) then
         inverIcon(icoInv, c);
      canvas.Draw(x, y, icoInv);
   finally
      icoInv.Free;
   end;
end;

procedure TMainForm.inverIcon(bmp: TBitmap; toColor: integer);
var
   kx, ky: integer;
begin
   for ky:= 0 to bmp.Height - 1 do
      for kx:= 0 to bmp.Width - 1 do
         if (bmp.Canvas.Pixels[kx, ky] = 0) then
            bmp.Canvas.Pixels[kx, ky] := toColor;
end;

procedure TMainForm.N15Click(Sender: TObject);
begin
   if (SchedDialog.showDialog(nil)) then
      schedLoad;
end;

procedure TMainForm.N7Click(Sender: TObject);
begin
   if (SchedList.ItemIndex = -1) then exit;

   if (SchedDialog.showDialog(TSchedListItem(SchedList.Items.Objects[SchedList.ItemIndex]))) then
      schedLoad;
end;

procedure TMainForm.N14Click(Sender: TObject);
begin
   if (SchedList.ItemIndex = -1) then exit;

   SchedDialog.Tag := TSchedListItem(SchedList.Items.Objects[SchedList.ItemIndex]).id;
   SchedDialog.Button1Click(nil);
end;

procedure TMainForm.Timer2Timer(Sender: TObject);
begin
   schedLoad;
end;

procedure TMainForm.N18Click(Sender: TObject);
begin
   if (SchedList.ItemIndex = -1) then exit;

   SchedDialog.Memo2.Text := TSchedListItem(SchedList.Items.Objects[SchedList.ItemIndex]).action;
   SchedDialog.SpeedButton1Click(nil);
end;

procedure TMainForm.VarPopupMenuPopup(Sender: TObject);
var
   o: TVarListItem;
begin
   if (VarList.ItemIndex = -1) then
   begin
      VarPopupItem1.Enabled := false;
      VarPopupItem2.Enabled := false;
      VarPopupItem3.Enabled := false;

      VarPopupItem4.Enabled := false;
      VarPopupItem5.Enabled := false;
      VarPopupItem6.Enabled := false;
      exit;
   end;
   o := TVarListItem(VarList.Items.Objects[VarList.ItemIndex]);

   VarPopupItem1.Enabled := (o.value = 0);
   VarPopupItem2.Enabled := (o.value = 0);
   VarPopupItem3.Enabled := (o.value = 0);

   VarPopupItem4.Enabled := (o.value = 1);
   VarPopupItem5.Enabled := (o.value = 1);
   VarPopupItem6.Enabled := (o.value = 1);
end;

procedure TMainForm.SchedListMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   i: integer;
begin
   i := SchedList.ItemAtPos(Point(X, Y), false);
   if (i > -1) then
      SchedList.ItemIndex := i;
end;

procedure TMainForm.MediaListMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   i: integer;
begin
   if (Button = mbRight) then
   begin
      i := MediaList.ItemAtPos(Point(X, Y), false);
      if (i > -1) then
         MediaList.ItemIndex := i;
   end;
end;

procedure TMainForm.VLC1Click(Sender: TObject);
begin
   VlcForm.Show;
end;

procedure TMainForm.N4Click(Sender: TObject);
begin
   PropertysForm.SpeedButton6Click(nil);
end;

procedure TMainForm.N8Click(Sender: TObject);
begin
   CoolTrayIcon1Click(nil);
end;

procedure TMainForm.CoolTrayIcon1Click(Sender: TObject);
begin
   if (MainForm.Visible) then
      CoolTrayIcon1.HideMainForm
   else
      CoolTrayIcon1.ShowMainForm;
end;

procedure TMainForm.PopupMenu3Popup(Sender: TObject);
var
   k: integer;
   mi: TMenuItem;
   mg: TMediaGroupItem;
begin
   TransferMenu.Clear;
   for k:= 0 to Length(fSessions) - 1 do
   begin
      if ((fSessions[k][2] <> 'None') and (fSessions[k][0] <> IntToStr(fAppID))) then
      //if (fSessions[k][2] <> 'None') then
      begin
         mi:= TMenuItem.Create(nil);
         mi.Caption := fSessions[k][1];
         mi.Tag := StrToInt(fSessions[k][0]);
         mi.OnClick := transferMedia;
         TransferMenu.Add(mi);
      end;
   end;

   if (TransferMenu.Count = 0) then
   begin
      mi:= TMenuItem.Create(nil);
      mi.Caption := '�����';
      mi.Enabled := false;
      TransferMenu.Add(mi);
   end;

   MediaGroupAdd.Clear;
   for k:= 0 to ComboBox1.Items.Count - 1 do
   begin
      if (ComboBox1.Items.Objects[k] <> nil) then
      begin
         mg:= TMediaGroupItem(ComboBox1.Items.Objects[k]);
         if (mg.typ > 0) then
         begin
            mi:= TMenuItem.Create(nil);
            mi.Caption := mg.comm;
            mi.Tag := mg.id;
            mi.OnClick := MediaGroupAddClick;
            MediaGroupAdd.Add(mi);
         end;
      end;
   end;  


end;

procedure TMainForm.AddMediaListButtonClick(Sender: TObject);
var
   s: string;
   id: integer;
begin
   if (InputQuery('�������� ������ ���������', '��������:', s)) then
   begin
      id := StrToInt(metaQuery('edit groups list', '-1' + chr(1) + s)[0][0]);
      //loadMediaGroups(-1);
   end;
end;

procedure TMainForm.N26Click(Sender: TObject);
var
   s: string;
   mg: TMediaGroupItem;
begin
   if (ComboBox1.ItemIndex = -1) then exit;
   if (ComboBox1.Items.Objects[ComboBox1.ItemIndex] = nil) then exit;
   mg := TMediaGroupItem(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
   if (mg.id = -1) then exit;
   s := ComboBox1.Text;
   if (InputQuery('�������������� �������� ���������', '��������:', s)) then
   begin
      metaQuery('edit groups list', IntToStr(mg.id) + chr(1) + s);
      //loadMediaGroups(-1);
   end;
end;

procedure TMainForm.N27Click(Sender: TObject);
var
   mg: TMediaGroupItem;
begin
   if (ComboBox1.ItemIndex = -1) then exit;
   if (ComboBox1.Items.Objects[ComboBox1.ItemIndex] = nil) then exit;
   mg := TMediaGroupItem(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
   if (mg.id = -1) then exit;
   if (MessageDlg('������� �������� "' + ComboBox1.Text + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
   begin
      metaQuery('del groups list', IntToStr(mg.id));
      //loadMediaGroups(-1);
   end;
end;

procedure TMainForm.loadMediaCross;
var
   res: TDataRec;
   k: integer;
begin
   if (ComboBox1.ItemIndex = -1) then exit;
   if (ComboBox1.Items.Objects[ComboBox1.ItemIndex] = nil) then exit;
   
   res := metaQuery('get groups cross', IntToStr(TMediaGroupItem(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).id));
   SetLength(fMediaGroupCross, Length(res));
   for k:= 0 to Length(res) - 1 do
      fMediaGroupCross[k] := StrToInt(res[k][0]);
   freeDataRec(res);
end;

procedure TMainForm.MediaGroupAddClick(Sender: TObject);
var
   mo: TMediaListItem;
   k: integer;
begin
   for k:= 0 to MediaList.Count - 1 do
   begin
      if (MediaList.Selected[k]) then
      begin
         mo := TMediaListItem(MediaList.Items.Objects[k]);
         metaQuery('add groups cross', IntToStr(mo.id) + chr(1) + IntToStr(TMenuItem(Sender).Tag), true);
      end;
   end;

   if ((ComboBox1.Items.Objects[ComboBox1.ItemIndex] <> nil) and (TMediaGroupItem(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).id = -1)) then
      ComboBox1Change(nil);
end;

procedure TMainForm.MediaGroupDelClick(Sender: TObject);
var
   mo: TMediaListItem;
   mg: TMediaGroupItem;
   k: integer;
begin
   if (ComboBox1.Items.Objects[ComboBox1.ItemIndex] = nil) then
   begin
      MessageDlg('���������� ��������� ���������� �������� ������.', mtWarning, [mbOk], 0);
      exit;
   end;
   mg := TMediaGroupItem(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
   for k:= 0 to MediaList.Count - 1 do
   begin
      if (MediaList.Selected[k]) then
      begin
         mo := TMediaListItem(MediaList.Items.Objects[k]);
         metaQuery('del groups cross', IntToStr(mo.id) + chr(1) + IntToStr(mg.id), true);
      end;
   end;
end;

procedure TMainForm.loadMediaGroups(id: integer);
var
   res: TDataRec;
   k, i, prev_id: integer;
   mg: TMediaGroupItem;
begin
   i := ComboBox1.ItemIndex;
   if ((i > -1) and (ComboBox1.Items.Objects[i] <> nil)) then
      prev_id := TMediaGroupItem(ComboBox1.Items.Objects[i]).id;

   if (id = -1) then
      id := prev_id;

   setLength(res, 0);
   ComboBox1.Items.BeginUpdate;
   ComboBox1.Clear;
   ComboBox1.AddItem('��� �����', nil);
   ComboBox1.AddItem('������ �����', nil);
   ComboBox1.AddItem('������ ������', nil);
   ComboBox1.AddItem('������ ����������', nil);

   mg:= TMediaGroupItem.Create();
   mg.id := -1;
   mg.typ := 0;
   ComboBox1.AddItem('�� ���������� � ���������', mg);

   res := metaQuery('get groups list', '');
   for k := 0 to Length(res) - 1 do
   begin
      mg:= TMediaGroupItem.Create();
      mg.id := StrToInt(res[k][0]);
      mg.typ := 1;// StrToInt(res[k][1]);
      mg.comm := res[k][2];
      ComboBox1.AddItem(mg.comm, mg);
      if (mg.id = id) then
         i := ComboBox1.Items.Count - 1;
   end;
   freeDataRec(res);
   if (i > -1) then
      ComboBox1.ItemIndex := i
   else
      ComboBox1.ItemIndex := 0;
   ComboBox1.Items.EndUpdate;

   if (id <> prev_id) then
      ComboBox1Change(nil);
end;

procedure TMainForm.ComboBox1DrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
   itemBmp: TBitmap;
   tl, tr: integer;
begin
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

         if (ComboBox1.Items.Objects[Index] <> nil) then
         begin
            if (TMediaGroupItem(ComboBox1.Items.Objects[Index]).id = -1) then
            begin
               Pen.Color := clBlack;
               MoveTo(0, itemBmp.Height - 1);
               LineTo(itemBmp.Width, itemBmp.Height - 1);
            end;
         end;

         tl := 5;
         tr := 5;

         Font.Style := [];
         TextOut(tl, 1, trimText(itemBmp.Canvas, itemBmp.Width - tl - tr, ComboBox1.Items[Index]));
      end;

      ComboBox1.Canvas.Draw(Rect.Left, Rect.Top, itemBmp);
      if (odFocused in State) then
         ComboBox1.Canvas.DrawFocusRect(Rect);
   finally
      itemBmp.Free;
   end;
end;

procedure TMainForm.N12Click(Sender: TObject);
var
   mo: TMediaListItem;
begin
   if (MediaList.ItemIndex = -1) then exit;
   mo := TMediaListItem(MediaList.Items.Objects[MediaList.ItemIndex]);
   MediaInfoDialog.Tag := mo.id;
   MediaInfoDialog.Edit1.Text := mo.title;
   MediaInfoDialog.Label3.Caption := mo.file_name;
   MediaInfoDialog.ShowModal;
end;

procedure TMainForm.ActionSelAllExecute(Sender: TObject);
begin
   case currView of
      100:
      begin
         MediaList.Items.BeginUpdate;
         MediaList.SelectAll;
         MediaList.Items.EndUpdate;
      end;
   end;
end;

procedure TMainForm.updatePlayLoopButtonIcon;
begin
   with PlayLoopButton do
   begin
      Glyph.Canvas.Pen.Color := clFuchsia;
      Glyph.Canvas.Brush.Color := clFuchsia;
      Glyph.Canvas.Rectangle(0, 0, Glyph.Width, Glyph.Height);
   end;

   case PlayLoopButton.Tag of
      0, 1: ImageList2.GetBitmap(4, PlayLoopButton.Glyph);
      2: ImageList2.GetBitmap(5, PlayLoopButton.Glyph);
   end;
   PlayLoopButton.Repaint;
   PlayLoopButton.Down := PlayLoopButton.Tag <> 0;   
end;

procedure TMainForm.PlayLoopButtonMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
   i: integer;
begin
{   i := PlayLoopButton.Tag;
   inc(i);
   if (i > 2) then
      i := 0;
   PlayLoopButton.Tag := i;

   case i of
      0:
      begin
         saveProp('VlcPlayLoop', '')
      end;
      1:
      begin
         saveProp('VlcPlayLoop', 'loop')
      end;
      2:
      begin
         saveProp('VlcPlayLoop', 'shufle')
      end;
   end;
   updatePlayLoopButtonIcon;}
end;

procedure TMainForm.SpeedButton8Click(Sender: TObject);
begin
   playMediaNextItem;
end;

procedure TMainForm.freeDataRec(dr: TDataRec);
var
   k: integer;
begin
   for k:= 0 to Length(dr) - 1 do
      SetLength(dr[k], 0);
   SetLength(dr, 0);
end;

end.

