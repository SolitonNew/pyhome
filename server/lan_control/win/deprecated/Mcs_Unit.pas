unit Mcs_Unit;

interface

uses
   NB30, SysUtils;

type
   Tsl = array of string;

function first: string;   
function find(s:string):Boolean;

implementation

var
   mcs:Tsl;

function first: string;
begin
   if (Length(mcs) > 0) then
      Result := mcs[0];
end;

function find(s:string):Boolean;
var
   k: integer;
begin
   Result := false;
   for k:= 0 to Length(mcs) - 1 do
   begin
      if (mcs[k] = s) then
      begin
         Result := true;
         break;
      end;
   end;
end;

function GetAdapterInfo(Lana: Char): String;

   function num1(c: char): char;
   begin
      Result := ' ';

      case c of
         '0': Result := 'A';
         '1': Result := 'B';
         '2': Result := 'C';
         '3': Result := 'D';
         '4': Result := 'E';
         '5': Result := 'F';
         '6': Result := 'G';
         '7': Result := 'H';
         '8': Result := 'I';
         '9': Result := 'J';
      end;
   end;

   function num2(c: char): char;
   begin
      Result := ' ';

      case c of
         '0': Result := 'K';
         '1': Result := 'L';
         '2': Result := 'M';
         '3': Result := 'N';
         '4': Result := 'O';
         '5': Result := 'P';
         '6': Result := 'Q';
         '7': Result := 'R';
         '8': Result := 'S';
         '9': Result := 'T';
      end;
   end;

   function num3(c: char): char;
   begin
      Result := ' ';

      case c of
         '0': Result := 'U';
         '1': Result := 'V';
         '2': Result := 'W';
         '3': Result := 'X';
         '4': Result := 'Y';
         '5': Result := 'Z';
         '6': Result := '1';
         '7': Result := '3';
         '8': Result := '5';
         '9': Result := '7';
      end;
   end;

   function code(c: char): String;
   var
      k: integer;
      s: string;
   begin
      Result := '';
      Result := IntToHex(Byte(c), 2);
      {s := IntToStr(Byte(c));
      for k:= 1 to Length(s) do
         case k of
            1, 4: Result := Result + num1(s[k]);
            2, 5: Result := Result + num2(s[k]);
            3, 6: Result := Result + num3(s[k]);
         end;}
   end;

var
   Adapter: TAdapterStatus;
   NCB: TNCB;
begin
   FillChar(NCB, SizeOf(NCB), 0);
   NCB.ncb_command := Char(NCBRESET);
   NCB.ncb_lana_num := Lana;
   if Netbios(@NCB) <> Char(NRC_GOODRET) then
   begin
      Result := 'mac not found';
      Exit;
   end;

   FillChar(NCB, SizeOf(NCB), 0);
   NCB.ncb_command := Char(NCBASTAT);
   NCB.ncb_lana_num := Lana;
   NCB.ncb_callname := '*';

   FillChar(Adapter, SizeOf(Adapter), 0);
   NCB.ncb_buffer := @Adapter;
   NCB.ncb_length := SizeOf(Adapter);
   if Netbios(@NCB) <> Char(NRC_GOODRET) then
   begin
      Result := 'mac not found';
      Exit;
   end;

   Result := code(Adapter.adapter_address[0]) + '.' +
             code(Adapter.adapter_address[1]) + '.' +
             code(Adapter.adapter_address[2]) + '.' +
             code(Adapter.adapter_address[3]) + '.' +
             code(Adapter.adapter_address[4]) + '.' +
             code(Adapter.adapter_address[5]);
end;

function list: Tsl;
var
   AdapterList: TLanaEnum;
   NCB: TNCB;
   k: integer;
begin
   FillChar(NCB, SizeOf(NCB), 0);
   NCB.ncb_command := Char(NCBENUM);
   NCB.ncb_buffer := @AdapterList;
   NCB.ncb_length := SizeOf(AdapterList);
   Netbios(@NCB);

   SetLength(Result, byte(AdapterList.length));

   for k:= 0 to Byte(AdapterList.length) - 1 do
      Result[k] := GetAdapterInfo(AdapterList.lana[k]);
end;

initialization
   mcs := list;

end.
