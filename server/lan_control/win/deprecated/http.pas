unit http;

interface

uses
  Classes, blcksock, winsock, Synautil, SysUtils, Dialogs;

type
  TTCPHttpDaemon = class(TThread)
  private
    Sock:TTCPBlockSocket;
  public
    port: integer;
    Constructor Create;
    Destructor Destroy; override;
    procedure Execute; override;
  end;

  TTCPHttpThrd = class(TThread)
  private
    Sock:TTCPBlockSocket;
  public
    file_id: integer;
    file_name: string;
    Headers: TStringList;
    InputData: TMemoryStream;
    OutputData: TFileStream;
    Constructor Create (hsock:tSocket);
    Destructor Destroy; override;
    procedure Execute; override;
    function ProcessHttpRequest(Request, URI: string; range_start, range_end: integer): integer;
  end;


var
   syncThread: TTCPHttpThrd;

implementation

uses MainForm_Unit;

{ TTCPHttpDaemon }

Constructor TTCPHttpDaemon.Create;
begin
   inherited create(false);
   port := 8092;
   sock := TTCPBlockSocket.create;
   FreeOnTerminate:= true;
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
      setLinger(true, 10000);
      bind('0.0.0.0', IntToStr(port));
      listen;
      repeat
         if terminated then break;
         if canread(1000) then
         begin
            ClientSock := accept;
            if lastError=0 then
               TTCPHttpThrd.create(ClientSock);
         end;
      until false;
   end;
end;

{ TTCPHttpThrd }

Constructor TTCPHttpThrd.Create(Hsock:TSocket);
begin
  sock:=TTCPBlockSocket.create;
  Headers := TStringList.Create;
  InputData := TMemoryStream.Create;
  //OutputData := TMemoryStream.Create;
  Sock.socket:=HSock;
  FreeOnTerminate:=true;
  //Priority := tpTimeCritical;
  inherited create(false);
end;

Destructor TTCPHttpThrd.Destroy;
begin
  Sock.free;
  Headers.Free;
  InputData.Free;
  if (OutputData <> nil) then
     OutputData.Free;
  inherited Destroy;
end;

procedure TTCPHttpThrd.Execute;
var
  timeout: integer;
  s, s1: string;
  method, uri, protocol: string;
  range_start, range_end: integer;
  size: integer;
  x, n, i: integer;
  resultcode: integer;
  close: boolean;
begin
   timeout := 120000;
   repeat
      //read request line
      s := sock.RecvString(timeout);
      if sock.lasterror <> 0 then
         exit;
      if s = '' then
         exit;
      method := fetch(s, ' ');
      if (s = '') or (method = '') then
         exit;
      uri := fetch(s, ' ');
      if uri = '' then
         exit;
      protocol := fetch(s, ' ');
      headers.Clear;
      size := -1;
      close := false;
      range_start := 0;
      range_end := 0;      
      //read request headers
      if protocol <> '' then
      begin
         if pos('HTTP/', protocol) <> 1 then
            exit;
         if pos('HTTP/1.1', protocol) <> 1 then
            close := true;
         repeat
            s := sock.RecvString(Timeout);
            if sock.lasterror <> 0 then
               exit;
            if s <> '' then
               Headers.add(s);
            if Pos('CONTENT-LENGTH:', Uppercase(s)) = 1 then
               Size := StrToIntDef(SeparateRight(s, ' '), -1);
            if Pos('CONNECTION: CLOSE', Uppercase(s)) = 1 then
               close := true;
            if Pos('RANGE:', Uppercase(s)) = 1 then
            begin
               if (Pos('BYTES=', Uppercase(s)) > 0) then
               begin
                  s := SeparateRight(s, '=');
                  i := Pos('-', s);
                  if (i > 0) then
                  begin
                     range_start := StrToIntDef(Copy(s, 1, i - 1), 0);
                     range_end := StrToIntDef(SeparateRight(s, '-'), 0);
                  end
                  else
                  begin
                     range_start := StrToIntDef(s, 0);
                     range_end := 0;
                  end;

                  if (range_end > 0) then
                     ShowMessage('RANGE END: ' + IntToSTr(range_end));
               end;
            end;
         until s = '';
      end;
      //recv document...
      InputData.Clear;
      if size >= 0 then
      begin
         InputData.SetSize(Size);
         x := Sock.RecvBufferEx(InputData.Memory, Size, Timeout);
         InputData.SetSize(x);
         if sock.lasterror <> 0 then
            exit;
      end;
      ResultCode := ProcessHttpRequest(method, uri, range_start, range_end);
      sock.SendString(protocol + ' ' + IntTostr(ResultCode) + CRLF);
      if protocol <> '' then
      begin
         headers.Add('Content-length: ' + IntTostr(OutputData.Size - OutputData.Position));
         if close then
            headers.Add('Connection: close');
         headers.Add('Date: ' + Rfc822DateTime(now));
         headers.Add('Server: Synapse HTTP server');
         headers.Add('');
         for n := 0 to headers.count - 1 do
            sock.sendstring(headers[n] + CRLF);
      end;
      if sock.lasterror <> 0 then
         exit;
      Sock.SendStream(OutputData);
      //Sock.SendBuffer(OutputData.Memory, OutputData.Size);
      if close then
         break;
   until Sock.LastError <> 0;
end;

function TTCPHttpThrd.ProcessHttpRequest(Request, URI: string; range_start, range_end: integer): integer;
var
   size: integer;
begin
   if (OutputData <> nil) then
      FreeAndNil(OutputData);

   result := 504;
   if ((request = 'GET') or (request = 'HEAD')) then
   begin
      file_id := StrToInt(Copy(uri, 2, Length(uri)));
      syncThread := self;
      //Synchronize(MainForm.httpFileName);
      file_name := 'E:\Video\Я офигевая мама.mp4';
      OutputData:= TFileStream.Create(file_name, fmOpenRead or fmShareDenyWrite);
      try
         headers.Clear;
         headers.Add('Content-Type: video/mp4');
         headers.Add('Accept-Ranges: bytes');
         try
            OutputData.Position := range_start;
         except
            on ERangeError do
            begin
               range_start := OutputData.Position;
               range_end := 0;
            end;
         end;
         if range_end = 0 then
            range_end := OutputData.Size;
         size := range_end - range_start;
         if OutputData.Size = size then
            Result := 200
         else
            Result := 206;
      except
         OutputData.Free;              
      end;
   end;
end;

end.
