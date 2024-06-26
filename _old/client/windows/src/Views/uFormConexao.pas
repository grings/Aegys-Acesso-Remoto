unit uFormConexao;

{
   Aegys Remote Access Project.
  Criado por XyberX (Gilbero Rocha da Silva), o Aegys Remote Access Project tem como objetivo o uso de Acesso remoto
  Gratuito para utiliza��o de pessoas em geral.
   O Aegys Remote Access Project tem como desenvolvedores e mantedores hoje

  Membros do Grupo :

  XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
  Wendel Fassarela           - Devel and Admin
  Mobius One                 - Devel, Tester and Admin.
  Gustavo                    - Devel and Admin.
  Roniery                    - Devel and Admin.
  Alexandre Abbade           - Devel and Admin.
  e Outros como voc�, venha participar tamb�m.
}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Actions, System.Win.ScktComp, System.Messaging,
  System.IOUtils, System.Rtti, System.DateUtils,

  windows, shellapi, Messages,

  // ERRO
  Vcl.Forms, VCL.Graphics, Vcl.Imaging.jpeg,
  // ERRO

  FMX.Types, FMX.Controls, FMX.Dialogs, FMX.Edit, FMX.Objects,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Ani, FMX.TabControl, FMX.ListBox,
  FMX.Menus, FMX.StdCtrls, FMX.Forms, FMX.ActnList, FMX.Graphics, FMX.Clipboard,
  FMX.Platform.Win,

  uAegysBase, uAegysDataTypes, uAegysConsts, uAegysClientMotor, uAegysBufferPack,
  uAegysZlib, uAegysTools,
  uFunctions, CCR.Clipboard, StreamManager,

  Config.SQLite.FireDAC, uLocale
  ;

