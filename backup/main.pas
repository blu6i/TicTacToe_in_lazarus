unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Buttons, Menus, Math, GameData, GameBoard, GameLogic, StrUtils;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnResume: TButton;
    btnRestart: TButton;
    btnToMainMenu: TButton;
    btnReplay: TButton;
    btnToMenu: TButton;
    labelWinner: TLabel;
    btnMenu: TButton;
    labelGoes: TLabel;
    GameType: TLabel;
    Player: TPaintBox;
    PanelMainMenu: TPanel;
    OverlayPanel: TPanel;
    PanelWinning: TPanel;
    PanelMenu: TPanel;
    StartBtn: TButton;
    btnLeft: TImage;
    btnRight: TImage;
    btnBottom: TImage;
    btnTop: TImage;
    PaintBox1: TPaintBox;
    ComboBoxGameMode: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnBottomClick(Sender: TObject);
    procedure btnLeftClick(Sender: TObject);
    procedure btnMenuClick(Sender: TObject);
    procedure btnRightClick(Sender: TObject);
    procedure btnTopClick(Sender: TObject);
    procedure InitGame(Mode: TGameMode);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
    procedure PlayerPaint(Sender: TObject);
    procedure btnToMainMenuClick(Sender: TObject);
    procedure btnRestartClick(Sender: TObject);
    procedure btnResumeClick(Sender: TObject);
    procedure ShowMainMenu;
    procedure ShowWinningPanel(const WinnerName: string);
    procedure RedrawCell(Row, Col: Integer);
  end;

var
  Form1: TForm1;
  GamePaused: Boolean = False;

implementation

{$R *.lfm}

// Инициализация форм
procedure TForm1.FormCreate(Sender: TObject);
begin
  ComboBoxGameMode.ItemIndex := 0;
  GameStarted := False;
  PaintBox1.Enabled := False;
  PaintBox1.Visible := False;
  BoardSize := 3;
  TurnNumber := 0;
  CurrentPlayer := cpCross;
  Width := 1372;
  Height := 981;
  Form1.Width := Width;
  Form1.Height := Height;
  Form1.Left := (Screen.Width - Form1.Width) div 2;
  Form1.Top := 0;
  // Привязка к PaintBox1
  with btnLeft do
  begin
    AnchorSideRight.Control := PaintBox1;
    AnchorSideRight.Side := asrLeft;
    Anchors := [akRight, akTop];
    Top := PaintBox1.Top + (PaintBox1.Height - Height) div 2;
  end;

  with btnRight do
  begin
    AnchorSideLeft.Control := PaintBox1;
    AnchorSideLeft.Side := asrRight;
    Anchors := [akLeft, akTop];
    Top := PaintBox1.Top + (PaintBox1.Height - Height) div 2;
  end;

  with btnTop do
  begin
    AnchorSideBottom.Control := PaintBox1;
    AnchorSideBottom.Side := asrTop;
    Anchors := [akTop, akLeft];
    Left := PaintBox1.Left + (PaintBox1.Width - Width) div 2;
  end;

  with btnBottom do
  begin
    AnchorSideTop.Control := PaintBox1;
    AnchorSideTop.Side := asrBottom;
    Anchors := [akTop, akLeft];
    Left := PaintBox1.Left + (PaintBox1.Width - Width) div 2;
  end;
  ShowMainMenu;
end;

// Инициализация игры
procedure TForm1.InitGame(Mode: TGameMode);
begin
  GameStarted := True;
  TurnNumber := 0;
  CurrentPlayer := cpCross;
  BoardSize := 3;

  case Mode of
    gmExpand: begin
      EnableCapture := False;
      GameType.Caption := 'Классический режим';
    end;
    gmConquest: begin
      EnableCapture := True;
      GameType.Caption := 'Режим с захватом';
    end;
    gmHybrid: begin
      EnableCapture := True;
      GameType.Caption := 'Гибридный режим';
    end;
  end;

  ExpandCount := 0;
  NextExpandTurn := 6;
  BaseExpandInterval := 9;
  WinLength := 3;

  SetLength(Board, BoardSize, BoardSize);
  FillBoard;

  PanelMainMenu.Visible := False;
  PaintBox1.Visible := True;
  Player.Visible := True;
  btnLeft.Visible := True;
  btnRight.Visible := True;
  btnTop.Visible := True;
  btnBottom.Visible := True;
  labelGoes.Visible := True;
  PaintBox1.Enabled := True;
  btnMenu.Visible := True;
  PaintBox1.Invalidate;
  Player.Invalidate;
