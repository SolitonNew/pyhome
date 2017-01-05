unit http;

interface

uses
  Classes, blcksock, winsock, Synautil, SysUtils;

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
    Headers: TStringList;
    InputData: TMemoryStream;
    OutputData: TFileStream;
    Constructor Create (hsock:tSocket);
    Destructor Destroy; override;
    procedure Execute; override;
    function ProcessHttpRequest(Request, URI: string): integer;
  end;

implementation

{ TTCPHttpDaemon }

Constructor TTCPHttpDaemon.Create;
begin
  inherited create(false);
  sock:=TTCPBlockSocket.create;
  FreeOnTerminate:=true;
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
      bind('0.0.0.0','8093');
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
  s: string;
  method, uri, protocol: string;
  size: integer;
  x, n: integer;
  resultcode: integer;
  close: boolean;
begin
  timeout := 120000;
  repeat
    //read request line
    s := sock.RecvString(timeout);
    if sock.lasterror <> 0 then
      Exit;
    if s = '' then
      Exit;
    method := fetch(s, ' ');
    if (s = '') or (method = '') then
      Exit;
    uri := fetch(s, ' ');
    if uri = '' then
      Exit;
    protocol := fetch(s, ' ');
    headers.Clear;
    size := -1;
    close := false;
    //read request headers
    if protocol <> '' then
    begin
      if pos('HTTP/', protocol) <> 1 then
        Exit;
      if pos('HTTP/1.1', protocol) <> 1 then
        close := true;
      repeat
        s := sock.RecvString(Timeout);
        if sock.lasterror <> 0 then
          Exit;
        if s <> '' then
          Headers.add(s);
        if Pos('CONTENT-LENGTH:', Uppercase(s)) = 1 then
          Size := StrToIntDef(SeparateRight(s, ' '), -1);
        if Pos('CONNECTION: CLOSE', Uppercase(s)) = 1 then
          close := true;
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
        Exit;
    end;
    ResultCode := ProcessHttpRequest(method, uri);
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
    if sock.lasterror <> 0 then
      Exit;
    Sock.SendStream(OutputData);
    //Sock.SendBuffer(OutputData.Memory, OutputData.Size);
    if close then
      Break;
  until Sock.LastError <> 0;
end;

function TTCPHttpThrd.ProcessHttpRequest(Request, URI: string): integer;
begin
   if (OutputData <> nil) then
      FreeAndNil(OutputData);

  result := 504;
  if request = 'GET' then
  begin
    headers.Clear;
    //headers.Add('Content-type: Text/Html');
    OutputData := TFileStream.Create('e:\video\1.mp4', fmShareDenyRead);
    Result := 200;
  end;
end;

end.
