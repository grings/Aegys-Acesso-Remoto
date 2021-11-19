unit uCtrl_ThreadsService;

interface

uses
  System.Classes, System.Win.ScktComp;

type
  TThreadConexaoDefinidor = class(TThread)
  private
    scClient: TCustomWinSocket;
  public
    constructor Create(ASocket: TCustomWinSocket); overload;
    procedure Execute; override;
  end;

  TThreadConexaoPrincipal = class(TThread)
  private
    scAcesso: TCustomWinSocket;
    FProtocolo: string;
  public
    scClient: TCustomWinSocket;
    constructor Create(ASocket: TCustomWinSocket; AProtocolo: string); overload;
    procedure Execute; override;
    procedure ThreadTerminate(ASender: TObject);
  end;

  TThreadConexaoAreaRemota = class(TThread)
  private
    scClient, scAcesso: TCustomWinSocket;
    FProtocolo: string;
  public
    constructor Create(ASocket: TCustomWinSocket; AProtocolo: string); overload;
    procedure Execute; override;
    procedure ThreadTerminate(ASender: TObject);
  end;

  TThreadConexaoTeclado = class(TThread)
  private
    scClient, scAcesso: TCustomWinSocket;
    FProtocolo: string;
  public
    constructor Create(ASocket: TCustomWinSocket; AProtocolo: string); overload;
    procedure Execute; override;
    procedure ThreadTerminate(ASender: TObject);
  end;

  TThreadConexaoArquivos = class(TThread)
  private
    scClient, scAcesso: TCustomWinSocket;
    FProtocolo: string;
  public
    constructor Create(ASocket: TCustomWinSocket; AProtocolo: string); overload;
    procedure Execute; override;
    procedure ThreadTerminate(ASender: TObject);
  end;

implementation

{ TThreadConexaoDefinidor }

uses System.SysUtils, uConstants, uCtrl_Conexoes, uDMServer, Vcl.Dialogs;

{ TThreadConexaoDefinidor }

constructor TThreadConexaoDefinidor.Create(ASocket: TCustomWinSocket);
begin
  inherited Create(True);
  scClient := ASocket;
  FreeOnTerminate := True;
  Resume;
end;

procedure TThreadConexaoDefinidor.Execute;
var
  xBuffer, xBufferTemp, xID: string;
  iPosition: Integer;
begin
  inherited;

  while True do
  begin
    Sleep(FOLGAPROCESSAMENTO);

    if (scClient = nil)
      or not(scClient.Connected)
      or not(Assigned(DMServer)) then
      Break;

    if scClient.ReceiveLength < 1 then
      Continue;

    xBuffer := scClient.ReceiveText;

    iPosition := Pos('<|MAINSOCKET|>', xBuffer);
    if iPosition > 0 then
    begin
      DMServer.Conexoes.AdicionarConexao(IntToStr(scClient.Handle));
      DMServer.Conexoes.RetornaItemPorConexao(IntToStr(scClient.Handle)).CriarThread(ttPrincipal, scClient);
      Break;
    end;

    iPosition := Pos('<|DESKTOPSOCKET|>', xBuffer);
    if iPosition > 0 then
    begin
      xBufferTemp := xBuffer;
      Delete(xBufferTemp, 1, iPosition + 16);
      xID := Copy(xBufferTemp, 1, Pos('<|END|>', xBufferTemp) - 1);
      DMServer.Conexoes.RetornaItemPorID(xID).CriarThread(ttAreaRemota, scClient);
      Break;
    end;

    iPosition := Pos('<|KEYBOARDSOCKET|>', xBuffer);
    if iPosition > 0 then
    begin
      xBufferTemp := xBuffer;
      Delete(xBufferTemp, 1, iPosition + 17);
      xID := Copy(xBufferTemp, 1, Pos('<|END|>', xBufferTemp) - 1);
      DMServer.Conexoes.RetornaItemPorID(xID).CriarThread(ttTeclado, scClient);
      Break;
    end;

    iPosition := Pos('<|FILESSOCKET|>', xBuffer);
    if iPosition > 0 then
    begin
      xBufferTemp := xBuffer;
      Delete(xBufferTemp, 1, Pos('<|FILESSOCKET|>', xBuffer) + 14);
      xID := Copy(xBufferTemp, 1, Pos('<|END|>', xBufferTemp) - 1);
      DMServer.Conexoes.RetornaItemPorID(xID).CriarThread(ttArquivos, scClient);
      Break;
    end;
  end;