end;

// Рисование поля
procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  i, j: Integer;
  CellSize, x, y: Integer;
  FieldWidth, FieldHeight: Integer;
  ShiftX, ShiftY: Integer;
begin
  //if not GameStarted then Exit;

  CellSize := Min(PaintBox1.Width div BoardSize, PaintBox1.Height div BoardSize);
  FieldWidth := CellSize * BoardSize;
  FieldHeight := CellSize * BoardSize;

  // Смещение — чтобы центрировать поле в PaintBox
  ShiftX := (PaintBox1.Width - FieldWidth) div 2;
  ShiftY := (PaintBox1.Height - FieldHeight) div 2;

  with PaintBox1.Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(Rect(0, 0, PaintBox1.Width, PaintBox1.Height));

    for i := 0 to BoardSize - 1 do
      for j := 0 to BoardSize - 1 do
      begin
        Pen.Color := clBlack;
        Pen.Width := 1;
        x := ShiftX + j * CellSize;
        y := ShiftY + i * CellSize;
        Rectangle(x, y, x + CellSize, y + CellSize);

        Pen.Width := 3;
        case Board[i][j] of
          1: begin
               Pen.Color := clRed;
               MoveTo(x + 4, y + 4);
               LineTo(x + CellSize - 4, y + CellSize - 4);
               MoveTo(x + CellSize - 4, y + 4);
               LineTo(x + 4, y + CellSize - 4);
             end;
          2: begin
               Pen.Color := clBlue;
               Ellipse(x + 4, y + 4, x + CellSize - 4, y + CellSize - 4);
             end;
        end;
      end;
  end;
end;

procedure TForm1.RedrawCell(Row, Col: Integer);
var
  CellSize, x, y: Integer;
  Rect: TRect;
  ShiftX, ShiftY: Integer;
begin
  CellSize := Min(PaintBox1.Width div BoardSize, PaintBox1.Height div BoardSize);
  ShiftX := (PaintBox1.Width - (CellSize * BoardSize)) div 2;
  ShiftY := (PaintBox1.Height - (CellSize * BoardSize)) div 2;

  x := ShiftX + Col * CellSize;
  y := ShiftY + Row * CellSize;

  Rect.Left := x;
  Rect.Top := y;
  Rect.Right := x + CellSize;
  Rect.Bottom := y + CellSize;

  InvalidateRect(PaintBox1.Handle, @Rect, False);
end;


// Рисование фигуры
procedure TForm1.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Row, Col, CellSize: Integer;
begin
  if not GameStarted then Exit;

  CellSize := Min(PaintBox1.Width div BoardSize, PaintBox1.Height div BoardSize);
  Col := X div CellSize;
  Row := Y div CellSize;

  if (Row >= 0) and (Row < BoardSize) and
     (Col >= 0) and (Col < BoardSize) and
     (Board[Row][Col] = 0) then
  begin
    // Устанавливаем фигуру
    if CurrentPlayer = cpCross then
      Board[Row][Col] := 1
    else
      Board[Row][Col] := 2;
    // Проверка победы
    if CheckWin(Row, Col, Board[Row][Col]) then
    begin
      ShowWinningPanel(IfThen(Board[Row][Col] = 1, 'Крестик', 'Нолик'));
      GameStarted := False;
      Exit;
    end;

    // Переключение игрока
    SwitchPlayer;
    Player.Invalidate;

    // Проверка на расширение
    Inc(TurnNumber);
    if TurnNumber >= NextExpandTurn then
    begin
      ExpandBoard;
      UpdateNextExpandTurn;
      WinLength := WinLength + 2;
      PaintBox1.Invalidate;
      Exit;
    end;
    RedrawCell(Row, Col);
  end;
