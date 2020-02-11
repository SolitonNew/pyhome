unit DlgMessagesRU;

interface

uses
   Types, Forms, Windows, Dialogs, StdCtrls, Graphics, Math, ExtCtrls;

type
  TMsgDlgBtn = (mbYes, mbNo, mbOK, mbCancel, mbAbort, mbRetry, mbIgnore,
    mbAll, mbNoToAll, mbYesToAll, mbHelp);   
  TMsgDlgButtons = set of TMsgDlgBtn;

type
   TAddingsMethod = procedure(Sender: TObject; Text: string) of object;

function MessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer;
function InputQuery(const ACaption, APrompt: string; var Value: string): Boolean;
function InputBox(const ACaption, APrompt, ADefault: string): string;
function InputPassword(const ACaption, APrompt: string; var Value: string): Boolean;

procedure SetAddingsMethodParams(MethodName: string; Method: TAddingsMethod);

implementation

uses Controls, Classes, SysUtils;

type
   TMessForm = class(TForm)
   private
      DetailButton: TButton;
      DetailMessage: string;
      procedure OnDetailErrorClick(Sender: TObject);
      procedure OnDetailErrorAddingsClick(Sender: TObject);      
   end;

var
   AddingsMethodButtonName: string;
   AddingsMethod: TAddingsMethod;

procedure SetAddingsMethodParams(MethodName: string; Method: TAddingsMethod);
begin
   AddingsMethodButtonName:= MethodName;
   AddingsMethod:= Method;
end;   

{ Message dialog }

function GetAveCharSize(Canvas: TCanvas): TPoint;
var
  I: Integer;
  Buffer: array[0..51] of Char;
begin
  for I := 0 to 25 do Buffer[I] := Chr(I + Ord('A'));
  for I := 0 to 25 do Buffer[I + 26] := Chr(I + Ord('a'));
  GetTextExtentPoint(Canvas.Handle, Buffer, 52, TSize(Result));
  Result.X := Result.X div 52;
end;

{  --------  }

resourcestring

  SMsgDlgWarning = 'Внимание';
  SMsgDlgError = 'Ошибка';
  SMsgDlgInformation = 'Информация';
  SMsgDlgConfirm = 'Подтверждение';

  SMsgDlgYes = '&Да';
  SMsgDlgNo = '&Нет';
  SMsgDlgOK = 'OK';
  SMsgDlgCancel = 'Отмена';
  SMsgDlgHelp = '&Справка';
  SMsgDlgHelpNone = 'No help available';
  SMsgDlgHelpHelp = 'Справка';
  SMsgDlgAbort = '&Прервать';
  SMsgDlgRetry = 'П&овторить';
  SMsgDlgIgnore = '&Игнорировать';
  SMsgDlgAll = '&Все';
  SMsgDlgNoToAll = 'Н&ет для всех';
  SMsgDlgYesToAll = 'Д&а для всех';
  SDetailErrorInfo = 'Детально >>';

var
   Captions: array[TMsgDlgType] of Pointer = (@SMsgDlgWarning, @SMsgDlgError, @SMsgDlgInformation, @SMsgDlgConfirm, nil);
   IconIDs: array[TMsgDlgType] of PChar = (IDI_EXCLAMATION, IDI_HAND, IDI_ASTERISK, IDI_QUESTION, nil);
   ButtonNames: array[TMsgDlgBtn] of string = (
      'Yes', 'No', 'OK', 'Cancel', 'Abort', 'Retry', 'Ignore', 'All', 'NoToAll', 'YesToAll', 'Help');
   ButtonCaptions: array[TMsgDlgBtn] of Pointer = (
      @SMsgDlgYes, @SMsgDlgNo, @SMsgDlgOK, @SMsgDlgCancel, @SMsgDlgAbort,
      @SMsgDlgRetry, @SMsgDlgIgnore, @SMsgDlgAll, @SMsgDlgNoToAll, @SMsgDlgYesToAll,
      @SMsgDlgHelp);
   ModalResults: array[TMsgDlgBtn] of Integer = (
      mrYes, mrNo, mrOk, mrCancel, mrAbort, mrRetry, mrIgnore, mrAll, mrNoToAll, mrYesToAll, 0);
   ButtonWidths : array[TMsgDlgBtn] of integer;  // initialized to zero

function CreateLongMessageDialog(const Msg: string; DlgType: TMsgDlgType;
                                 Buttons: TMsgDlgButtons; DetailErrorInfo: boolean): TForm;
const
   mcHorzMargin = 8;
   mcVertMargin = 8;
   mcHorzSpacing = 10;
   mcVertSpacing = 10;
   mcButtonWidth = 50;
   mcButtonHeight = 15;
   mcButtonSpacing = 4;
