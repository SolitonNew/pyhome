unit AlertForm_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, IconButton;

const
   PHONE_CLICK = WM_USER + 100;

type
   TAlertTime = class
      fAudio: string;
      fNow: TDateTime;
   end;

  TAlertForm = class(TForm)
    Timer1: TTimer;
    Timer2: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure FormClick(Sender: TObject);
  private
    fDrawBitmap: TBitmap;
    fTexts: TStringList;
    procedure resizeAlert;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

procedure show(messageText, audio: String);
procedure hideAlert;
procedure setOnTop();

var
   AlertForm: TAlertForm;

implementation

uses DateUtils, MainForm_Unit;

{$R *.dfm}

procedure show(messageText, audio: String);
var
   AlertTime: TAlertTime;
begin
   try
      if (AlertForm = nil) then
         Application.CreateForm(TAlertForm, AlertForm);

      with AlertForm do
      begin
         try
            AlertTime:= TAlertTime.Create;
            AlertTime.fNow := Now;
            AlertTime.fAudio := audio;
            fTexts.AddObject(messageText, AlertTime);
            resizeAlert;
            Timer1.Enabled := true;
            ShowWindow(Handle, SW_SHOWNOACTIVATE);
            setOnTop();
         except
            hideAlert;
         end;
      end;
   except
   end;
end;

procedure hideAlert;
begin
   try
      if (AlertForm <> nil) then
      begin
         AlertForm.Timer1.Enabled := false;
         FreeAndNil(AlertForm);
      end;
   except
   end;
end;

procedure setOnTop();
begin
   if (AlertForm <> nil) then
      SetWindowPos(AlertForm.Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
end;

constructor TAlertForm.Create(AOwner: TComponent);
begin
   inherited;
   fTexts := TStringList.Create;
   fDrawBitmap := TBitmap.Create;
   fDrawBitmap.Canvas.Font.Name := 'Arial';
   fDrawBitmap.Canvas.Font.Charset := RUSSIAN_CHARSET;
   fDrawBitmap.Canvas.Font.Size := 9;
end;

destructor TAlertForm.Destroy;
var
   k: integer;
begin
   FreeAndNil(fDrawBitmap);
   for k := 0 to fTexts.Count - 1 do
      fTexts.Objects[k].Free; 
   fTexts.Free;
   inherited Destroy;
end;

procedure TAlertForm.resizeAlert;
var
   paddingW, paddingH: integer;

   procedure splitTextToLines(text: string; lines:TStringList);
   var
      i: integer;
      s: string;
      sl: TStringList;
   begin
      sl:= TStringList.Create;
      try
         sl.Delimiter := ' ';
         sl.DelimitedText := text;
         s := '';
         for i := 0 to sl.Count - 1 do
         begin
            if (fDrawBitmap.Canvas.TextWidth(s + sl[i]) > Width - paddingW) then
            begin
               lines.Add(s);
               s := '';
            end;
            s := s + sl[i] + ' ';

            if (i = sl.Count - 1) then
               lines.Add(s);
         end;
      finally
         sl.Free;
      end;
   end;

   function drawLine(s, audio: string): integer;
   var
      k: integer;
      sl: TStringList;
      t_h: integer;
      y: integer;
   begin
      t_h := fDrawBitmap.Canvas.TextHeight('W') - 2;
      sl:= TStringList.Create;
      try
         splitTextToLines(s, sl);

         y := fDrawBitmap.Height;
         fDrawBitmap.Height := fDrawBitmap.Height + sl.Count * t_h + paddingH;

         fDrawBitmap.Canvas.Brush.Color := clFuchsia;
         fDrawBitmap.Canvas.Pen.Color := Brush.Color;
         fDrawBitmap.Canvas.Rectangle(0, y, fDrawBitmap.Width, fDrawBitmap.Height);

         if (audio = 'alarm') then
         begin
            fDrawBitmap.Canvas.Brush.Color := clRed;
            fDrawBitmap.Canvas.Font.Color := clWhite;
         end
         else
         begin
            fDrawBitmap.Canvas.Brush.Color := $00333333;
            fDrawBitmap.Canvas.Font.Color := clWhite;
         end;
         fDrawBitmap.Canvas.Font.Charset := RUSSIAN_CHARSET;
         //fDrawBitmap.Canvas.Pen.Color := Brush.Color;
         fDrawBitmap.Canvas.Rectangle(0, y, fDrawBitmap.Width, fDrawBitmap.Height);

         y := y + paddingH div 2;

         for k:= 0 to sl.Count - 1 do
         begin
            fDrawBitmap.Canvas.TextOut(paddingW div 2, y + k * t_h, sl[k]);            
         end;
      finally
         sl.Free;
      end;
   end;

var
   k: integer;
begin
   if (fDrawBitmap = nil) then exit; 
   Width := MainForm.ClientWidth;

   paddingW := 20;
   paddingH := 20;
   fDrawBitmap.Width := Width;
   fDrawBitmap.Height := 0;

   for k := 0 to fTexts.Count - 1 do
      drawLine(fTexts[k], TAlertTime(fTexts.Objects[k]).fAudio);

   Height := fDrawBitmap.Height;
   Left := MainForm.Left + (MainForm.Width - MainForm.ClientWidth) div 2;
   Top := MainForm.Top + MainForm.Height - Height - 35;

   Repaint;
end;

procedure TAlertForm.Timer1Timer(Sender: TObject);
var
   nowU: int64;
   k: integer;
   isDel: Boolean;
begin
   isDel := false;
   nowU := DateTimeToUnix(Now) - 10;

   for k:= fTexts.Count - 1 downto 0 do
   begin
      if nowU > DateTimeToUnix(TAlertTime(fTexts.Objects[k]).fNow) then
      begin
         fTexts.Objects[k].Free;
         fTexts.Delete(k);
         isDel := true;
      end;
   end;

   if isDel then
   begin
      if (fTexts.Count > 0) then
         resizeAlert
      else
         hideAlert;
   end;
end;

procedure TAlertForm.FormPaint(Sender: TObject);
begin
   Canvas.Draw(0, 0, fDrawBitmap);
end;

procedure TAlertForm.Timer2Timer(Sender: TObject);
begin
   //setOnTop();
end;

procedure TAlertForm.FormClick(Sender: TObject);
begin
   hideAlert;
end;

end.
