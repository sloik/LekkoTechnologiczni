import 'package:flutter/cupertino.dart';
import 'package:kik_flutter/ui/kik_app_widget.dart';

  @pragma('vm:entry-point')
  void startIosApp() {
    print("INVOKED DEFAULT ENTRY POINT");
    runApp(KikApp(false));
  }
