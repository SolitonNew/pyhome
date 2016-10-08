program lan_speacker;

uses
  ExceptionLog,
  Forms,
  MainForm_Unit in 'MainForm_Unit.pas' {MainForm},
  Speacker in 'Speacker.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