var
   DialogUnits: TPoint;
   HorzMargin, VertMargin, HorzSpacing, VertSpacing, ButtonWidth,
   ButtonHeight, ButtonSpacing, ButtonCount, ButtonGroupWidth,
   IconTextWidth, IconTextHeight, X, ALeft: Integer;
   B, DefaultButton, CancelButton: TMsgDlgBtn;
   IconID: PChar;
   TextRect: TRect;
begin
   Result:= TMessForm.CreateNew(Application);
   with Result do
   begin
      FormStyle := fsStayOnTop;
      // ---------------------- For Detail Errror Info
      if DetailErrorInfo then
         if (ExceptObject <> nil) then
            TMessForm(Result).DetailMessage:= Exception(ExceptObject).Message;
      // ---------------------- 
      BiDiMode := Application.BiDiMode;
      BorderStyle := bsDialog;
      Canvas.Font := Font;
      KeyPreview := True;
//    OnKeyDown := TMessageForm(Result).CustomKeyDown;
      DialogUnits := GetAveCharSize(Canvas);
      HorzMargin := MulDiv(mcHorzMargin, DialogUnits.X, 4);
      VertMargin := MulDiv(mcVertMargin, DialogUnits.Y, 8);
      HorzSpacing := MulDiv(mcHorzSpacing, DialogUnits.X, 4);
      VertSpacing := MulDiv(mcVertSpacing, DialogUnits.Y, 8);
      ButtonWidth := MulDiv(mcButtonWidth, DialogUnits.X, 4);

      for B := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
      begin
         if B in Buttons then
         begin
            if ButtonWidths[B] = 0 then
            begin
               TextRect := Rect(0,0,0,0);
               Windows.DrawText( canvas.handle,
                  PChar(LoadResString(ButtonCaptions[B])), -1,
                  TextRect, DT_CALCRECT or DT_LEFT or DT_SINGLELINE or
                  DrawTextBiDiModeFlagsReadingOnly);
               with TextRect do ButtonWidths[B] := Right - Left + 8;
            end;

            if ButtonWidths[B] > ButtonWidth then ButtonWidth := ButtonWidths[B];
         end;
      end;
      //ButtonWidth := 73;
      ButtonHeight := 25;

      ButtonSpacing := MulDiv(mcButtonSpacing, DialogUnits.X, 4);
      SetRect(TextRect, 0, 0, Screen.Width div 2, 0);
      DrawText(Canvas.Handle, PChar(Msg), Length(Msg)+1, TextRect,
         DT_EXPANDTABS or DT_CALCRECT or DT_WORDBREAK or
         DrawTextBiDiModeFlagsReadingOnly);
      IconID := IconIDs[DlgType];
      IconTextWidth := TextRect.Right;
      IconTextHeight := TextRect.Bottom;
      if IconID <> nil then
      begin
         Inc(IconTextWidth, 32 + HorzSpacing);
         if IconTextHeight < 32 then IconTextHeight:= 32;
      end;
      ButtonCount := 0;
      for B := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
         if B in Buttons then Inc(ButtonCount);
      ButtonGroupWidth := 0;
      if ButtonCount <> 0 then
         ButtonGroupWidth := ButtonWidth * ButtonCount + ButtonSpacing * (ButtonCount - 1);
      ClientWidth := Max(IconTextWidth, ButtonGroupWidth) + HorzMargin * 2;
      // --------------------- For Detail Errror Info
      if DetailErrorInfo then ClientWidth:= ClientWidth + ButtonWidth + mcHorzMargin;
      // ---------------------
      ClientHeight := IconTextHeight + ButtonHeight + VertSpacing + VertMargin * 2;
      Left := (Screen.Width div 2) - (Width div 2);
      Top := (Screen.Height div 2) - (Height div 2);
      if DlgType <> mtCustom then Caption := LoadResString(Captions[DlgType])
      else Caption := Application.Title;
      if IconID <> nil then
         with TImage.Create(Result) do
         begin
            Name := 'Image';
            Parent := Result;
            Picture.Icon.Handle := LoadIcon(0, IconID);
            SetBounds(HorzMargin, VertMargin, 32, 32);
         end;
      with TLabel.Create(Result) do
      begin
         Name := 'Message';
         Parent := Result;
         WordWrap := True;
         Caption := Msg;
         BoundsRect := TextRect;
         BiDiMode := Result.BiDiMode;
         ALeft := IconTextWidth - TextRect.Right + HorzMargin;
         if UseRightToLeftAlignment then
            ALeft := Result.ClientWidth - ALeft - Width;
         SetBounds(ALeft, VertMargin, TextRect.Right, TextRect.Bottom);
      end;
      if mbOk in Buttons then DefaultButton := mbOk
      else
      if mbYes in Buttons then DefaultButton := mbYes
      else DefaultButton := mbRetry;

      if mbCancel in Buttons then CancelButton := mbCancel
      else
      if mbNo in Buttons then CancelButton := mbNo
      else CancelButton := mbOk;

      X := (ClientWidth - ButtonGroupWidth) div 2;
      for B := Low(TMsgDlgBtn) to High(TMsgDlgBtn) do
         if B in Buttons then
            with TButton.Create(Result) do
            begin
               Name := ButtonNames[B];
               Parent := Result;
               Caption := LoadResString(ButtonCaptions[B]);
               ModalResult := ModalResults[B];
               if B = DefaultButton then Default := True;
               if B = CancelButton then Cancel := True;
               SetBounds(X, IconTextHeight + VertMargin + VertSpacing, ButtonWidth, ButtonHeight);
               Inc(X, ButtonWidth + ButtonSpacing);

