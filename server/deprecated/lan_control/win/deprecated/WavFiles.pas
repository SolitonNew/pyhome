unit WavFiles;

interface

uses Windows, Classes, acm, Text2Speech;

type
  TWavFile = class(TObject)
  private
    FPcmStream: TMemoryStream;
  public
    function GetSize: Integer;
    function GetPosition: Integer;
    procedure SetPosition(Value: Integer);
    function GetBuffer(Buffer: PAnsiChar; BufLen: Integer): Integer;
    Procedure SaveToStream(Stream: TStream);
    procedure SaveToFile(const FileName: AnsiString);
    constructor Create(const AFileName: AnsiString);
    constructor CreateFromBuf(Buf:PAnsiChar; Len:Integer);
    destructor Destroy; override;
  end;

  TWavStream = class(TObject)
  private
    FPcmStream: TMemoryStream;
  protected
    function GetSize: Integer;
    function GetPosition: Integer;
    procedure Setposition(Value: Integer);
    function GetBuffer(Buffer: PAnsiChar; BufLen: Integer): Integer;
    Procedure SaveToStream(Stream: TStream);
    procedure SaveToFile(const FileName: AnsiString);
  public
    constructor Create(const AText: String; VoiceIndex:Integer);
    constructor CreateFromStream(const AStream: TStream);
    destructor Destroy; override;
  end;

procedure PcmToGsm (PcmStm, GsmStm: TStream);
procedure GsmToWav (PcmStm, WavStm: TStream);
procedure PcmToWav (PcmStm, WavStm: TStream);
procedure GetPcmFromWavFile (SrcStm, DstStm: TStream; DstBPS: Longint; DstSPS: Longint);

implementation

uses CodecGSM;

const
  WAVE_FORMAT_GSM610 = $31;
  WAVE_FORMAT_PCM    = $01;

type
  TWaveHeader = record
    riff: array[1..4] of AnsiChar;
    filesize: Longint;
    wave: array[1..4] of AnsiChar;
    fmt: array[1..4] of AnsiChar;
    schunk: Longint;
    wtype: Word;
    mono_stereo: Word;
    sample_rate: Longint;
    byte_sec: Longint;
    blockal: Word;
    bits_sample: Word;
    data: array[1..4] of AnsiChar;
    datasize: Longint;
  end;
  TWave49Header = record
    riff: array[1..4] of AnsiChar;
    filesize: Longint;
    wave: array[1..4] of AnsiChar;
    fmt: array[1..4] of AnsiChar;
    schunk: Longint;
    wtype: Word;
    mono_stereo: Word;
    sample_rate: Longint;
    byte_sec: Longint;
    blockal: Word;
    w1,w2,w3: Word;
    data: array[1..4] of AnsiChar;
    datasize: Longint;
  end;

procedure PcmToGsm (PcmStm, GsmStm: TStream);
var
  gsmblock: TGsmBlock;
  pcmblock: TPcmBlock;
  has: THandle;
  sf: TWAVEFORMATEX;
  df: TWAVEFORMATGSM;
  hdr: TACMSTREAMHEADER;
const
  WAVE_FORMAT_GSM610 = $31;
  WAVE_FORMAT_PCM    = $01;
Begin
  InitFormatEx(sf, WAVE_FORMAT_PCM, 1, 8000, 16000, 2, 16, 0);
  InitFormatEx(TWAVEFORMATEX(df), WAVE_FORMAT_GSM610, 1, 8000, 1625, 65, 0, 2);
  df.unpackedBlockSize := Length(pcmblock);
  InitAcmHeader(hdr,@pcmblock,SizeOf(pcmblock),SizeOf(pcmblock),@gsmblock,SizeOf(gsmblock),SizeOf(gsmblock),0);
  if acmFormatSuggest(0,@sf,@df,SizeOf(df),ACM_FORMATSUGGESTF_WFORMATTAG)=0 Then
  Begin
    if acmStreamOpen(@has,0,@sf,@df,Nil,0,0,ACM_STREAMOPENF_NONREALTIME)=0 Then
    Begin
      if acmStreamPrepareHeader(has,@hdr,0)=0 Then
      Begin
        GsmStm.Seek(0,soFromBeginning);
        PcmStm.Seek(0,soFromBeginning);
        while PcmStm.Read(pcmblock,SizeOf(pcmblock))=SizeOf(pcmblock) Do
        Begin
          if acmStreamConvert(has,@hdr,ACM_STREAMCONVERTF_BLOCKALIGN)<>0 then Break;
          GsmStm.Write(gsmblock,SizeOf(gsmblock));
        end;
        GsmStm.Seek(0,soFromBeginning);
        PcmStm.Seek(0,soFromBeginning);
        acmStreamUnprepareHeader(has,@hdr,0);
      end;
      acmStreamClose(has,0);
    end;
  end
  else MessageBoxEx(0,'Make sure that GSM 6.10 codec is installed on your computer',
    'Can''t convert GSM to PCM',MB_ICONHAND,0);
