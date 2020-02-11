program lan_control;

uses
  FastMM4,
<<<<<<< HEAD
  //ExceptionLog,
=======
>>>>>>> f403c4e94a67db0012d3f91f6004fdf123cbcf7b
  Forms,
  Windows,
  MainForm_Unit in 'MainForm_Unit.pas' {MainForm},
  PropertysForm_Unit in 'PropertysForm_Unit.pas' {PropertysForm},
  RegForm_Unit in 'RegForm_Unit.pas' {RegForm},
  SchedDialog_Unit in 'SchedDialog_Unit.pas' {SchedDialog},
  MediaInfoDialog_Unit in 'MediaInfoDialog_Unit.pas' {MediaInfoDialog},
  AlertForm_Unit in 'AlertForm_Unit.pas' {AlertForm},
  DataRec_Unit in 'DataRec_Unit.pas',
  Mp3Player_Unit in 'Mp3Player_Unit.pas' {Mp3Player},
  http in 'http.pas',
  CamDisplay_Unit in 'CamDisplay_Unit.pas' {CamDisplay},
  CamAlertDiaplay_Unit in 'CamAlertDiaplay_Unit.pas' {CamAlertDiaplay},
  CamPlayer_Unit in 'CamPlayer_Unit.pas' {CamPlayer: TFrame},
  libvlc in 'libvlc.pas';

{$R *.res}

var
   mutex:integer;

function CheckExeCopy: Boolean;
begin
   mutex := CreateMutex(nil, false, 'LAN_CONTROL 16/10/1982');
   Result := (WaitForSingleObject(mutex, 5000) <> 0);
end;

begin
  SetErrorMode(SEM_FAILCRITICALERRORS);
  Set8087CW($133F);

  if (CheckExeCopy) then exit;

  SetThreadLocale(1049);

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TPropertysForm, PropertysForm);
  Application.CreateForm(TRegForm, RegForm);
  Application.CreateForm(TSchedDialog, SchedDialog);
  Application.CreateForm(TMediaInfoDialog, MediaInfoDialog);
  Application.CreateForm(TMp3Player, Mp3Player);
  Application.Run;

  ReleaseMutex(mutex);
end.
