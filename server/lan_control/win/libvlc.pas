unit libvlc;

interface

uses
   Windows, Dialogs, Classes, SysUtils, SyncObjs, Registry;

const
   LIBVLC_ROOT = 'vizier';
   LIBVLC_SNAPSHOTS = 'vizier\snapshots';


const
   libvlc_MediaMetaChanged              = 0;
   libvlc_MediaSubItemAdded             = 1;
   libvlc_MediaDurationChanged          = 2;
   libvlc_MediaParsedChanged            = 3;
   libvlc_MediaFreed                    = 4;
   libvlc_MediaStateChanged             = 5;
   libvlc_MediaSubItemTreeAdded         = 6;

   libvlc_MediaPlayerMediaChanged       = $100;
   libvlc_MediaPlayerNothingSpecial     = $101;
   libvlc_MediaPlayerOpening            = $102;
   libvlc_MediaPlayerBuffering          = $103;
   libvlc_MediaPlayerPlaying            = $104;
   libvlc_MediaPlayerPaused             = $105;
   libvlc_MediaPlayerStopped            = $106;
   libvlc_MediaPlayerForward            = $107;
   libvlc_MediaPlayerBackward           = $108;
   libvlc_MediaPlayerEndReached         = $109;
   libvlc_MediaPlayerEncounteredError   = $10A;
   libvlc_MediaPlayerTimeChanged        = $10B;
   libvlc_MediaPlayerPositionChanged    = $10C;
   libvlc_MediaPlayerSeekableChanged    = $10D;
   libvlc_MediaPlayerPausableChanged    = $10E;
   libvlc_MediaPlayerTitleChanged       = $10F;
   libvlc_MediaPlayerSnapshotTaken      = $110;
   libvlc_MediaPlayerLengthChanged      = $111;
   libvlc_MediaPlayerVout               = $112;
   libvlc_MediaPlayerScrambledChanged   = $113;
   libvlc_MediaPlayerESAdded            = $114; // VLC 3.0.0
   libvlc_MediaPlayerESDeleted          = $115; // VLC 3.0.0
   libvlc_MediaPlayerESSelected         = $116; // VLC 3.0.0
   libvlc_MediaPlayerCorked             = $117;
   libvlc_MediaPlayerUncorked           = $118;
   libvlc_MediaPlayerMuted              = $119;
   libvlc_MediaPlayerUnmuted            = $11A;
   libvlc_MediaPlayerAudioVolume        = $11B;
   libvlc_MediaPlayerAudioDevice        = $11C; // VLC 3.0.0
   libvlc_MediaPlayerChapterChanged     = $11D; // VLC 3.0.0

   libvlc_MediaListItemAdded            = $200;
   libvlc_MediaListWillAddItem          = $201;
   libvlc_MediaListItemDeleted          = $202;
   libvlc_MediaListWillDeleteItem       = $203;
   libvlc_MediaListEndReached           = $204;

   libvlc_MediaListViewItemAdded        = $300;
   libvlc_MediaListViewWillAddItem      = $301;
   libvlc_MediaListViewItemDeleted      = $302;
   libvlc_MediaListViewWillDeleteItem   = $303;

   libvlc_MediaListPlayerPlayed         = $400;
   libvlc_MediaListPlayerNextItemSet    = $401;
   libvlc_MediaListPlayerStopped        = $402;

   {$IFDEF USE_VLC_DEPRECATED_API}
   libvlc_MediaDiscovererStarted        = $500;
   libvlc_MediaDiscovererEnded          = $501;
   {$ENDIF}
   libvlc_RendererDiscovererItemAdded   = $502;
   libvlc_RendererDiscovererItemDeleted = $503;

   libvlc_VlmMediaAdded                 = $600;
   libvlc_VlmMediaRemoved               = $601;
   libvlc_VlmMediaChanged               = $602;
   libvlc_VlmMediaInstanceStarted       = $603;
   libvlc_VlmMediaInstanceStopped       = $604;
   libvlc_VlmMediaInstanceStatusInit    = $605;
   libvlc_VlmMediaInstanceStatusOpening = $606;
   libvlc_VlmMediaInstanceStatusPlaying = $607;
   libvlc_VlmMediaInstanceStatusPause   = $608;
   libvlc_VlmMediaInstanceStatusEnd     = $609;
   libvlc_VlmMediaInstanceStatusError   = $60A;

