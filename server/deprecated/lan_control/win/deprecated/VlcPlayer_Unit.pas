unit VlcPlayer_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, AXVLC_TLB;

type
   TVlcPlayPosEvent = procedure(Sender: TObject; pos, len: integer) of object;

  TVlcPlayer = class(TForm)
    VLCPlugin21: TVLCPlugin2;
    procedure VLCPlugin21MediaPlayerPositionChanged(ASender: TObject;
      position: Single);
    procedure VLCPlugin21MediaPlayerLengthChanged(ASender: TObject;
      length: Integer);
    procedure VLCPlugin21MediaPlayerPlaying(Sender: TObject);
    procedure VLCPlugin21MediaPlayerPaused(Sender: TObject);
    procedure VLCPlugin21MediaPlayerStopped(Sender: TObject);
    procedure VLCPlugin21MediaPlayerTimeChanged(ASender: TObject;
      time: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    fPlayLen: integer;
    fPlayPos: integer;
    fVolume: integer;
    fPlayState: integer;
    fOnPlayPosEvent: TVlcPlayPosEvent;
    fOnStopEvent: TNotifyEvent;
    fOnChange: TNotifyEvent;
    function GetPlayState: integer;
    procedure setPlayPos(const Value: integer);
    procedure setVolume(const Value: integer);
    procedure doChange();
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
    property onPlayPosEvent: TVlcPlayPosEvent read fOnPlayPosEvent write fOnPlayPosEvent;
    property onStopEvent: TNotifyEvent read fOnStopEvent write fOnStopEvent;
  end;

var
  VlcPlayer: TVlcPlayer;

implementation

uses Math;

{$R *.dfm}

{ TVlcPlayer }

function TVlcPlayer.GetPlayState: integer;
begin
   Result := fPlayState;
   //if (VLCPlugin21.playlist.isPlaying) then      Result := 2;
end;

procedure TVlcPlayer.pause;
begin
   VLCPlugin21.playlist.togglePause;
end;

procedure TVlcPlayer.play(id, typ: integer; s, title: string; withPause: boolean; seek: integer);
begin
   stop;
   VLCPlugin21.playlist.clear;
   VLCPlugin21.playlist.add(s, NULL, NULL);
   VLCPlugin21.playlist.play;
   playFileName := s;
   playFileID := id;

   //VLCPlugin21.Anchors.volume := 30;

   Show;
end;

procedure TVlcPlayer.setPlayPos(const Value: integer);
begin
   VLCPlugin21.input.time := Value * 1000;
end;

procedure TVlcPlayer.setVolume(const Value: integer);
begin
   fVolume := Value;
   VLCPlugin21.audio.volume := round(fVolume * 100 / 320);
end;

procedure TVlcPlayer.stop;
begin
   VLCPlugin21.playlist.stop;
   while VLCPlugin21.playlist.isPlaying do
      Sleep(10);
   Hide;
end;

procedure TVlcPlayer.VLCPlugin21MediaPlayerPositionChanged(ASender: TObject; position: Single);
begin
   //
end;

procedure TVlcPlayer.VLCPlugin21MediaPlayerLengthChanged(ASender: TObject; length: Integer);
begin
   fPlayLen := length div 1000;
   if (Assigned(fOnPlayPosEvent)) then
      fOnPlayPosEvent(Self, fPlayPos, fPlayLen);
end;

procedure TVlcPlayer.VLCPlugin21MediaPlayerPlaying(Sender: TObject);
begin
   fPlayState := 2;
   doChange();
end;

procedure TVlcPlayer.VLCPlugin21MediaPlayerPaused(Sender: TObject);
begin
   fPlayState := 3;
   doChange();
end;

procedure TVlcPlayer.VLCPlugin21MediaPlayerStopped(Sender: TObject);
begin
   fPlayState := 4;
   doChange();   
end;

procedure TVlcPlayer.doChange;
begin
   if (Assigned(fOnChange)) then
      fOnChange(Self);
end;

procedure TVlcPlayer.VLCPlugin21MediaPlayerTimeChanged(ASender: TObject;
  time: Integer);
begin
   fPlayPos := time div 1000;
   if (Assigned(fOnPlayPosEvent)) then
      fOnPlayPosEvent(Self, fPlayPos, fPlayLen);
end;

procedure TVlcPlayer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   stop;
end;

end.
