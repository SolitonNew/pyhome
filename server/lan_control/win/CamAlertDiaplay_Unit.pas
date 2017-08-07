unit CamAlertDiaplay_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, AXVLC_TLB, ExtCtrls, DataRec_Unit;

type
  TCamAlertDiaplay = class(TForm)
    VLCPlugin21: TVLCPlugin2;
    CamFullScreenBtn: TPanel;
    Image1: TImage;
    Timer1: TTimer;
    procedure FormHide(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure ShowForAlertId(id: integer);
  end;

var
  CamAlertDiaplay: TCamAlertDiaplay;

implementation

uses MainForm_Unit, CamDisplay_Unit;

{$R *.dfm}

{ TCamAlertDiaplay }

procedure TCamAlertDiaplay.ShowForAlertId(id: integer);
var
   res: TDataRec;
   k: integer;
   url: string;
begin
   if (CamDisplay.Visible) then exit;

   Timer1.Enabled := false;
   Timer1.Enabled := true;   
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

   if (url = '') then exit;

   VLCPlugin21.playlist.stop;
   VLCPlugin21.playlist.clear;
   VLCPlugin21.playlist.add(url, NULL, NULL);
   VLCPlugin21.playlist.play;
   Show;
end;

procedure TCamAlertDiaplay.FormHide(Sender: TObject);
begin
   VLCPlugin21.playlist.stop;
   VLCPlugin21.playlist.clear;
   Timer1.Enabled := false;   
end;

procedure TCamAlertDiaplay.Timer1Timer(Sender: TObject);
begin
   Hide;
end;

procedure TCamAlertDiaplay.Image1Click(Sender: TObject);
begin
   Hide;
   MainForm.Image1Click(nil);
end;

procedure TCamAlertDiaplay.FormCreate(Sender: TObject);
begin
   ClientWidth := 640;
   ClientHeight := 360;
end;

end.