type
   plibvlc_instance_t        = type Pointer;
   plibvlc_media_player_t    = type Pointer;
   plibvlc_media_t           = type Pointer;
   plibvlc_event_manager_t   = type Pointer;
	plibvlc_event_type_t      = type Integer;

type
   libvlc_time_t_ptr = ^libvlc_time_t;
   libvlc_time_t = Int64;

type
  	libvlc_state_t = (
      libvlc_NothingSpecial, // 0,
      libvlc_Opening,        // 1,
    
      // Deprecated value. Check the
      // libvlc_MediaPlayerBuffering event to know the
      // buffering state of a libvlc_media_player
      libvlc_Buffering,      // 2,

      libvlc_Playing,        // 3,
      libvlc_Paused,         // 4,
      libvlc_Stopped,        // 5,
      libvlc_Ended,          // 6,
      libvlc_Error           // 7
	);   

type
   event_media_duration_changed_t = record
      new_duration : Int64;
   end;

type
   media_parsed_changed_t = record
	   new_status : Integer; // see @ref libvlc_media_parsed_status_t
   end;

type
   media_state_changed_t = record
      new_state : libvlc_state_t; // see @ref libvlc_state_t
   end;

type
   media_player_buffering_t = record
      new_cache : Single; // float
   end;

type
   media_player_chapter_changed_t = record
      new_chapter : Integer;
   end;

type
   media_player_time_changed_t = record
      new_time : libvlc_time_t;
   end;
  
type
   media_player_position_changed_t = record
      new_position : Single; // float
   end;

type
   media_player_seekable_changed_t = record
      new_seekable : Integer;
   end;

type
   media_player_pausable_changed_t = record
      new_pausable : Integer;
   end;

type
   media_player_vout_t = record
      new_count : Integer;
   end;

type
   media_player_scrambled_changed_t = record
      new_scrambled : Integer;
   end;

type
   media_player_snapshot_taken_t = record
      psz_filename : PAnsiChar;
   end;

type
   media_player_length_changed_t = record
      new_length : libvlc_time_t;
   end;

type
   media_player_title_changed_t = record
      new_title : Integer;
   end;

type
   vlm_media_event_t = record
      psz_media_name    : PAnsiChar;
      psz_instance_name : PAnsiChar;
   end;

// Extra MediaPlayer

type
   media_player_media_changed_t = record
      new_media : plibvlc_media_t;
   end;

type
   media_player_audio_volume_t = record
      volume : Single;
   end;