type
  TFormConexao = class(TForm)
    lyHeader: TLayout;
    PhLogo: TPath;
    LSubTitle: TLabel;
    Layout2: TLayout;
    LTitle: TLabel;
    Layout3: TLayout;
    lyMachineID: TLayout;
    RMachineID: TRectangle;
    LlyMachineIDCaption: TLabel;
    LMachineID: TLabel;
    Layout6: TLayout;
    PhMachineIDCopy: TPath;
    sbMachineIDCopy: TSpeedButton;
    lyGuestID: TLayout;
    RGuestID: TRectangle;
    LlyGuestIDCaption: TLabel;
    Layout10: TLayout;
    EGuestID: TEdit;
    lyConnect: TLayout;
    btnConectar: TRoundRect;
    LbtnConectar: TLabel;
    aniBtnLogin: TFloatAnimation;
    ActionList1: TActionList;
    actConnect: TAction;
    lyStatus: TLayout;
    PhStatus: TPath;
    LStatus: TLabel;
    tmrIntervalo: TTimer;
    tmrClipboard: TTimer;
    actCopyID: TAction;
    actCopyPassword: TAction;
    Layout4: TLayout;
    sbPasteID: TSpeedButton;
    PhPasteID: TPath;
    actPasteID: TAction;
    LVersion: TLabel;
    phOptions: TPath;
    sbOptions: TSpeedButton;
    lyQuality: TLayout;
    rQuality: TRectangle;
    LlyResolutionCaption: TLabel;
    cbQuality: TComboBox;
    lyPassword: TLayout;
    RPassword: TRectangle;
    LlyPasswordCaption: TLabel;
    Layout8: TLayout;
    LPassword: TLabel;
    sbPasswordCopy: TSpeedButton;
    PhPasswordCopy: TPath;
    TmrSystemTray: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure actPasteIDExecute(Sender: TObject);
    procedure actConnectExecute(Sender: TObject);
    procedure actCopyIDExecute(Sender: TObject);
    procedure actCopyPasswordExecute(Sender: TObject);
    procedure tmrClipboardTimer(Sender: TObject);
    procedure tmrIntervaloTimer(Sender: TObject);
    procedure EGuestIDTyping(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sbOptionsClick(Sender: TObject);
    procedure TmrSystemTrayTimer(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    Position,
    vFPS,
    MousePosX,
    MousePosY         : Integer;
    vInitTime,
    vFinalTime        : TDateTime;
    aPackList         : TPackList;
    Locale            : TLocale;
    aConnection,
    vClientID,
    vOldClipboardFile,
    vOldClipboardText : String;
    TrayWnd           : HWND;
    TrayIconData      : TNotifyIconData;
    BInputsBlock,
    TrayIconAdded,
    vVisualizador,
    isvisible         : Boolean;
    SendDataThread    : TAegysMotorThread;//Envio de Desktop
//    SendCommandEvents : TAegysMotorThread;//Envio de Comandos
    Function  MascaraID              (AText,
                                      AMascara          : String) : String;
    procedure Translate;
    procedure SetColors;
    function  ClipboardGetAsFile                        : String;
    procedure TrayWndProc            (Var Message       : TMessage);
    procedure ShowAppOnTaskbar;
    procedure HideApponTaskbar;
    procedure SetTrayIcon;
    procedure OnBeforeConnect        (Sender            : TObject;
                                      Var WelcomeString : String);
    procedure OnConnect              (Sender            : TObject);
    procedure OnServerLogin          (Sender            : TObject);
    procedure OnDisconnect           (Sender            : TObject);
    procedure OnBeginTransactionError(Connection        : String);
    procedure OnBeginTransaction     (Connection        : String;
                                      Var ClientID,
                                      Alias             : String);
    procedure OnIncommingConnect     (Connection        : String;
                                      Var ClientID,
                                      ClientPassword,
                                      Alias             : String);
    procedure OnAccessGranted        (Connection        : String;
                                      Var ClientID,
                                      ClientPassword,
                                      SpecialData       : String);
    procedure OnPeerConnected        (Connection        : String;
                                      Var ClientID,
                                      ClientPassword,
                                      Alias             : String);
    procedure OnPeerKick             (Connection        : String;
                                      Var ClientID,
                                      ClientPassword,
                                      Alias             : String);
    procedure OnPeerDisconnected     (Connection        : String;
                                      Var ClientID,
                                      ClientPassword,
                                      Alias             : String);
    Function  OnPulseData            (aPack             : TAegysBytes;
                                      CommandType       : TCommandType = tctScreenCapture): Boolean;
    procedure OnProcessData          (aPackList         : TPackList;
                                      aFullFrame        : Boolean);
    procedure OnScreenCapture        (Connection,
                                      ID, Command       : String;
                                      MultiPack         : Boolean;
                                      PackCount         : AeInteger;
                                      aBuf              : TAegysBytes);
    procedure OnKeyboardCapture      (Command           : String);
    procedure OnMouseCapture         (Command           : String);
    procedure KillThreads;
    procedure ExecuteCommand         (aLine             : String);
    procedure AccessDenied;
  public
    Procedure Kick;
    procedure SetPeerDisconnected;
    procedure LimparConexao;
    procedure MudarStatusConexao     (AStatus           : Integer;
                                      AMensagem         : String);
    procedure SetOffline;
    procedure SetOnline;
    procedure SetSockets;
  end;

  Function RFB_Data : Boolean;

var
  FormConexao        : TFormConexao;
  Conexao            : TAegysClient;
  aMonitor           : String;
  vDrawCursor,
  Bblockinput        : Boolean;
  vResolucaoLargura,
  vOldResolucaoLargura,
  vResolucaoAltura,
  vOldResolucaoAltura,
  CF_FILE            : Integer;
  mx, my             : Single;

const
  WM_ICONTRAY = WM_USER + 1;

implementation

{$R *.fmx}

uses
  uFormTelaRemota, uFileTransfer, uFormChat, uLibClass, uConstants, uFormConfig,
  uFormSenha, uSendKeyClass, NB30;


Function RFB_Data : Boolean;
var
 ver            : tosversioninfo;
 majorversion,
 minorversion,
 buildnumber    : Integer;
 name,
 csdversion     : String;
Begin
 majorversion := 0;
 minorversion := 0;
 Ver.dwOSVersionInfoSize := SizeOf( TOSVersionInfo );
 If Windows.GetVersionEx(Ver) Then
  Begin
   With Ver Do
    Begin
     Case dwPlatformId Of
      VER_PLATFORM_WIN32s        : Name := 'Win32s';
      VER_PLATFORM_WIN32_WINDOWS : Name := 'Windows 95';
      VER_PLATFORM_WIN32_NT      : Name := 'Windows NT';
     End;
     majorversion := dwMajorVersion;
     minorversion := dwminorversion;
     buildnumber  := dwBuildNumber;
     csdversion   := szCSDVersion;
//            label1.caption:=name;
//            label10.caption:=minorversion;
//            label2.caption:=majorversion;
//            label3.caption:=buildnumber;
//            label4.caption:=csdversion;
    End;
  End;
 Result := (majorversion < 7);
End;

Procedure TFormConexao.ExecuteCommand(aLine : String);
Var
 aTempID        : String;
 InicioPalavra,
 TamanhoPalavra : Integer;
 vOnMouseShow   : Boolean;
Begin
 vOnMouseShow   := False;
 If aLine.Contains(cShowMouse)    Then
  Begin
   vOnMouseShow  := True;
   vMostrarMouse := vOnMouseShow;
  End;
 If aLine.Contains(cHideMouse)    Then
  Begin
   vOnMouseShow  := True;
   vMostrarMouse := False;
  End;
 If aLine.Contains(cBlockInput)   Then
  Begin
   BInputsBlock := True;
   Blockinput(BInputsBlock);
  End;
 If aLine.Contains(cUnBlockInput) Then
  Begin
   BInputsBlock := False;
   Blockinput(BInputsBlock);
  End;
 Position := Pos(cMousePos, aLine);
 While Position > 0 Do
  Begin
   Delete(aLine, InitStrPos, Position + Length(cMousePos) -1);
   Position := Pos(cSeparatorTag, aLine);
   aTempID  := aMonitor;
   If Trim(aTempID) = '' Then
    aTempID := '0';
   MousePosX := Trunc(Screen.Displays[StrToInt(aTempID)].WorkArea.Left) +
      StrToInt(Copy(aLine, InitStrPos, Position - 1));
   Delete(aLine, InitStrPos, Position + 2);
   MousePosY := Trunc(Screen.Displays[StrToInt(aTempID)].WorkArea.Top) +
      StrToInt(Copy(aLine, InitStrPos, Pos(cEndTag, aLine) - 1));
   Delete(aLine, InitStrPos, Pos(cEndTag, aLine) + Length(cEndTag) -1);
   If aLine.Contains(cBlockInput) then
    Begin
     BlockInput(False);
     SetCursorPos(MousePosX, MousePosY);
     Application.ProcessMessages;
     BlockInput(True);
    End
   Else
    SetCursorPos(MousePosX, MousePosY);
   Application.Processmessages;
   Position := Pos(cMousePos, aLine);
  End;
 Position := Pos(cMouseClickLeftDown, aLine);
 If Position > 0 then
  Begin
   aTempID   := aMonitor;
   If Trim(aTempID) = '' Then
    aTempID := '0';
   Delete(aLine, InitStrPos, Position + Length(cMouseClickLeftDown) -1);
   Position   := Pos(cSeparatorTag, aLine);
   MousePosX := Trunc(Screen.Displays[StrToInt(aTempID)].WorkArea.Left) +
     StrToInt(Copy(aLine, InitStrPos, Position - 1));
   Delete(aLine, 1, Position + 2);
   MousePosY := Trunc(Screen.Displays[StrToInt(aTempID)].WorkArea.Top) +
     StrToInt(Copy(aLine, InitStrPos, Pos(cEndTag, aLine) - 1));
   Delete(aLine, InitStrPos, Pos(cEndTag, aLine) + Length(cEndTag) -1);
   If aLine.Contains(cBlockInput) Then
    Begin
     BlockInput(false);
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
     Application.ProcessMessages;
     BlockInput(true);
    End
   Else
    Begin
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
    End;
  End;
 Position := Pos(cMouseClickLeftUp, aLine);
 If Position > 0 then
  Begin
   aTempID   := aMonitor;
   If Trim(aTempID) = '' Then
    aTempID := '0';
   Delete(aLine, InitStrPos, Position + Length(cMouseClickLeftUp) -1);
   Position := Pos(cSeparatorTag, aLine);
   MousePosX := Trunc(Screen.Displays[StrToInt(aTempID)].WorkArea.Left) +
     StrToInt(Copy(aLine, InitStrPos, Position - 1));
   Delete(aLine, 1, Position + 2);
   MousePosY := Trunc(Screen.Displays[StrToInt(aTempID)].WorkArea.Top) +
     StrToInt(Copy(aLine, InitStrPos, Pos(cEndTag, aLine) - 1));
   Delete(aLine, InitStrPos, Pos(cEndTag, aLine) + Length(cEndTag) -1);
   If aLine.Contains(cBlockInput) then
    Begin
     BlockInput(false);
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
     Application.ProcessMessages;
     blockinput(true);
    End
   Else
    Begin
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
    End;
  End;
 Position := Pos(cMouseClickRightDown, aLine);
 If Position > 0 Then
  Begin
   aTempID   := aMonitor;
   If Trim(aTempID) = '' Then
    aTempID := '0';
   Delete(aLine, InitStrPos, Position + Length(cMouseClickRightDown) -1);
   Position := Pos(cSeparatorTag, aLine);
   MousePosX := Trunc(Screen.Displays[StrToInt(aTempID)].WorkArea.Left) +
      StrToInt(Copy(aLine, InitStrPos, Position - 1));
   Delete(aLine, 1, Position + 2);
   MousePosY := Trunc(Screen.Displays[StrToInt(aTempID)].WorkArea.Top) +
      StrToInt(Copy(aLine, InitStrPos, Pos(cEndTag, aLine) - 1));
   Delete(aLine, InitStrPos, Pos(cEndTag, aLine) + Length(cEndTag) -1);
   If aLine.Contains(cBlockInput) Then
    Begin
     BlockInput(false);
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
     Application.ProcessMessages;
     Blockinput(true);
    End
   Else
    Begin
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTDOWN, 0, 0, 0, 0);
    End;
  End;
 Position := Pos(cMouseClickRightUp, aLine);
 If Position > 0 Then
  Begin
   aTempID   := aMonitor;
   If Trim(aTempID) = '' Then
    aTempID := '0';
   Delete(aLine, InitStrPos, Position + Length(cMouseClickRightUp) -1);
   Position := Pos(cSeparatorTag, aLine);
   MousePosX := Trunc(Screen.Displays[StrToInt(aTempID)].WorkArea.Left) +
      StrToInt(Copy(aLine, InitStrPos, Position - 1));
   Delete(aLine, 1, Position + 2);
   MousePosY := Trunc(Screen.Displays[StrToInt(aTempID)].WorkArea.Top) +
      StrToInt(Copy(aLine, InitStrPos, Pos(cEndTag, aLine) - 1));
   Delete(aLine, InitStrPos, Pos(cEndTag, aLine) + Length(cEndTag) -1);
   If aLine.Contains(cBlockInput) then
    Begin
     BlockInput(false);
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
     Application.ProcessMessages;
     BlockInput(true);
    End
   Else
    Begin
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_RIGHTUP, 0, 0, 0, 0);
    End;
  End;
 Position := Pos(cMouseClickMiddleDown, aLine);
 If Position > 0 Then
  Begin
   aTempID   := aMonitor;
   If Trim(aTempID) = '' Then
    aTempID := '0';
   Delete(aLine, InitStrPos, Position + Length(cMouseClickMiddleDown) -1);
   Position := Pos(cSeparatorTag, aLine);
   MousePosX := Trunc(Screen.Displays[StrToInt(aTempID)].WorkArea.Left) +
      StrToInt(Copy(aLine, InitStrPos, Position - 1));
   Delete(aLine, 1, Position + 2);
   MousePosY := Trunc(Screen.Displays[StrToInt(aTempID)].WorkArea.Top) +
      StrToInt(Copy(aLine, InitStrPos, Pos(cEndTag, aLine) - 1));
   Delete(aLine, InitStrPos, Pos(cEndTag, aLine) + Length(cEndTag) -1);
   If aLine.Contains(cBlockInput) Then
    Begin
     BlockInput(false);
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEDOWN, 0, 0, 0, 0);
     Application.ProcessMessages;
     BlockInput(true);
    End
   Else
    Begin
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEDOWN, 0, 0, 0, 0);
    End;
  End;
 Position := Pos(cMouseClickMiddleUp, aLine);
 If Position > 0 Then
  Begin
   aTempID   := aMonitor;
   If Trim(aTempID) = '' Then
    aTempID := '0';
   Delete(aLine, InitStrPos, Position + Length(cMouseClickMiddleUp) -1);
   Position := Pos(cSeparatorTag, aLine);
   MousePosX := Trunc(Screen.Displays[StrToInt(aTempID)].WorkArea.Left) +
      StrToInt(Copy(aLine, InitStrPos, Position - 1));
   Delete(aLine, 1, Position + 2);
   MousePosY := Trunc(Screen.Displays[StrToInt(aTempID)].WorkArea.Top) +
      StrToInt(Copy(aLine, InitStrPos, Pos(cEndTag, aLine) - 1));
   Delete(aLine, InitStrPos, Pos(cEndTag, aLine) + Length(cEndTag) -1);
   If aLine.Contains(cBlockInput) Then
    Begin
     BlockInput(false);
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEUP, 0, 0, 0, 0);
     Application.ProcessMessages;
     BlockInput(true);
    End
   Else
    Begin
     SetCursorPos(MousePosX, MousePosY);
     Mouse_Event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MIDDLEUP, 0, 0, 0, 0);
    End;
  End;
 Position := Pos(cWheelMouse, aLine);
 If Position > 0 then
  Begin
   Delete(aLine, InitStrPos, Position + Length(cWheelMouse) -1);
   Position := StrToInt(Copy(aLine, InitStrPos, Pos(cEndTag, aLine) - 1));
   Delete(aLine, InitStrPos, Pos(cEndTag, aLine) + Length(cEndTag) -1);
   If aLine.Contains(cBlockInput) Then
    Begin
     BlockInput(false);
     Mouse_Event(MOUSEEVENTF_WHEEL, 0, 0, DWORD(StrToInt(aLine)), 0);
     Application.ProcessMessages;
     BlockInput(true);
    End
   Else
    Mouse_Event(MOUSEEVENTF_WHEEL, 0, 0, DWORD(Position), 0);
  End;
 If vOnMouseShow then
  vDrawCursor := vMostrarMouse;
 Bblockinput := aLine.Contains(cBlockInput);
 If Bblockinput Then
  Begin
   InicioPalavra  := pos(cBlockInput, aLine);
   TamanhoPalavra := Length(cBlockInput);
   If InicioPalavra > 0          Then
    Delete(aLine, InicioPalavra, TamanhoPalavra);
   BlockInput(false);
  End;
 If aLine.Contains(cAltDown)     Then
  Begin
   aLine := StringReplace(aLine, cAltDown, '', [rfReplaceAll]);
   keybd_event(18, 0, 0, 0);
  End;
 If aLine.Contains(cAltUp)       Then
  Begin
   aLine := StringReplace(aLine, cAltUp, '', [rfReplaceAll]);
   keybd_event(18, 0, KEYEVENTF_KEYUP, 0);
  End;
 If aLine.Contains(cCtrlDown)    Then
  Begin
   aLine := StringReplace(aLine, cCtrlDown, '', [rfReplaceAll]);
   keybd_event(17, 0, 0, 0);
  End;
 If aLine.Contains(cCtrlUp) Then
  Begin
   aLine := StringReplace(aLine, cCtrlUp, '', [rfReplaceAll]);
   keybd_event(17, 0, KEYEVENTF_KEYUP, 0);
  End;
 If aLine.Contains(cShiftDown) then
  Begin
   aLine := StringReplace(aLine, cShiftDown, '', [rfReplaceAll]);
   keybd_event(16, 0, 0, 0);
  End;
 If aLine.Contains(cShiftUp) then
  Begin
   aLine := StringReplace(aLine, cShiftUp, '', [rfReplaceAll]);
   keybd_event(16, 0, KEYEVENTF_KEYUP, 0);
  End;
 If aLine.Contains('?') Then
  Begin
   If GetKeyState(VK_SHIFT) < 0 Then
    Begin
     keybd_event(16, 0, KEYEVENTF_KEYUP, 0);
     SendKeys(PWideChar(aLine), False);
     keybd_event(16, 0, 0, 0);
    End;
  End
 Else If aLine <> '' Then
  SendKeys(PWideChar(aLine), False);
