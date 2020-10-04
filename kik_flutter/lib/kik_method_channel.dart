import 'package:flutter/services.dart';

class KikMethodChannel {
  static const platform = const MethodChannel('KikMethodChannel');

  void printHelloFromIos() async {

    try {
      final String result = await platform.invokeMethod('printHello');
      print(result);
    } on PlatformException catch (e){
      print(e);
    }
  }

}