end;

{ TThreadConexaoPrincipal }

constructor TThreadConexaoPrincipal.Create(ASocket: TCustomWinSocket; AProtocolo: string);
begin
  inherited Create(True);
  FProtocolo := AProtocolo;
  scClient := ASocket;
  FreeOnTerminate := True;
  OnTerminate := ThreadTerminate;
  Resume;
end;

procedure TThreadConexaoPrincipal.Execute;
var
  xBuffer, xBufferTemp, xID, xIDAcesso, xSenhaAcesso: string;
  iPosition: Integer;
  FConexao, FConexaoAcesso: TConexao;
begin
  inherited;
  FConexao := DMServer.Conexoes.RetornaItemPorConexao(FProtocolo);

  while scClient.SendText('<|ID|>' + FConexao.ID + '<|>' + FConexao.Senha + '<|END|>') < 0 do
    Sleep(FOLGAPROCESSAMENTO);

  while True do
  begin
    Sleep(FOLGAPROCESSAMENTO);

    if (scClient = nil)
      or not(scClient.Connected)
      or (Terminated)
      or not(Assigned(DMServer)) then
      Break;

    if scClient.ReceiveLength < 1 then
      Continue;

    xBuffer := scClient.ReceiveText;

    iPosition := Pos('<|FINDID|>', xBuffer);
    if iPosition > 0 then
    begin
      xBufferTemp := xBuffer;
      Delete(xBufferTemp, 1, iPosition + 9);
      xIDAcesso := Copy(xBufferTemp, 1, Pos('<|END|>', xBufferTemp) - 1);

      if DMServer.Conexoes.VerificaID(xIDAcesso) then
      begin
//        if DMServer.Conexoes.RetornaIDParceiroPorID(xIDAcesso) = '' then
//        begin
          while scClient.SendText('<|IDEXISTS!REQUESTPASSWORD|>') < 0 do
            Sleep(FOLGAPROCESSAMENTO);
//        end
//        else
//        begin
          // impede futura terceira conexao
