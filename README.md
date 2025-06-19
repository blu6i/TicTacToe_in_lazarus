https://техномастерская.рф/wp-content/uploads/2023/10/lazarus_appendix.pdf
https://ulspo.ru/library/technical/programing/lazarus/osnovy_programmirovanija_v_srede_lazarus.pdf
http://www.freepascal.ru/download/book/tutorial_fpc&lazarus.pdf

### Работа с CheckBox
Проверка на установленный флаг

```FreePascal
  CheckBox.Checked // Возвращает True или False
```

### Работа с ComboBox
```FreePascal
  ComboBox1.Items.Count; // Получает кол-во элементов
  ComboBox1.Items.Add(NewItem); // Добавляет строку в список
  ComboBox1.ItemIndex; // Получает индекс выбранного элемента
  SelectedItem := ComboBox1.Items[ComboBox1.ItemIndex]; // Получает выбранный элемент
  ComboBox1.Items.Delete(ComboBox1.ItemIndex); // Удаляет выбранный элемент
```

### Работа с RadioGroup
```FreePascal
  RadioGroup1.Items.Add('Вариант 1'); // Добавление кнопки
  RadioGroup1.ItemIndex; // Узнать выбранный вариант (Вернет -1, если вариант не выбран)
  RadioGroup1.Items[RadioGroup1.ItemIndex]; // Получить кнопку по индексу
```

### Работа с CheckGroup
```FreePascal
  CheckGroup1.Checked[I]; // Проверят элемент на флаг
  CheckGroup1.Items[I]; // Выбирает элемент
```

Пример работы с CheckGroup
```FreePascal
var
  I: Integer;
  Selected: String;
begin
  Selected := '';
  for I := 0 to CheckGroup1.Items.Count - 1 do
    if CheckGroup1.Checked[I] then
      Selected := Selected + CheckGroup1.Items[I] + ', ';
  if Selected <> '' then
    ShowMessage('Выбраны: ' + Selected)
  else
    ShowMessage('Ничего не выбрано!');
end.
```

### Работа с Timer
```FreePascal
  Timer1.Interval := 1000; // Устанавливаем интервал 1 секунда
  Timer1.Enabled := True;  // Запускаем таймер
```
Событие OnTimer срабатывает, когда проходит интервал

### Работа с TImage
```FreePascal
  Image1.Picture.LoadFromFile('image.png'); // Загружаем PNG-файл
  Image1.Picture.Graphic.ClassName // Тип файла
  Image1.Picture.Height // Высота имг
  Image1.Picture.Width // Ширина имг
  Image1.Picture.Clear; // Очищаем изображение
```

### Работа с StringGrid
```FreePascal
  StringGrid1.Cells[1, 1] := 'Привет'; // Устанавливаем текст в ячейку (1,1)
  Value := StringGrid1.Cells[1, 1]; // Получаем текст из ячейки (1,1)
  StringGrid1.Cells[1, 1] := ''; // Очищаем ячейку (1,1)
  StringGrid1.DeleteRow(1); // Удаляем строку с индексом 1
  StringGrid1.DeleteCol(1); // Удаляем столбцу с индексом 1
  StringGrid1.Clear; // Очищаем все ячейки
  StringGrid1.RowCount := StringGrid1.RowCount + 1; // Добавляем строку
  StringGrid1.ColCount := StringGrid1.ColCount + 1; // Добавляем столбец
```

### Работа с TEdit
```FreePascal
  Edit1.ReadOnly := True; // Запрещаем редактирование
  Edit1.MaxLength := 5; // Ограничиваем ввод 5 символами (Нужно делать проверку, если вводятся с помощью TButton)
```
Фильтр ввода данных (Цифр + Энтер + BackSpace);
```FreePascal
  procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: Char);
  begin
    if not (Key in ['0'..'9', #8, #13]) then // Разрешаем цифры, Backspace, Enter
      Key := #0; // Отменяем ввод других символов
  end;
```

### Работа с TMaskEdit
```FreePascal
  MaskEdit1.EditMask := '!(999) 000-0000;1;_';
  EditMask = <маска>; <опция сохранения>; <заполнитель> //  Формат маски
  маска — сама структура ввода;
  опция сохранения:
(123) - 132
  0 — сохраняется только то, что ввёл пользователь (123132);
  1 — сохраняется всё, включая маску ((123) - 132);
  заполнитель — символ, который отображается на пустых позициях (_ по умолчанию).
```
🔣 Специальные символы маски
Символ	Значение
0	Цифра (обязательно)
9	Цифра (необязательно)
#	Цифра, +/– знак
L	Буква (обязательно)
?	Буква (необязательно)
A	Буква или цифра (обязательно)
a	Буква или цифра (необязательно)
C	Любой символ (обязательно)
c	Любой символ (необязательно)
>	Все последующие символы — заглавные
<	Все последующие — строчные
\	Следующий символ — буквально

### Работа с Canvas
```FreePascal
  Canvas.Pen.Color := clRed;    // Красный цвет линии
  Canvas.Pen.Width := 2;       // Толщина линии 2 пикселя
  Canvas.Pen.Style := psDash;  // Пунктирная линия
  Canvas.Brush.Style := bsSolid;  // Сплошная заливка
  Canvas.Line(10, 10, 100, 100); // Рисуем линию
  Canvas.Rectangle(50, 50, 150, 100); // Рисуем залитый прямоугольник
  Canvas.Font.Name := 'Arial';  // Шрифт Arial
  Canvas.Font.Size := 12;       // Размер 12
  Canvas.TextOut(10, 10, 'Привет, мир!'); // Выводим текст
  Canvas.MoveTo(50, 50); // Устанавливаем начальную точку
  Canvas.LineTo(150, 150); // Линия от (50,50) до (150,150)
  Canvas.RoundRect(50, 50, 150, 100, 20, 20); // Скругленный прямоугольник
  Canvas.Ellipse(50, 50, 100, 100); // Круг радиусом 25 пикселей
  Canvas.Arc(50, 50, 150, 150, 0, 90 * 16); // Дуга от 0 до 90 градусов
  Canvas.Chord(50, 50, 150, 150, 0, 90 * 16); // Хорда от 0 до 90 градусов
  Canvas.Pie(50, 50, 150, 150, 0, 90 * 16); // Сектор от 0 до 90 градусов
  Canvas.Polygon(Points); // Треугольник Points - массив точек
  Canvas.PolyLine(Points); // Ломаная линия
```
