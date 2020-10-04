
import 'package:kik_flutter/model/rows_columns_diagonals.dart';

import 'kik_service.dart';

class KikGameService extends KikService {
  RowsColumnsDiagonals _model = RowsColumnsDiagonals();

  List<String> get items => _model.item;
  String _currentSymbol = "X";

  String _oppositeSymbol(String symbol) {
    if (symbol == "X") {
      return "O";
    }
    return "X";
  }

  @override
  void updateSymbol(int index) {
    _model.updateItem(index, _currentSymbol);
    _currentSymbol = _oppositeSymbol(_currentSymbol);
  }

  @override
  bool checkIfWin(int index) {
    bool flag = false;
    [
      _model.row1,
      _model.row2,
      _model.row3,
      _model.column1,
      _model.column2,
      _model.column3,
      _model.diagonal1,
      _model.diagonal2,
    ]..forEach((element) {
      if (!element.contains("-") && element.length == 3) {
        if (element.toSet().length == 1) {
          flag = true;
        }
      }
    });
    return flag;
  }

  @override
  void reset() {
    _model = RowsColumnsDiagonals();
  }
}
