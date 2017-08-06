unit CamDisplay_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DlgMessagesRU, DataRec_Unit, AXVLC_TLB, StdCtrls, ExtCtrls;

type
  TCamDisplay = class(TForm)
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
     procedure loadCamList;
     procedure clearAllCamViewers;
  public
     procedure resizeCamList;
  end;

var
  CamDisplay: TCamDisplay;

implementation

uses MainForm_Unit;

{$R *.dfm}

procedure TCamDisplay.FormResize(Sender: TObject);
begin
   resizeCamList;
end;

procedure TCamDisplay.resizeCamList;

   procedure setCamBounds(i, x, y, w, h: integer);
   var
      v: TVLCPlugin2;
   begin
      if (i >= ControlCount) then exit;
      v := TVLCPlugin2(Controls[i]);
      v.Left := x;
      v.Top := y;
      v.Width := w;
      v.Height := h;
   end;

var
   cw, ch: integer;
   ww, hh : integer;
   cl, ct: integer;
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
   setCamBounds(0, cl, ct, cw, ch);
   setCamBounds(1, cl + cw + 1, ct, cw, ch);
   setCamBounds(2, cl, ct + ch + 1, cw, ch);
   setCamBounds(3, cl + cw + 1, ct + ch + 1, cw, ch);

   FormPaint(nil);   
end;

procedure TCamDisplay.FormShow(Sender: TObject);
begin
   loadCamList;
end;

procedure TCamDisplay.FormHide(Sender: TObject);
begin
   clearAllCamViewers;
   if (MainForm.SpeedButton2.Down) then
      MainForm.SpeedButton2.Click;
end;

procedure TCamDisplay.loadCamList;
var
   cw: TVLCPlugin2;
   res: TDataRec;
   k: integer;
   h: integer;
begin
   clearAllCamViewers;
   res := MainForm.metaQuery('cams', '');
   try
      h := round(ClientWidth / 1.78);
      for k := 0 to res.Count - 1 do
      begin
         cw:= TVLCPlugin2.Create(Self);
         try
            cw.Parent := Self;
            cw.playlist.add(res.val(k, 2), NULL, NULL);
            cw.ControlInterface.Toolbar := false;
            cw.DefaultInterface.Toolbar := false;
            cw.video.aspectRatio := '16:9';
            cw.playlist.play;
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
begin
   for k := ControlCount - 1 downto 0 do
   begin
      TVLCPlugin2(Controls[k]).playlist.stop;
      TVLCPlugin2(Controls[k]).Free;
   end;
end;

procedure TCamDisplay.FormPaint(Sender: TObject);
var
   k: integer;
begin
   with Canvas do
   begin
      Brush.Style := bsSolid;
      Brush.Color := clBlack;
      Pen.Color := clBlack;
      Rectangle(0, 0, Width, Height);

      Brush.Style := bsClear;
      Pen.Color := clYellow;
      for k:= ControlCount - 1 downto 0 do
      begin
         Rectangle(Controls[k].Left - 1,
                   Controls[k].Top - 1,
                   Controls[k].Left + Controls[k].Width + 1,
                   Controls[k].Top + Controls[k].Height + 1);
      end;
   end;
end;

procedure TCamDisplay.FormCreate(Sender: TObject);
begin
   ControlStyle := ControlStyle + [csOpaque];
   ClientWidth := 1280;
   ClientHeight := 720;
end;

end.
