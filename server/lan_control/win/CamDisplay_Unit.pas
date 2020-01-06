unit CamDisplay_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DlgMessagesRU, DataRec_Unit, StdCtrls, ExtCtrls,
  Buttons, CamPlayer_Unit, libvlc;

type
  TCamDisplay = class(TForm)
    Panel2: TPanel;
    SpeedButton2: TSpeedButton;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
     fFullScreenIndex: integer;
     procedure loadCamList;
     procedure clearAllCamViewers;
     function camAtIndex(i: integer): TCamPlayer;

     procedure MSG_FULLSCREEN_Handler(var msg: TMessage); message MSG_FULLSCREEN;
  public
     procedure resizeCamList;
  end;

var
  CamDisplay: TCamDisplay;

procedure showCamAll();
procedure hideCamAll();


implementation

uses MainForm_Unit, Types;

{$R *.dfm}

procedure showCamAll();
begin
   if (CamDisplay <> nil) then exit;

   CamDisplay := TCamDisplay.Create(nil);
   try
      SendMessage(MainForm.Handle, HIDE_CAM_ALERT_MESS, 0, 0);
      CamDisplay.Show();
      CamDisplay.loadCamList;
   except
      FreeAndNil(CamDisplay);
   end;
end;

procedure hideCamAll();
begin
   if (CamDisplay <> nil) then
      FreeAndNil(CamDisplay);
end;

procedure TCamDisplay.FormResize(Sender: TObject);
begin
   resizeCamList;
end;

procedure TCamDisplay.resizeCamList;

   procedure setCamBounds(i, x, y, w, h: integer);
   var
      v: TCamPlayer;
   begin
      v := camAtIndex(i);
      if (v = nil) then exit;
      v.Left := x;
      v.Top := y;
      v.Width := w;
      v.Height := h;

      v.Realign;
   end;

var
   cw, ch: integer;
   ww, hh : integer;
   cl, ct: integer;
   k: integer;
begin
	if (fFullScreenIndex = 0) then
   begin
      if (ClientWidth / 1.78 >= ClientHeight) then
      begin
         hh := ClientHeight - 3;
         ww := round(hh * 1.78);
      end
      else
      begin
         ww := ClientWidth - 3;
         hh := round(ww / 1.78);
      end;

      cl := (ClientWidth - ww) div 2;
      ct := (ClientHeight - hh) div 2;
      cw := ww div 2;
      ch := hh div 2;
      if (not SpeedButton2.Down) then
      begin
         setCamBounds(1, cl, ct, cw, ch);
         setCamBounds(2, cl + cw + 1, ct, cw, ch);
         setCamBounds(3, cl, ct + ch + 1, cw, ch);
         setCamBounds(4, cl + cw + 1, ct + ch + 1, cw, ch);
      end
      else
      begin
         ch := ClientHeight div 4 - 2;
         for k:= 1 to 4 do
            setCamBounds(k, 1, (k - 1) * (ch + 1) + 1, ClientWidth - 2, ch);
      end;

      Panel2.Visible := true;
      Panel2.BringToFront;
   end
   else
   begin     
      Panel2.Visible := false;
	   setCamBounds(fFullScreenIndex, 0, 0, ClientWidth, ClientHeight);      
      camAtIndex(fFullScreenIndex).BringToFront;
   end;
   
   Repaint;
end;

procedure TCamDisplay.loadCamList;
var
   res: TDataRec;
   k: integer;
   url: string;
   op : array of string;

   cp: TCamPlayer;
   
begin
   clearAllCamViewers;
   res := MainForm.metaQuery('cams', '');
   try
      for k := 0 to res.Count - 1 do
      begin
         cp := TCamPlayer.Create(nil);
         try
            InsertControl(cp);         
            cp.Init(k + 1, res.val(k, 2));
         except
            cp.Free;
         end;
   	end;
   finally
      res.Free;
   end;

   resizeCamList;
end;

procedure TCamDisplay.clearAllCamViewers;
var
   k: integer;
   c: TCamPlayer;
begin
   for k := ControlCount - 1 downto 0 do
   begin
      if (Controls[k] is TCamPlayer) then
      begin
         c := TCamPlayer(Controls[k]);
         RemoveControl(c);
         FreeAndNil(c);
      end;
   end;
end;

procedure TCamDisplay.FormCreate(Sender: TObject);
begin
   ControlStyle := ControlStyle + [csOpaque];
   ClientWidth := 1280;
   ClientHeight := 720;

   fFullScreenIndex := 0;
end;

procedure TCamDisplay.SpeedButton2Click(Sender: TObject);
var
   n: integer;
begin
	SpeedButton2.Tag := 0;

   if (SpeedButton2.Down) then
      n := round((ClientHeight / 4) * 1.78)
   else
      n := round(ClientHeight * 1.78);
   Left := Left - (n - ClientWidth);
   ClientWidth := n;
   resizeCamList();
end;

procedure TCamDisplay.FormPaint(Sender: TObject);
var
   k: integer;
   r: TRect;
begin
   with Canvas do
   begin
      Brush.Style := bsSolid;
      Brush.Color := clBlack;
      Pen.Color := clBlack;
      Rectangle(0, 0, Width, Height);

      Pen.Color := clYellow;
      Brush.Style := bsClear;
      for k:= 0 to ControlCount - 1 do
      begin
         if (Controls[k] is TCamPlayer) then
         begin
            r := Controls[k].BoundsRect;
            InflateRect(r, 1, 1);
            Rectangle(r);
         end;
      end;
   end;
end;

procedure TCamDisplay.FormDestroy(Sender: TObject);
begin
   clearAllCamViewers;
end;

procedure TCamDisplay.FormHide(Sender: TObject);
begin
   PostMessage(MainForm.Handle, HIDE_CAM_ALL_MESS, 0, 0);
end;

procedure TCamDisplay.FormShow(Sender: TObject);
begin
	resizeCamList;
end;

procedure TCamDisplay.MSG_FULLSCREEN_Handler(var msg: TMessage);
var
   k: integer;
   c: TCamPlayer;
begin
	if (fFullScreenIndex <> msg.WParam) then 
   begin
      if (SpeedButton2.Down) then 
      begin
         SpeedButton2.Down := false;
      	SpeedButton2Click(nil);
         SpeedButton2.Tag := 1;         
      end;
      fFullScreenIndex := msg.WParam;
   end
   else
   begin
   	if (SpeedButton2.Tag = 1) then
      begin
         SpeedButton2.Down := true;
      	SpeedButton2Click(nil);
      end;
   	fFullScreenIndex := 0;
   end;

   resizeCamList;
end;

function TCamDisplay.camAtIndex(i: integer): TCamPlayer;
var
   k: integer;
begin
   Result := nil;
   for k:= 0 to ControlCount - 1 do
   begin
      if (Controls[k] is TCamPlayer) then
      begin
         if (TCamPlayer(Controls[k]).fIndex = i) then
         begin
            Result := TCamPlayer(Controls[k]);
            break;
         end;
      end;
   end;
end;

end.