//          while scClient.SendText('<|ACCESSBUSY|>') < 0 do
//            Sleep(FOLGAPROCESSAMENTO);
//        end
      end
      else
      begin
        while scClient.SendText('<|IDNOTEXISTS|>') < 0 do
          Sleep(FOLGAPROCESSAMENTO);
      end;
    end;

    if xBuffer.Contains('<|PONG|>') then
      FConexao.PingFinal := GetTickCount - FConexao.PingInicial;

    iPosition := Pos('<|CHECKIDPASSWORD|>', xBuffer);
    if iPosition > 0 then
    begin
      xIDAcesso := '';
      xSenhaAcesso := '';

      xBufferTemp := xBuffer;
      Delete(xBufferTemp, 1, iPosition + 18);
      iPosition := Pos('<|>', xBufferTemp);
      xIDAcesso := Copy(xBufferTemp, 1, iPosition - 1);

      Delete(xBufferTemp, 1, iPosition + 2);
      xSenhaAcesso := Copy(xBufferTemp, 1, Pos('<|END|>', xBufferTemp) - 1);

      if (DMServer.Conexoes.VerificaIDSenha(xIDAcesso, xSenhaAcesso)) then
      begin
        while scClient.SendText('<|ACCESSGRANTED|>') < 0 do
          Sleep(FOLGAPROCESSAMENTO);
      end
      else
      begin
        while scClient.SendText('<|ACCESSDENIED|>') < 0 do
          Sleep(FOLGAPROCESSAMENTO);
      end;
    end;

    iPosition := Pos('<|RELATION|>', xBuffer);
    if iPosition > 0 then
    begin
      xID := '';
      xIDAcesso := '';

      xBufferTemp := xBuffer;
      Delete(xBufferTemp, 1, iPosition + 11);
      iPosition := Pos('<|>', xBufferTemp);
      xID := Copy(xBufferTemp, 1, iPosition - 1);

      Delete(xBufferTemp, 1, iPosition + 2);
      xIDAcesso := Copy(xBufferTemp, 1, Pos('<|END|>', xBufferTemp) - 1);

      FConexao := nil;
      FConexaoAcesso := nil;
      FConexao := DMServer.Conexoes.RetornaItemPorID(xID);
      FConexaoAcesso := DMServer.Conexoes.RetornaItemPorID(xIDAcesso);

      // RECONNECT SOCKET CLIENT

      DMServer.Conexoes.InserirIDAcesso(IntToStr(scClient.Handle), xIDAcesso);

      FConexao.ThreadPrincipal.scAcesso := FConexaoAcesso.ThreadPrincipal.scClient;
      FConexaoAcesso.ThreadPrincipal.scAcesso := FConexao.ThreadPrincipal.scClient;

      FConexao.ThreadAreaRemota.scAcesso := FConexaoAcesso.ThreadAreaRemota.scClient;
      FConexaoAcesso.ThreadAreaRemota.scAcesso := FConexao.ThreadAreaRemota.scClient;

      FConexao.ThreadTeclado.scAcesso := FConexaoAcesso.ThreadTeclado.scClient;

      FConexao.ThreadArquivos.scAcesso := FConexaoAcesso.ThreadArquivos.scClient;
      FConexaoAcesso.ThreadArquivos.scAcesso := FConexao.ThreadArquivos.scClient;

      FConexao.ThreadPrincipal.scAcesso.SendText('<|ACCESSING|>');

      FConexao.ThreadAreaRemota.scAcesso.SendText('<|GETFULLSCREENSHOT|>');
    end;

    // Stop relations
    if xBuffer.Contains('<|STOPACCESS|>') then
    begin
      scClient.SendText('<|DISCONNECTED|>');
      scAcesso.SendText('<|DISCONNECTED|>');
      scAcesso := nil;
      TThreadConexaoPrincipal(FConexaoAcesso.ThreadPrincipal).scAcesso := nil;
      FConexao.IDParceiro := '';
      FConexaoAcesso.IDParceiro := '';
    end;

    // Redirect commands
    iPosition := Pos('<|REDIRECT|>', xBuffer);
    if iPosition > 0 then
    begin
      xBufferTemp := xBuffer;
      Delete(xBufferTemp, 1, iPosition + 11);

      if (Pos('<|FOLDERLIST|>', xBufferTemp) > 0) then
      begin
        while (scClient.Connected) do
        begin
          Sleep(FOLGAPROCESSAMENTO); // Avoids using 100% CPU

          if (Pos('<|ENDFOLDERLIST|>', xBufferTemp) > 0) then
            Break;

          xBufferTemp := xBufferTemp + scClient.ReceiveText;
        end;
      end;

      if (Pos('<|FILESLIST|>', xBufferTemp) > 0) then
      begin
        while (scClient.Connected) do
        begin
          Sleep(FOLGAPROCESSAMENTO); // Avoids using 100% CPU

          if (Pos('<|ENDFILESLIST|>', xBufferTemp) > 0) then
            Break;

          xBufferTemp := xBufferTemp + scClient.ReceiveText;
        end;
      end;

      if (scAcesso <> nil) and (scAcesso.Connected) then
      begin
        while scAcesso.SendText(xBufferTemp) < 0 do
          Sleep(FOLGAPROCESSAMENTO);
      end;
    end;
  end;
end;

procedure TThreadConexaoPrincipal.ThreadTerminate(ASender: TObject);
var
  FConexao, FConexaoAcesso: TConexao;
begin
  if Assigned(DMServer) then
  begin
    if (scAcesso <> nil) and (scAcesso.Connected) then
    begin
      while scAcesso.SendText('<|DISCONNECTED|>') < 0 do
        Sleep(FOLGAPROCESSAMENTO);
    end;

    FConexao := DMServer.Conexoes.RetornaItemPorConexao(FProtocolo);

    FConexaoAcesso := DMServer.Conexoes.RetornaItemPorID(FConexao.IDParceiro);

    if Assigned(FConexaoAcesso) then
      FConexaoAcesso.IDParceiro := '';

    if not Terminated then
      DMServer.Conexoes.RetornaItemPorConexao(FProtocolo).LimparThread(ttPrincipal);

    DMServer.Conexoes.RemoverConexao(FConexao.Protocolo);
  end;