{          if B = mbHelp then
            OnClick := TMessageForm(Result).HelpButtonClick;}
            end;
         end;
   // --------------------- For Detail Errror Info
   if DetailErrorInfo then
   begin
      TMessForm(Result).DetailButton:= TButton.Create(Result);
      with TMessForm(Result).DetailButton do
      begin
         Name:= 'DetailInfoButton';
         Parent:= Result;
         Caption:= SDetailErrorInfo;
         SetBounds(Result.ClientWidth - ButtonWidth - mcHorzMargin,
                   IconTextHeight + VertMargin + VertSpacing,
                   ButtonWidth,
                   ButtonHeight);
         OnClick:= TMessForm(Result).OnDetailErrorClick;
      end;
   end;
   // ---------------------
end;

{  --------  }

function MessageDlg(const Msg: string; DlgType: TMsgDlgType; Buttons: TMsgDlgButtons; HelpCtx: Longint): Integer;
var
   Det: boolean;
begin
   case DlgType of
      mtError: Det:= true;
      else
         Det:= false;
   end;
   
   with CreateLongMessageDialog(Msg, DlgType, Buttons, Det) do
   begin
      try
         HelpContext := HelpCtx;
         Position := poScreenCenter;
         Result:= ShowModal;
      finally
         Free;
      end;
   end;
end;

{ Input dialog }

function InputQuery(const ACaption, APrompt: string;
  var Value: string): Boolean;
var
  Form: TForm;
  Prompt: TLabel;
  Edit: TEdit;
  Group: TGroupBox;
  DialogUnits: TPoint;
  ButtonTop, ButtonWidth, ButtonHeight: Integer;
begin
  Result := False;
  Form:= TForm.Create(Application);
  with Form do
    try
      Canvas.Font := Font;
      DialogUnits := GetAveCharSize(Canvas);
      BorderStyle := bsDialog;
      Caption := ACaption;
      ClientWidth := MulDiv(180, DialogUnits.X, 4);
      Position := poScreenCenter;
      Group:= TGroupBox.Create(Form);
      with Group do
      begin
        Parent := Form;
        Caption := '';
        Left := 8;
        Top := 8;
        Width := Form.ClientWidth - 16;
      end;
      
         Prompt := TLabel.Create(Group);
         with Prompt do
         begin
           Parent := Group;
           Caption := APrompt;
           Left := 16;
           Top := 16;
           Constraints.MaxWidth := MulDiv(148, DialogUnits.X, 4);
           WordWrap:= True;
         end;
         Edit := TEdit.Create(Group);
         with Edit do
         begin
           Parent := Group;
           Left := Prompt.Left;
           Top := Prompt.Top + Prompt.Height;
           Width := MulDiv(148, DialogUnits.X, 4);
           MaxLength:= 255;
           Text := Value;
           SelectAll;
         end;

      Group.ClientHeight := Edit.Top + Edit.Height + 16;

      ButtonTop := Group.Top + Group.Height + 16;

      ButtonWidth := 73;
      ButtonHeight := 25;

      with TButton.Create(Form) do
      begin
        Parent := Form;
        Caption := 'ОК';
        ModalResult := mrOk;
        Default := True;
        SetBounds(Group.Left + Group.Width - (ButtonWidth * 2) - 8 , ButtonTop, ButtonWidth,
          ButtonHeight);
      end;
      with TButton.Create(Form) do
      begin
        Parent := Form;
        Caption := 'Отмена';
        ModalResult := mrCancel;
        Cancel := True;
        SetBounds(Group.Left + Group.Width - ButtonWidth, ButtonTop,
          ButtonWidth, ButtonHeight);
        Form.ClientHeight := Top + Height + 8;
      end;

      if ShowModal = mrOk then
      begin
        Value := Edit.Text;
        Result := True;
      end;
    finally
      Form.Free;
    end;
