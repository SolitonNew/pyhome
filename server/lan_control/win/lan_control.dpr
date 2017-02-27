program lan_control;

uses
  FastMM4,
  ExceptionLog,
  Forms,
  Windows,
  MainForm_Unit in 'MainForm_Unit.pas' {MainForm},
  Speacker in 'Speacker.pas',
  PropertysForm_Unit in 'PropertysForm_Unit.pas' {PropertysForm},
  Mcs_Unit in 'Mcs_Unit.pas',
  RegForm_Unit in 'RegForm_Unit.pas' {RegForm},
  TerminalForm_Unit in 'TerminalForm_Unit.pas' {TerminalForm},
  Vlc_Unit in 'Vlc_Unit.pas' {VlcForm},
  SchedDialog_Unit in 'SchedDialog_Unit.pas' {SchedDialog},
  MediaInfoDialog_Unit in 'MediaInfoDialog_Unit.pas' {MediaInfoDialog},
  AlertForm_Unit in 'AlertForm_Unit.pas' {AlertForm};

{$R *.res}

var
   mutex:integer;

function CheckExeCopy: Boolean;
begin
   mutex := CreateMutex(nil, false, 'LAN_CONTROL 16/10/1982');
   Result := (WaitForSingleObject(mutex, 5000) <> 0);
end;

begin
  if (CheckExeCopy) then exit;

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TPropertysForm, PropertysForm);
  Application.CreateForm(TRegForm, RegForm);
  Application.CreateForm(TTerminalForm, TerminalForm);
  Application.CreateForm(TVlcForm, VlcForm);
  Application.CreateForm(TSchedDialog, SchedDialog);
  Application.CreateForm(TMediaInfoDialog, MediaInfoDialog);
  Application.Run;

  ReleaseMutex(mutex);
end.
