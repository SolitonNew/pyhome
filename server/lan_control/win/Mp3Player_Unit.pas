unit Mp3Player_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ACS_Classes, ACS_WinMedia, ACS_smpeg, ACS_DXAudio, Buttons,
  ComCtrls, StdCtrls, ExtCtrls, HTTPSend;

type
  TMp3PlayPosEvent = procedure(Sender: TObject; pos, len: integer) of object;

  TMp3Player = class(TForm)
    DXAudioOut1: TDXAudioOut;
    MP3In1: TMP3In;
    ProgressBar1: TProgressBar;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    ProgressBar2: TProgressBar;
    Label1: TLabel;
    Label2: TLabel;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure ProgressBar1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ProgressBar1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ProgressBar2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ProgressBar2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure DXAudioOut1Done(Sender: TComponent);
    procedure FormDestroy(Sender: TObject);
  private
    fVolume: integer;
    fOnChange: TNotifyEvent;
    fOnPlayPosEvent: TMp3PlayPosEvent;
    fOnStopEvent: TNotifyEvent;
    fLockDoneMessage: Boolean;
    fPlayLen: integer;
    fPlayPos: integer;
    procedure setVolume(const Value: integer);
    procedure doChange();
    procedure doPlayPosEvent();
    function GetPlayState: integer;
    procedure setPlayPos(const Value: integer);
  public
    playFileName: string;
    playFileID: integer;
    procedure play(id, typ: integer; s, title: string; withPause:boolean = false; seek: integer = 0);
    procedure pause();
    procedure stop();
    property volume: integer read fVolume write setVolume;
    property playLen: integer read fPlayLen;
    property playPos: integer read fPlayPos write setPlayPos;    
    property playState: integer read GetPlayState;    
    property onChange:TNotifyEvent read fOnChange write fOnChange;
    property onPlayPosEvent: TMp3PlayPosEvent read fOnPlayPosEvent write fOnPlayPosEvent;
    property onStopEvent: TNotifyEvent read fOnStopEvent write fOnStopEvent;
  end;

var
  Mp3Player: TMp3Player;

implementation

uses Math;

{$R *.dfm}

procedure TMp3Player.Timer1Timer(Sender: TObject);
begin
   if ((DXAudioOut1.Status = tosPlaying) or (DXAudioOut1.Status = tosPaused)) then
   begin
      fPlayLen := MP3In1.TotalTime;
      fPlayPos := DXAudioOut1.TimeElapsed;
   end
   else
   begin
      fPlayLen := 0;
      fPlayPos := 0;
   end;


   if ((ProgressBar1.Max <> fPlayLen) or (ProgressBar1.Position <> fPlayPos)) then
   begin
      ProgressBar1.Max := fPlayLen;
      ProgressBar1.Position := fPlayPos;
      doPlayPosEvent;
   end;
end;

procedure TMp3Player.ProgressBar1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if (ssLeft in Shift) and (DXAudioOut1.Status <> tosIdle) then
   begin
      MP3In1.Seek(round(MP3In1.TotalSamples / ProgressBar1.ClientWidth * X));
   end;
end;

procedure TMp3Player.ProgressBar1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
   if (ssLeft in Shift) then
   begin
      ProgressBar1.Position := round(ProgressBar1.Max / ProgressBar1.ClientWidth * X);
   end;
end;

procedure TMp3Player.ProgressBar2MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   if (ssLeft in Shift) then
   begin
      ProgressBar2.Position := round(ProgressBar2.Max / ProgressBar2.ClientWidth * X);
      setVolume(ProgressBar2.Position);
      doChange();
   end;
end;

procedure TMp3Player.ProgressBar2MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
   if (ssLeft in Shift) then
   begin
      ProgressBar2.Position := round(ProgressBar2.Max / ProgressBar2.ClientWidth * X);
      setVolume(ProgressBar2.Position);
      doChange();
   end;
end;

procedure TMp3Player.setVolume(const Value: integer);
begin
   if fVolume <> Value then
   begin
      fVolume := Value;
      if (Value > 0) then
         DXAudioOut1.Volume := -4000 + round(40 * Value)
      else
         DXAudioOut1.Volume := -10000;
   {-4000 = 1
        0 = 320}
   end;
end;

procedure TMp3Player.doChange;
begin
   if (Assigned(fOnChange)) then
   begin
      fOnChange(Self);
   end;
end;

procedure TMp3Player.doPlayPosEvent;
begin
   if (Assigned(fOnPlayPosEvent)) then
   begin
      fOnPlayPosEvent(Self, fPlayPos, fPlayLen);
   end;
end;

procedure TMp3Player.DXAudioOut1Done(Sender: TComponent);
begin
   if (Assigned(fOnStopEvent) and (not fLockDoneMessage) and (fPlayLen > 0) and (fPlayPos = fPlayLen)) then
   begin
      fOnStopEvent(Self);
   end;
end;

procedure TMp3Player.pause;
begin
   case DXAudioOut1.Status of
      tosPlaying: DXAudioOut1.Pause;
      tosPaused: DXAudioOut1.Resume;
   end;
   doChange();
end;

procedure TMp3Player.play(id, typ: integer; s, title: string; withPause: boolean; seek: integer);
var
   f_name: string;
   is_ok: Boolean;
   HTTP: THTTPSend;
begin
   stop;

   Label1.Caption := title;
   // typ:2 audio
   is_ok := False;
   f_name := GetEnvironmentVariable('TEMP') + '\lan_control.mp3';

   HTTP:= THTTPSend.Create;
   try
      HTTP.HTTPMethod('GET', s);
      HTTP.Document.SaveToFile(f_name);
      is_ok := True;
   finally
      HTTP.Free;
   end;

   if (is_ok) then
   begin
      MP3In1.FileName := f_name;
      DXAudioOut1.Run;

      playFileName := s;
      playFileID := id;

      doChange();
   end;

   fLockDoneMessage := False;   
end;

procedure TMp3Player.stop;
begin
   fLockDoneMessage := True;
   DXAudioOut1.Stop();
   while DXAudioOut1.Status <> tosIdle do
      Sleep(10);

   doChange();
end;

procedure TMp3Player.FormDestroy(Sender: TObject);
begin
   stop;
end;

function TMp3Player.GetPlayState: integer;
begin
   case DXAudioOut1.Status of
      tosPlaying: Result := 2;
      tosPaused: Result := 3;
      tosIdle: Result := 4;
   end;
end;

procedure TMp3Player.setPlayPos(const Value: integer);
begin
   if ((DXAudioOut1.Status = tosPlaying) or (DXAudioOut1.Status = tosPaused)) then
   begin
      MP3In1.Seek(round(MP3In1.TotalSamples / MP3In1.TotalTime * Value));
      fPlayPos := value;
   end;
end;

end.
