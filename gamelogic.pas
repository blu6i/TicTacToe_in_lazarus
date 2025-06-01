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
          (Board[nx][ny] = PlayerValue) do
    begin
      Inc(Count);
      Inc(nx, dy);
      Inc(ny, dx);
    end;

    // Назад
    nx := Row - dy;
    ny := Col - dx;
    while (nx >= 0) and (ny >= 0) and (nx < BoardSize) and (ny < BoardSize) and
          (Board[nx][ny] = PlayerValue) do
    begin
      Inc(Count);
      Dec(nx, dy);
      Dec(ny, dx);
    end;

    if Count >= WinLength then
    begin
      Result := True;
      Exit;
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
  for i := 0 to BoardSize - 1 do
  begin
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
  for i := 0 to BoardSize - 1 do
  begin
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
  for j := 0 to BoardSize - 1 do
  begin
    Temp := Board[0][j]; // верхняя строка
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
  for j := 0 to BoardSize - 1 do
  begin
    Temp := Board[BoardSize - 1][j]; // нижняя строка
    for i := BoardSize - 1 downto 1 do
      Board[i][j] := Board[i - 1][j];
    Board[0][j] := Temp;
  end;
end;
end.

