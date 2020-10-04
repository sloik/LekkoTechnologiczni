import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'kik_screen.dart';

class KikApp extends StatelessWidget {

  final bool showAppBar;

  KikApp(this.showAppBar);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: KikScreen(showAppBar),
    );
  }
}