unit GameLogic;

{$mode objfpc}{$H+}

interface

uses
  GameData;

procedure UpdateNextExpandTurn;
procedure SwitchPlayer;
function CheckWin(Row, Col, PlayerValue: Integer): Boolean;
procedure ShiftDown;
procedure ShiftUp;
procedure ShiftLeft;
procedure ShiftRight;
procedure CheckAndCaptureStrict(PlayerID: Integer);
function CheckEndCapture: Integer;

implementation

// Проверка на выигрыш
function CheckWin(Row, Col, PlayerValue: Integer): Boolean;
var
  dx, dy, Count, i: Integer;
  nx, ny: Integer;
const
  Directions: array[0..3] of record dx, dy: Integer; end =
    ((dx: 1; dy: 0), (dx: 0; dy: 1), (dx: 1; dy: 1), (dx: 1; dy: -1));
begin
  Result := False;

  for i := 0 to 3 do
  begin
    dx := Directions[i].dx;
    dy := Directions[i].dy;
    Count := 1;

    // Вперёд
    nx := Row + dy;
    ny := Col + dx;
    while (nx >= 0) and (ny >= 0) and (nx < BoardSize) and (ny < BoardSize) and
          (Board[nx][ny] = PlayerValue) do begin
      Inc(Count);
      Inc(nx, dy);
      Inc(ny, dx);
    end;

    // Назад
    nx := Row - dy;
    ny := Col - dx;
    while (nx >= 0) and (ny >= 0) and (nx < BoardSize) and (ny < BoardSize) and
          (Board[nx][ny] = PlayerValue) do begin
      Inc(Count);
      Dec(nx, dy);
      Dec(ny, dx);
    end;

    if Count >= WinLength then begin
      Result := True;
      Exit;
    end;
  end;
end;

function CheckEndCapture: Integer;
var
  i, j: Integer;
  HasCrosses, HasNoughts, HasEmpty: Boolean;
  CrossCount, NoughtCount: Integer;
begin
  HasCrosses := False;
  HasNoughts := False;
  HasEmpty := False;
  CrossCount := 0;
  NoughtCount := 0;

  for i := 0 to BoardSize - 1 do
    for j := 0 to BoardSize - 1 do begin
      case Board[i][j] of
        0: HasEmpty := True;
        1: begin
             HasCrosses := True;
             Inc(CrossCount);
           end;
        2: begin
             HasNoughts := True;
             Inc(NoughtCount);
           end;
      end;
    end;

  // Победа крестиков
  if HasCrosses and not HasNoughts and (CrossCount >= 2) then
    Exit(1)
  // Победа ноликов
  else if HasNoughts and not HasCrosses and (NoughtCount >= 2) then
    Exit(2)
  // Ничья
  else if not HasEmpty then
    Exit(3)
  else
    Exit(0);
end;

procedure CheckAndCaptureStrict(PlayerID: Integer);
type
  TPoint = record X, Y: Integer; end;
var
  Visited: array of array of Boolean;
  Queue: array of TPoint;
  Region: array of TPoint;
  Head, Tail: Integer;
  i, j, d: Integer;
  OpponentID: Integer;
  cx, cy, nx, ny: Integer;
  Escaped, SurroundedByPlayer: Boolean;

  function InBounds(x, y: Integer): Boolean;
  begin
    Result := (x >= 0) and (x < BoardSize) and (y >= 0) and (y < BoardSize);
  end;

begin
  SetLength(Visited, BoardSize, BoardSize);
  OpponentID := 3 - PlayerID;

  for i := 0 to BoardSize - 1 do
    for j := 0 to BoardSize - 1 do
    begin
      if (Board[i][j] = OpponentID) and not Visited[i][j] then
      begin
        // Инициализация
        SetLength(Queue, 1);
        Queue[0].X := i;
        Queue[0].Y := j;
        SetLength(Region, 0);
        Visited[i][j] := True;
        Escaped := False;
        SurroundedByPlayer := False;
        Head := 0;

        while Head < Length(Queue) do begin
          cx := Queue[Head].X;
          cy := Queue[Head].Y;

          // Сохраняем в регион
          SetLength(Region, Length(Region) + 1);
          Region[High(Region)].X := cx;
          Region[High(Region)].Y := cy;

          for d := 0 to 3 do begin
            case d of
              0: begin nx := cx - 1; ny := cy; end; // Вверх
              1: begin nx := cx + 1; ny := cy; end; // Вниз
              2: begin nx := cx; ny := cy - 1; end; // Влево
              3: begin nx := cx; ny := cy + 1; end; // Вправо
            end;

            if not InBounds(nx, ny) then begin
              Escaped := True;
            end
            else if (Board[nx][ny] = 0) or (Board[nx][ny] = OpponentID) then begin
              if not Visited[nx][ny] then begin
                Visited[nx][ny] := True;
                SetLength(Queue, Length(Queue) + 1);
                Queue[High(Queue)].X := nx;
                Queue[High(Queue)].Y := ny;
              end;
            end
            else if Board[nx][ny] = PlayerID then begin
              SurroundedByPlayer := True;
            end;
          end;

          Inc(Head);
        end;

        // Условие для захвата: не сбежали и окружены
        if not Escaped and SurroundedByPlayer then begin
          for Head := 0 to High(Region) do
            if Board[Region[Head].X][Region[Head].Y] = OpponentID then
              Board[Region[Head].X][Region[Head].Y] := PlayerID;
        end;
      end;
    end;
end;

// Обновление следующей комбинации для расширения
procedure UpdateNextExpandTurn;
begin
  Inc(ExpandCount);
  NextExpandTurn := TurnNumber + BaseExpandInterval * ExpandCount - 5;
end;

// Смена игрока
procedure SwitchPlayer;
begin
  if CurrentPlayer = cpCross then
    CurrentPlayer := cpZero
  else
    CurrentPlayer := cpCross;
end;

// Смещение влево
procedure ShiftLeft;
var
  i, j: Integer;
  Temp: Integer;
begin
  for i := 0 to BoardSize - 1 do begin
    Temp := Board[i][0]; // крайняя левая
    for j := 0 to BoardSize - 2 do
      Board[i][j] := Board[i][j + 1];
    Board[i][BoardSize - 1] := Temp;
  end;
end;

// Смещение вправо
procedure ShiftRight;
var
  i, j: Integer;
  Temp: Integer;
begin
  for i := 0 to BoardSize - 1 do begin
    Temp := Board[i][BoardSize - 1]; // крайняя правая
    for j := BoardSize - 1 downto 1 do
      Board[i][j] := Board[i][j - 1];
    Board[i][0] := Temp;
  end;
end;

// Смещение вверх
procedure ShiftUp;
var
  i, j: Integer;
  Temp: Integer;
begin
  for j := 0 to BoardSize - 1 do begin
    Temp := Board[0][j];
    for i := 0 to BoardSize - 2 do
      Board[i][j] := Board[i + 1][j];
    Board[BoardSize - 1][j] := Temp;
  end;
end;

// Смещение вниз
procedure ShiftDown;
var
  i, j: Integer;
  Temp: Integer;
begin
  for j := 0 to BoardSize - 1 do begin
    Temp := Board[BoardSize - 1][j];
    for i := BoardSize - 1 downto 1 do
      Board[i][j] := Board[i - 1][j];
    Board[0][j] := Temp;
  end;
end;
end.

