unit MainForm_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, CoolTrayIcon, ScktComp, StdCtrls, Speacker, ExtCtrls;

type
  TMainForm = class(TForm)
    ClientSocket1: TClientSocket;
    CoolTrayIcon1: TCoolTrayIcon;
    Timer1: TTimer;
    Panel1: TPanel;
    procedure CoolTrayIcon1Click(Sender: TObject);
    procedure ClientSocket1Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientSocket1Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ClientSocket1Connecting(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure ClientSocket1Disconnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure Timer1Timer(Sender: TObject);
  private
    fSpeaker: TSpeakerThread;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.CoolTrayIcon1Click(Sender: TObject);
begin
   if (MainForm.Visible) then
      CoolTrayIcon1.HideMainForm
   else
      CoolTrayIcon1.ShowMainForm;
end;

procedure TMainForm.ClientSocket1Error(Sender: TObject;
  Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
   ErrorCode := 0;
   Panel1.Caption := 'ERROR';
   ClientSocket1.Close;
end;

procedure TMainForm.ClientSocket1Read(Sender: TObject;
  Socket: TCustomWinSocket);
var
   b: TBuff;
   i: integer;
begin
   i := Socket.ReceiveBuf(b, SizeOf(TBuff));
   fSpeaker.Play(@b, i);
   Socket.SendText('ping');
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
   fSpeaker:= TSpeakerThread.Create(0);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
   fSpeaker.Free;
end;

procedure TMainForm.ClientSocket1Connecting(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   Panel1.Caption := 'CONNECTING';
end;

procedure TMainForm.ClientSocket1Disconnect(Sender: TObject;
  Socket: TCustomWinSocket);
begin
   Panel1.Caption := 'DISCONNECT';
   ClientSocket1.Close;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
   if Timer1.Tag = 0 then
   begin
      CoolTrayIcon1.HideMainForm;
      Timer1.Tag := 1;
   end;

   if (not ClientSocket1.Active) then
   begin
      ClientSocket1.Close;
      ClientSocket1.Open;
   end;
end;

end.
