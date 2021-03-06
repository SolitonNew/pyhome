unit Vlc_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DlgMessagesRU, StdCtrls, ExtCtrls, ScktComp, ShellApi, Buttons;

const
   MESS_STOP = WM_USER + 1;
   VLC_COMMAND = WM_USER + 2;

type
  TPlayPosEvent = procedure(Sender: TObject; pos, len: integer) of object;   

  TVlcPlayer = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    ClientSocket1: TClientSocket;
    Timer1: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    SpeedButton1: TSpeedButton;
    procedure ClientSocket1Connect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Disconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientSocket1Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
  private
    fPostPlayFile: string;
    fPostPlayTitle: string;
    // -------------------------
    fPlayFile: string;
    fPlayTitle: string;
    fPlayFileID: integer;
    fPlayFileTYP: integer;
    fPlayWithPause: boolean;
    fPlaySeek: integer;
    // -------------------------
    fPrevForegroundWindow:cardinal;
    fPlayLen, fPlayPos: integer;
    fPlayState: integer;
    fVlcHandler: cardinal;
    fStartPlayOK: boolean;
    fVolume: integer;
    fOnChange: TNotifyEvent;
    fonPlayPosEvent: TPlayPosEvent;
    fOnStopEvent: TNotifyEvent;
    procedure setPlayPos(const Value: integer);
    procedure setVolume(const Value: integer);
    procedure doChange();
    procedure setState(s: integer);
    procedure doPlayPosEvent();
    procedure doStopEvent();
    procedure messageStop(var Message: TMessage); message MESS_STOP;
    procedure messageVlcCommand(var Message: TMessage); message VLC_COMMAND;
  public
    fVlcExe:string;
    procedure play(id, typ: integer; s, title: string; withPause:boolean = false; seek: integer = 0);
    procedure playUrl(url: string);
    procedure pause();
    procedure stop();
    property playLen: integer read fPlayLen;
    property playPos: integer read fPlayPos write setPlayPos;
    property playFileName: string read fPlayFile;
    property playFileID: integer read fPlayFileID;
    property playState: integer read fPlayState;
    property volume: integer read fVolume write setVolume;
    property onChange:TNotifyEvent read fOnChange write fOnChange;
    property onPlayPosEvent: TPlayPosEvent read fonPlayPosEvent write fonPlayPosEvent;
    property onStopEvent: TNotifyEvent read fOnStopEvent write fOnStopEvent;
  end;

var
  VlcPlayer: TVlcPlayer;

implementation

uses Math, PropertysForm_Unit;

{$R *.dfm}

procedure TVlcPlayer.ClientSocket1Connect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   Memo1.Clear;
   Memo1.Lines.Add('CONNECT');
   fStartPlayOK := false;
   PostMessage(Handle, VLC_COMMAND, 10, 0); // sendVlcComm('clear');
   fPostPlayFile := AnsiToUtf8(fPlayFile);
   PostMessage(Handle, VLC_COMMAND, 1, 0); //sendVlcComm('add ' + AnsiToUtf8(fPlayFile));
   sleep(100);
   PostMessage(Handle, VLC_COMMAND, 2, 0); //sendVlcComm('play');
   fPostPlayTitle := AnsiToUtf8(fPlayTitle);
   //PostMessage(Handle, VLC_COMMAND, 20, fVolume); //sendVlcComm('volume ' + IntToStr(fVolume));
   //PostMessage(Handle, VLC_COMMAND, 30, 0); //sendVlcComm('get_length');
end;

procedure TVlcPlayer.ClientSocket1Disconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   Memo1.Lines.Add('DISCONNECT');
   fPlayPos := 0;
   fPlayLen := 0;   
   if (fPlayState <> 4) then
   begin
      setState(4);
      ClientSocket1.Open;
   end
   else
   begin
      doPlayPosEvent;
      PostMessage(Handle, MESS_STOP, 0, 0);
   end;
end;

