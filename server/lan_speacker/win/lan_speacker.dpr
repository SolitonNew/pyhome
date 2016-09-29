program lan_speacker;

uses
  ExceptionLog,
  Forms,
  MainForm_Unit in 'MainForm_Unit.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