// Processmessages;
// BlockInput(Bblockinput);
End;

Procedure TFormConexao.LimparConexao;
Begin
  vResolucaoLargura := 986;
  vResolucaoAltura  := 600;
  vVisualizador     := False;
  vOldClipboardText := '';
  If Assigned(FormTelaRemota) Then
   FreeAndNil(FormTelaRemota);
  If Assigned(fFileTransfer) Then
   FreeAndNil(fFileTransfer);
  If Assigned(FormChat) Then
   FreeAndNil(FormChat);
End;

Procedure TFormConexao.tmrClipboardTimer(Sender: TObject);
Var

  FileStream: TFileStream;
  s, FileName: string;
  ClipFormat: TClipboardFormat;
  aFileStream : TAegysBytes;
Begin
  tmrClipboard.Enabled := vVisualizador;
  try

    if Clipboard.HasText then
    begin
      if (vOldClipboardText <> Clipboard.AsText) Then
      Begin
        vOldClipboardText := Clipboard.AsText;
        Conexao.SendMessage(EGuestID.Text, '<|CLIPBOARD|>' + vOldClipboardText + '<|END|>', tctClipBoard);
      End;
    end
    else
    begin
      for s in Clipboard.GetFileNames do
      begin
        if s <> '' then
          if (vOldClipboardFile <> s) And (FileExists(s)) Then
          begin
            FileStream := TFileStream.Create(s, fmOpenRead);
            Try
             FileName := ExtractFileName(s);
             vOldClipboardFile := s;
             Conexao.SendMessage(EGuestID.Text, '<|DIRECTORYTOSAVE|>' + FileName + '<|><|SIZE|>' + intToStr(FileStream.Size) + '<|END|>', tctFileTransfer);
             FileStream.Position := 0;
             FileStream.Read(aFileStream, FileStream.Size);
             Conexao.SendBytes(EGuestID.Text, aFileStream);
             Application.Processmessages;
            Finally
             SetLength(aFileStream, 0);
             FreeAndNil(FileStream);
            End;
          end;
      end;
    end;
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;

