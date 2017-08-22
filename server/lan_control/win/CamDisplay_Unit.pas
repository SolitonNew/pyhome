unit CamDisplay_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DlgMessagesRU, DataRec_Unit, StdCtrls, ExtCtrls,
  Buttons;

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
  private
     procedure loadCamList;
     procedure clearAllCamViewers;
  public
     procedure resizeCamList;
  end;

var
  CamDisplay: TCamDisplay;

procedure showCamAll();
procedure hideCamAll();


implementation

uses MainForm_Unit, AXVLC_TLB;

{$R *.dfm}

var
   urls: array of string;

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

   function camAtIndex(i: integer): TVLCPlugin2;
   var
      k, n: integer;
   begin
      Result := nil;
      n := 0;
      for k:= 0 to ControlCount - 1 do
      begin
         if (Controls[k] is TVLCPlugin2) then
         begin
            if (n = i) then
            begin
               Result := TVLCPlugin2(Controls[k]);
               break;
            end;
            n := n + 1;
         end;
      end;
   end;

   procedure setCamBounds(i, x, y, w, h: integer);
   var
      v: TVLCPlugin2;
   begin
      v := camAtIndex(i);
      if (v = nil) then exit;
      v.Left := x;
      v.Top := y;
      v.Width := w;
      v.Height := h;
   end;

var
   cw, ch: integer;
   ww, hh : integer;
   cl, ct: integer;
   k: integer;
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
      setCamBounds(0, cl, ct, cw, ch);
      setCamBounds(1, cl + cw + 1, ct, cw, ch);
      setCamBounds(2, cl, ct + ch + 1, cw, ch);
      setCamBounds(3, cl + cw + 1, ct + ch + 1, cw, ch);
   end
   else
   begin
      ch := ClientHeight div 4 - 2;
      for k:= 0 to 3 do
         setCamBounds(k, 1, k * (ch + 1) + 1, ClientWidth - 2, ch);
   end;

   Panel2.BringToFront;

   Repaint;
end;

procedure TCamDisplay.loadCamList;
var
   cw: TVLCPlugin2;
   res: TDataRec;
   k: integer;
   url: string;
begin
   clearAllCamViewers;
   res := MainForm.metaQuery('cams', '');
   try
      SetLength(urls, res.Count);
      for k := 0 to res.Count - 1 do
      begin
         cw:= TVLCPlugin2.Create(nil);
         try
            cw.ControlInterface.Toolbar := false;
            cw.DefaultInterface.Toolbar := false;
            cw.video.aspectRatio := '16:9';
            url := res.val(k, 2);
            //url := StringReplace(url, '0.sdp', '1.sdp', [rfReplaceAll]);
            cw.playlist.add(url, NULL, NULL);
            InsertControl(cw);
         except
            cw.Free;
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
   c: TVLCPlugin2;
begin
   for k := ControlCount - 1 downto 0 do
   begin
      if (Controls[k] is TVLCPlugin2) then
      begin
         c := TVLCPlugin2(Controls[k]);
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
end;

procedure TCamDisplay.SpeedButton2Click(Sender: TObject);
var
   n: integer;
begin
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
         if (Controls[k] is TVLCPlugin2) then
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

end.
