program lan_control;

uses
  ExceptionLog,
  Forms,
  MainForm_Unit in 'MainForm_Unit.pas' {MainForm},
  Speacker in 'Speacker.pas',
  PropertysForm_Unit in 'PropertysForm_Unit.pas' {PropertysForm},
  Mcs_Unit in 'Mcs_Unit.pas',
  RegForm_Unit in 'RegForm_Unit.pas' {RegForm},
  TerminalForm_Unit in 'TerminalForm_Unit.pas' {TerminalForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TPropertysForm, PropertysForm);
  Application.CreateForm(TRegForm, RegForm);
  Application.CreateForm(TTerminalForm, TerminalForm);
  Application.Run;
end.