procedure TVlcPlayer.ClientSocket1Error(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   ErrorCode := 0;
   Memo1.Lines.Add('ERROR');
   setState(4);
   //play(fPlayFileID, fPlayFileTYP, fPlayFile, fPlayTitle);
end;

procedure TVlcPlayer.ClientSocket1Read(Sender: TObject;
  Socket: TCustomWinSocket);

   function checkInt(s: string):Boolean;
   var
      k: integer;
   begin
      Result := true;
      for k := 1 to Length(s) do
      begin
         case s[k] of
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9': ;
            else
            begin
               Result := false;
               exit;
            end;
         end;
      end;

      doPlayPosEvent();
   end;

const
   volume_str = 'status change: ( audio volume: ';

var
   s: string;
   sl: TStringList;
   k, v: integer;
   line: string;
begin
   s := Utf8ToAnsi(ClientSocket1.Socket.ReceiveText());
   Memo1.Lines.Add(s);
   sl:= TStringList.Create();
   try
      sl.Text := s;
      for k:= 0 to sl.Count - 1 do
      begin
         line := sl[k];

         if ((line = 'status change: ( play state: 2 ): Play') or
             (line = 'status change: ( play state: 3 )')) then
         begin
            setState(2);
         end
         else
         if (line = 'status change: ( pause state: 3 ): Pause') then
         begin
            setState(3);
         end
         else
         if ((line = 'status change: ( pause state: 4 ): End') or
             (line = 'status change: ( play state: 4 ): End')) then
         begin
            PostMessage(Handle, VLC_COMMAND, 11, 0); //sendVlcComm('quit');
            setState(4);
         end
         else
         if (line = 'status change: ( play state: 5 ): Error') then
         begin
            PostMessage(Handle, VLC_COMMAND, 11, 0); //sendVlcComm('quit');
         end
         else
         if (Pos('status change: ( new input:', line) > 0) then
         begin
            //
         end
         else
         //status change: ( audio volume: 192 )
         if (Pos(volume_str, line) > 0) then
         begin
            v := StrToInt(Copy(line, Length(volume_str), Length(line) - Length(volume_str) - 1));
            if ((v > 0) and (fStartPlayOK)) then
            begin
               if (fVolume <> v) then
               begin
                  fVolume := v;
                  doChange();
               end;
            end;
         end
         else
         if (checkInt(line)) then
         begin
            if not fStartPlayOK then
            begin
               fPlayLen := StrToInt(line);
               fStartPlayOK := (fPlayLen > 0);

               if (fPlaySeek > 0) then
               begin
                  PostMessage(Handle, VLC_COMMAND, 21, fPlaySeek); //seek
                  fPlayPos := fPlaySeek;
                  fPlaySeek := 0;
               end;

               if (fPlayWithPause) then
               begin
                  PostMessage(Handle, VLC_COMMAND, 3, 0); //pause
                  fPlayWithPause := false;
               end;
            end
            else
            begin
               fPlayPos := StrToInt(line);
            end;
         end;
         //status change: ( new input:
         //status change: ( time: 0s )
      end;
   finally
      sl.Free;
   end;
end;

procedure TVlcPlayer.play(id, typ: integer; s, title: string; withPause:boolean = false; seek: integer = 0);
var
   cif: STARTUPINFO;
   pi: PROCESS_INFORMATION;
   k: integer;
begin
   for k := 0 to 1000 do
   begin
      Application.ProcessMessages;
      if(fPlayState = 4) then break;
      Sleep(10);
   end;

   if (fPlayState = 4) then
   begin
      setState(0);
      fPlayFile := s;
      fPlayTitle := title;
      fPlayFileID := id;
      fPlayFileTYP := typ;
      fPlayWithPause := withPause;
      fPlaySeek := seek;

      if (ClientSocket1.Active) then
      begin
         ClientSocket1.Close;
         TerminateProcess(fVlcHandler, NO_ERROR);
         fVlcHandler := 0;         
      end;

      for k:= 0 to 1000 do
      begin
         Application.ProcessMessages;
         if not ClientSocket1.Active then
            break;
         Sleep(10);
      end;

      ZeroMemory(@cif, sizeof(STARTUPINFO));
      cif.cb := SizeOf(cif);
      cif.dwFlags := STARTF_USESHOWWINDOW;
      cif.wShowWindow := SW_HIDE;
      fVlcHandler := 0;
      fPrevForegroundWindow := GetForegroundWindow;
      if (CreateProcess(PAnsiChar(fVlcExe),
                        PAnsiChar(' --control=rc --network-caching=20000 --rc-host 127.0.0.1:' + IntToStr(ClientSocket1.Port)),
                        nil, nil, False, 0, nil, nil, cif, pi)) then
      begin
         fVlcHandler := pi.hProcess;
      end;
      Sleep(1000);
      ClientSocket1.Open;
   end;
end;

procedure TVlcPlayer.pause;
begin
   PostMessage(Handle, VLC_COMMAND, 3, 0); //sendVlcComm('pause');
end;

procedure TVlcPlayer.stop;
begin
   fPlayFile := '';
   PostMessage(Handle, VLC_COMMAND, 11, 0); //sendVlcComm('quit');
end;

procedure TVlcPlayer.Timer1Timer(Sender: TObject);
begin
   if ((fPlayState <> 4) and (fStartPlayOK)) then
   begin
      if (fPlayState <> 3) then
         PostMessage(Handle, VLC_COMMAND, 31, 0); //sendVlcComm('get_time');
   end
   else
   begin
      PostMessage(Handle, VLC_COMMAND, 20, fVolume); //sendVlcComm('volume ' + IntToStr(fVolume));
      PostMessage(Handle, VLC_COMMAND, 30, 0); //sendVlcComm('get_length');
   end;
   Label1.Caption := IntToStr(fPlayPos);
   Label2.Caption := IntToStr(fPlayLen);
end;

procedure TVlcPlayer.FormCreate(Sender: TObject);
begin
   fVlcExe := 'c:\Program Files (x86)\VideoLAN\VLC\vlc.exe';
   setState(4);
end;

procedure TVlcPlayer.FormDestroy(Sender: TObject);
begin
   //PostMessage(Handle, VLC_COMMAND, 11, 0); //sendVlcComm('quit');
   if (ClientSocket1.Active) then
      ClientSocket1.Socket.SendText('quit' + chr(13));
end;

procedure TVlcPlayer.setPlayPos(const Value: integer);
begin
   PostMessage(Handle, VLC_COMMAND, 21, Value); //sendVlcComm('seek ' + IntToStr(Value));
   fPlayPos := Value;
end;

procedure TVlcPlayer.setVolume(const Value: integer);
begin
   PostMessage(Handle, VLC_COMMAND, 20, Value); //sendVlcComm('volume ' + IntToStr(Value));
   fVolume := Value;
end;

procedure TVlcPlayer.doChange;
begin
   if (Assigned(fOnChange)) then
      fOnChange(self);
end;

procedure TVlcPlayer.setState(s: integer);
begin
   fPlayState := s;
   doChange();
   doPlayPosEvent();
end;

procedure TVlcPlayer.doPlayPosEvent;
begin
   if (Assigned(fonPlayPosEvent)) then
      fonPlayPosEvent(self, fPlayPos, fPlayLen);
end;

procedure TVlcPlayer.doStopEvent;
begin
   if (Assigned(fOnStopEvent)) then
      fOnStopEvent(self);
end;

procedure TVlcPlayer.messageStop(var Message: TMessage);
begin
   doStopEvent;
end;

procedure TVlcPlayer.messageVlcCommand(var Message: TMessage);
var
   comm: string;
begin
   if ((ClientSocket1.Active) and (fVlcHandler > 0)) then
   begin
      case Message.WParam of
         1: comm := 'add ' + fPostPlayFile;
         2: comm := 'play';
         3: comm := 'pause';
         4: comm := 'stop';
         10: comm := 'clear';
         11: comm := 'quit';
         12: comm := 'title [' + fPostPlayTitle + ']';
         20: comm := 'volume ' + IntToStr(Message.LParam);
         21: comm := 'seek ' + IntToStr(Message.LParam);
         30: comm := 'get_length';
         31: comm := 'get_time';
      end;

      ClientSocket1.Socket.SendText(comm + chr(13));
   end;
end;

procedure TVlcPlayer.SpeedButton1Click(Sender: TObject);
begin
   ClientSocket1.Socket.SendText(AnsiToUtf8(Edit1.Text) + chr(13));
end;

procedure TVlcPlayer.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
   if key = chr(13) then
      SpeedButton1Click(nil);
end;

procedure TVlcPlayer.playUrl(url: string);
begin
   stop;
   play(-1, 3, url, '');
end;

end.
