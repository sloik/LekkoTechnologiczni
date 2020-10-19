import 'package:flutter/material.dart';
import 'package:kik_flutter/services/kik_game_service.dart';
import 'package:kik_flutter/services/kik_service.dart';

class KikViewModel extends ChangeNotifier {

  final KikService _gameService = KikGameService();
  bool isWinning = false;

  List<String> get items => _gameService.items;

  void changeColor(int index) {
    _gameService.updateSymbol(index);
    notifyListeners();
  }

  void reset() {
    _gameService.reset();
    notifyListeners();
  }

  void checkWinner(int index) {
    isWinning = _gameService.checkIfWin(index);
    notifyListeners();
  }
}