unit CamPlayer_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, LibVlc, ExtCtrls;

const
   VLC_TIMEOUT = 500;

   MSG_FULLSCREEN = WM_USER + 100;

type
  TCamPlayer = class(TFrame)
    Button1: TButton;
    Panel1: TPanel;
    procedure FrameResize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Panel1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    fIndex: integer;
    fUrl: string;
    procedure Init(aIndex: integer; aUrl: string);
    procedure reinit;
    procedure replay;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

{ TCamPlayer }

procedure TCamPlayer.Init(aIndex: integer; aUrl: string);
var
   url: string;
begin
   fIndex := aIndex;
	fUrl := aUrl;

	reinit;
end;

procedure TCamPlayer.FrameResize(Sender: TObject);
begin
	Button1.Left := ClientWidth - Button1.Width - 5;
   Button1.Top := ClientHeight - Button1.Height - 5;
end;

destructor TCamPlayer.Destroy;
begin
   libvlc.play(fIndex, fUrl, -1);
   inherited;
end;

procedure TCamPlayer.Button1Click(Sender: TObject);
begin
	if (Button1.Tag = 0) then
   begin
   	Button1.Tag := 1;
      Button1.Caption := 'HIGH';
   end
   else
   begin
   	Button1.Tag := 0;
      Button1.Caption := 'LOW';
   end;

   replay;
end;

procedure TCamPlayer.Panel1DblClick(Sender: TObject);
begin
	PostMessage(Parent.Handle, MSG_FULLSCREEN, fIndex, 0);
end;

procedure TCamPlayer.reinit;
begin
   libvlc.init(fIndex, Panel1.Handle);
   replay;
end;

procedure TCamPlayer.replay;
var
   url: string;
begin
	if (Button1.Tag = 1) then
   begin
      url := StringReplace(fUrl, '1.sdp', '0.sdp', [rfReplaceAll]);
      libvlc.play(fIndex, url, VLC_TIMEOUT);
   end
   else
   begin
      libvlc.play(fIndex, fUrl, VLC_TIMEOUT);
   end;
end;

end.