type
   media_player_audio_device_t = record
      device : PAnsiChar;
   end;

	libvlc_event_t_ptr = ^libvlc_event_t;
   
   libvlc_event_t = record
      event_type : plibvlc_event_type_t;
      p_obj      : Pointer;              (* Object emitting the event *)

      case plibvlc_event_type_t of
         // media descriptor
         libvlc_MediaDurationChanged          : (media_duration_changed           : event_media_duration_changed_t);
         libvlc_MediaParsedChanged            : (media_parsed_changed             : media_parsed_changed_t);
         libvlc_MediaStateChanged             : (media_state_changed              : media_state_changed_t);

         // media instance
         libvlc_MediaPlayerBuffering          : (media_player_buffering           : media_player_buffering_t);
         libvlc_MediaPlayerChapterChanged     : (media_player_chapter_changed     : media_player_chapter_changed_t);
         libvlc_MediaPlayerPositionChanged    : (media_player_position_changed    : media_player_position_changed_t);
         libvlc_MediaPlayerTimeChanged        : (media_player_time_changed        : media_player_time_changed_t);
         libvlc_MediaPlayerTitleChanged       : (media_player_title_changed       : media_player_title_changed_t);
         libvlc_MediaPlayerSeekableChanged    : (media_player_seekable_changed    : media_player_seekable_changed_t);
         libvlc_MediaPlayerPausableChanged    : (media_player_pausable_changed    : media_player_pausable_changed_t);
         libvlc_MediaPlayerScrambledChanged   : (media_player_scrambled_changed   : media_player_scrambled_changed_t);
         libvlc_MediaPlayerVout               : (media_player_vout                : media_player_vout_t);

         // snapshot taken
         libvlc_MediaPlayerSnapshotTaken      : (media_player_snapshot_taken      : media_player_snapshot_taken_t);

         // Length changed
         libvlc_MediaPlayerLengthChanged      : (media_player_length_changed      : media_player_length_changed_t);

         // VLM media
         libvlc_VlmMediaAdded,
         libvlc_VlmMediaRemoved,
         libvlc_VlmMediaChanged,
         libvlc_VlmMediaInstanceStarted,
         libvlc_VlmMediaInstanceStopped,
         libvlc_VlmMediaInstanceStatusInit,
         libvlc_VlmMediaInstanceStatusOpening,
         libvlc_VlmMediaInstanceStatusPlaying,
         libvlc_VlmMediaInstanceStatusPause,
         libvlc_VlmMediaInstanceStatusEnd,
         libvlc_VlmMediaInstanceStatusError   : (vlm_media_event : vlm_media_event_t);

         // Extra MediaPlayer
         libvlc_MediaPlayerMediaChanged       : (media_player_media_changed       : media_player_media_changed_t);
         libvlc_MediaPlayerESAdded,
         libvlc_MediaPlayerESDeleted,
         libvlc_MediaPlayerAudioVolume        : (media_player_audio_volume        : media_player_audio_volume_t);
         libvlc_MediaPlayerAudioDevice        : (media_player_audio_device        : media_player_audio_device_t);
		end;   
   
   plibvlc_event_callback_t = procedure(p_event: libvlc_event_t_ptr; p_data: Pointer); cdecl;

procedure init(player: integer; Handle: Cardinal);
procedure play(player: integer; url: string; cacheTime: integer = 5);
function size(player: integer): TPoint;
function getPlayUrl(player: integer): string;
function getPlayCacheTime(player: integer): integer;
function status(player: integer): integer;
procedure snapshot(player: integer; filename: string);
//procedure vlcReplay;
//function vlcSize: TPoint;
//function vlcGetStatus: libvlc_state_t;

type
   TLibVlcThread = class(TThread)
   protected
      procedure execute; override;
   end;

type
   TVlcPlayer = record
   	vlcPanelHandle: cardinal;
      vlcInstance: plibvlc_instance_t;
      vlcMedia: plibvlc_media_t;
      vlcMediaPlayer: plibvlc_media_player_t;
      //vlcEventManager: plibvlc_event_manager_t;
      vlcUrl: string;
      vlcStatus: integer;
      vlcCacheTime: integer;
      vlcWH: TPoint;
      prevUrl: string;
      prevCache: integer;
      replay: boolean;
      lastPlayTime: TDateTime;
   end;

implementation

var
   vlcPlayers: array[1..10] of TVlcPlayer;

var
   libVlcThread: TLibVlcThread;
   libVlcThreadCS: TCriticalSection;

