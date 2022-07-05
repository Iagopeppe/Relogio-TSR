{$M 3000, 0, 20}
program Relogio;

uses
  Crt,
  Dos;

var
  Ticks    : Byte;
  Anterior : Pointer;
  CPURegisters: Registers;
  IsRunning : Boolean;
  UserInput : String;

procedure ExitProc;
begin
  SetIntVec($1C, Anterior);
  CPURegisters.AH := $49;
  CPURegisters.ES := PrefixSeg;
  Intr($21, CPURegisters);
end;

procedure OpenCfg;
var
  f : text;
  s : string;

begin
  Assign(f, 'relogcfg.txt');
  Reset(f);
  Readln(f,s);
  Close(f);
  if pos('false', s)=1 then
    IsRunning := false
  else
    IsRunning := true;
end;

procedure ChangeCfg(newState:Boolean);
var
  f : text;

begin
  if newState then
  begin
    Assign(f, 'relogcfg.txt');
    Rewrite(f);
    Write(f,'true ');
    Close(f)
  end
  else
  begin
    Assign(f, 'relogcfg.txt');
    Rewrite(f);
    Write(f,'false');
    Close(f);
  end
end;

procedure ShouldTerminate;
begin
  OpenCfg;
  if not IsRunning then
  begin
    Writeln('Terminating...');
    ChangeCfg(false);
    ExitProc;
  end
end;

procedure Horas; Interrupt;
var
  Linha,
  Coluna : Byte;
  H,
  M,
  S,
  Ms     : Word;

begin
    Inc(Ticks);
    if Ticks = 18 then
    begin
      GetTime(H, M, S, Ms);
      Linha := WhereY;
      Coluna := WhereX;
      GotoXY(70, 01);
      ClrEol;
      if H <= 9 then
        Write('0');
      Write(H, ':');
      if M <= 9 then
        Write('0');
      Write(M, ':');
      if S <= 9 then
        Write('0');
      Write(S);
      GotoXY(Coluna, Linha);
      Ticks := 0;
      ShouldTerminate;
    end;
end;


begin
  OpenCfg;
  Writeln(IsRunning);
  if IsRunning then
  begin
    Writeln('O programa ja esta rodando. Digite Y para desligar e iniciar novamente, ou N para desligar');
    Readln(UserInput);
    Writeln(UserInput);
    if (pos('Y', UserInput) = 1) then
    begin
      ChangeCfg(false);
      Writeln('Pressione Enter quando o relogio parar.');
      Readln;
      ChangeCfg(true);
      Ticks := 0;
      GetIntVec($1C, Anterior);
      SetIntVec($1C, Addr(Horas));
      Keep(0);
    end
    else if (pos('N', UserInput) = 1) then
    begin
      ChangeCfg(false);
      Exit;
    end
    else
    begin
      Writeln('Comando nao aceito');
      Exit;
    end
  end
  else
  begin
    ChangeCfg(true);
    Ticks := 0;
    GetIntVec($1C, Anterior);
    SetIntVec($1C, Addr(Horas));
    Keep(0);
  end
end.