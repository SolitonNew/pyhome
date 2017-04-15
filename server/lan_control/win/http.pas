unit http;

interface

uses
  Classes, blcksock, winsock, Synautil, SysUtils, SyncObjs;

type
  TTCPHttpDaemon = class(TThread)
  private
    Sock:TTCPBlockSocket;
  public
    Constructor Create;
    Destructor Destroy; override;
    procedure Execute; override;
  end;

  TTCPHttpThrd = class(TThread)
  private
    Sock:TTCPBlockSocket;
  public
    fCS: TCriticalSection;
    fFileName: string;
    fID: integer;
    Headers: TStringList;
    InputData: TMemoryStream;
    OutputData: TFileStream;
    Constructor Create (hsock:tSocket);
    Destructor Destroy; override;
    procedure Execute; override;
    function ProcessHttpRequest(Request, URI: string; range_s, range_e: int64; var len: int64): integer;
    procedure loadFileName;
  end;

const
   httpPort = 8092;

implementation

uses MainForm_Unit;

{ TTCPHttpDaemon }

Constructor TTCPHttpDaemon.Create;
begin
   inherited create(false);
   sock := TTCPBlockSocket.create;
   FreeOnTerminate := true;
end;

Destructor TTCPHttpDaemon.Destroy;
begin
   Sock.free;
   inherited Destroy;
end;

procedure TTCPHttpDaemon.Execute;
var
   ClientSock:TSocket;
begin
   with sock do
   begin
      CreateSocket;
      setLinger(true,10000);
      bind('0.0.0.0', IntToStr(httpPort));
      listen;
      repeat
         if terminated then break;
         if canread(1000) then
         begin
            ClientSock := accept;
            if lastError=0 then TTCPHttpThrd.create(ClientSock);
         end;
      until false;
   end;
end;

{ TTCPHttpThrd }

Constructor TTCPHttpThrd.Create(Hsock:TSocket);
begin
   fCS:= TCriticalSection.Create;
   sock := TTCPBlockSocket.create;
   Headers := TStringList.Create;
   InputData := TMemoryStream.Create;
   OutputData := nil;
   Sock.socket := HSock;
   FreeOnTerminate := true;
   inherited create(false);
   Priority := tpIdle;
end;

Destructor TTCPHttpThrd.Destroy;
begin
   Sock.free;
   Headers.Free;
   InputData.Free;
   if (OutputData <> nil) then
      OutputData.Free;
   fCS.Free;
   inherited Destroy;
end;

procedure TTCPHttpThrd.Execute;
var
   timeout: integer;
   s: string;
   method, uri, protocol: string;
   size: int64;
   x, n: integer;
   resultcode: integer;
   close: boolean;

   buf: array [1..100000] of byte;
   k, c: integer;
   range_s, range_e: int64;
   out_len: int64;
begin
   timeout := 120000;
   repeat
      range_s := 0;
      range_e := 0;
      //read request line
      s := sock.RecvString(timeout);
      if sock.lasterror <> 0 then exit;
      if s = '' then exit;
      method := fetch(s, ' ');
      if (s = '') or (method = '') then exit;
      uri := fetch(s, ' ');
      if uri = '' then exit;
      protocol := fetch(s, ' ');
      headers.Clear;
      size := -1;
      close := false;
      //read request headers
      if protocol <> '' then
      begin
         if pos('HTTP/', protocol) <> 1 then exit;
         if pos('HTTP/1.1', protocol) <> 1 then
            close := true;
         repeat
            s := sock.RecvString(Timeout);
            if sock.lasterror <> 0 then exit;
            if s <> '' then
               Headers.add(s);
            if Pos('CONTENT-LENGTH:', Uppercase(s)) = 1 then
               Size := StrToIntDef(SeparateRight(s, ' '), -1);
            if Pos('CONNECTION: CLOSE', Uppercase(s)) = 1 then
               close := true;
            if Pos('RANGE: BYTES=', Uppercase(s)) = 1 then
            begin
               s := Copy(s, 14, Length(s));
               range_s := StrToInt64Def(Copy(s, 1, Pos('-', s) - 1), 0);
               range_e := StrToInt64Def(Copy(s, Pos('-', s) + 1, Length(s)), 0);
            end;
               //Size := StrToIntDef(SeparateRight(s, ' '), -1);

         until s = '';
      end;
      //recv document...
      InputData.Clear;
      if size >= 0 then
      begin
         InputData.SetSize(Size);
         x := Sock.RecvBufferEx(InputData.Memory, Size, Timeout);
         InputData.SetSize(x);
         if sock.lasterror <> 0 then exit;
      end;

      ResultCode := ProcessHttpRequest(method, uri, range_s, range_e, out_len);
      sock.SendString(protocol + ' ' + IntTostr(ResultCode) + CRLF);
      if protocol <> '' then
      begin
         headers.Add('Content-length: ' + IntTostr(OutputData.Size));
         if close then
            headers.Add('Connection: close');
         headers.Add('Date: ' + Rfc822DateTime(now));
         headers.Add('Server: Synapse HTTP server demo');
         headers.Add('');
         for n := 0 to headers.count - 1 do
            sock.sendstring(headers[n] + CRLF);
      end;
      if sock.lasterror <> 0 then exit;

      range_e := range_s + out_len;
      while (OutputData.Position < range_e) do
      begin
         c := length(buf);
         if ((range_e - OutputData.Position) < c) then
            c := range_e - OutputData.Position;
         OutputData.ReadBuffer(buf, c);
         Sock.SendBuffer(@buf[1], c);
      end;
      
      if close then break;
   until Sock.LastError <> 0;
end;

procedure TTCPHttpThrd.loadFileName;
var
   om: TMediaListItem;
begin
   try

   except
   end;
end;

function TTCPHttpThrd.ProcessHttpRequest(Request, URI: string; range_s, range_e: int64; var len: int64): integer;
var
   om: TMediaListItem;
begin
   result := 504;
   if request = 'GET' then
   begin
      fID := StrToInt(Copy(URI, 2, Length(URI)));
      fCS.Enter;
      try
         om := MainForm.getMediaAtId(fID);
         fFileName := om.file_name;
      finally
         fCS.Leave;
      end;

      headers.Clear;
      //headers.Add('Content-type: Text/Html');
      Headers.Add('Accept-Ranges: bytes');

      OutputData := TFileStream.Create(fFileName, fmOpenRead or fmShareDenyWrite);
      OutputData.Position := range_s;
      if (range_e = 0) then
         range_e := OutputData.Size;

      len := range_e - range_s;

      if (len = OutputData.Size) then
         Result := 200
      else
         Result := 206;
   end;
end;

end.