end;

procedure GsmToWav (PcmStm, WavStm: TStream);
var
  header:TWave49Header;
Begin
  with header do
  begin
    Move('RIFF', riff, 4);
    Move('WAVE', wave, 4);
    Move('fmt ', fmt, 4);
    schunk := $14;
    wtype := WAVE_FORMAT_GSM610;
    mono_stereo := 1;
    sample_rate := 8000;
    byte_sec := 1625;
    blockal := High(TGsmFrames);
    w1:=0;
    w2:=2;
    w3:=High(TPcmBlock);
    Move('data', data, 4);
    datasize := 0;
  end;
  header.datasize := PcmStm.Size;
  header.filesize := header.datasize + sizeof(header) - 8;
  PcmStm.Seek(0, soFromBeginning);
  WavStm.Seek(0, soFromBeginning);
  WavStm.Write(header, sizeof(header));
  WavStm.CopyFrom(PcmStm, PcmStm.Size);
  PcmStm.Seek(0, soFromBeginning);
  WavStm.Seek(0, soFromBeginning);
end;

procedure PcmToWav(PcmStm, WavStm: TStream);
var
  header: TWaveHeader;
begin
  with header do
  begin
    Move('RIFF', riff, 4);
    Move('WAVE', wave, 4);
    Move('fmt ', fmt, 4);
    schunk := $10;
    wtype := 1;
    mono_stereo := 1;
    sample_rate := 8000;
    byte_sec := 8000 * 2;
    blockal := 2;
    bits_sample := 16;
    Move('data', data, 4);
    datasize := 0;
  end;
  header.datasize := PcmStm.Size;
  header.filesize := header.datasize + sizeof(header) - 8;
  PcmStm.Seek(0, soFromBeginning);
  WavStm.Seek(0, soFromBeginning);
  WavStm.Write(header, sizeof(header));
  WavStm.CopyFrom(PcmStm, PcmStm.Size);
  PcmStm.Seek(0, soFromBeginning);
  WavStm.Seek(0, soFromBeginning);
end;

procedure ReadFileType(WavStm: TStream; var WavFormat, BitsPerSample,
                       SamplesPerSec, DataPos, DataSize: Longint);
var
  Pos, SPos, SN, RIFF: Longint;
  WF: TWAVEFORMATEX;
const
  SN_DATA = $61746164; // data
  SN_FMT  = $20746D66; // fmt
  RIFF_ID = $46464952; // RIFF
begin
  WavStm.Seek(0, soFromBeginning);
  WavStm.Read(RIFF, 4);
  if RIFF <> RIFF_ID then
  begin
    WavStm.Seek(0, soFromBeginning);
    WavFormat := 100000;
    DataSize := WavStm.Size;
    DataPos := 0;
    Exit;
  end;
  WavStm.Seek(12, soFromBeginning);
  while SN <> SN_DATA do
  begin
    WavStm.Read(SN, 4);
    WavStm.Read(Pos, 4);
    if SN = SN_FMT then
    begin
      SPos := WavStm.Position;
      WavStm.Read(WF, SizeOf(WF));
      WavFormat := WF.wFormatTag;
      BitsPerSample := WF.wBitsPerSample;
      SamplesPerSec := WF.nSamplesPerSec;
      WavStm.Seek(SPos, soFromBeginning);
    end;
    if SN <> SN_DATA then WavStm.Seek(Pos, soFromCurrent)
    else
    begin
      DataPos := WavStm.Position;
      DataSize := Pos;
    end;
  end;
end;

procedure GsmToPcm (GsmStm, PcmStm: TStream);
var
  gsmblock: TGsmBlock;
  pcmblock: TPcmBlock;
  has: THandle;
  df: TWAVEFORMATEX;
  sf: TWAVEFORMATGSM;
  hdr: TACMSTREAMHEADER;