end;

procedure TFormConexao.FormActivate(Sender: TObject);
begin
  if not Conexao.Active then
    try
      Conexao.Connect;
    except
      Conexao.Disconnect;
    end;
end;

procedure TFormConexao.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(Conexao) then
    FreeAndNil(Conexao);

end;

procedure TFormConexao.FormCreate(Sender: TObject);
var
  CFG: TSQLiteConfig;
begin
 CF_FILE := RegisterClipboardFormat('FileName');
 // inicializando os objetos
 Locale  := TLocale.Create;
 Conexao := TAegysClient.Create(Self);
 // --------------------------
 SetColors;
 SetOffline;
 Translate;
 isvisible := True;
 // load confg
 CFG := TSQLiteConfig.Create;
 Try
  lyGuestID.Visible := Not StrToIntDef(CFG.getValue(QUICK_SUPPORT), 0).ToBoolean;
  lyConnect.Visible := Not StrToIntDef(CFG.getValue(QUICK_SUPPORT), 0).ToBoolean;
  lyQuality.Visible := Not StrToIntDef(CFG.getValue(QUICK_SUPPORT), 0).ToBoolean;
 Finally
  FreeAndNil(CFG);
 End;
 aPackList         := TPackList.Create;
 SendDataThread    := Nil;
// SendCommandEvents := Nil;
 Position          := 0;
 MousePosX         := 0;
 MousePosY         := 0;
end;

procedure TFormConexao.FormDestroy(Sender: TObject);
begin
 FreeAndNil(aPackList);
 FreeAndNil(Locale);
end;

procedure TFormConexao.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Single);
begin
  mx := X;
  my := Y;
end;

procedure TFormConexao.FormShow(Sender: TObject);
Var
 CFG : TSQLiteConfig;
Begin
 CFG := TSQLiteConfig.Create;
 Try
  If StrToIntDef(CFG.getValue(ENABLE_SYSTRAY), 0).ToBoolean Then
   If isvisible Then
    SetTrayIcon;
 Finally
  FreeAndNil(CFG);
 End;
End;

procedure TFormConexao.HideApponTaskbar;
var
  hAppWnd: HWND;
  ExStyle: LONG_PTR;
begin
  hAppWnd := FMX.Platform.Win.ApplicationHWND();
  ShowWindow(hAppWnd, SW_HIDE);
  ExStyle := GetWindowLongPtr(hAppWnd, GWL_EXSTYLE);
  SetWindowLongPtr(hAppWnd, GWL_EXSTYLE, (ExStyle and WS_EX_APPWINDOW) or
    WS_EX_TOOLWINDOW);
  // ShowWindow(hAppWnd, SW_SHOW);
end;

function TFormConexao.MascaraID(AText, AMascara: string): string;
var
  i: Integer;