end;

procedure TForm1.PlayerPaint(Sender: TObject);
var
  Margin, Size: Integer;
  X1, Y1, X2, Y2: Integer;
begin
  Size := Min(Player.Width, Player.Height);
  Margin := Size div 6;
  X1 := Margin;
  Y1 := Margin;
  X2 := Size - Margin;
  Y2 := Size - Margin;

  with Player.Canvas do
  begin
    Pen.Width := 3;
    Brush.Style := bsClear;

    if CurrentPlayer = cpCross then
    begin
      Pen.Color := clRed;
      MoveTo(X1, Y1);
      LineTo(X2, Y2);
      MoveTo(X2, Y1);
      LineTo(X1, Y2);
    end
    else
    begin
      Pen.Color := clBlue;
      Ellipse(X1, Y1, X2, Y2);
    end;
  end;
end;

// Нажатие на кнопку с меню
procedure TForm1.btnMenuClick(Sender: TObject);
const
  ButtonSpacing = 50;
  ButtonWidth = 270;
  ButtonHeight = 70;
var
  TotalHeight, StartTop: Integer;
begin
  if GamePaused then begin
    OverlayPanel.Visible := False;
    PanelMenu.Visible := False;
    GamePaused := False;
    Exit;
  end;

  GamePaused := True;
  PanelMenu.Width := 400;
  PanelMenu.Height := 350;

  PanelMenu.Left := (ClientWidth - PanelMenu.Width) div 2;
  PanelMenu.Top := (ClientHeight - PanelMenu.Height) div 2;

  // Настройка кнопок
  btnResume.Width := ButtonWidth;
  btnResume.Height := ButtonHeight;
  btnRestart.Width := ButtonWidth;
  btnRestart.Height := ButtonHeight;
  btnToMainMenu.Width := ButtonWidth;
  btnToMainMenu.Height := ButtonHeight;
  // Считаем общую высоту кнопок + отступы
  TotalHeight := 3 * ButtonHeight + 2 * ButtonSpacing;
  StartTop := (PanelMenu.Height - TotalHeight) div 2;

  // Центрируем по ширине панели
  btnResume.Left := (PanelMenu.Width - ButtonWidth) div 2;
  btnResume.Top := StartTop;

  btnRestart.Left := btnResume.Left;
  btnRestart.Top := btnResume.Top + ButtonHeight + ButtonSpacing;

  btnToMainMenu.Left := btnResume.Left;
  btnToMainMenu.Top := btnRestart.Top + ButtonHeight + ButtonSpacing;
  OverlayPanel.Visible := True;
  PanelMenu.Visible := True;
end;

// Главное меню
procedure TForm1.ShowMainMenu;
const
  MenuWidth = 300;
  MenuHeight = 320;
  Spacing = 50;
var
  TotalHeight: Integer;
begin
  // Установим размеры панели
  PanelMainMenu.Width := MenuWidth;
  PanelMainMenu.Height := MenuHeight;

  // Центрируем панель на форме
  PanelMainMenu.Left := (ClientWidth - PanelMainMenu.Width) div 2;
  PanelMainMenu.Top := (ClientHeight - PanelMainMenu.Height) div 2;

  // Высота содержимого
  TotalHeight := ComboBoxGameMode.Height + Spacing + StartBtn.Height;

  // Центрируем элементы внутри панели
  ComboBoxGameMode.Left := (PanelMainMenu.Width - ComboBoxGameMode.Width) div 2;
  ComboBoxGameMode.Top := (PanelMainMenu.Height - TotalHeight) div 2;

  StartBtn.Left := (PanelMainMenu.Width - StartBtn.Width) div 2;
  StartBtn.Top := ComboBoxGameMode.Top + ComboBoxGameMode.Height + Spacing;

  // Отобразим панель
  PanelMainMenu.Visible := True;
