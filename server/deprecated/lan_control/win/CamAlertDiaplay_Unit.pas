unit CamAlertDiaplay_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, DataRec_Unit, OleCtrls, AXVLC_TLB;

type
  TCamAlertDiaplay = class(TForm)
    CamFullScreenBtn: TPanel;
    Image1: TImage;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure FormHide(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fUrl: string;
    fVlc: TVLCPlugin2;
  public
    fId: integer;
    procedure ShowForAlertId(id: integer);
  end;

var
   camAlerts: TList;

procedure showCamAlert(id: integer);
procedure hideCamAlert(id: integer);
procedure hideAllCamAlerts;

implementation

uses MainForm_Unit, CamDisplay_Unit, PropertysForm_Unit;

{$R *.dfm}

procedure showCamAlert(id: integer);
var
   cam: TCamAlertDiaplay;
   k: integer;
begin
   if (CamDisplay <> nil) then exit;

   for k:= 0 to camAlerts.Count - 1 do
   begin
      if (TCamAlertDiaplay(camAlerts[k]).fId = id) then
      begin
         TCamAlertDiaplay(camAlerts[k]).Timer1.Enabled := false;
         TCamAlertDiaplay(camAlerts[k]).Timer1.Enabled := true;
         exit;
      end;
   end;

   cam := TCamAlertDiaplay.Create(Application);
   try
      camAlerts.Add(cam);
      cam.ShowForAlertId(id);
   except
      cam.Free;
   end;
end;

procedure hideCamAlert(id: integer);
var
   k: integer;
begin
   for k:= 0 to camAlerts.Count - 1 do
   begin
      if (TCamAlertDiaplay(camAlerts[k]).fId = id) then
      begin
         TCamAlertDiaplay(camAlerts[k]).Free;
         camAlerts.Delete(k);
         break;
      end;
   end;
end;

procedure hideAllCamAlerts;
var
   k: integer;
begin
   for k:= 0 to camAlerts.Count - 1 do
      TCamAlertDiaplay(camAlerts[k]).Free;
   camAlerts.Clear;
end;

{ TCamAlertDiaplay }

procedure TCamAlertDiaplay.ShowForAlertId(id: integer);
var
   res: TDataRec;
   k: integer;
   url: string;
begin
   Timer1.Enabled := false;
   Timer1.Enabled := true;
   fId := id;   
   url := '';
   res := MainForm.metaQuery('cams', '');
   try
      for k := 0 to res.Count - 1 do
      begin
         if (res.val(k, 4) = IntToStr(id)) then
         begin
            url := res.val(k, 2);
            break;
         end;
      end;
   finally
      res.Free;
   end;

   url := StringReplace(url, '0.sdp', '1.sdp', [rfReplaceAll]);
   fUrl := url;

   fVlc.video.aspectRatio := '16:9';
   fVlc.playlist.stop;
   fVlc.playlist.clear;
   fVlc.playlist.add(url, NULL, NULL);
   Show;
end;

procedure TCamAlertDiaplay.FormHide(Sender: TObject);
begin
   fVlc.playlist.stop;
   fVlc.playlist.clear;
   Timer1.Enabled := false;

   saveProp('CAM_' + IntToStr(fId), IntToStr(Left) + ';' + IntToStr(Top) + ';' + IntToStr(Width) + ';' + IntToStr(Height));

   PostMessage(MainForm.Handle, HIDE_CAM_ALERT_MESS, 1, fId);
end;

procedure TCamAlertDiaplay.Timer1Timer(Sender: TObject);
begin
   if (not fVlc.video.fullscreen) then
      Hide();
end;

procedure TCamAlertDiaplay.Image1Click(Sender: TObject);
begin
   showCamAll;
end;

procedure TCamAlertDiaplay.FormCreate(Sender: TObject);
begin
   ClientWidth := 640;
   ClientHeight := 360;

   fVlc:= TVLCPlugin2.Create(nil);
   InsertControl(fVlc);
   fVlc.Align := alClient;
   fVlc.ControlInterface.Toolbar := false;
   fVlc.DefaultInterface.Toolbar := false;

   CamFullScreenBtn.BringToFront;   
end;

procedure TCamAlertDiaplay.Timer2Timer(Sender: TObject);
begin
   if (fVlc.video.fullscreen) then
      Timer1.Enabled := false
   else
      Timer1.Enabled := true;
end;

procedure TCamAlertDiaplay.FormShow(Sender: TObject);
var
   s: string;
   sl: TStringList;
begin
   s := loadProp('CAM_' + IntToStr(fId));
   sl:= TStringList.Create;
   try
      sl.Delimiter := ';';
      sl.DelimitedText := s;
      if (sl.Count = 4) then
      begin
         Left := StrToInt(sl[0]);
         Top := StrToInt(sl[1]);
         Width := StrToInt(sl[2]);
         Height := StrToInt(sl[3]);
      end;
   finally
      sl.Free;
   end;

   //fVlc.playlist.play;
end;

procedure TCamAlertDiaplay.FormDestroy(Sender: TObject);
begin
   RemoveControl(fVlc);
   fVlc.Free;
end;

initialization
   camAlerts:= TList.Create;

finalization
   hideAllCamAlerts;
   camAlerts.Free;

end.
