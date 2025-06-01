unit GameData;

{$mode objfpc}{$H+}

interface

type
  TGameMode = (gmExpand, gmConquest, gmHybrid);
  TPlayer = (cpCross, cpZero);

var
  GameMode: TGameMode;
  GameStarted: Boolean;
  BoardSize: Integer;
  TurnNumber: Integer;
  CurrentPlayer: TPlayer;
  WinLength: Integer;
  ExpandEach: Integer;
  NextExpandTurn: Integer;
  BaseExpandInterval: Integer;
  EnableCapture: Boolean;
  ExpandCount: Integer;
  Board: array of array of Integer;

implementation

end.

