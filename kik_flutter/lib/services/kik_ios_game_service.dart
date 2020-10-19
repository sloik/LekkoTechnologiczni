
import 'package:flutter/services.dart';
import 'package:kik_flutter/services/kik_service.dart';

class KikIosGameService extends KikService {

  static const platform = const MethodChannel('KikMethodChannel');

  @override
  bool checkIfWin(int index) {


  }

  @override
  // TODO: implement items
  List get items => null;

  @override
  void reset() {
    // TODO: implement reset
  }

  @override
  void updateSymbol(int index) {
    // TODO: implement updateSymbol
  }

  Future<List> _getIosKikModel() async {
    try {
    final String model = await platform.invokeMethod('_getModel');
    print(model);
  } on PlatformException catch (e){
    print(e);
  }
  }

}


// void printHelloFromIos() async {
//
//   try {
//     final String result = await platform.invokeMethod('printHello');
//     print(result);
//   } on PlatformException catch (e){
//     print(e);
//   }
// }