var
   libvlc_media_new_path              : function(p_instance: Plibvlc_instance_t; path: PAnsiChar): Plibvlc_media_t; cdecl;
   libvlc_media_new_location          : function(p_instance: plibvlc_instance_t; psz_mrl: PAnsiChar): Plibvlc_media_t; cdecl;
   libvlc_media_add_option            : procedure(p_media_player: Plibvlc_media_player_t; psz_options: PAnsiChar; i_flags: integer); cdecl;
   libvlc_media_player_new_from_media : function(p_media: Plibvlc_media_t): Plibvlc_media_player_t; cdecl;
   libvlc_media_player_set_hwnd       : procedure(p_media_player: Plibvlc_media_player_t; drawable: Pointer); cdecl;
   libvlc_media_player_play           : procedure(p_media_player: Plibvlc_media_player_t); cdecl;
   libvlc_media_player_pause          : procedure(p_media_player: Plibvlc_media_player_t); cdecl;   
   libvlc_media_player_stop           : procedure(p_media_player: Plibvlc_media_player_t); cdecl;
   libvlc_media_player_release        : procedure(p_media_player: Plibvlc_media_player_t); cdecl;
   libvlc_media_player_is_playing     : function(p_media_player: Plibvlc_media_player_t): Integer; cdecl;
   libvlc_media_player_get_state      : function(p_media_player: Plibvlc_media_player_t): libvlc_state_t; cdecl;
   libvlc_media_release               : procedure(p_media: Plibvlc_media_t); cdecl;
   libvlc_new                         : function(argc: Integer; argv: PAnsiChar): Plibvlc_instance_t; cdecl;
   libvlc_release                     : procedure(p_instance: Plibvlc_instance_t); cdecl;
   libvlc_video_set_mouse_input       : procedure(p_media_player: Plibvlc_media_player_t; p_on: LongBool); cdecl;
   libvlc_video_set_key_input         : procedure(p_media_player: Plibvlc_media_player_t; p_on: LongBool); cdecl;
   libvlc_video_get_size              : function(p_media_player: Plibvlc_media_player_t; p_num: integer; var p_width, p_height: integer) : Integer; cdecl;
   libvlc_video_set_aspect_ratio      : procedure(p_media_player: Plibvlc_media_player_t; aspect:PChar); cdecl;
   libvlc_media_player_event_manager  : function(p_media_player: Plibvlc_media_player_t): plibvlc_event_manager_t; cdecl;
   libvlc_event_attach                : function(p_event_manager: plibvlc_event_manager_t; i_event_type: plibvlc_event_type_t; f_callback: plibvlc_event_callback_t; user_data: Pointer): integer; cdecl;
   libvlc_video_take_snapshot         : procedure(p_media_player: Plibvlc_media_player_t; num: byte; psz_filepath: PAnsiChar; i_width, i_height:  LongWord); cdecl;

   vlcLib: integer;

function LoadVLCLibrary: integer;
var
   APath, vlcPath: string;
   reg: TRegistry;
begin
   vlcPath := '';
	reg := TRegistry.Create;
   try
      reg.RootKey := HKEY_LOCAL_MACHINE;
      if (reg.OpenKey('SoftWare\Microsoft\Windows\CurrentVersion\App Paths\vlc.exe', false)) then
      begin
      	vlcPath := reg.ReadString('Path');
      end;
   finally
      reg.Free;
   end;


	APath := ExtractFileDir(ParamStr(0));

   Result := LoadLibrary(PAnsiChar(vlcPath + '\libvlccore.dll'));
   Result := LoadLibrary(PAnsiChar(vlcPath + '\libvlc.dll'));
end;

procedure GetAProcAddress(handle: integer; var addr: Pointer; procName: string);
begin
   addr := GetProcAddress(handle, PAnsiChar(procName));
end;

procedure LoadVLCFunctions(vlcHandle: integer);
begin
   GetAProcAddress(vlcHandle, @libvlc_new, 'libvlc_new');
   GetAProcAddress(vlcHandle, @libvlc_media_new_location, 'libvlc_media_new_location');
   GetAProcAddress(vlcHandle, @libvlc_media_add_option, 'libvlc_media_add_option');
   GetAProcAddress(vlcHandle, @libvlc_media_player_new_from_media, 'libvlc_media_player_new_from_media');
   GetAProcAddress(vlcHandle, @libvlc_media_release, 'libvlc_media_release');
   GetAProcAddress(vlcHandle, @libvlc_media_player_set_hwnd, 'libvlc_media_player_set_hwnd');
   GetAProcAddress(vlcHandle, @libvlc_media_player_play, 'libvlc_media_player_play');
   GetAProcAddress(vlcHandle, @libvlc_media_player_pause, 'libvlc_media_player_pause');
   GetAProcAddress(vlcHandle, @libvlc_media_player_stop, 'libvlc_media_player_stop');
   GetAProcAddress(vlcHandle, @libvlc_media_player_release, 'libvlc_media_player_release');
   GetAProcAddress(vlcHandle, @libvlc_release, 'libvlc_release');
   GetAProcAddress(vlcHandle, @libvlc_media_player_is_playing, 'libvlc_media_player_is_playing');
   GetAProcAddress(vlcHandle, @libvlc_media_player_get_state, 'libvlc_media_player_get_state');
   GetAProcAddress(vlcHandle, @libvlc_media_new_path, 'libvlc_media_new_path');
   GetAProcAddress(vlcHandle, @libvlc_video_set_mouse_input, 'libvlc_video_set_mouse_input');
   GetAProcAddress(vlcHandle, @libvlc_video_set_key_input, 'libvlc_video_set_key_input');
   GetAProcAddress(vlcHandle, @libvlc_video_get_size, 'libvlc_video_get_size');
   GetAProcAddress(vlcHandle, @libvlc_video_set_aspect_ratio, 'libvlc_video_set_aspect_ratio');
   GetAProcAddress(vlcHandle, @libvlc_media_player_event_manager, 'libvlc_media_player_event_manager');
   GetAProcAddress(vlcHandle, @libvlc_video_take_snapshot, 'libvlc_video_take_snapshot');
