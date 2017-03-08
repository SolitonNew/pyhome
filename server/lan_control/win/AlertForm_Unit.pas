unit AlertForm_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, IconButton;

const
   PHONE_CLICK = WM_USER + 100;

type
   TAlertTime = class
      fNow: TDateTime;
   end;

  TAlertForm = class(TForm)
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    fDrawBitmap: TBitmap;
    fTexts: TStringList;
    procedure resizeAlert;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

procedure show(messageText: String);
procedure hideAlert;

implementation

uses DateUtils, MainForm_Unit;

var
   AlertForm: TAlertForm;

{$R *.dfm}

procedure show(messageText: String);
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
            fTexts.AddObject(messageText, AlertTime);
            resizeAlert;
            Timer1.Enabled := true;
            ShowWindow(Handle, SW_SHOWNOACTIVATE);
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

constructor TAlertForm.Create(AOwner: TComponent);
begin
   inherited;
   fTexts := TStringList.Create;
   fDrawBitmap := TBitmap.Create;
   fDrawBitmap.Canvas.Font.Name := 'Arial';
   fDrawBitmap.Canvas.Font.Size := 9;
end;

destructor TAlertForm.Destroy;
begin
   fDrawBitmap.Free;
   fTexts.Free;
   inherited Destroy;
end;

procedure TAlertForm.resizeAlert;
var
   lines: TStringList;
   paddingW, paddingH: integer;


   procedure splitTextToLines;
   var
      k, i: integer;
      s: string;
      sl: TStringList;
   begin
      sl:= TStringList.Create;
      try
         sl.Delimiter := ' ';
         for k:= 0 to fTexts.Count - 1 do
         begin
            sl.DelimitedText := fTexts[k];
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
            lines.Add(chr(1));
         end;
      finally
         sl.Free;
      end;

      if (lines.Count > 0) then
         lines.Delete(lines.Count - 1);
   end;

var
   k, t_h, y: integer;
begin
   Width := MainForm.ClientWidth;

   paddingW := 20;
   paddingH := 20;
   lines:= TStringList.Create;
   try
      t_h := fDrawBitmap.Canvas.TextHeight('W') - 2;
      fDrawBitmap.Width := Width;
      splitTextToLines;
      fDrawBitmap.Height := lines.Count * t_h + paddingH;
      with fDrawBitmap.Canvas do
      begin
         Brush.Color := clSkyBlue;
         Pen.Color := Brush.Color;
         Rectangle(0, 0, fDrawBitmap.Width, fDrawBitmap.Height);
         for k := 0 to lines.Count - 1 do
         begin
            y := paddingH div 2 + k * t_h;
            if (lines[k] <> chr(1)) then
            begin
               TextOut(paddingW div 2, y, lines[k]);
            end
            else
            begin
               Pen.Color := clWhite;
               MoveTo(paddingW div 2, y + t_h div 2 + 1);
               LineTo(Width - paddingW div 2, y + t_h div 2 + 1);
            end;
         end;
      end;
   finally
      lines.Free;
   end;

   Height := fDrawBitmap.Height;
   Left := MainForm.Left + (MainForm.Width - MainForm.ClientWidth) div 2;
   Top := MainForm.Top + MainForm.Height - Height - 30;

   Repaint;
end;

procedure TAlertForm.Timer1Timer(Sender: TObject);
var
   nowU: int64;
   k: integer;
   isDel: Boolean;
begin
   nowU := DateTimeToUnix(Now) - 10;

   for k:= fTexts.Count - 1 downto 0 do
   begin
      if nowU > DateTimeToUnix(TAlertTime(fTexts.Objects[k]).fNow) then
      begin
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

end.