Begin
  InitFormatEx(TWAVEFORMATEX(sf), WAVE_FORMAT_GSM610, 1, 8000, 1625, SizeOf(TGsmBlock), 0, 2);
  sf.unpackedBlockSize := Length(pcmblock);
  InitFormatEx(df, WAVE_FORMAT_PCM, 1, 8000, 16000, 2, 16, 0);
  FillChar(hdr,SizeOf(hdr),0);
  InitAcmHeader(hdr,@gsmblock,SizeOf(gsmblock),SizeOf(gsmblock),@pcmblock,SizeOf(pcmblock),SizeOf(pcmblock),0);
  if acmFormatSuggest(0,@sf,@df,SizeOf(df),ACM_FORMATSUGGESTF_WFORMATTAG)=0 Then
  Begin
    if acmStreamOpen(@has,0,@sf,@df,Nil,0,0,ACM_STREAMOPENF_NONREALTIME)=0 Then
    Begin
      if acmStreamPrepareHeader(has,@hdr,0)=0 Then
      Begin
        GsmStm.Seek(0,soFromBeginning);
        PcmStm.Seek(0,soFromBeginning);
        while GsmStm.Read(gsmblock,SizeOf(gsmblock))=SizeOf(gsmblock) Do
        Begin
          if acmStreamConvert(has,@hdr,ACM_STREAMCONVERTF_BLOCKALIGN)<>0 then Break;
          PcmStm.Write(pcmblock,SizeOf(pcmblock));
        end;
        GsmStm.Seek(0,soFromBeginning);
        PcmStm.Seek(0,soFromBeginning);
        acmStreamUnprepareHeader(has,@hdr,0);
      end;
      acmStreamClose(has,0);
    end;
  end;
  PcmStm.Position:=0;
end;

procedure GetPcmFromWavFile (SrcStm, DstStm: TStream; DstBPS: Longint; DstSPS: Longint);
var
  src, dst: array[1..65535] of Byte; // should be in HEAP
  has: THandle;
  sf: TWAVEFORMATEX;
  df: TWAVEFORMATEX;
  hdr: TACMSTREAMHEADER;
  SrcLen, DstLen, BytesRead: Longint;
  WavFormat, SrcBPS, SrcSPS, DataPos, DataSize: Longint;
  m: TMemoryStream;
Begin
  ReadFileType(SrcStm,WavFormat,SrcBPS,SrcSPS,DataPos,DataSize);
  if WavFormat=WAVE_FORMAT_GSM610 Then
  Begin
    m:=TMemoryStream.Create;
    try
      SrcStm.Position:=DataPos;
      m.CopyFrom(SrcStm,DataSize);
      m.Position:=0;
      GsmToPcm(m,DstStm);
      DstStm.Position:=0;
    Finally
      m.Free;
    end;
  end;
  if (SrcBPS = DstBPS)and(SrcSPS = DstSPS) Then
  Begin
    SrcStm.Seek(DataPos,soFromBeginning);
    DstStm.CopyFrom(SrcStm,DataSize);
    Exit;
  end;
  SrcLen := ((SrcBPS div 8) * SrcSPS) div 2;
  DstLen := ((DstBPS div 8) * DstSPS) div 2;
  InitFormatEx(sf,WAVE_FORMAT_PCM,1,SrcSPS,(SrcBPS div 8)*SrcSPS,SrcBPS Div 8,SrcBPS,0);
  InitFormatEx(df,WAVE_FORMAT_PCM,1,DstSPS,(DstBPS div 8)*DstSPS,DstBPS div 8,DstBPS,0);
  InitAcmHeader(hdr,@src,SrcLen,SrcLen,@dst,DstLen,DstLen,0);
  FillChar(dst,SizeOf(dst),127);
  if acmStreamOpen(@has,0,@sf,@df,Nil,0,0,ACM_STREAMOPENF_NONREALTIME)=0 Then
  Begin
    if acmStreamPrepareHeader(has,@hdr,0)=0 Then
    Begin
      DstStm.Seek(0,soFromBeginning);
      while SrcStm.Position<SrcStm.Size do
      Begin
        BytesRead:=SrcStm.Read(src,SrcLen);
        if acmStreamConvert(has,@hdr,ACM_STREAMCONVERTF_BLOCKALIGN)<>0 then Break;
        if BytesRead=SrcLen then DstStm.Write(dst,DstLen)
          Else DstStm.Write(dst, Round(BytesRead*(DstLen/SrcLen)/(DstBPS div 8))*(DstBPS div 8));
      end;
      DstStm.Seek(0,soFromBeginning);
      SrcStm.Seek(0,soFromBeginning);
      acmStreamUnprepareHeader(has,@hdr,0);
    end;
    acmStreamClose(has,0);
  end;
end;

{ TWavFile }

constructor TWavFile.Create(const AFileName: AnsiString);
var
  m, pcm: TMemoryStream;
  sl: TStringList;
  s: AnsiString;
  i: Integer;