begin
  for i := 1 to Length(AText) do
  begin
    if (AMascara[i] = '9') and not(AText[i] in ['0' .. '9']) and
      (Length(AText) = Length(AMascara) + 1) then
      Delete(AText, i, 1);
    if (AMascara[i] <> '9') and (AText[i] in ['0' .. '9']) then
      Insert(AMascara[i], AText, i);
  end;
  Result := AText;
end;

procedure TFormConexao.MudarStatusConexao(AStatus: Integer; AMensagem: string);
var
  cColor: TAlphaColor;
begin
 cColor := TAlphaColorRec.Yellow;
  case AStatus of
    1:
      cColor := TAlphaColorRec.Yellow;
    2:
      cColor := $FFED3237;
    3:
      cColor := TAlphaColorRec.Mediumseagreen;
  end;
  PhStatus.Fill.Color := cColor;
  PhStatus.Tag := AStatus;
  LStatus.Text := AMensagem;
//  SetOnline;
end;

procedure TFormConexao.sbOptionsClick(Sender: TObject);
begin
  Application.CreateForm(TfConfig, fConfig);
  fConfig.show;
  fConfig.CallBackConfig := Translate;
end;

procedure TFormConexao.actPasteIDExecute(Sender: TObject);
begin
  EGuestID.Text := MascaraID(TRDLib.ColarTexto, '99-999-999');
  EGuestID.GoToTextEnd;
end;

function TFormConexao.ClipboardGetAsFile: string;
var
  Data: THandle;
begin
  Clipboard.Open;
  Data := GetClipboardData(CF_FILE);
  try
    if Data <> 0 then
      Result := PChar(GlobalLock(Data))
    else
      Result := '';
  finally
    if Data <> 0 then
      GlobalUnlock(Data);
    Clipboard.Close;
  end;
end;

procedure TFormConexao.actConnectExecute(Sender: TObject);
begin
 If LbtnConectar.Enabled Then
  Begin
   vOldResolucaoAltura   := -1;
   vOldResolucaoLargura  := -1;
   If Assigned(FormTelaRemota) Then
    FreeAndNil(FormTelaRemota);
   vDrawCursor := False;
   If not(LlyGuestIDCaption.Text = '   -   -   ') then
    begin
      if (LlyGuestIDCaption.Text = Conexao.SessionID) then
        MessageBox(0, Locale.GetLocaleDlg(lsDIALOGS, lvDlgErrorSelfConnect),
          Locale.GetLocaleDlg(lsDIALOGS, lvDlgRemoteSupport),
          MB_ICONASTERISK + MB_TOPMOST)
      else
      begin
        LbtnConectar.Enabled := False;
        Conexao.SendCommand(cFindID + EGuestID.Text);
        btnConectar.Enabled := False;
        MudarStatusConexao(1, Locale.GetLocale(lsMESSAGES, lvMsgSearchingID));
      end;
    end;
  End;
end;

procedure TFormConexao.actCopyIDExecute(Sender: TObject);
begin
  TRDLib.CopiarTexto(LMachineID.Text);
end;

procedure TFormConexao.actCopyPasswordExecute(Sender: TObject);
begin
  TRDLib.CopiarTexto(LPassword.Text)
end;

procedure TFormConexao.Translate;
begin
  self.Caption := Locale.GetLocale(lsFORMS, lvFrmMainTitle);
  LSubTitle.Text := Locale.GetLocale(lsFORMS, lvFrmMainSubTitle);
  LVersion.Text := Format(Locale.GetLocale(lsSYSTEMINFO, lvSysVersion),
    [TRDLib.GetAppVersionStr]);
  LlyMachineIDCaption.Text := Locale.GetLocale(lsFORMS, lvFrmMainMachineID);
  LlyPasswordCaption.Text := Locale.GetLocale(lsFORMS, lvFrmMainPassword);
  LlyGuestIDCaption.Text := Locale.GetLocale(lsFORMS, lvFrmMainGuestID);
  LlyResolutionCaption.Text := Locale.GetLocale(lsFORMS, lvFrmMainResolution);
  LbtnConectar.Text := Locale.GetLocale(lsFORMS, lvFrmMainConnectButton);
  Locale.GetLocale(cbQuality, tcbQuality);
  SetSockets;

end;

procedure TFormConexao.TrayWndProc(var Message: TMessage);
begin
  if Message.MSG = WM_ICONTRAY then
  begin
    case Message.LParam of
      WM_LBUTTONDOWN:
        begin
          if not isvisible then
            self.show; // If u use some frmMain.hide
          SetForegroundWindow(FmxHandleToHWND(FormConexao.Handle));
          if TrayIconAdded then
          begin
            // Shell_NotifyIcon(NIM_DELETE, @TrayIconData);
            TrayIconAdded := False;
            ShowAppOnTaskbar;
          end;
        end;
      // WM_RBUTTONDOWN: ShowMessage('RolePlay , but can be a PopUpMenu');
    end;
  end
  else
    Message.Result := DefWindowProc(TrayWnd, Message.MSG, Message.WParam,
      Message.LParam);
end;

procedure TFormConexao.SetColors;
begin
  RGuestID.Fill.Color := SECONDARY_COLOR;
  RMachineID.Fill.Color := SECONDARY_COLOR;
  rQuality.Fill.Color := SECONDARY_COLOR;
  RPassword.Fill.Color := SECONDARY_COLOR;
  PhLogo.Fill.Color := PRIMARY_COLOR;
  phOptions.Fill.Color := PRIMARY_COLOR;
  btnConectar.Fill.Color := PRIMARY_COLOR;
end;

procedure TFormConexao.SetOffline;
begin
  LMachineID.Text      := Locale.GetLocale(lsMESSAGES, lvMsgOffline);
  LPassword.Text       := LMachineID.Text;
  btnConectar.Enabled  := False;
  LbtnConectar.Enabled := btnConectar.Enabled;
  tmrIntervalo.Enabled := False;
  tmrClipboard.Enabled := False;
  MudarStatusConexao(1, Locale.GetLocale(lsMESSAGES, lvMsgOffline));
end;


Procedure TFormConexao.Kick;
Begin
 Conexao.DisconnectAllPeers;
End;

