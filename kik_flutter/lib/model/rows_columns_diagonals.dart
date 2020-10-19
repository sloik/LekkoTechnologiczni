class RowsColumnsDiagonals {
  RowsColumnsDiagonals();

  List<String> item = List<String>.generate(9, (index) => "-");

  List get row1 => [item[0], item[1], item[2]];
  List get row2 => [item[3], item[4], item[5]];
  List get row3 => [item[6], item[7], item[8]];
  List get column1 => [item[0], item[3], item[6]];
  List get column2 => [item[1], item[4], item[7]];
  List get column3 => [item[2], item[5], item[8]];
  List get diagonal1 => [item[0], item[4], item[8]];
  List get diagonal2 => [item[2], item[4], item[6]];

  void updateItem(int index, String element) {
    item.removeAt(index);
    item.insert(index, element);
  }

  String oppositeSymbol(String symbol) {
    if (symbol == "X") {
      return "O";
    }
    return "X";
  }
}
