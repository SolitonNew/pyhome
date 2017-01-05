unit Speacker;

interface

uses Windows, Messages, SysUtils, Classes, MMSystem, SyncObjs, Math;

const
  MaxBuffersCount = 15;

type
  TPcmBuffer = array[$1..$500] of Smallint;

  TBuff = array[1..1024] of Smallint;
  PBuff = ^TBuff;

  TSpeakerThread = class (TThread)
  private
    FWnd: THandle ;
    FId: Integer;
    FCS: TCriticalSection;
    FHandle: THandle;
    FHeaders: array[0..MaxBuffersCount-1] of TWaveHdr;
    FBuffers: array[0..MaxBuffersCount-1] of TPcmBuffer;
    FWindowCreatedEvent: THandle;
    FFreeBuffers: Integer;
    procedure WndProc (var Message: TMessage);
    procedure HandleBufferDone (AWaveHdr: PWaveHdr);
    function LocateBuffer (var Index: Integer): Boolean;
    function waveVolume(volume: integer; buf: pointer; samples: cardinal): Smallint;
  protected
    procedure Execute; override;
  public
    fVolume:integer;
    fMute: Boolean;
    procedure Play (Buffer: Pointer; Size: Integer);
    function BuffersAvailable: Boolean;
    constructor Create (AID: Int64);
    destructor Destroy; override;
  end;

implementation

{ TSpeakerThread }

procedure TSpeakerThread.Execute;
var
  Msg: TMsg;

  procedure OpenAudio;
  var
    WF: TPCMWaveFormat;
    i: Integer;
  begin
    WF.wBitsPerSample:= 16;
    WF.wf.wFormatTag:= WAVE_FORMAT_PCM;
    WF.wf.nChannels:= 2;
    WF.wf.nSamplesPerSec:= 44100;
    WF.wf.nBlockAlign:= WF.wBitsPerSample div 8 * 2;
    WF.wf.nAvgBytesPerSec:= WF.wf.nSamplesPerSec * WF.wf.nBlockAlign;
    waveOutOpen(@FHandle, FId, @WF, FWnd, 0, CALLBACK_WINDOW);
    for i:=0 to High(FHeaders) do
    Begin
      // WITH optimization is possible
      FHeaders[i].lpData:=@FBuffers[i][1];
      FHeaders[i].dwBufferLength:=SizeOf(TPcmBuffer);
      FHeaders[i].lpNext:=Nil;
      FHeaders[i].dwUser:=0;
      waveOutPrepareHeader(FHandle,@FHeaders[i],SizeOf(TWaveHdr));
    end;
    FFreeBuffers:=MaxBuffersCount;
  end;

  Procedure CloseAudio;
  var
    i:Integer;
  Begin
    waveOutReset(FHandle);
    for i:=0 to High(FHeaders) Do
      waveOutUnprepareHeader(FHandle,@FHeaders[i],SizeOf(TWaveHdr));
    waveOutClose(FHandle);
  end;

Begin
  FWnd:=AllocateHWnd(WndProc);
  SetEvent(FWindowCreatedEvent);
  try
    OpenAudio;
    try
      While Not Terminated Do
      Try
        GetMessage(Msg,FWnd,0,0);
        if not Terminated and (Msg.message=MM_WOM_DONE) then HandleBufferDone(PWaveHdr(Msg.lParam))
        else if not Terminated then DispatchMessage(Msg); // can be optimized for Terminated
      Except
      End;
    Finally
      CloseAudio;
    end;
  Finally
    DeallocateHWnd(Fwnd);
  End;
end;

function TSpeakerThread.LocateBuffer (var Index: Integer): Boolean;
var
  i: Integer;
begin
  Result:=False;
  for i:=0 to High(FHeaders) Do
    if FHeaders[i].dwUser=0 Then
    Begin
      Index:=i;
      Result:=True;
      Exit;
    end;
end;

procedure saveRtpDataToFile(time: dword; data: Pointer; size: integer);
var
   fs: TFileStream;
begin
   fs:= TFileStream.Create('d:\udp\' + IntToStr(time), fmCreate);
   try
      fs.Write(data^, size);
   finally
      fs.Free;
   end;
end;

procedure TSpeakerThread.Play (Buffer: Pointer; Size: Integer);
var
  idx: Integer;
begin
   waveVolume(fVolume, Buffer, Size);

   If (LocateBuffer(idx) and (not fMute)) Then
   Begin
      Dec(FFreeBuffers);
      FHeaders[idx].dwBufferLength:=Size;
      FHeaders[idx].dwUser:=1;
      Move(Buffer^,FBuffers[idx][1],FHeaders[idx].dwBufferLength); // Size can be reused
      waveOutWrite(FHandle,@FHeaders[idx],SizeOf(TWaveHdr));
   end;
end;

procedure TSpeakerThread.HandleBufferDone (AWaveHdr: PWaveHdr);
begin
  FCS.Enter;
  try
    Inc(FFreeBuffers);
    AWaveHdr.dwUser:=0;
    AWaveHdr.dwFlags:=AWaveHdr.dwFlags And not WHDR_DONE;
  Finally
    FCS.Leave;
  end;
end;

procedure TSpeakerThread.WndProc (var Message: TMessage);
begin
  DefWindowProc(FWnd,Message.Msg,Message.WParam,Message.LParam);
end;

constructor TSpeakerThread.Create (AID: Int64); // no need for 64 bits
begin
  Inherited Create(True);
  FFreeBuffers:=MaxBuffersCount;
  FWindowCreatedEvent:=CreateEvent(Nil,True,False,Nil);
  Priority:=tpTimeCritical;
  FCS:=TCriticalSection.Create;
  FreeOnTerminate:=False;
  FId:=AID;
  Resume;
  WaitForSingleObject(FWindowCreatedEvent,INFINITE);
end;

Destructor TSpeakerThread.Destroy;
Begin
  Terminate;
  PostMessage(FWnd,WM_USER,0,0);
  WaitFor;
  FCS.Free;
  CloseHandle(FWindowCreatedEvent);
  Inherited;
end;

function TSpeakerThread.BuffersAvailable: Boolean;
begin
  FCS.Enter;
  try
    Result:=FFreeBuffers>0;
  Finally
    FCS.Leave;
  end;
end;

function TSpeakerThread.waveVolume(volume: integer; buf: pointer;samples: cardinal): Smallint;
var
   k, i: integer;
   bb: array[1..1024] of Smallint;
   v: Double;
begin
   Result := 0;

   v := volume / 100;
   Move(buf^, bb[1], samples);

   if (volume > 0) then
   begin
      for k:= 1 to samples div 2 do
      begin
         i := round(bb[k] * v);

         if (i < -32768) then
            i := -32768
         else
         if (i > 32767) then
            i := 32767;

         bb[k] := i;
      end;

      Move(bb[1], buf^, samples);
   end;
end;

end.
