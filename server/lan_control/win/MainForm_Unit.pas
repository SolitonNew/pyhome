unit MainForm_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DlgMessagesRU, CoolTrayIcon, ScktComp, StdCtrls, ExtCtrls, ToolWin,
  DataRec_Unit, ComCtrls, Buttons, ImgList, Menus, ShellApi,
  ACS_Classes, ACS_WinMedia, ACS_smpeg, ACS_Wave, ACS_DXAudio, ActnList,
  OleCtrls, AXVLC_TLB, http, SyncObjs;

const
   MEDIA_END = WM_USER + 1;
   SHOW_CAM_ALERT_MESS = WM_USER + 10;
   HIDE_CAM_ALERT_MESS = WM_USER + 11;
   HIDE_CAM_ALL_MESS = WM_USER + 12;

type
   //TDataRec = array of array of string;

   TVarListItem = class
      id:integer;
      name:string;
      comm:string;
      typ:integer;
      value: Double;
      group_id: integer;      
      link_id: integer;
      link_value: Double;
   end;

   TVarGroupItem = class
      id, parent_id: integer;
      name: string;
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

  TMainForm = class(TForm)
    CoolTrayIcon1: TCoolTrayIcon;
    Timer1: TTimer;
    Panel2: TPanel;
    SpeedButton1: TSpeedButton;
    SocketMeta: TClientSocket;
    SpeedButton3: TSpeedButton;
    SpeedButton5: TSpeedButton;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N3: TMenuItem;
    SpeedButton9: TSpeedButton;
    MediaPanel: TPanel;
    Panel5: TPanel;
    FilterEdit: TEdit;
    VarList: TListBox;
    MediaList: TListBox;
    InfoPanel: TPanel;
    InfoLabel: TLabel;
    Panel6: TPanel;
    ComboBox1: TComboBox;
    ImageList2: TImageList;
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
    DXAudioOut1: TDXAudioOut;
    WaveIn1: TWaveIn;
    Timer3: TTimer;
    MP3In1: TMP3In;
    DXAudioOut2: TDXAudioOut;
    SpeedButton2: TSpeedButton;
    Panel8: TPanel;
    Panel1: TPanel;
    Label1: TLabel;
    Panel4: TPanel;
    SpeedButton10: TSpeedButton;
    VolumePanel: TPanel;
    VolumeShape: TShape;
    Panel7: TPanel;
    PlayButton: TSpeedButton;
    PauseButton: TSpeedButton;
    StopButton: TSpeedButton;
    PlayNextButton: TSpeedButton;
    PlayLoopButton: TSpeedButton;
    Bevel1: TBevel;
    TimePanel: TPanel;
    TimeShape: TShape;
    TimeLabel: TLabel;
    Panel3: TPanel;
    SpeedButton6: TSpeedButton;
    MediaVolPanel: TPanel;
    MediaVolShape: TShape;
    CamAlertBtn: TSpeedButton;
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
    procedure TimePanelResize(Sender: TObject);
    procedure TimePanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TimePanelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure TimePanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MediaVolPanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MediaVolPanelMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure MediaVolPanelMouseUp(Sender: TObject; Button: TMouseButton;
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
    procedure PlayNextButtonClick(Sender: TObject);
    procedure DXAudioOut1Done(Sender: TComponent);
    procedure Timer3Timer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure DXAudioOut2Done(Sender: TComponent);
    procedure Panel7Resize(Sender: TObject);
    procedure CamAlertBtnClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Label1DblClick(Sender: TObject);
  private
    fHTTPServer: TTCPHttpDaemon;

    fMediaPlayFileID: integer;
    fMediaPlayFileType: integer;
    //fSpeach: TSpeach;
    fQuietTime: integer;
    fSpeachList: TStringList;
    fSocketMetaBufer: string;
    fTimePanelDown: Boolean;

    fSessionMediaState: integer;
    fSessionMediaID: integer;

    fMediaGroupCross: array of integer;

    fMiniPlayer: TVLCPlugin2;
    fMiniPlayerState: integer;
    fMiniPlayerLen: integer;
    fMiniPlayerPos: integer;
    fMiniPlayerFullscreen: boolean;

    procedure setStatusText(text:String);
    procedure refreshVarList();
    procedure refreshMediaList();
    function currView:integer;
    procedure sendVarValue(id:integer; val:Double);
    procedure setVolume();
    procedure setMediaVolume();
    procedure timeSeek;
    function checkAppatId(id: integer):Boolean;
    procedure transferMedia(Sender:TObject);
    procedure startMediaPlay(id: integer; withPause: boolean; seek: integer; blockWarning: boolean = false);

    procedure vlcOnChange(sender:TObject);
    procedure vlcOnPlayPosEvent(sender:TObject; pos, len: integer);
    procedure vlcOnStopEvent(Sender: TObject);

    procedure mp3OnChange(sender:TObject);
    procedure mp3OnPlayPosEvent(sender:TObject; pos, len: integer);
    procedure mp3OnStopEvent(Sender: TObject);
    
    procedure updateTimePanel();
    procedure playMediaNextItem();

    procedure startLoad();
    //procedure syncLoad();
    procedure syncLoadAsync();
    procedure firstRun();

    procedure syncHandler(res: TDataRec);
    procedure queueHandler(res: TDataRec);
    procedure sessionHandler(res: TDataRec);
    procedure mediaHandler(res: TDataRec);

    procedure clearList(ls:TList);
    procedure clearStrings(ls:TStrings);
    function trimText(canvas: TCanvas; w:integer; s: string):string;
    procedure drawIcon(canvas:TCanvas; imageList: TImageList; isSel:Boolean; x, y, index:integer; color_no_sel:integer = -1; color_sel:integer = -1);
    procedure inverIcon(bmp:TBitmap; toColor: integer);

    procedure loadMediaGroups(id: integer);
    procedure loadMediaCross();

    procedure updatePlayLoopButtonIcon();

    function checkSpechData(id: string): Boolean;

    procedure playMiniPlayer(id, typ: integer; url: string; withPause:boolean = false; seek: integer = 0);
    procedure pauseMiniPlayer();
    procedure stopMiniPlayer();

    procedure VLCPlugin21MediaPlayerLengthChanged(ASender: TObject; length: Integer);
    procedure VLCPlugin21MediaPlayerPlaying(Sender: TObject);
    procedure VLCPlugin21MediaPlayerPaused(Sender: TObject);
    procedure VLCPlugin21MediaPlayerStopped(Sender: TObject);
    procedure VLCPlugin21MediaPlayerTimeChanged(ASender: TObject; time: Integer);
  protected
    procedure WMGetSysCommand(var message : TMessage); message WM_SYSCOMMAND;
    procedure MEDIA_END_MESS(var Message: TMessage); message MEDIA_END;
    procedure SHOW_CAM_ALERT(var Message: TMessage); message SHOW_CAM_ALERT_MESS;
    procedure HIDE_CAM_ALERT(var Message: TMessage); message HIDE_CAM_ALERT_MESS;
    procedure HIDE_CAM_ALL(var Message: TMessage); message HIDE_CAM_ALL_MESS;
  public
    fAppID: integer;
    fItemList: TList;
    fVarGroupList: TList;
    fMediaList: TList;
    fSessions:TDataRec;
    fPlayOnlyVLC: boolean;
    fCameraAlertIds: array of integer;

    function metaQuery(pack_name, pack_data: string; blokMessages: boolean = false): TDataRec;
    function getMediaAtId(id: integer): TMediaListItem;

    procedure sendMediaState(state: string; id, time: integer);
    procedure playMediaPlayAt(index: integer; blockWarning: boolean = false);
    procedure schedLoad();

//    procedure syncSpeachThread();
  end;

var
  MainForm: TMainForm;
  CS: TCriticalSection;

implementation

uses StrUtils, PropertysForm_Unit, RegForm_Unit,
  Types, DateUtils, SchedDialog_Unit,
  MediaInfoDialog_Unit, AlertForm_Unit, Mp3Player_Unit, Math,
  CamDisplay_Unit, CamAlertDiaplay_Unit;

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
var
   s: string;
   b: boolean;
begin
   CS:= TCriticalSection.Create;

   fVarGroupList := TList.Create;
   fSpeachList:= TStringList.Create;
   //fSpeach:= TSpeach.Create;

   Randomize;

   //saveProp('ID', '');
   InfoPanel.Align := alClient;
   
   MediaPanel.Align := alClient;
   //MediaList.DoubleBuffered := true;

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

   if (Width > Screen.Width div 2) then Width := Screen.Width div 2;
   if (Height > Screen.Height) then Height := Screen.Height;
   if (Left > Screen.Width - Width) then Left := Screen.Width - Width;
   if (Top < 0) then Top := 0;

   try
      VolumeShape.Width := (VolumePanel.ClientWidth) * StrToInt(loadProp('Volume')) div 100;
   except
   end;

   try
      MediaVolShape.Width := (MediaVolPanel.ClientWidth) * StrToInt(loadProp('MediaVolume')) div 100;
   except
   end;

   CamAlertBtn.Down := (loadProp('ShowCamAlert') = 'true');

   fPlayOnlyVLC := loadProp('PlayOnlyVlc') = 'True';

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
   Timer2.Enabled := true;

   setStatusText('Запуск');

   updateTimePanel;

   fHTTPServer:= TTCPHttpDaemon.Create;   
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
   k: integer;
begin
   stopMiniPlayer;

   fHTTPServer.Terminate;

   Timer2.Enabled := false;   
   Timer1.Enabled := false;
   SocketMeta.Close;

   if fPlayOnlyVLC then
      saveProp('PlayOnlyVlc', 'True')
   else
      saveProp('PlayOnlyVlc', 'False');
   saveProp('Left', IntToStr(Left));
   saveProp('Top', IntToStr(Top));
   saveProp('Width', IntToStr(Width));
   saveProp('Height', IntToStr(Height));
   saveProp('Volume', IntToStr(VolumeShape.Width * 100 div VolumePanel.ClientWidth));
   if (not SpeedButton6.Down) then
      setMediaVolume();

   clearList(fMediaList);
   fMediaList.Free;
   clearList(fItemList);
   fItemList.Free;

   clearStrings(SchedList.Items);
   clearStrings(ComboBox1.Items);


   //fSpeach.Terminate;
   //fSpeach.Free;

   fSpeachList.Free;

   DXAudioOut1.Stop(true);
   while DXAudioOut1.Status <> tosIdle do
      Sleep(10);

   DXAudioOut2.Stop(true);
   while DXAudioOut2.Status <> tosIdle do
      Sleep(10);

   fSessions.Free;
   clearList(fVarGroupList);
   fVarGroupList.Free;

   CS.Free;
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
            //syncLoad();
            syncLoadAsync();
         end;
   finally
      Timer1.Enabled := true;
   end;

   Label1.Visible := fQuietTime = 1;
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

procedure TMainForm.refreshVarList;
var
   k, t, i: integer;
   lb: string;
   o:TVarListItem;
   ok: Boolean;
   topIndex: integer;
begin
   t := currView();

   VarList.Items.BeginUpdate;
   topIndex := VarList.TopIndex;
   i := 0;
   for k:= 0 to fItemList.Count - 1 do
   begin
      o := TVarListItem(fItemList[k]);
      lb := o.comm + ' [' + FloatToStr(o.value) + ']';

      ok := False;
      case t of
         1: ok := (o.typ in [1, 3]); // Свет, Розетки
         4: ok := (o.typ in [4, 5, 10]); // Термометр, Термостат, Влажнометр
         7: ok := (o.typ in [7, 11, 13]); // Вентиляторы, Датчик СО, Атм. давление
      end;

      if (ok) or (o.id = -1) then
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
      
   VarList.TopIndex := topIndex;
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
      200: t := 3;
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
         if (Sender <> nil) then
            VarList.TopIndex := 0;      
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
      3:
      begin
         {if (MainForm.Visible) then
            CamList.SetFocus;
         if (CamDisplay.Visible = False) then
            loadCamList();}
      end;
   end;

   if (t <> 3) then
   begin
      Application.ProcessMessages;
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
   syncHandler(metaQuery('setvar', p));
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
         if ((odSelected in State) and (o.id <> -1)) then
         begin
            Pen.Color := $00777777;
            Brush.Color := $00777777;
            Font.Color := clWhite;
         end
         else
         begin
            Pen.Color := clWhite;
            Brush.Color := clWhite;
            Font.Color := clBlack;
         end;
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

            4, 5, 10, 11, 13:
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
                        v := v + '°C';

                        if (o.link_id > 0) then
                        begin
                           v := '<' + IntToStr(trunc(o.link_value)) + '>    ' + v;
                        end;                        
                     end;
                     5:
                     begin
                        v := IntToStr(trunc(o.value)) + '°C';
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
                     13:
                     begin
                        v := FloatToStr(o.value) + 'mm';
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
                  ImageList1.Draw(bmp.Canvas, 0, -12 * trunc(o.value / 2), 1);
                  Draw(itemBmp.Width - 5 - 29, 6, bmp);
               finally
                  bmp.Free;
               end;
            end;

            else
               if (o.id = -1) then
               begin
                  Font.Color := clSilver;
                  tl := (itemBmp.Width - TextWidth(o.comm)) div 2;
                  Pen.Color := clSilver;
                  MoveTo(5, 12);
                  LineTo(tl - 10, 12);
                  MoveTo(tl + TextWidth(o.comm) + 10, 12);
                  LineTo(itemBmp.Width - 5, 12);
               end;
         end;

         Font.Size := 8;
         Font.Style := [];
         if (o.typ = 10) then
            Font.Style := Font.Style + [fsItalic];
         if (o.id = -1) then
            Font.Style := Font.Style + [fsBold];
         TextOut(tl, 5, trimText(itemBmp.Canvas, itemBmp.Width - tl - tr, o.comm));
         Font.Style := [];
      end;

      VarList.Canvas.Draw(Rect.Left, Rect.Top, itemBmp);
   finally
      itemBmp.Free;
   end;
   if (odFocused in State) then
      DrawFocusRect(VarList.Canvas.Handle, Rect);
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
   DXAudioOut1.Tag := -4000 + v * 40;
   DXAudioOut1.Volume := DXAudioOut1.Tag;
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
            if (o.link_id > 0) then
            begin
               v := trunc(o.link_value);
               if (Key = 37) then
                  dec(v);
               if (Key = 39) then
                  inc(v);
               if (v < 10) then
                  v := 10;
               if (v > 40) then
                  v := 40;
               if (v <> trunc(o.link_value)) then
                  sendVarValue(o.link_id, v);
            end;
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
   CanClose := ((fAppID = -1) or (MessageDlg('Вы хотите выйти из програмы и потерять контроль над домом?', mtConfirmation, [mbYes, mbNo], 0) = mrYes));
   if (CanClose) then
   begin
      hideAllCamAlerts;
      hideCamAll;
   end;
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
   p_top: integer;
begin
   p_top := MediaList.TopIndex;
   i := 0;
   MediaList.Items.BeginUpdate;
   try
      MediaList.Items.Clear();

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

   if (fMediaPlayFileID > -1) then
   begin
      for k := 0 to MediaList.Count - 1 do
      begin
         om := TMediaListItem(MediaList.Items.Objects[k]);
         if (om.id = fMediaPlayFileID) then
         begin
            i := k;
            break;
         end;
      end;

      c := MediaList.ClientHeight div MediaList.ItemHeight;
      if ((i < p_top) or (i > p_top + c - 1)) then
      begin
         i := i - c + 1;
         MediaList.TopIndex := i;
      end
      else
         MediaList.TopIndex := p_top;
   end;
end;

procedure TMainForm.FilterEditChange(Sender: TObject);
begin
   refreshMediaList;
   if (FilterEdit.Text = '') then
      FilterEdit.Color := clWindow
   else
      FilterEdit.Color := clYellow;
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
   ps: integer;
begin
   om := TMediaListItem(MediaList.Items.Objects[index]);
   if (om = nil) then exit;
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
         if (om.id = fMediaPlayFileID) then
         begin
            if (fMediaPlayFileType = 2) and not fPlayOnlyVLC then
               ps := Mp3Player.playState
            else
               ps := fMiniPlayerState;
               
            Font.Style := [fsBold];
            tl := 5;
            if (ps in [2, 3]) then
            begin
               drawIcon(itemBmp.Canvas, ImageList2, (odSelected in State), 1, 4, ps - 1);
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
   pl, pp: integer;
   isBuffering: Boolean;
begin
   if (Mp3Player = nil) then exit;

   isBuffering := False;
   if (fMediaPlayFileType = 2) and not fPlayOnlyVLC then
   begin
      pl := Mp3Player.playLen;
      pp := Mp3Player.playPos;
   end
   else
   begin
      pl := fMiniPlayerLen;
      pp := fMiniPlayerPos;
   end;

   if (not fTimePanelDown) then
   begin
      if (pl > 0) then
      begin
         TimeShape.Width := round(pp * (TimePanel.ClientWidth - 2) / pl);
      end
      else
         TimeShape.Width := 0;
   end;

   ts1 := DateTimeToTimeStamp(Now());
   ts2 := ts1;

   ts1.Time := pp * 1000;
   ts2.Time := pl * 1000;
   if (pl < 1) then
      TimeLabel.Caption := ''
   else
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
   ps: integer;
begin
   if (fMediaPlayFileType = 2) and not fPlayOnlyVLC then
      ps := Mp3Player.playState
   else
      ps := fMiniPlayerState;

   if ((Button = mbLeft) and (ps in [2, 3])) then
   begin
      mx := x;
      if ((Sender = TimeShape) or (Sender = TimeLabel)) then
         mx := mx + TControl(Sender).Left; // + TimePanel.BorderWidth; 

      fTimePanelDown := true;
      TimeShape.Width := mx;
      updateTimePanel;
      //timeSeek();
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
         mx := mx + TControl(Sender).Left;// + TimePanel.BorderWidth;
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
         mx := mx + TControl(Sender).Left; // + TimePanel.BorderWidth;
      TimeShape.Width := mx;
      timeSeek();
      fTimePanelDown := false;
      //updateTimePanel;
   end;
end;

procedure TMainForm.timeSeek;
var
   v: integer;
begin
   if (fMediaPlayFileType = 2) and not fPlayOnlyVLC then
   begin
      Mp3Player.playPos := round((Mp3Player.playLen * TimeShape.Width) / (TimePanel.ClientWidth - 2));
   end
   else
   begin
      if (fMiniPlayer <> nil) then
      begin
         v := round((fMiniPlayerLen * TimeShape.Width) / (TimePanel.ClientWidth - 2)) * 1000;
         fMiniPlayer.input.time := v;
      end;
   end;
end;

procedure TMainForm.MediaVolPanelMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if (Sender = MediaVolShape) then
      inc(x, 2);

   if (ssLeft in Shift) then
   begin
      MediaVolShape.Width := x;
      setMediaVolume;
   end;
end;

procedure TMainForm.MediaVolPanelMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
   if (Sender = MediaVolShape) then
      inc(x, 2);

   if (ssLeft in Shift) then
   begin
      MediaVolShape.Width := x;
      setMediaVolume;
   end;
end;

procedure TMainForm.MediaVolPanelMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if (Sender = MediaVolShape) then
      inc(x, 2);

   if (ssLeft in Shift) then
   begin
      MediaVolShape.Width := x;
      setMediaVolume;
   end;
end;

procedure TMainForm.setMediaVolume;
var
   v: integer;
begin
   if (MediaVolShape.Width > MediaVolPanel.ClientWidth) then
      MediaVolShape.Width := MediaVolPanel.ClientWidth;

   v := round(MediaVolShape.Width * 100 / MediaVolPanel.ClientWidth);
   if (v < 1) then v := 1;
   if (v > 100) then v := 100;

   if (fMiniPlayer <> nil) then
      fMiniPlayer.audio.volume := v; 
   Mp3Player.volume := v;
   SpeedButton6.Down := true;

   saveProp('MediaVolume', IntToStr(v));
end;

procedure TMainForm.SpeedButton6Click(Sender: TObject);
begin
   if (not SpeedButton6.Down) then
   begin
      Mp3Player.volume := 0;
      if (fMiniPlayer <> nil) then
         fMiniPlayer.audio.volume := 0;
   end
   else
      setMediaVolume();
end;

function TMainForm.checkAppatId(id: integer): Boolean;
var
   k: integer;
   s_id: string;
begin
   Result := False;
   s_id := IntToStr(id);
   if (fSessions <> nil) then
   begin
      for k:= 0 to fSessions.Count - 1 do
      begin
         if (fSessions.val(k, 0) = s_id) then
         begin
            if (fSessions.val(k, 2) <> '') then
               Result := true;
            break;
         end;
      end;
   end;
end;

function TMainForm.metaQuery(pack_name, pack_data: string; blokMessages: boolean = false): TDataRec;
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
         Result := TDataRec.Create(s); // parceTable(s);
         break;
      end;
   end;
   if (not blokMessages) then
      Application.ProcessMessages;
end;

procedure TMainForm.transferMedia(Sender: TObject);
var
   s: string;
   ps: integer;
   pp: integer;
begin
   if (fMediaPlayFileType = 2) and not fPlayOnlyVLC then
   begin
      ps := Mp3Player.playState;
      pp := Mp3Player.playPos;
   end
   else
   begin
      ps := fMiniPlayerState;
      pp := fMiniPlayerPos;
   end;

   if (not (ps in [2, 3])) then
   begin
      MessageDlg('У вас не запущено проигрывание. Переводить нечего.', mtWarning, [mbOk], 0);
      exit;
   end;
   
   s := IntToStr(fMediaPlayFileID) + chr(1) + IntToStr(pp);
   metaQuery('media transfer', IntToStr(TMenuItem(Sender).Tag) + chr(1) + s).Free;
   if (ps = 2) then
      PauseButtonClick(nil);
end;

procedure TMainForm.sendMediaState(state: string; id, time: integer);
begin
   metaQuery('media state', state + ';' + IntToStr(id) + ';' + IntToSTr(time)).Free;
end;

procedure TMainForm.StopButtonClick(Sender: TObject);
begin
   StopButton.Tag := 1;
   Mp3Player.stop;
   stopMiniPlayer;
end;

procedure TMainForm.PauseButtonClick(Sender: TObject);
begin
   pauseMiniPlayer;
   Mp3Player.pause;
end;

procedure TMainForm.PlayButtonClick(Sender: TObject);
var
   ps: integer;
begin
   if (fMediaPlayFileType = 2) and not fPlayOnlyVLC then
      ps := Mp3Player.playState
   else
      ps := fMiniPlayerState;

   if (ps = 3) then
   begin
      PauseButtonClick(nil);
   end
   else
   begin
      StopButton.Tag := 1;
      playMediaPlayAt(MediaList.ItemIndex);
   end;
end;

procedure TMainForm.playMediaPlayAt(index: integer; blockWarning: boolean = false);
var
   id: integer;
begin
   if ((index > -1) and (index < MediaList.Count)) then
   begin
      TimeShape.Tag := 0;   
      id := TMediaListItem(MediaList.Items.Objects[index]).id;
      startMediaPlay(id, false, 0, blockWarning);
   end;
end;

procedure TMainForm.startMediaPlay(id: integer; withPause: boolean; seek: integer; blockWarning: boolean = false);
var
   fileName: string;
   om: TMediaListItem;
   k: integer;
   ip: string;
   comm: string;
   q: TDataRec;
begin
   StopButtonClick(nil);

   Application.ProcessMessages;

   om := getMediaAtId(id);
   if (om <> nil) then
   begin
      for k:= 0 to fSessions.Count - 1 do
      begin
         if (StrToInt(fSessions.val(k, 0)) = om.app_id) then
         begin
            comm := fSessions.val(k, 1);
            ip := fSessions.val(k, 2);
            break;
         end;
      end;
      
      if (ip <> '') then
      begin
         fMediaPlayFileID := id;
         fMediaPlayFileType := om.file_type;
         fileName := 'http://' + ip + ':' + IntToStr(http.httpPort) + '/' + IntToStr(id);
         if ((WideUpperCase(ExtractFileExt(om.file_name)) = '.MP3') and not fPlayOnlyVLC) then
         begin
            Mp3Player.play(id, om.file_type, fileName, om.title, withPause, seek);
         end
         else
         begin
            playMiniPlayer(id, om.file_type, fileName, withPause, seek)
         end;
      end
      else
         if (not blockWarning) then
         begin
            q := metaQuery('get app info', IntToStr(om.app_id));
            try
               comm := q.val(0, 0);
            finally
               q.Free;
            end;
            MessageDlg('Источник "' + comm + '" не включен. Включите источник "' + comm + '" и повторите операцию.', mtWarning, [mbOk], 0);
         end;
   end;
end;

procedure TMainForm.MediaListDblClick(Sender: TObject);
begin
   StopButtonClick(nil);
   PlayButtonClick(nil);
end;

procedure TMainForm.vlcOnChange(sender: TObject);
begin
   MediaList.Repaint;
   if (fMiniPlayerState = 2) then
      StopButton.Tag := 0;

   Panel7Resize(nil);
   AlphaBlend := (fMiniPlayer <> nil) and fMiniPlayer.video.fullscreen and (fMiniPlayerState = 2);
end;

procedure TMainForm.mp3OnChange(sender: TObject);
begin
   MediaList.Repaint;
   if (Mp3Player.playState = 2) then
      StopButton.Tag := 0;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
   if (not Assigned(Mp3Player.onChange)) then // Это проверка самого первого запуска приложения. 
   begin
      Mp3Player.onChange := mp3OnChange;
      Mp3Player.onPlayPosEvent := mp3OnPlayPosEvent;
      Mp3Player.onStopEvent := mp3OnStopEvent;

      updateTimePanel();

      SpeedButton1Click(nil);
      updatePlayLoopButtonIcon;

      CoolTrayIcon1.HideTaskbarIcon;

      setMediaVolume;      
   end;
end;

procedure TMainForm.vlcOnPlayPosEvent(sender: TObject; pos, len: integer);
begin
   updateTimePanel();
end;

procedure TMainForm.mp3OnPlayPosEvent(sender: TObject; pos, len: integer);
begin
   updateTimePanel();
end;

procedure TMainForm.playMediaNextItem;
var
   k, i: integer;
   ind: integer;
   l: TList;
begin
   l := TList.Create;
   try
      for k:= 0 to MediaList.Count - 1 do
      begin
         if (TMediaListItem(MediaList.Items.Objects[k]).id = fMediaPlayFileID) then
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
               for k := 0 to 10 do
               begin
                  i := trunc(random(l.Count));
                  ind := MediaList.Items.IndexOfObject(l[i]);
                  if (TMediaListItem(l[i]).id <> fMediaPlayFileID) then
                     break;
               end;
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
         saveProp('MediaPlayLoop', '')
      end;
      1:
      begin
         saveProp('MediaPlayLoop', 'loop')
      end;
      2:
      begin
         saveProp('MediaPlayLoop', 'shufle')
      end;
   end;
   updatePlayLoopButtonIcon;
end;

procedure TMainForm.vlcOnStopEvent(Sender: TObject);
begin
   if (PlayLoopButton.Tag > 0) then
      playMediaNextItem;
   Panel7Resize(nil);
end;

procedure TMainForm.mp3OnStopEvent(Sender: TObject);
begin
   if (PlayLoopButton.Tag > 0) then
      playMediaNextItem;
end;

procedure TMainForm.MediaListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if (Key = 32) then
      PauseButtonClick(nil);
end;

procedure TMainForm.startLoad;

   function getParentVarGroup(id: integer): integer;
   var
      k: integer;
   begin
      Result := -1;
      for k:= 0 to fVarGroupList.Count - 1 do
      begin
         if (TVarGroupItem(fVarGroupList[k]).id = id) then
         begin
            Result := TVarGroupItem(fVarGroupList[k]).parent_id;
            break;
         end;
      end;
   end;

   function getNameVarGroup(id: integer): string;
   var
      k: integer;
   begin
      Result := 'Остальное';
      for k:= 0 to fVarGroupList.Count - 1 do
      begin
         if (TVarGroupItem(fVarGroupList[k]).id = id) then
         begin
            Result := TVarGroupItem(fVarGroupList[k]).name;
            break;
         end;
      end;
   end;

   function compVarGroup(i1, i2: Pointer): integer;
   var
      id1, id2: integer;
      c1, c2: string;
   begin
      id1 := TVarListItem(i1).group_id;
      id2 := TVarListItem(i2).group_id;
      c1 := TVarListItem(i1).comm;
      c2 := TVarListItem(i2).comm;
      Result := 0;
      if (id1 > id2) then
         Result := 1
      else
      if (id1 < id2) then
         Result := -1
      else
      if (c1 > c2) then
         Result := 1
      else
      if (c1 < c2) then
         Result := -1;
   end;

var
   res: TDataRec;
   k, i: integer;
   o, o2: TVarListItem;
   vg: TVarGroupItem;
   om: TMediaListItem;
   mg: TMediaGroupItem;
   v: string;
begin
   addToMetaLog('start LOAD');

   clearList(fVarGroupList);
   res := metaQuery('load variable group', '');
   try
      for k := 0 to res.Count - 1 do
      begin
         vg := TVarGroupItem.Create();
         try
            vg.id := StrToInt(res.val(k, 0));
            vg.name := res.val(k, 1);
            if (res.val(k, 2) = 'None') then
               vg.parent_id := -1
            else
               vg.parent_id := StrToInt(res.val(k, 2));
            fVarGroupList.Add(vg);
         except
            vg.Free;
         end;
      end;
   finally
      res.Free;
   end;   

   clearList(fItemList);
   res := metaQuery('load variables', IntToStr(fAppID));
   try
      for k := 0 to res.Count - 1 do
      begin
         o:= TVarListItem.Create;
         try
            o.id := StrToInt(res.val(k, 0));
            o.name := res.val(k, 1);
            o.comm := res.val(k, 2);
            o.typ := StrToInt(res.val(k, 3));
            o.group_id := getParentVarGroup(StrToInt(res.val(k, 5)));
            v := res.val(k, 4);
            if (v = 'None') then
               v := '-9999';
            o.value := StrToFloat(StringReplace(v, '.', ',', [rfReplaceAll]));
            if (o.id = 123) then // QUIET_TIME
               fQuietTime := trunc(o.value);
            fItemList.Add(o);
         except
            o.Free;
         end;
      end;
   finally
      res.Free;
   end;

   // Выполняем линковку по группе и названию для термометров и темостатов

   for k := fItemList.Count - 1 downto 0 do
   begin
      o := TVarListItem(fItemList[k]);
      if (o.typ = 5) then // Нашли термостат
      begin
         for i := 0 to fItemList.Count - 1 do
         begin
            o2 := TVarListItem(fItemList[i]);
            if ((o2.typ = 4) and (o2.group_id = o.group_id) and (o2.comm = o.comm)) then
            begin
               o2.link_id := o.id;
               o2.link_value := o.value;
               o.Free;
               fItemList.Delete(k);
               break;
            end; 
         end;
      end;
   end;

   // Сортируем список переменных по группе

   fItemList.Sort(@compVarGroup);

   // Проставляем пустышки для индикации групп

   i := -9999;   
   for k := fItemList.Count - 1 downto 0 do
   begin
      o := TVarListItem(fItemList[k]);
      if ((i <> -9999) and (i <> o.group_id)) then
      begin
         o2 := TVarListItem.Create;
         try
            o2.id := -1;
            o2.comm := getNameVarGroup(i);
            fItemList.Insert(k + 1, o2);
         except
            o2.Free;
         end;
      end;
      i := o.group_id;
   end;

   // ------------------------------------

   refreshVarList();
   addToMetaLog('finish LOAD');

   // ------------------------------------------

   res := metaQuery('get media exts', '');
   try
      MediaExts := res.val(0, 0);
   finally
      res.Free;
   end;



   // ------------------------------------------
   res := metaQuery('get media folders', '');
   try
      if (res.Count > 0) then
         PropertysForm.ListBox1.Items.Text := res.val(0, 0);
   finally
      res.Free;
   end;
   setStatusText('Загрузка списка медиафайлов');

   // ------------------------------------------

   addToMetaLog('start MEDIA PACK');
   clearList(fMediaList);

   res := metaQuery('get media list', '');
   try
      for k := 0 to res.Count - 1 do
      begin
         om:= TMediaListItem.Create;
         try
            om.id := StrToInt(res.val(k, 0));
            om.app_id := StrToInt(res.val(k, 1));
            om.title := res.val(k, 2);
            om.file_name := res.val(k, 3);
            om.file_type := StrToInt(res.val(k, 4));
            fMediaList.Add(om);
         except
            om.Free;
         end;
      end;
   finally
      res.Free;
   end;
   refreshMediaList();
   addToMetaLog('finish MEDIA PACK');
   setStatusText('Сканирование медиафайлов');
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

   // --------------------------------------------
end;

{procedure TMainForm.syncLoad;
var
   res: TDataRec;
   k, i: integer;
   om: TMediaListItem;
   s, s2: string;
   sl: TStringList;
begin
   syncPack(metaQuery('sync', ''));

   // --------------------------------------------

   res := metaQuery('exe queue', '');
   try
      if (res.Count > 0) then
      begin
         for k:= 0 to res.Count - 1 do
         begin
            if (res.val(k, 1) = 'speech') then
            begin
               s := res.val(k, 4);
               s2 := res.val(k, 3);
               AlertForm_Unit.show(s, s2);
               checkSpechData(s2);
               checkSpechData(res.val(k, 2));
               if ((SpeedButton10.Down) and (fQuietTime = 0)) or (s2 = 'alarm') then
               begin
                  fSpeachList.Add(s2);
                  fSpeachList.Add(res.val(k, 2));
               end;
            end
            else
            if (res.val(k, 1) = 'play') then
            begin
               s := res.val(k, 4);
               s2 := GetEnvironmentVariable('TEMP') + '\audio\' + s;
               checkSpechData(s);
               if (MP3In1.FileName = '') and (FileExists(s2)) and (ExtractFileExt(WideUpperCase(s)) = '.MP3') then
               begin
                  MP3In1.FileName := s2;
                  DXAudioOut2.Run;
               end               
            end;
         end;
      end;
   finally
      res.Free;
   end;

   // --------------------------------------------

   res := metaQuery('sessions', '');
   if (fSessions <> nil) then
      FreeAndNil(fSessions);
   fSessions := res;
   MediaList.Repaint;

   // --------------------------------------------

   res := metaQuery('media queue', '');
   try
      if (res.Count > 0) then
      begin
         for k:= 0 to res.Count - 1 do
         begin
            case StrToInt(res.val(k, 1)) of
               0:
               begin
                  om:= TMediaListItem.Create;
                  try
                     om.id := StrToInt(res.val(k, 2));
                     om.app_id := StrToInt(res.val(k, 4));
                     om.title := res.val(k, 5);
                     om.file_name := res.val(k, 6);
                     om.file_type := StrToInt(res.val(k, 7));
                     fMediaList.Add(om);
                  except
                     om.Free;
                  end;
               end;
               1:
               begin
                  for i:= 0 to fMediaList.Count - 1 do
                  begin
                     om:= TMediaListItem(fMediaList[i]);
                     if (om.id = StrToInt(res.val(k, 2))) then
                     begin
                        om.id := StrToInt(res.val(k, 2));
                        om.app_id := StrToInt(res.val(k, 4));
                        om.title := res.val(k, 5);
                        om.file_name := res.val(k, 6);
                        om.file_type := StrToInt(res.val(k, 7));
                        break;
                     end;
                  end;
               end;
               2:
               begin
                  for i:= 0 to fMediaList.Count - 1 do
                  begin
                     om:= TMediaListItem(fMediaList[i]);
                     if (om.id = StrToInt(res.val(k, 2))) then
                     begin
                        fMediaList.Delete(i);
                        break;
                     end;
                  end;
               end;

               10: // Transfer media
               begin
                  StopButton.Tag := 1;
                  startMediaPlay(StrToInt(res.val(k, 2)), true, StrToInt(res.val(k, 3)));
               end;

               20: // Изменение списка плейлистов
               begin
                  loadMediaGroups(-1); //StrToInt(res[k][2]));
               end;

               21: // Изменение содиржимого плейлиста
               begin
                  if ((ComboBox1.ItemIndex > -1) and (ComboBox1.Items.Objects[ComboBox1.ItemIndex] <> nil)) then
                     if (TMediaGroupItem(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).id = StrToInt(res.val(k, 2))) then
                        ComboBox1Change(nil);
               end;
            end;
         end;
         refreshMediaList();
      end;
   finally
      res.Free;
   end;
end;}

procedure TMainForm.syncHandler(res: TDataRec);
var
   k, i, o_id: integer;
   v: string;
begin
   try
      for k := 0 to res.Count - 1 do
      begin
         o_id := StrToInt(res.val(k, 1));
         if (o_id = 123) then // QUIET_TIME
            fQuietTime := trunc(StrToFloat(StringReplace(res.val(k, 2), '.', ',', [rfReplaceAll])));

         case (o_id) of
            166, 167, 168, 169:
            begin
               if ((loadProp('ShowCamAlert') = 'true') and (res.val(k, 2) = '1.0')) then
                  SendMessage(Handle, SHOW_CAM_ALERT_MESS, o_id, 0);
            end;
         end;

         for i:= 0 to fItemList.Count - 1 do
         begin
            if (TVarListItem(fItemList[i]).id = o_id) then
            begin
               v := res.val(k, 2);
               if (v = 'None') then
                  v := '-9999';
               TVarListItem(fItemList[i]).value := StrToFloat(StringReplace(v, '.', ',', [rfReplaceAll]));
            end;

            if (TVarListItem(fItemList[i]).link_id = o_id) then
            begin
               v := res.val(k, 2);
               if (v = 'None') then
                  v := '-9999';
               TVarListItem(fItemList[i]).link_value := StrToFloat(StringReplace(v, '.', ',', [rfReplaceAll]));
            end;
         end;
      end;
      if (res.Count > 0) then
         refreshVarList();
   finally
      res.Free;
   end;
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

   setVolume();
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
         if InputQuery('Включить позже', 'Через (минут):', s) then
         begin
            if (s <> '') then
               SchedDialog.fastInsert('Включить "' + o.comm + '" через ' + s + ' минут', 'on("' + o.name + '")', IncMinute(Now(), StrToInt(s)), o.id)
            else
               SchedDialog.fastInsert('', '', Now(), o.id);
            schedLoad;
         end;
      end;
      12:
      begin
         if InputQuery('Включить временно', 'На (минут):', s) then
         begin
            if (s <> '') then
            begin
               if (o.value = 0) then
                  sendVarValue(o.id, 1);
               SchedDialog.fastInsert('Выключить "' + o.comm + '" через ' + s + ' минут', 'off("' + o.name + '")', IncMinute(Now(), StrToInt(s)), o.id);
            end
            else
               SchedDialog.fastInsert('', '', Now(), o.id);
            schedLoad;
         end;
      end;
      20: sendVarValue(o.id, 0);
      21:
      begin
         if InputQuery('Выключить позже', 'Через (минут):', s) then
         begin
            if (s <> '') then
            begin
               SchedDialog.fastInsert('Выключить "' + o.comm + '" через ' + s + ' минут', 'off("' + o.name + '")', IncMinute(Now(), StrToInt(s)), o.id);
            end
            else
               SchedDialog.fastInsert('', '', Now(), o.id);
            schedLoad;
         end;
      end;
      22:
      begin
         if InputQuery('Выключить временно', 'На (минут):', s) then
         begin
            if (s <> '') then
            begin
               if (o.value = 1) then
                  sendVarValue(o.id, 0);
               SchedDialog.fastInsert('Включить "' + o.comm + '" через ' + s + ' минут', 'on("' + o.name + '")', IncMinute(Now(), StrToInt(s)), o.id);
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
   clearStrings(SchedList.Items);
   res := metaQuery('get scheduler list', '');
   try
      for k:= 0 to res.Count - 1 do
      begin
         os:= TSchedListItem.Create;
         try
            os.id := StrToInt(res.val(k, 0));
            os.comm := res.val(k, 1);
            os.action := res.val(k, 2);
            os.datetime := strToDate(res.val(k, 3));
            os.timeOfDay := res.val(k, 4);
            os.dayOfType := res.val(k, 5);
            os.typ := StrToInt(res.val(k, 6));
            os.variable := StrToInt(res.val(k, 7));
            SchedList.AddItem(os.comm, os);
            if (os.id = SchedList.Tag) then
               SchedList.ItemIndex := SchedList.Count - 1;
         except
            os.Free;
         end;
      end;
   finally
      res.Free;
   end;

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

procedure TMainForm.clearStrings(ls:TStrings);
var
   k: integer;
begin
   for k:= 0 to ls.Count - 1 do
   begin
      if (ls.Objects[k] <> nil) then
      begin
         ls.Objects[k].Free;
         ls.Objects[k] := nil;
      end;
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

   setOnTop();
end;

procedure TMainForm.PopupMenu3Popup(Sender: TObject);
var
   k: integer;
   mi: TMenuItem;
   mg: TMediaGroupItem;
begin
   TransferMenu.Clear;
   for k:= 0 to fSessions.Count - 1 do
   begin
      if ((fSessions.val(k, 2) <> 'None') and (fSessions.val(k, 0) <> IntToStr(fAppID))) then
      //if (fSessions[k][2] <> 'None') then
      begin
         mi:= TMenuItem.Create(nil);
         try
            mi.Caption := fSessions.val(k, 1);
            mi.Tag := StrToInt(fSessions.val(k, 0));
            mi.OnClick := transferMedia;
            TransferMenu.Add(mi);
         except
            mi.Free;
         end;
      end;
   end;

   if (TransferMenu.Count = 0) then
   begin
      mi:= TMenuItem.Create(nil);
      try
         mi.Caption := 'Пусто';
         mi.Enabled := false;
         TransferMenu.Add(mi);
      except
         mi.Free;
      end;
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
            try
               mi.Caption := mg.comm;
               mi.Tag := mg.id;
               mi.OnClick := MediaGroupAddClick;
               MediaGroupAdd.Add(mi);
            except
               mi.Free;
            end;
         end;
      end;
   end;  


end;

procedure TMainForm.AddMediaListButtonClick(Sender: TObject);
var
   s: string;
   id: integer;
   res: TDataRec;
begin
   if (InputQuery('Создание нового плейлиста', 'Название:', s)) then
   begin
      res := metaQuery('edit groups list', '-1' + chr(1) + s);
      try
         id := StrToInt(res.val(0, 0));
      finally
         res.Free;
      end;
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
   if (InputQuery('Редактирование названия плейлиста', 'Название:', s)) then
   begin
      metaQuery('edit groups list', IntToStr(mg.id) + chr(1) + s).Free;
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
   if (MessageDlg('Удалить плейлист "' + ComboBox1.Text + '"?', mtConfirmation, [mbYes, mbNo], 0) = mrYes) then
   begin
      metaQuery('del groups list', IntToStr(mg.id)).Free;
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
   try
      SetLength(fMediaGroupCross, res.Count);
      for k:= 0 to res.Count - 1 do
         fMediaGroupCross[k] := StrToInt(res.val(k, 0));
   finally
      res.Free;
   end;
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
         metaQuery('add groups cross', IntToStr(mo.id) + chr(1) + IntToStr(TMenuItem(Sender).Tag), true).Free;
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
      MessageDlg('Содержимое системных плейлистов изменять нельзя.', mtWarning, [mbOk], 0);
      exit;
   end;
   mg := TMediaGroupItem(ComboBox1.Items.Objects[ComboBox1.ItemIndex]);
   for k:= 0 to MediaList.Count - 1 do
   begin
      if (MediaList.Selected[k]) then
      begin
         mo := TMediaListItem(MediaList.Items.Objects[k]);
         metaQuery('del groups cross', IntToStr(mo.id) + chr(1) + IntToStr(mg.id), true).Free;
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

   ComboBox1.Items.BeginUpdate;
   clearStrings(ComboBox1.Items);
   ComboBox1.AddItem('Вся медия', nil);
   ComboBox1.AddItem('Только видео', nil);
   ComboBox1.AddItem('Только музыка', nil);
   ComboBox1.AddItem('Только фотографии', nil);

   mg:= TMediaGroupItem.Create();
   mg.id := -1;
   mg.typ := 0;
   ComboBox1.AddItem('Не добавленые в плейлисты', mg);

   res := metaQuery('get groups list', '');
   try
      for k := 0 to res.Count - 1 do
      begin
         mg:= TMediaGroupItem.Create();
         try
            mg.id := StrToInt(res.val(k, 0));
            mg.typ := 1;// StrToInt(res[k][1]);
            mg.comm := res.val(k, 2);
            ComboBox1.AddItem(mg.comm, mg);
            if (mg.id = id) then
               i := ComboBox1.Items.Count - 1;
         except
            mg.Free;
         end;
      end;
   finally
      res.Free;
   end;

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

procedure TMainForm.PlayNextButtonClick(Sender: TObject);
begin
   playMediaNextItem;
   refreshMediaList;
end;

function TMainForm.checkSpechData(id: string): Boolean;

   function decodeHex(c: char): byte;
   begin
      case c of
         '0': Result := 0;
         '1': Result := 1;
         '2': Result := 2;
         '3': Result := 3;
         '4': Result := 4;
         '5': Result := 5;
         '6': Result := 6;
         '7': Result := 7;
         '8': Result := 8;
         '9': Result := 9;
         'a': Result := 10;
         'b': Result := 11;
         'c': Result := 12;
         'd': Result := 13;
         'e': Result := 14;
         'f': Result := 15;
      end;
   end;

   function FileSizeByName(s: string): int64;
   var
      f: TFileStream;
   begin
      Result := 0;
      if (FileExists(s)) then
      begin
         f:= TFileStream.Create(s, fmOpenRead or fmShareDenyWrite);
         try
            Result := f.Size;
         finally
            f.Free;
         end;
      end;
   end;

var
   path, fileName: string;
   res, res2: TDataRec;
   f: TFileStream;
   k: integer;
   s: string;
   i: integer;
   b: byte;
begin
   Result := true;
   path := GetEnvironmentVariable('TEMP') + '\audio';
   if not DirectoryExists(path) then
      CreateDir(path);

   if (ExtractFileExt(WideUpperCase(id)) = '.MP3') then
      fileName := path + '\' + id
   else
      fileName := path + '\' + id + '.wav';

   if (not FileExists(fileName) or (FileSizeByName(fileName) = 0)) then
   begin
      res := metaQuery('audio data', id);
      try
         if (res.Count > 0) then
         begin
            f:= TFileStream.Create(fileName, fmCreate);
            try
               s := res.val(0, 0);
               i := 1;
               for k:= 1 to Length(s) div 2 do
               begin
                  b := decodeHex(s[i + 1]) + (decodeHex(s[i]) shl 4);
                  inc(i, 2);
                  f.Write(b, 1);
               end;
            finally
               f.Free;
            end;
         end;
      finally
         res.Free;
      end;
   end;
end;

{procedure TMainForm.syncSpeachThread;
begin
   if ((fSpeach.fPlayList.Count > 0) and (fSpeach.fPlayFile <> '')) then
   begin
      fSpeach.fPlayList.Delete(0);
      fSpeach.fPlayFile := '';
   end;

   if (fSpeach.fPlayList.Count > 0) then
      fSpeach.fPlayFile := fSpeach.fPlayList[0];
end;}

var
   prevSpeechIdTime: TDateTime;
   prevSpeechAllTime: TDateTime;      
   prevSpeechType: string;
   prevSpeechID: string;
   
procedure TMainForm.Timer3Timer(Sender: TObject);
var
   isPlay: Boolean;
   f_key: string;
begin
   DXAudioOut1.Volume := DXAudioOut1.Tag;
   if (not SpeedButton10.Down) then
      DXAudioOut2.Volume := -10000
   else
      DXAudioOut2.Volume := DXAudioOut1.Tag;
   if (fSpeachList.Count > 0) and (DXAudioOut1.Status = tosIdle) then
   begin
      f_key := fSpeachList[0];
      try
         isPlay := False;
         if (Pos(f_key[1], '0123456789') > 0) then
         begin
            isPlay := (prevSpeechID <> f_key) or (prevSpeechIdTime <= Now());
            prevSpeechID := f_key;
         end
         else
         begin
            isPlay := (prevSpeechType <> f_key) or (prevSpeechAllTime <= Now());
            prevSpeechType := f_key;
         end;

         if isPlay then
         begin
            WaveIn1.FileName := GetEnvironmentVariable('TEMP') + '\audio\' + f_key + '.wav';
            DXAudioOut1.Run;
         end;
      except
      end;
      fSpeachList.Delete(0);
   end;
end;

procedure TMainForm.DXAudioOut1Done(Sender: TComponent);
var
   f_key: string;
begin
   f_key := ExtractFileName(WaveIn1.FileName);
   if (Length(f_key) > 0) then
   begin
      if (Pos(f_key[1], '0123456789') > 0) then
         prevSpeechIdTime := IncSecond(Now(), 2);
   end;
   prevSpeechAllTime := IncSecond(Now(), 1);
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
   setOnTop();
end;

procedure TMainForm.FormDeactivate(Sender: TObject);
begin
   setOnTop();
end;

procedure TMainForm.WMGetSysCommand(var message: TMessage);
begin
   if (message.wParam = SC_MINIMIZE) then
      CoolTrayIcon1.HideMainForm
   else
      inherited;
end;

procedure TMainForm.DXAudioOut2Done(Sender: TComponent);
begin
   while DXAudioOut2.Status <> tosIdle do
      sleep(10);
   MP3In1.FileName := '';
end;

procedure TMainForm.Panel7Resize(Sender: TObject);
var
   playHeight: integer;
begin
   playHeight := 0;
   if (fMiniPlayer <> nil) then
   begin
      playHeight :=  Panel7.ClientWidth * 9 div 16 + 4;
      if (fMediaPlayFileType = 2) then
         playHeight := 0;
      fMiniPlayer.Left := 0;
      fMiniPlayer.Top := 0;
      fMiniPlayer.Width := Panel7.ClientWidth;
      fMiniPlayer.Height := playHeight;
   end;

   TimePanel.Top := 4 + playHeight;
   Panel3.Top := 23 + playHeight;
   PlayButton.Top := 24 + playHeight;
   PauseButton.Top := 24 + playHeight;
   StopButton.Top := 24 + playHeight;
   PlayNextButton.Top := 24 + playHeight;
   PlayLoopButton.Top := 24 + playHeight;
   TimePanel.Width := Panel7.ClientWidth - (TimePanel.Left * 2);
   Panel3.Left := Panel7.ClientWidth - Panel3.Width;
   updateTimePanel;

   Panel8.Height := 59 + playHeight + Panel1.Height;   
end;

procedure TMainForm.playMiniPlayer(id, typ: integer; url: string; withPause: boolean; seek: integer);
begin
   stopMiniPlayer;

   fMiniPlayer := TVLCPlugin2.Create(nil);
   fMiniPlayer.Height := 0;
   fMiniPlayer.video.fullscreen := fMiniPlayerFullscreen and (typ <> 2);
   fMiniPlayer.OnMediaPlayerLengthChanged :=  VLCPlugin21MediaPlayerLengthChanged;
   fMiniPlayer.OnMediaPlayerPlaying := VLCPlugin21MediaPlayerPlaying;
   fMiniPlayer.OnMediaPlayerPaused := VLCPlugin21MediaPlayerPaused;
   //fMiniPlayer.OnMediaPlayerStopped := VLCPlugin21MediaPlayerStopped;
   fMiniPlayer.OnMediaPlayerTimeChanged := VLCPlugin21MediaPlayerTimeChanged;
   fMiniPlayer.OnMediaPlayerEndReached := VLCPlugin21MediaPlayerStopped;

   fMiniPlayer.ControlInterface.Toolbar := false;
   fMiniPlayer.playlist.clear;
   fMiniPlayer.playlist.add(url, NULL, NULL);
   Panel7.InsertControl(fMiniPlayer);
   fMiniPlayer.playlist.play;
   setMediaVolume;

   if (withPause) then
      fMiniPlayer.playlist.pause;

   if (seek > 0) then
      fMiniPlayer.input.time := seek * 1000;

   Panel7Resize(nil);
end;

procedure TMainForm.pauseMiniPlayer;
begin
   if (fMiniPlayer <> nil) then
      fMiniPlayer.playlist.togglePause;
end;

procedure TMainForm.stopMiniPlayer;
var
   k: integer;
begin
   if (fMiniPlayer <> nil) then
   begin
      fMiniPlayer.video.fullscreen := False;
      Application.ProcessMessages;
      fMiniPlayer.playlist.stop;
      for k:= 0 to 500 do
      begin
         Application.ProcessMessages;
         if (not fMiniPlayer.playlist.isPlaying) then break;
         Sleep(10);
      end;
      Panel7.RemoveControl(fMiniPlayer);
      FreeAndNil(fMiniPlayer);
      fMiniPlayerLen := 0;
      fMiniPlayerPos := 0;            
      Panel7Resize(nil);
      fMiniPlayerState := 4;
      vlcOnChange(nil);
   end;
end;

procedure TMainForm.VLCPlugin21MediaPlayerLengthChanged(ASender: TObject;
  length: Integer);
begin
   if (fMiniPlayerLen = 0) then
   begin
      fMiniPlayerLen := length div 1000;
      vlcOnPlayPosEvent(nil, fMiniPlayerPos, fMiniPlayerLen);
   end;
end;

procedure TMainForm.VLCPlugin21MediaPlayerPaused(Sender: TObject);
begin
   fMiniPlayerState := 3;
   vlcOnChange(nil);
end;

procedure TMainForm.VLCPlugin21MediaPlayerPlaying(Sender: TObject);
begin
   fMiniPlayerState := 2;
   vlcOnChange(nil);
end;

procedure TMainForm.VLCPlugin21MediaPlayerStopped(Sender: TObject);
begin
   fMiniPlayer.video.fullscreen := False;
   AlphaBlend := False;
   fMiniPlayerState := 4;
   fMiniPlayerLen := 0;
   fMiniPlayerPos := 0;
   vlcOnChange(nil);
   vlcOnPlayPosEvent(nil, fMiniPlayerPos, fMiniPlayerLen);
   PostMessage(Handle, MEDIA_END, 0, 0);
end;

procedure TMainForm.VLCPlugin21MediaPlayerTimeChanged(ASender: TObject;
  time: Integer);
begin
   fMiniPlayerPos := time div 1000;
   vlcOnPlayPosEvent(nil, fMiniPlayerPos, fMiniPlayerLen);
   if (fMediaPlayFileType <> 2) then
      fMiniPlayerFullscreen := fMiniPlayer.video.fullscreen;
   AlphaBlend := fMiniPlayer.video.fullscreen and (fMiniPlayerState = 2);
   if fMiniPlayer.video.fullscreen then
      SetForegroundWindow(Handle);
end;

procedure TMainForm.MEDIA_END_MESS(var Message: TMessage);
begin
   vlcOnStopEvent(nil);
end;

procedure TMainForm.syncLoadAsync;
begin
   syncHandler(metaQuery('sync', ''));
   queueHandler(metaQuery('exe queue', ''));
   sessionHandler(metaQuery('sessions', ''));
   mediaHandler(metaQuery('media queue', ''));
end;

procedure TMainForm.queueHandler(res: TDataRec);
var
   k: integer;
   s, s2: string;
begin
   try
      if (res.Count > 0) then
      begin
         for k:= 0 to res.Count - 1 do
         begin
            if (res.val(k, 1) = 'speech') then
            begin
               s := res.val(k, 4);
               s2 := res.val(k, 3);
               AlertForm_Unit.show(s, s2);
               checkSpechData(s2);
               checkSpechData(res.val(k, 2));
               if ((SpeedButton10.Down) and (fQuietTime = 0)) or (s2 = 'alarm') then
               begin
                  fSpeachList.Add(s2);
                  fSpeachList.Add(res.val(k, 2));
               end;
            end
            else
            if (res.val(k, 1) = 'play') then
            begin
               s := res.val(k, 4);
               s2 := GetEnvironmentVariable('TEMP') + '\audio\' + s;
               checkSpechData(s);
               if (MP3In1.FileName = '') and (FileExists(s2)) and (ExtractFileExt(WideUpperCase(s)) = '.MP3') then
               begin
                  MP3In1.FileName := s2;
                  DXAudioOut2.Run;
               end               
            end;
         end;
      end;
   finally
      res.Free;
   end;
end;

procedure TMainForm.sessionHandler(res: TDataRec);
begin
   try
      if (fSessions <> nil) then
         FreeAndNil(fSessions);
      fSessions := res;
      MediaList.Repaint;
   except
   end;
end;

procedure TMainForm.mediaHandler(res: TDataRec);
var
   k, i: integer;
   om: TMediaListItem;
begin
   try
      if (res.Count > 0) then
      begin
         for k:= 0 to res.Count - 1 do
         begin
            case StrToInt(res.val(k, 1)) of
               0:
               begin
                  om:= TMediaListItem.Create;
                  try
                     om.id := StrToInt(res.val(k, 2));
                     om.app_id := StrToInt(res.val(k, 4));
                     om.title := res.val(k, 5);
                     om.file_name := res.val(k, 6);
                     om.file_type := StrToInt(res.val(k, 7));
                     fMediaList.Add(om);
                  except
                     om.Free;
                  end;
               end;
               1:
               begin
                  for i:= 0 to fMediaList.Count - 1 do
                  begin
                     om:= TMediaListItem(fMediaList[i]);
                     if (om.id = StrToInt(res.val(k, 2))) then
                     begin
                        om.id := StrToInt(res.val(k, 2));
                        om.app_id := StrToInt(res.val(k, 4));
                        om.title := res.val(k, 5);
                        om.file_name := res.val(k, 6);
                        om.file_type := StrToInt(res.val(k, 7));
                        break;
                     end;
                  end;
               end;
               2:
               begin
                  for i:= 0 to fMediaList.Count - 1 do
                  begin
                     om:= TMediaListItem(fMediaList[i]);
                     if (om.id = StrToInt(res.val(k, 2))) then
                     begin
                        fMediaList.Delete(i);
                        break;
                     end;
                  end;
               end;

               10: // Transfer media
               begin
                  StopButton.Tag := 1;
                  startMediaPlay(StrToInt(res.val(k, 2)), true, StrToInt(res.val(k, 3)));
               end;

               20: // Изменение списка плейлистов
               begin
                  loadMediaGroups(-1); //StrToInt(res[k][2]));
               end;

               21: // Изменение содиржимого плейлиста
               begin
                  if ((ComboBox1.ItemIndex > -1) and (ComboBox1.Items.Objects[ComboBox1.ItemIndex] <> nil)) then
                     if (TMediaGroupItem(ComboBox1.Items.Objects[ComboBox1.ItemIndex]).id = StrToInt(res.val(k, 2))) then
                        ComboBox1Change(nil);
               end;
            end;
         end;
         refreshMediaList();
      end;
   finally
      res.Free;
   end;
end;

procedure TMainForm.CamAlertBtnClick(Sender: TObject);
begin
   if (CamAlertBtn.Down) then
      saveProp('ShowCamAlert', 'true')
   else
      saveProp('ShowCamAlert', 'false');
end;

procedure TMainForm.SHOW_CAM_ALERT(var Message: TMessage);
begin
   showCamAlert(Message.WParam);
end;

procedure TMainForm.HIDE_CAM_ALERT(var Message: TMessage);
begin
   try
      if (Message.WParam = 0) then
         hideAllCamAlerts()
      else
         hideCamAlert(Message.LParam);
   except
   end;
end;

procedure TMainForm.SpeedButton2Click(Sender: TObject);
begin
   showCamAll();
end;

procedure TMainForm.Label1DblClick(Sender: TObject);
begin
   showCamAlert(trunc(166 + random(4)));
end;

procedure TMainForm.HIDE_CAM_ALL(var Message: TMessage);
begin
   hideCamAll;
end;

end.


