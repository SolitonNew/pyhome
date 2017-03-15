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

   {function CopyNew(s: string; i1, count: integer):string;
   var
      k: integer;
   begin
      Result := '';
      SetLength(Result, count);
      for k := i1 to i1 + count - 1 do
         Result[k - i1 + 1] := s[k];
   end;}

var
   F:integer;
   i, k: integer;
   cols:integer;

   row: TList;
   val: TDataValue;
   //s: string;
begin
   fRows:= TList.Create;

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
               //SetLength(Result, Length(Result) + 1);
               //SetLength(Result[Length(Result) - 1], F);
               F := 0;
            end;
            //s := copy(aTableStr, 1, i - 1);
            TDataValue(row[F]).fValue := Copy(aTableStr, 1, i - 1);
            //s := '';
            //TDataValue(TList(fRows[fRows.Count - 1])[F]).fValue := copy(aTableStr, 1, i - 1);
            //Result[Length(Result) - 1][F] := copy(data, 1, i - 1);
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