Procedure TFormConexao.KillThreads;
Begin
 If Assigned(SendDataThread) Then //Thread da Area de Trabalho
  Begin
   Try
    SendDataThread.Kill;
   Except
   End;
   {$IFDEF FPC}
    WaitForThreadTerminate(SendDataThread.Handle, 100);
   {$ELSE}
    {$IF Not Defined(HAS_FMX)}
     WaitForSingleObject  (SendDataThread.Handle, 100);
    {$IFEND}
   {$ENDIF}
   FreeAndNil(SendDataThread);
  End;
End;

procedure TFormConexao.SetPeerDisconnected;
begin
  Kick;
//  KillThreads;
  btnConectar.Enabled  := True;
  LbtnConectar.Enabled := btnConectar.Enabled;
  tmrIntervalo.Enabled := False;
  tmrClipboard.Enabled := False;
  MudarStatusConexao(1, Locale.GetLocale(lsMESSAGES, lvMsgPeerDisconnected));
  If Conexao.ConnectionList.Count = 0 Then
   Windows.ShowWindow(FormToHWND(Application.MainForm), SW_RESTORE);
end;

procedure TFormConexao.SetOnline;
begin
  LMachineID.Text      := Conexao.SessionID;
  LPassword.Text       := Conexao.SessionPWD;
  btnConectar.Enabled  := True;
  LbtnConectar.Enabled := btnConectar.Enabled;
  MudarStatusConexao(3, Locale.GetLocale(lsMESSAGES, lvMsgOnline));
end;

Function SerialNumHardDisk(FDrive : String): String;
Var
 Serial,
 DirLen,
 Flags   : DWORD;
 DLabel  : Array [0 .. 11] of Char;
