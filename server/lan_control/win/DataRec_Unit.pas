unit DataRec_Unit;

interface

uses
   Classes, SysUtils;

type
   TDataValue = class
      fValue: string;
   end;

   TDataRec = class
   private
      fRows: TList;
   public
      constructor Create(aTableStr: string);
      destructor Destroy; override;
      function Count(): integer;
      function val(r, c: integer): string;
   end;

implementation

{ TDataRec }

function TDataRec.Count: integer;
begin
   Result := 0;
   if (fRows <> nil) then
      Result := fRows.Count;
end;

constructor TDataRec.Create(aTableStr: string);
var
   F:integer;
   i, k: integer;
   cols:integer;
   row: TList;
begin
   fRows:= TList.Create;
   row := nil;
   try
      i := Pos(chr(1), aTableStr);
      cols := StrToInt(copy(aTableStr, 1, i - 1));
      Delete(aTableStr, 1, i);
      F := cols - 1;
      repeat
         i := Pos(chr(1), aTableStr);
         if (i > 0) then
         begin
            inc(F);
            if F > cols - 1 then
            begin
               row := TList.Create;
               for k := 0 to F - 1 do
                  row.Add(TDataValue.Create);
               fRows.Add(row);
               F := 0;
            end;
            TDataValue(row[F]).fValue := Copy(aTableStr, 1, i - 1);
            Delete(aTableStr, 1, i);
         end;
      until i < 1;
   finally
      aTableStr := '';
   end;
end;

destructor TDataRec.Destroy;
var
   k, i: integer;
begin
   for k := 0 to fRows.Count - 1 do
   begin
      for i := 0 to TList(fRows[k]).Count - 1 do
      begin
         TDataValue(TList(fRows[k])[i]).fValue := '';
         TDataValue(TList(fRows[k])[i]).Free;
      end;
      TList(fRows[k]).Clear;
      TList(fRows[k]).Free;
   end;
   fRows.Clear;
   fRows.Free;
   inherited;
end;

function TDataRec.val(r, c: integer): string;
begin
   Result := TDataValue(TList(fRows[r])[c]).fValue;
end;

end.
