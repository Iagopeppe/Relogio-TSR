{$M 3000, 0, 20}
program Relogio;

uses
  Crt,
  Dos;

var
  Ticks    : Byte;
  Anterior : Pointer;
  CPURegisters: Registers;

procedure ExitProc;
begin
  SetIntVec($1C, Anterior);

  CPURegisters.AH := $49;
  CPURegisters.ES := PrefixSeg;
  Intr($21, CPURegisters);
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
      ExitProc;
    end;
end;


begin
  Ticks := 0;
  GetIntVec($1C, Anterior);
  SetIntVec($1C, Addr(Horas));
  Keep(0);
end.