Begin
 Try
  GetVolumeInformation(PChar(Copy(FDrive, 1, 1) + ':\'), DLabel, 12, @Serial, DirLen, Flags, nil, 0);
  Result := IntToHex(Serial, 8);
 Except
  Result := '';
 End;
End;

Function MacAddress : String;
var
 AdapterList: TLanaEnum;
 Adapter: TAdapterStatus;
 NCB1, NCB2: TNCB;
 Lana: AnsiChar;
begin
  FillChar(NCB1, SizeOf(NCB1), 0);
  NCB1.ncb_command := Char(NCBENUM);
  NCB1.ncb_buffer := @AdapterList;
  NCB1.ncb_length := SizeOf(AdapterList);
  Netbios(@NCB1);
  if Byte(AdapterList.length) > 0 then
  begin
    //AdapterList.lana[] contiene i vari dispositivi hardware
    Lana := AdapterList.lana[0];
    FillChar(NCB2, SizeOf(NCB2), 0);
    NCB2.ncb_command := Char(NCBRESET);
    NCB2.ncb_lana_num := Lana;
    if Netbios(@NCB2) <> Char(NRC_GOODRET) then begin Result := 'mac non trovato'; Exit; end;
    FillChar(NCB2, SizeOf(NCB2), 0);
    NCB2.ncb_command := Char(NCBASTAT);
    NCB2.ncb_lana_num := Lana;
    NCB2.ncb_callname := '*';
    FillChar(Adapter, SizeOf(Adapter), 0);
    NCB2.ncb_buffer := @Adapter;
    NCB2.ncb_length := SizeOf(Adapter);
    if Netbios(@NCB2) <> Char(NRC_GOODRET) then begin Result := 'mac non trovato'; Exit; end;
    Result := IntToHex(Byte(Adapter.adapter_address[0]), 2) + '-' +
              IntToHex(Byte(Adapter.adapter_address[1]), 2) + '-' +
              IntToHex(Byte(Adapter.adapter_address[2]), 2) + '-' +
              IntToHex(Byte(Adapter.adapter_address[3]), 2) + '-' +
              IntToHex(Byte(Adapter.adapter_address[4]), 2) + '-' +
              IntToHex(Byte(Adapter.adapter_address[5]), 2);
  end
  else Result := 'mac non trovato';
end;

Procedure TFormConexao.OnBeforeConnect(Sender            : TObject;
                                       Var WelcomeString : String);
Var
 vDrive : String;
Begin
 vDrive        := Uppercase(Copy(ParamStr(0), 1, 1));
 Welcomestring := MacAddress + '|' + SerialNumHardDisk(vDrive);
End;

procedure TFormConexao.OnServerLogin(Sender: TObject);
begin
 TThread.Synchronize(Nil, Procedure
                          Begin
                           SetOnline;
                           aConnection := Conexao.Connection;
                          End);
end;

procedure TFormConexao.OnConnect(Sender: TObject);
begin
 //SetOnline;
 Application.ProcessMessages;
end;

procedure TFormConexao.OnBeginTransaction(Connection        : String;
                                          Var ClientID,
                                          Alias             : String);
Begin
 If Not Assigned(FormSenha) Then
  FormSenha := TFormSenha.Create(Self);
 FormSenha.Showmodal;
End;

procedure TFormConexao.AccessDenied;
Begin
 btnConectar.Enabled  := True;
 LbtnConectar.Enabled := btnConectar.Enabled;
 MudarStatusConexao(3, Format('Id "%s" denied...', [EGuestID.Text]));
End;

procedure TFormConexao.OnBeginTransactionError(Connection : String);
Begin
 SetOnline;
 MudarStatusConexao(2, Format('Id "%s" not found...', [Connection]));
End;

procedure TFormConexao.OnDisconnect(Sender: TObject);
begin
 TThread.Synchronize(Nil, Procedure
                          Begin
                           SetOffline;
                          End);
end;

Procedure TFormConexao.OnKeyboardCapture (Command           : String);
Begin
 OnMouseCapture(Command);
End;

Procedure TFormConexao.OnMouseCapture    (Command           : String);
Begin
 ExecuteCommand(Command);
End;

Procedure TFormConexao.OnIncommingConnect(Connection        : String;
                                          Var ClientID,
                                          ClientPassword,
                                          Alias             : String);
Begin
 MudarStatusConexao(1, Format(Locale.GetLocale(lsMESSAGES, lvMsgIncomming), [Connection]));
End;

Function TFormConexao.OnPulseData(aPack       : TAegysBytes;
                                  CommandType : TCommandType = tctScreenCapture) : Boolean;
Begin
 Result := Conexao.Active;
 If Result Then
  Begin
   If CommandType = tctScreenCapture Then
    Conexao.SendBytes(aPack)
   Else
    Conexao.SendCommand(aConnection, aPack);
  End;
 //Processmessages;
End;

Procedure TFormConexao.OnProcessData(aPackList  : TPackList;
                                     aFullFrame : Boolean);
Var
 aPackClass  : TPackClass;
 Procedure aCapture;
 Var
  vMonitor : String;
 Begin
  Try
   vMonitor := aMonitor;
   If vMonitor = '' Then
    vMonitor := '0';
   GetScreenToMemoryStream(aPackClass, vDrawCursor, pf16bit, vMonitor, aFullFrame);
  Finally
  End;
 End;
Begin
 Try
  aPackClass              := Nil;
  Processmessages;
  aCapture;
  If Assigned(aPackClass)  Then
   Begin
    If Not Assigned(Conexao) Then
     Exit;
    If Assigned(aPackList)   Then
     aPackList.Add(aPackClass)
    Else
     Exit;
   End;
  Processmessages;
 Finally
 End;
End;

Procedure TFormConexao.OnAccessGranted(Connection        : String;
                                       Var ClientID,
                                       ClientPassword,
                                       SpecialData       : String); //tela remota
Begin
 Try
  //ResolucaoLargura
  vFPS := 0;
  If Not Assigned(FormTelaRemota) Then
   FormTelaRemota                 := TFormTelaRemota.Create(Self);
  vClientID                       := ClientID;
  FormTelaRemota.Caption          := Format(cCaptureTitle, [vClientID, vFPS]);
  FormTelaRemota.Connection       := Connection;
  aConnection                     := FormTelaRemota.Connection;
  FormTelaRemota.Show;
 Finally

 End;
End;

Procedure TFormConexao.OnPeerConnected(Connection        : String;
                                       Var ClientID,
                                       ClientPassword,
                                       Alias             : String); //Captura de tela
Begin
 If (Not Assigned(SendDataThread))     Or
    (Conexao.ConnectionList.Count = 1) Then
  Begin
   If Not Assigned(SendDataThread) Then
    Begin
     SendDataThread                := TAegysMotorThread.Create;
     aConnection                   := Connection;
     Try
      Windows.ShowWindow(FormToHWND(Self), SW_Minimize);
      SendDataThread.OnProcessData := OnProcessData;
      SendDataThread.OnPulseData   := OnPulseData;
      SendDataThread.Resume;
     Finally

     End;
    End
   Else
    SendDataThread.GetFullFrame;
  End
 Else
  SendDataThread.GetFullFrame;
End;

Procedure TFormConexao.OnPeerDisconnected(Connection        : String;
                                          Var ClientID,
                                          ClientPassword,
                                          Alias             : String); //Captura de tela
Begin
 SetPeerDisconnected;
End;

Procedure TFormConexao.OnPeerKick(Connection      : String;
                                  Var ClientID,
                                  ClientPassword,
                                  Alias           : String);
Begin
 If Assigned(FormTelaRemota) Then
  FormTelaRemota.Close;
 If Conexao.ConnectionList.Count = 0 Then
  KillThreads;  //TODO XyberX, Pois isso daqui para a Captura geral...
 btnConectar.Enabled  := True;
 LbtnConectar.Enabled := btnConectar.Enabled;
 tmrIntervalo.Enabled := False;
 tmrClipboard.Enabled := False;
 MudarStatusConexao(1, 'Peer Disconnected');
 If Conexao.ConnectionList.Count = 0 Then
  Windows.ShowWindow(FormToHWND(Self), SW_RESTORE);
End;

Procedure TFormConexao.OnScreenCapture(Connection,
                                       ID,
                                       Command         : String;
                                       MultiPack       : Boolean;
                                       PackCount       : AeInteger;
                                       aBuf            : TAegysBytes);
Var
 ArrayOfPointer : TArrayOfPointer;
 vStream        : TStream;
 vAltura,
 vLargura       : String;
 vGetFPS,
 aPackCountData,
 I, pRectTop,
 pRectLeft,
 pRectBottom,
 pRectRight,
 aBuffPosition  : AeInteger;
 aSizeData      : AeInt64;
 bBuf           : TAegysBytes;
 aOldbmpPart,
 MybmpPart      : Vcl.Graphics.TBitmap;
 vStreamBitmap  : TMemoryStream;
 Function GetFps : Integer;
 Begin
  Result     := 0;
  vFinalTime := Now;
  If MilliSecondsBetween(vInitTime, vFinalTime) >= 1000 Then
   Begin
    Result    := vFPS;
    vFPS      := 0;
    vInitTime := Now;
   End
  Else
   Inc(vFPS);
 End;
 Procedure ResizeScreen(Altura, Largura : Integer);
 Var
  vScreenSizeFact,
  vFatorA : Integer;
  Function MDC(a, b : Integer) : Integer;
  Var
   resto : Integer;
  Begin
   While b <> 0 Do
    Begin
     resto := a mod b;
     a     := b;
     b     := resto;
    End;
   Result := a;
  End;
  Function ProporcaoTela(Direita, Topo : Integer) : Integer;
  Begin
   Result := Round(Direita / MDC(Direita, Topo))
  End;
 Begin
  If ((vResolucaoAltura  >  0)  And
      (vResolucaoLargura >  0)) And
     ((vResolucaoAltura  <> vOldResolucaoAltura)   Or
      (vResolucaoLargura <> vOldResolucaoLargura)) Then
   Begin
    vOldResolucaoAltura   := vResolucaoAltura;
    vOldResolucaoLargura  := vResolucaoLargura;
    If vOldResolucaoAltura  > vOldResolucaoLargura Then
     Begin
      vFatorA          := Round((vOldResolucaoLargura  / vOldResolucaoAltura)  * 100);
      FormTelaRemota.Width  := Round((Screen.Height    / 100) * vFatorA);
      If vOldResolucaoAltura > Screen.Height Then
       vFatorA          := Round((Screen.Height        / vOldResolucaoAltura)  * 100)
      Else
       vFatorA          := Round((vOldResolucaoAltura  / Screen.Height)        * 100);
      vScreenSizeFact  := Round((Screen.Height / 100)  * vFatorA);
      FormTelaRemota.Height := vScreenSizeFact + ((round(Screen.Height) - vScreenSizeFact) div 2);
      FormTelaRemota.Top    := Round((Screen.Height / 2) - (FormTelaRemota.Height / 2));
      FormTelaRemota.Left   := Round(Screen.Width - FormTelaRemota.Width);
     End
    Else
     Begin
      If vOldResolucaoAltura  > Screen.Height Then
       vFatorA              := Round((Screen.Height         / vOldResolucaoAltura)   * 100)
      Else If vOldResolucaoAltura = Screen.Height Then
       vFatorA              := Round(((vOldResolucaoAltura  - 100) / Screen.Height)  * 100)
      Else
       vFatorA              := Round((vOldResolucaoAltura   / Screen.Height)         * 100);
      FormTelaRemota.Height := Round((Screen.Height         / 100) * vFatorA);
      If vOldResolucaoLargura  > Screen.Width Then
       vFatorA              := Round((Screen.Width          / vOldResolucaoLargura)  * 100)
      Else If vOldResolucaoLargura  = Screen.Width Then
       vFatorA              := Round(((vOldResolucaoLargura - 50) / Screen.Width)    * 100)
      Else
       vFatorA              := Round((vOldResolucaoLargura   / Screen.Width)         * 100);
      vScreenSizeFact       := Round((Screen.Width          / 100) * vFatorA);
      FormTelaRemota.Width  := vScreenSizeFact;
      FormTelaRemota.Top    := Round((Screen.Height / 2) - (FormTelaRemota.Height / 2));
      FormTelaRemota.Left   := Round((Screen.Width  / 2) - (FormTelaRemota.Width  / 2));
     End;
   End;
 End;
Begin
 If Assigned(FormTelaRemota) Then
  Begin
   vStream := TMemoryStream.Create;
   Try
    If Command <> '' Then
     Begin
      ArrayOfPointer := [@vAltura, @vLargura];
      ParseValues(Command, ArrayOfPointer);
      If vAltura <> '' Then
       vResolucaoAltura  := Round(StrToFloat(vAltura));
      If vLargura <> '' Then
       vResolucaoLargura := Round(StrToFloat(vLargura));
     End;
    If cCompressionData Then
     ZDecompressBytesStream(aBuf, vStream)
    Else
     Begin
      vStream.Write(aBuf[0], Length(aBuf));
      vStream.Position := 0;
     End;
    Try
     ResizeScreen(vResolucaoAltura, vResolucaoLargura);
     FormTelaRemota.imgTelaRemota.Fill.Bitmap.Bitmap.LoadFromStream(vStream); //.Bitmap.LoadFromStream(vStream);
     vGetFPS := GetFps;
     Application.ProcessMessages;
     If vGetFPS > 0 Then
      Begin
       TThread.Queue(Nil,  Procedure
                           Begin
                            FormTelaRemota.Caption := Format(cCaptureTitle, [vClientID, vGetFPS]);
                            Application.ProcessMessages;
                           End);
      End;
    Finally
     FreeAndNil(vStream);
    End;
   Finally
    Application.ProcessMessages;
   End;
  End;
End;

Procedure TFormConexao.SetSockets;
Var
 CFG : TSQLiteConfig;
 host : string;
Begin
 CFG := TSQLiteConfig.Create;
 Try
  Conexao.Disconnect;
  If SERVIDOR <> '' Then
    host := SERVIDOR
  Else
    host := CFG.getValue(SERVER);
  if host <> '' then
  begin
    Conexao.OnBeforeConnect         := OnBeforeConnect;
    Conexao.OnConnect               := OnConnect;
    Conexao.OnDisconnect            := OnDisconnect;
    Conexao.OnServerLogin           := OnServerLogin;
    Conexao.OnBeginTransactionError := OnBeginTransactionError;
    Conexao.OnBeginTransaction      := OnBeginTransaction;
    Conexao.OnIncommingConnect      := OnIncommingConnect;
    Conexao.OnAccessGranted         := OnAccessGranted;
    Conexao.OnPeerConnected         := OnPeerConnected;
    Conexao.OnPeerDisconnected      := OnPeerDisconnected;
    Conexao.OnScreenCapture         := OnScreenCapture;
    Conexao.OnKeyboardCapture       := OnKeyboardCapture;
    Conexao.OnMouseCapture          := OnMouseCapture;
    Conexao.OnPeerKick              := OnPeerKick;
    Conexao.Host                    := Host;
    Conexao.Port                    := PORTA;
    Sleep(FOLGAPROCESSAMENTO);
    Conexao.Connect;
  end;
 Finally
  FreeAndNil(CFG);
 End;
End;

procedure TFormConexao.SetTrayIcon;
begin
  HideApponTaskbar;
  TrayWnd := AllocateHWnd(TrayWndProc); // Alocate the wndProc
  with TrayIconData do
  begin // Instaciate
    cbSize := SizeOf;
    Wnd := TrayWnd;
    uID := 1;
    uFlags := NIF_MESSAGE + NIF_ICON + NIF_TIP;
    uCallbackMessage := WM_ICONTRAY;
    hIcon := GetClassLong(FmxHandleToHWND(self.Handle), GCL_HICONSM);
    StrPCopy(szTip, 'Aegys Remote Acess');
  end;
  // creating the icon
  if not TrayIconAdded then
    TrayIconAdded := Shell_NotifyIcon(NIM_ADD, @TrayIconData);
  if self.Visible then
  begin
    self.Hide;
    isvisible := False;
  end;
end;

procedure TFormConexao.ShowAppOnTaskbar;
var
  hAppWnd: HWND;
  ExStyle: LONG_PTR;
begin
  hAppWnd := FMX.Platform.Win.ApplicationHWND();
  ShowWindow(hAppWnd, SW_HIDE);
  ExStyle := GetWindowLongPtr(hAppWnd, GWL_EXSTYLE);
  SetWindowLongPtr(hAppWnd, GWL_EXSTYLE, (ExStyle and WS_EX_TOOLWINDOW) or
    WS_EX_APPWINDOW);
  ShowWindow(hAppWnd, SW_SHOW);
end;

procedure TFormConexao.TmrSystemTrayTimer(Sender: TObject);
begin
  // TmrSystemTray.Enabled := False;
  // if systemtray then
  // self.Hide;
end;

procedure TFormConexao.EGuestIDTyping(Sender: TObject);
begin
  TEdit(Sender).Text := MascaraID(TEdit(Sender).Text, '99-999-999');
  TEdit(Sender).GoToTextEnd;
end;

Procedure TFormConexao.tmrIntervaloTimer(Sender: TObject);
Begin
 If (Conexao.SessionTime > INTERVALOCONEXAO) Then
  Begin
   If (FormTelaRemota.Visible) Then
    FormTelaRemota.Close
   Else
    Begin
     SetOffline;
     Conexao.Disconnect;
     SetSockets;
    End;
  End;
 Conexao.SessionTime := Conexao.SessionTime + 1;
End;

End.