end;

{ TThreadConexaoAreaRemota }

constructor TThreadConexaoAreaRemota.Create(ASocket: TCustomWinSocket; AProtocolo: string);
begin
  inherited Create(True);
  FProtocolo := AProtocolo;
  scClient := ASocket;
  FreeOnTerminate := True;
  OnTerminate := ThreadTerminate;
  Resume;
end;

procedure TThreadConexaoAreaRemota.Execute;
var
  xBuffer: string;
begin
  inherited;

  while True do
  begin
    Sleep(FOLGAPROCESSAMENTO);

    if (scClient = nil)
      or not(scClient.Connected)
      or (Terminated)
      or not(Assigned(DMServer)) then
      Break;

    if scClient.ReceiveLength < 1 then
      Continue;

    xBuffer := scClient.ReceiveText;

    if (scAcesso <> nil) and (scAcesso.Connected) then
    begin
      while scAcesso.SendText(xBuffer) < 0 do
        Sleep(FOLGAPROCESSAMENTO);
    end;
  end;
end;

procedure TThreadConexaoAreaRemota.ThreadTerminate(ASender: TObject);
begin
  if (Assigned(DMServer)) and (not Terminated) then
    DMServer.Conexoes.RetornaItemPorConexao(FProtocolo).LimparThread(ttAreaRemota);
end;

{ TThreadConexaoTeclado }

constructor TThreadConexaoTeclado.Create(ASocket: TCustomWinSocket; AProtocolo: string);
begin
  inherited Create(True);
  FProtocolo := AProtocolo;
  scClient := ASocket;
  FreeOnTerminate := True;
  OnTerminate := ThreadTerminate;
  Resume;
end;

procedure TThreadConexaoTeclado.Execute;
var
  xBuffer: string;
begin
  inherited;

  while True do
  begin
    Sleep(FOLGAPROCESSAMENTO);

    if (scClient = nil)
      or not(scClient.Connected)
      or (Terminated)
      or not(Assigned(DMServer)) then
      Break;

    if scClient.ReceiveLength < 1 then
      Continue;

    xBuffer := scClient.ReceiveText;

    if (scAcesso <> nil) and (scAcesso.Connected) then
    begin
      while scAcesso.SendText(xBuffer) < 0 do
        Sleep(FOLGAPROCESSAMENTO);
    end;
  end;
end;

procedure TThreadConexaoTeclado.ThreadTerminate(ASender: TObject);
begin
  if (Assigned(DMServer)) and (not Terminated) then
    DMServer.Conexoes.RetornaItemPorConexao(FProtocolo).LimparThread(ttTeclado);
end;

{ TThreadConexaoArquivos }

constructor TThreadConexaoArquivos.Create(ASocket: TCustomWinSocket; AProtocolo: string);
begin
  inherited Create(True);
  FProtocolo := AProtocolo;
  scClient := ASocket;
  FreeOnTerminate := True;
  OnTerminate := ThreadTerminate;
  Resume;
end;

procedure TThreadConexaoArquivos.Execute;
var
  xBuffer: string;
begin
  inherited;

  while True do
  begin
    Sleep(FOLGAPROCESSAMENTO);

    if (scClient = nil)
      or not(scClient.Connected)
      or (Terminated)
      or not(Assigned(DMServer)) then
      Break;

    if scClient.ReceiveLength < 1 then
      Continue;

    xBuffer := scClient.ReceiveText;

    if (scAcesso <> nil) and (scAcesso.Connected) then
    begin
      while scAcesso.SendText(xBuffer) < 0 do
        Sleep(FOLGAPROCESSAMENTO);
    end;
  end;
end;

procedure TThreadConexaoArquivos.ThreadTerminate(ASender: TObject);
begin
  if (Assigned(DMServer)) and (not Terminated) then
    DMServer.Conexoes.RetornaItemPorConexao(FProtocolo).LimparThread(ttArquivos);
end;

end.