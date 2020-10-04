import 'package:flutter/material.dart';
import 'package:kik_flutter/model/rows_columns_diagonals.dart';

class KikModel extends ChangeNotifier {
  static Color _initialColor = Colors.white60;

  List<Color> color = List<Color>.generate(9, (index) => _initialColor);
  bool wasTapped = false;
  bool winner = false;
  RowsColumnsDiagonals rowColumnsDiagonals = RowsColumnsDiagonals();

  void changeColor(int index) {
    if (wasTapped == false) {
      color.removeAt(index);
      color.insert(index, Colors.blue);
      wasTapped = true;
      notifyListeners();
    } else if (wasTapped == true) {
      color.removeAt(index);
      color.insert(index, Colors.red);
      wasTapped = false;
      notifyListeners();
    }
  }

  void checkIfWin(int index) {
    switch (index) {
      case 0:
        rowColumnsDiagonals.row1.add(color[index]);
        rowColumnsDiagonals.column1.add(color[index]);
        rowColumnsDiagonals.diagonal1.add(color[index]);
        notifyListeners();
        break;
      case 1:
        rowColumnsDiagonals.row1.add(color[index]);
        rowColumnsDiagonals.column2.add(color[index]);
        notifyListeners();
        break;
      case 2:
        rowColumnsDiagonals.row1.add(color[index]);
        rowColumnsDiagonals.column3.add(color[index]);
        rowColumnsDiagonals.diagonal2.add(color[index]);
        notifyListeners();
        break;
      case 3:
        rowColumnsDiagonals.row2.add(color[index]);
        rowColumnsDiagonals.column1.add(color[index]);
        notifyListeners();
        break;
      case 4:
        rowColumnsDiagonals.row2.add(color[index]);
        rowColumnsDiagonals.column2.add(color[index]);
        rowColumnsDiagonals.diagonal1.add(color[index]);
        rowColumnsDiagonals.diagonal2.add(color[index]);
        notifyListeners();
        break;
      case 5:
        rowColumnsDiagonals.row2.add(color[index]);
        rowColumnsDiagonals.column3.add(color[index]);
        notifyListeners();
        break;
      case 6:
        rowColumnsDiagonals.row3.add(color[index]);
        rowColumnsDiagonals.column1.add(color[index]);
        rowColumnsDiagonals.diagonal2.add(color[index]);
        notifyListeners();
        break;
      case 7:
        rowColumnsDiagonals.row3.add(color[index]);
        rowColumnsDiagonals.column2.add(color[index]);
        notifyListeners();
        break;
      case 8:
        rowColumnsDiagonals.row3.add(color[index]);
        rowColumnsDiagonals.column3.add(color[index]);
        rowColumnsDiagonals.diagonal1.add(color[index]);
        notifyListeners();
        break;
    }

    [
      rowColumnsDiagonals.row1,
      rowColumnsDiagonals.row2,
      rowColumnsDiagonals.row3,
      rowColumnsDiagonals.column1,
      rowColumnsDiagonals.column2,
      rowColumnsDiagonals.column3,
      rowColumnsDiagonals.diagonal1,
      rowColumnsDiagonals.diagonal2,
    ]..forEach((element) {
      if (element.length == 3) {
        if (element.toSet().length == 1) {
          winner = true;
          notifyListeners();
        }
      }
    });
  }

  void reset() {
    color.clear();
    color = List<Color>.generate(9, (index) => _initialColor);
    rowColumnsDiagonals = RowsColumnsDiagonals();
    winner = false;
    notifyListeners();
  }
}