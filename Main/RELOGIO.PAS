{$M 3000, 0, 20}
program Relogio;

uses
  Crt,
  Dos;

var
  Ticks    :    Byte;
  Anterior :    Pointer;
  Anterior2:    Pointer;
  CPURegisters: Registers;
  UserInput :   String;


procedure ExitProc; Interrupt;
begin
  SetIntVec($1C, Anterior);
  SetIntVec($64, Anterior2);
  CPURegisters.AH := $49;
  CPURegisters.ES := PrefixSeg;
  Intr($21, CPURegisters);
end;

procedure AllocateExitProc;
begin
  GetIntVec($64, Anterior2);
  SetIntVec($64, Addr(ExitProc));
end;

function ExitProcExists: Boolean;
var
  p : Pointer;

begin
  GetIntVec($64, p);
  if p <> nil then
    ExitProcExists := true
  else
    ExitProcExists := false;
end;

procedure ExitOldProgram;
var
  R : Registers;

begin
  Intr($64, R);
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
    end;
end;


begin

  if ExitProcExists then
  begin
    Writeln('O programa ja esta rodando. Digite Y para desligar e iniciar novamente, ou N para desligar');
    Readln(UserInput);
    if (pos('Y', UserInput) = 1) then
    begin
      ExitOldProgram;
      AllocateExitProc;

      Ticks := 0;
      GetIntVec($1C, Anterior);
      SetIntVec($1C, Addr(Horas));
      Keep(0);
    end
    else if (pos('N', UserInput) = 1) then
    begin
      ExitOldProgram;
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
    AllocateExitProc;
    Ticks := 0;
    GetIntVec($1C, Anterior);
    SetIntVec($1C, Addr(Horas));
    Keep(0);
  end
end.