end;

procedure init(player: integer; Handle: Cardinal);
begin
   with vlcPlayers[player] do
   begin
   	vlcPanelHandle := Handle;
   end;
end;

procedure play(player: integer; url: string; cacheTime: integer = 5);
begin
   libVlcThreadCS.Enter;
   try
      vlcPlayers[player].vlcUrl := url;
      vlcPlayers[player].vlcCacheTime := cacheTime;
      vlcPlayers[player].replay := true;
		vlcPlayers[player].lastPlayTime := now;
   finally
      libVlcThreadCS.Leave;
   end;
end;

function size(player: integer): TPoint;
begin
   Result := vlcPlayers[player].vlcWH;
   if (Result.X > 10000) then Result.X := 0;
   if (Result.Y > 10000) then Result.Y := 0;
end;

function getPlayUrl(player: integer): string;
begin
   libVlcThreadCS.Enter;
   try
      Result := vlcPlayers[player].vlcUrl;
   finally
      libVlcThreadCS.Leave;
   end;
end;

function getPlayCacheTime(player: integer): integer;
begin
   libVlcThreadCS.Enter;
   try
      Result := vlcPlayers[player].vlcCacheTime;
   finally
      libVlcThreadCS.Leave;
   end;
end;

function status(player: integer): integer;
begin
   Result := vlcPlayers[player].vlcStatus;
end;

procedure snapshot(player: integer; filename: string);
begin
  	if not Assigned(vlcPlayers[player].vlcMediaPlayer) then Exit;
   if (size(player).X = 0) or (size(player).Y = 0) then exit;

   filename := ExtractFileDir(ParamStr(0)) + '\' + LIBVLC_SNAPSHOTS + '\' + filename;

   libVlcThreadCS.Enter;
   try
      libvlc_video_take_snapshot(vlcPlayers[player].vlcMediaPlayer, 0, PAnsiChar(filename), size(player).X, size(player).Y);
   finally
   	libVlcThreadCS.Leave;
   end;
end;

procedure vlcStop(player: integer);
begin
  	if not Assigned(vlcPlayers[player].vlcMediaPlayer) then Exit;

   with vlcPlayers[player] do
   begin
      libvlc_media_player_stop(vlcMediaPlayer);
      while (libvlc_media_player_is_playing(vlcMediaPlayer) > 0) do 
      begin
         Sleep(100);
      end;
      libvlc_media_player_release(vlcMediaPlayer);
      vlcMediaPlayer := nil;
      libvlc_release(vlcInstance);

      lastPlayTime := now;
   end;
end;

procedure vlcPlay(player: integer; url: string; cacheTime: integer = 5);
begin
  	if (vlcPlayers[player].vlcPanelHandle = 0) then Exit;

	vlcStop(player);

   with vlcPlayers[player] do
   begin
   	replay := false;
   
      vlcInstance := libvlc_new(0, nil);

      vlcMedia := libvlc_media_new_location(vlcInstance, PAnsiChar(url));
      vlcMediaPlayer := libvlc_media_player_new_from_media(vlcMedia);
      libvlc_media_add_option(vlcMedia, PAnsiChar(':network-caching=' + IntToStr(cacheTime)), 0);
      libvlc_media_add_option(vlcMedia, PAnsiChar(':rtsp-tcp'), 0);
      
      libvlc_media_release(vlcMedia);
      libvlc_media_player_set_hwnd(vlcMediaPlayer, Pointer(vlcPanelHandle));
      libvlc_media_player_play(vlcMediaPlayer);

      libvlc_video_set_aspect_ratio(vlcMediaPlayer, '16:9');
      libvlc_video_set_mouse_input(vlcMediaPlayer, false);
      libvlc_video_set_key_input(vlcMediaPlayer, false);
   end;
