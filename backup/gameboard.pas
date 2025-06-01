unit GameBoard;

{$mode objfpc}{$H+}

interface

uses
  GameData;

procedure ExpandBoard;
procedure FillBoard;

implementation
// Инициализация поля
procedure ExpandBoard;
var
  i, j, NewSize: Integer;
  NewBoard: array of array of Integer;
begin
  NewSize := BoardSize + 2;
  SetLength(NewBoard, NewSize, NewSize);
  for i := 0 to NewSize - 1 do
    for j := 0 to NewSize - 1 do
      NewBoard[i][j] := 0;
  for i := 0 to BoardSize - 1 do
    for j := 0 to BoardSize - 1 do
      NewBoard[i + 1][j + 1] := Board[i][j];

  Board := NewBoard;
  BoardSize := NewSize;
end;

// Заполнения поля 0
procedure FillBoard;
var
  i, j: Integer;
begin
  for i := 0 to High(Board) do
    for j := 0 to High(Board[i]) do
      Board[i][j] := 0;
end;

end.