begin
  inherited Create;
  FPcmStream := TMemoryStream.Create;
  sl:=TStringList.Create;
  for i:=1 To Length(AFileName) do
    Case AFileName[i] of
      ',',
      ';':
        if Length(s)>0 then
        begin
          sl.Add(s);
          s:='';
        End;
      else s:=s+AFileName[i];
    End;
  if Length(s)>0 then sl.Add(s);
  m := TMemoryStream.Create;
  pcm:=TMemoryStream.Create;
  try
    for i:=0 To sl.Count-1 do
    Begin
      m.LoadFromFile(sl[i]);
      m.Position := 0;
      GetPcmFromWavFile(m, pcm, 16, 8000);
      pcm.Position := 0;
      FPcmStream.CopyFrom(pcm,pcm.Size);
      pcm.Clear;
      m.Clear;
    end;
  finally
    sl.Free;
    m.Free;
    pcm.Free;
  end;
  FPcmStream.Position:=0;
end;

Constructor TWavFile.CreateFromBuf(Buf:PAnsiChar; Len:Integer);
var
  m:TMemoryStream;
Begin
  Inherited Create;
  FPcmStream:=TMemoryStream.Create;
  m:=TMemoryStream.Create;
  Try
    m.WriteBuffer(Buf^,Len);
    m.Position:=0;
    GetPcmFromWavFile(m,FPcmStream,16,8000);
    FPcmStream.Position:=0;
  Finally
    m.Free;
  End;
end;

destructor TWavFile.Destroy;
begin
  FPcmStream.Free;
  inherited;
end;

function TWavFile.GetBuffer(Buffer: PAnsiChar; BufLen: Integer): Integer;
begin
  Result := FPcmStream.Read(Buffer^, BufLen);
end;

function TWavFile.GetSize: Integer;
begin
  Result := FPcmStream.Size;
end;

function TWavFile.GetPosition: Integer;
begin
  Result := FPcmStream.Position;
end;

procedure TWavFile.SetPosition(Value: Integer);
begin
  FPcmStream.Position := Value;
end;

Procedure TWavFile.SaveToStream(Stream:TStream);
var
  ms:TMemoryStream;
Begin
  ms:=TMemoryStream.Create;
  try
    FPcmStream.Position:=0;
    PcmToGsm(FPcmStream,ms);
    FPcmStream.Clear;
    ms.Position:=0;
    GsmToWav(ms,FPcmStream);
    FPcmStream.SaveToStream(Stream);
  Finally
    ms.Free;
  End;
  FPcmStream.Clear;
end;

procedure TWavFile.SaveToFile(const FileName: AnsiString);
var
  ms:TMemoryStream;
Begin
  ms:=TMemoryStream.Create;
  try
    FPcmStream.Position:=0;
    SaveToStream(ms);
    ms.SaveToFile(FileName);
  Finally
    ms.Free;
  end;
end;

{ TWavStream }

constructor TWavStream.Create(const AText: String; VoiceIndex:Integer);
const
  MCW_EM = DWord($133f);
begin
  inherited Create;
  FPcmStream := TMemoryStream.Create;
  Set8087CW(MCW_EM);
  Text2Wav(AText, VoiceIndex, FPcmStream,0);
  FPcmStream.Position:=0;
end;

destructor TWavStream.Destroy;
begin
  FPcmStream.Free;
  inherited;
end;

function TWavStream.GetBuffer(Buffer: PAnsiChar; BufLen: Integer): Integer;
begin
  Result := FPcmStream.Read(Buffer^, BufLen);
end;

function TWavStream.GetSize: Integer;
begin
  Result := FPcmStream.Size;
end;

function TWavStream.GetPosition: Integer;
begin
  Result := FPcmStream.Position;
end;

procedure TWavStream.SetPosition(Value: Integer);
begin
  FPcmStream.Position := Value;
end;

constructor TWavStream.CreateFromStream(const AStream: TStream);
begin
  inherited Create;
  FPcmStream := TMemoryStream.Create;
  FPcmStream.LoadFromStream(AStream);
end;

procedure TWavstream.SaveToFile(const FileName: AnsiString);
var
  ms:TMemoryStream;
Begin
  ms:=TMemoryStream.Create;
  try
    FPcmStream.Position:=0;
    SaveToStream(ms);
    ms.SaveToFile(FileName);
  Finally
    ms.Free;
  End;
end;

procedure TWavStream.SaveToStream(Stream:TStream);
var
  ms:TMemoryStream;
Begin
  ms:=TMemoryStream.Create;
  try
    FPcmStream.Position:=0;
    PcmToGsm(FPcmStream,ms);
    FPcmStream.Clear;
    ms.Position:=0;
    GsmToWav(ms,FPcmStream);
    FPcmStream.SaveToStream(Stream);
  Finally
    ms.Free;
  end;
  FPcmStream.Clear;
end;

end.
