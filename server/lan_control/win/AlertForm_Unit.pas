unit AlertForm_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, IconButton;

const
   PHONE_CLICK = WM_USER + 100;

type
   TAlertTime = class
      fNow: TDateTime;
   end;

  TAlertForm = class(TForm)
    Shape1: TShape;
    Label1: TLabel;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
  private
    fTexts: TStringList;
    procedure resizeAlert;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

procedure show(text: String);
procedure hideAlert;

implementation

var
   AlertForm: TAlertForm;

{$R *.dfm}

procedure show(text: String);
var
   AlertTime: TAlertTime;
begin
   try
      if (AlertForm = nil) then
         Application.CreateForm(TAlertForm, AlertForm);

      with AlertForm do
      begin
         try
            AlertTime:= TAlertTime.Create;
            AlertTime.fNow := Now;
            fTexts.AddObject(text, AlertTime);
            resizeAlert;
            Timer1.Enabled := true;
            ShowWindow(Handle, SW_SHOWNOACTIVATE);
         except
            hideAlert;
         end;
      end;
   except
   end;
end;

procedure hideAlert;
begin
   try
      if (AlertForm <> nil) then
      begin
         AlertForm.Timer1.Enabled := false;
         FreeAndNil(AlertForm);
      end;
   except
   end;
end;

constructor TAlertForm.Create(AOwner: TComponent);
begin
   inherited;
   fTexts := TStringList.Create;
end;

destructor TAlertForm.Destroy;
begin
   fTexts.Free;
   inherited Destroy;
end;

procedure TAlertForm.resizeAlert;
begin
   //
end;

procedure TAlertForm.Timer1Timer(Sender: TObject);
var
   ts: TTimeStamp;
begin
   try
      Timer1.Tag := Timer1.Tag + 1;
      ts := DateTimeToTimeStamp(Now);
      ts.Time := Timer1.Tag * 1000;
   except
   end;
end;

end.