end;

function InputBox(const ACaption, APrompt, ADefault: string): string;
begin
   Result := ADefault;
   InputQuery(ACaption, APrompt, Result);
end;

function InputPassword(const ACaption, APrompt: string;
  var Value: string): Boolean;
var
  Form: TForm;
  Prompt: TLabel;
  Edit: TEdit;
  DialogUnits: TPoint;
  ButtonTop, ButtonWidth, ButtonHeight: Integer;
  TextRect: TRect;
begin
  Result := False;
  Form:= TForm.Create(Application);
  with Form do
    try
      Canvas.Font := Font;
      DialogUnits := GetAveCharSize(Canvas);
      BorderStyle := bsDialog;
      Caption := ACaption;
      ClientWidth := MulDiv(180, DialogUnits.X, 4);
      Position := poScreenCenter;
      Prompt := TLabel.Create(Form);
      with Prompt do
      begin
        AutoSize:= false;
        Parent:= Form;
        Caption:= APrompt;
        Left:= MulDiv(8, DialogUnits.X, 4);
        Top:= MulDiv(8, DialogUnits.Y, 8);
        Width:= MulDiv(164, DialogUnits.X, 4);
        WordWrap:= True;

        TextRect:= Rect(0, 0, Width, Height);
        DrawText(Canvas.Handle, PChar(APrompt), Length(APrompt) + 1, TextRect,
           DT_EXPANDTABS or DT_CALCRECT or DT_WORDBREAK or
           DrawTextBiDiModeFlagsReadingOnly);
        Prompt.Height:= TextRect.Bottom - TextRect.Top + 16;
      end;
      Edit := TEdit.Create(Form);
      with Edit do
      begin
        Parent := Form;
        Left := Prompt.Left;
        Top := Prompt.Top + Prompt.Height + 5;
        Width := MulDiv(164, DialogUnits.X, 4);
        MaxLength:= 255;
        Text := Value;
        SelectAll;
        PasswordChar := '*';
      end;
      ButtonTop := Edit.Top + Edit.Height + 15;
      ButtonWidth := MulDiv(50, DialogUnits.X, 4);
      ButtonHeight := MulDiv(14, DialogUnits.Y, 8);
      with TButton.Create(Form) do
      begin
        Parent := Form;
        Caption := 'Ок';
        ModalResult := mrOk;
        Default := True;
        SetBounds(MulDiv(38, DialogUnits.X, 4), ButtonTop, ButtonWidth,
          ButtonHeight);
      end;
      with TButton.Create(Form) do
      begin
        Parent := Form;
        Caption := 'Отмена';
        ModalResult := mrCancel;
        Cancel := True;
        SetBounds(MulDiv(92, DialogUnits.X, 4), Edit.Top + Edit.Height + 15,
          ButtonWidth, ButtonHeight);
        Form.ClientHeight := Top + Height + 13;
      end;

      if ShowModal = mrOk then
      begin
        Value := Edit.Text;
        Result := True;
      end;
    finally
      Form.Free;
    end;
end;

{ TMessForm }

procedure TMessForm.OnDetailErrorAddingsClick(Sender: TObject);
begin
   if Assigned(AddingsMethod) then
      AddingsMethod(Self, DetailMessage);
   TButton(Sender).Enabled:= false;
end;

procedure TMessForm.OnDetailErrorClick(Sender: TObject);
const
   MemoHeight = 120;
   MarginMemo = 8;
begin
   with TBevel.Create(Self) do
   begin
      Parent:= Self;
      Top:= Self.ClientHeight;
      Left:= 0;
      Height:= 2;
      Width:= Self.ClientWidth;
   end;
   if Assigned(AddingsMethod) then
   begin
      ClientHeight:= ClientHeight + MarginMemo + DetailButton.Height;
      with TButton.Create(Self) do
      begin
         Caption:= AddingsMethodButtonName;
         BoundsRect:= DetailButton.BoundsRect;
         Top:= Self.ClientHeight - Height;
         OnClick:= OnDetailErrorAddingsClick;
         Parent:= Self;
      end;
   end;
   ClientHeight:= ClientHeight + MemoHeight + MarginMemo * 2;
   with TMemo.Create(Self) do
   begin
      Parent:= Self;
      Top:= Self.ClientHeight - (MemoHeight + MarginMemo);
      Left:= MarginMemo;
      Width:= Self.ClientWidth - 2 * MarginMemo;
      Height:= MemoHeight;

      Text:= DetailMessage;
      ScrollBars:= ssVertical;
      ReadOnly:= true;

      Color:= Self.Color;
   end;

   DetailButton.Enabled:= false;
end;

initialization
   SetAddingsMethodParams('', nil);

end.