end;

function vlcSize(player: integer): TPoint;
var
   w, h: integer;
begin
   Result := Point(0, 0);
	if not Assigned(vlcPlayers[player].vlcMediaPlayer) then Exit;

   libvlc_video_get_size(vlcPlayers[player].vlcMediaPlayer, 0, w, h);
   Result := Point(w, h);
end;

function vlcCheckPlaying(player: integer): boolean;
begin
   Result := false;
	if not Assigned(vlcPlayers[player].vlcMediaPlayer) then Exit;
   Result := libvlc_media_player_is_playing(vlcPlayers[player].vlcMediaPlayer) > 0;
end;

function vlcGetStatus(player: integer): libvlc_state_t;
begin
   Result := libvlc_NothingSpecial;
	if not Assigned(vlcPlayers[player].vlcMediaPlayer) then Exit;
   Result := libvlc_media_player_get_state(vlcPlayers[player].vlcMediaPlayer);
end;


{ TLibVlcThread }

procedure TLibVlcThread.execute;
var
   url: string;
   cache: integer;
   k: integer;
begin
   inherited;
	while not Terminated do
   begin
   	for k := 1 to Length(vlcPlayers) do
      begin
      	try        
            if (vlcPlayers[k].vlcPanelHandle > 0) then
            begin
               if (vlclib = 0) then // Библиотека не загружена - грузим ее
               begin
                  vlclib := LoadVLCLibrary;
                  if vlclib > 0 then LoadVLCFunctions(vlclib);
               end;

               if (vlcLib > 0) then // Библиотека загружена
               begin
                  vlcPlayers[k].vlcStatus := integer(vlcGetStatus(k));
         
                  libVlcThreadCS.Enter;
                  try
                     url := vlcPlayers[k].vlcUrl;
                     cache := vlcPlayers[k].vlcCacheTime;
                  finally
                     libVlcThreadCS.Leave;
                  end;

                  if (vlcPlayers[k].prevUrl <> url) or 
                     (vlcPlayers[k].prevCache <> cache) or 
                     (vlcPlayers[k].replay) or 
                     (now - vlcPlayers[k].lastPlayTime > 120 / (24 * 3600)) then vlcPlayers[k].vlcStatus := -1;

                  case vlcPlayers[k].vlcStatus of
                     1, 2, 3, 4, 5: // Статусы которые при проигрывании
                     begin
                        vlcPlayers[k].vlcWH := vlcSize(k);
                     end;
                     else
                     begin
                        vlcPlayers[k].vlcWH := Point(0, 0);
                        vlcStop(k);
                        if (url <> '') and (cache >= 0) then vlcPlay(k, url, cache);
                     end;
                  end;

                  vlcPlayers[k].prevUrl := url;
                  vlcPlayers[k].prevCache := cache;
               end;

               Sleep(10);
            end
            else
            begin
               vlcPlayers[k].vlcStatus := -1;
            end;
         except
            Sleep(100);
         end;	      
      end;
      Sleep(50);      
   end;

   for k := 1 to Length(vlcPlayers) do
	begin
      try
		   vlcStop(k);
      except
      end;
   end;
   FreeLibrary(vlclib);
end;

initialization
   libVlcThreadCS := TCriticalSection.Create;

	libVlcThread := TLibVlcThread.Create(true);
   libVlcThread.Priority := tpIdle;
	libVlcThread.FreeOnTerminate := true;
   libVlcThread.Resume;
finalization
   libVlcThread.Terminate;
   WaitForSingleObject(libVlcThread.Handle, 10000);

   libVlcThreadCS.Free;
end.