end;

// Меню победителя
procedure TForm1.ShowWinningPanel(const WinnerName: string);
const
  ButtonWidth = 270;
  ButtonHeight = 70;
begin
  // Размер панели
  PanelWinning.Width := 500;
  PanelWinning.Height := 300;

  // Центрирование панели на форме
  PanelWinning.Left := (ClientWidth - PanelWinning.Width) div 2;
  PanelWinning.Top := (ClientHeight - PanelWinning.Height) div 2;

  // Установка текста победителя
  labelWinner.Caption := WinnerName + ' победил!';
  labelWinner.Left := (PanelWinning.Width - labelWinner.Width) div 2;
  labelWinner.Top := 20;

  btnToMenu.Width := ButtonWidth;
  btnReplay.Width := ButtonWidth;
  btnToMenu.Height := ButtonHeight;
  btnReplay.Height := ButtonHeight;

  // Расположение кнопок под надписью, по центру, с отступом
  btnReplay.Left := (PanelWinning.Width - btnReplay.Width) div 2;
  btnReplay.Top := labelWinner.Top + labelWinner.Height + 30;

  btnToMenu.Left := (PanelWinning.Width - btnToMenu.Width) div 2;
  btnToMenu.Top := btnReplay.Top + btnReplay.Height + 20;
  btnMenu.Visible := False;
  // Отобразить панель
  PanelWinning.Visible := True;
  OverlayPanel.Visible := True;

end;

// Нажатие старта
procedure TForm1.btnStartClick(Sender: TObject);
begin
  if ComboBoxGameMode.ItemIndex = -1 then
  begin
    ShowMessage('Пожалуйста, выберите режим игры.');
    Exit;
  end;

  case ComboBoxGameMode.ItemIndex of
    0: GameMode := gmExpand;
    1: GameMode := gmConquest;
    2: GameMode := gmHybrid;
  end;
  OverlayPanel.Visible := False;
  GameType.Visible := True;
  InitGame(GameMode);
end;

procedure TForm1.btnLeftClick(Sender: TObject);
begin
  ShiftLeft;
  PaintBox1.Invalidate;
  SwitchPlayer;
  Player.Invalidate;
end;

procedure TForm1.btnResumeClick(Sender: TObject);
begin
  GamePaused := False;
  OverlayPanel.Visible := False;
  btnMenu.Visible := True;
  PanelMenu.Visible := False;
end;

procedure TForm1.btnRestartClick(Sender: TObject);
var
  BtnParent: TWinControl;
begin
  BtnParent := (Sender as TButton).Parent;
  InitGame(GameMode);
  btnMenu.Visible := True;
  OverlayPanel.Visible := False;
  BtnParent.Visible := False;
end;

procedure TForm1.btnToMainMenuClick(Sender: TObject);
var
  BtnParent: TWinControl;
begin
  BtnParent := (Sender as TButton).Parent;
  GameStarted := False;
  BtnParent.Visible := False;
  PaintBox1.Visible := False;
  btnLeft.Visible := False;
  btnRight.Visible := False;
  btnBottom.Visible := False;
  btnTop.Visible := False;
  labelGoes.Visible := False;
  Player.Visible := False;
  GameType.Visible := False;
  btnMenu.Visible := False;
  PanelMenu.Visible := False;
  PanelMainMenu.Visible := True;
end;

procedure TForm1.btnRightClick(Sender: TObject);
begin
  ShiftRight;
  PaintBox1.Invalidate;
  SwitchPlayer;
  Player.Invalidate;
end;

procedure TForm1.btnTopClick(Sender: TObject);
begin
  ShiftUp;
  PaintBox1.Invalidate;
  SwitchPlayer;
  Player.Invalidate;
end;

procedure TForm1.btnBottomClick(Sender: TObject);
begin
  ShiftDown;
  PaintBox1.Invalidate;
  SwitchPlayer;
  Player.Invalidate;
end;

// Спрятать игровое поле

end.

