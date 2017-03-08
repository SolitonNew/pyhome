unit Speach_Unit;

interface

uses Windows, Messages, SysUtils, Classes, MMSystem, SyncObjs;

type
   TSpeach = class(TThread)
   private
   protected
      procedure Execute; override;
   public
      fQuietTime: integer;   
      fPlayList: TStringList;
      fPlayFile: string;
      fVolume:integer;
      fMute: Boolean;
      constructor Create();
      destructor Destroy; override;
   end;


implementation

uses MainForm_Unit, DateUtils;

{ TSpeach }

constructor TSpeach.Create;
begin
   inherited Create(True);
   fPlayList:= TStringList.Create;
   Resume;
end;

destructor TSpeach.Destroy;
begin
   fPlayList.Free;
   inherited;
end;

procedure TSpeach.Execute;
var
   sl: TStringList;
   prevTime: TDateTime;
   f1, f2: string;
   prevAudio: string;
   prevCommand: string;
   path: string;
begin
   inherited;

   path := GetEnvironmentVariable('TEMP') + '\audio';

   while not Terminated do
   begin
      if (fPlayFile <> '') then
      begin
         sl:= TStringList.Create;
         try
            sl.Delimiter := ';';
            sl.DelimitedText := fPlayFile;

            f1 := path + '\' + sl[0] + '.wav';
            f2 := path + '\' + sl[1] + '.wav';            

            if ((not fMute) and (fQuietTime = 0)) or (sl[0] = 'alarm') then
            begin
               if ((prevTime < Now()) or (prevAudio <> f1)) then
                  sndPlaySound(PAnsiChar(f1), SND_SYNC);

               if not ((prevTime < Now()) and (prevCommand = f2)) then
                  sndPlaySound(PAnsiChar(f2), SND_SYNC);

               prevCommand := f2;
               prevAudio := f1;
               prevTime := IncSecond(Now(), 5);
            end;
         finally
            sl.Free;
         end;
      end
      else
         sleep(50);
      Synchronize(MainForm.syncSpeachThread);
   end;
end;

end.
