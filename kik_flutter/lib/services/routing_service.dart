import 'package:flutter/cupertino.dart';
import 'package:kik_flutter/ui/kik_screen.dart';

class KiKRouter {

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch(settings.name) {
      case "/":
        return CupertinoPageRoute(builder: (_) => KikScreen(true));
    }
  }
}