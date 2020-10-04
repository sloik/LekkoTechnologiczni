import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kik_flutter/kik_method_channel.dart';
import 'package:kik_flutter/view_model/view_model.dart';
import 'package:provider/provider.dart';
import 'package:kik_flutter/extensions/extensions.dart';

import 'color_widget.dart';

class KikScreen extends StatelessWidget {

  final bool showAppBar;

  KikScreen(this.showAppBar);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<KikViewModel>(
      create: (context) => KikViewModel(),
      child: Consumer<KikViewModel>(
        builder: (context, model, child) =>
            Scaffold(
              appBar: showAppBar ? AppBar(title: Text("Kik Flutter")) : AppBar(title: Text("Dupaki")),
              body: Container(
                color: Colors.white,
                child: Center(
                  child: Wrap(
                    children: <Widget>[
                      ...model.items.mapIndexed((index, symbol) => GestureDetector(
                        child: ColorWidget(model.items[index], index),
                        onTap: () async {
                          KikMethodChannel().printHelloFromIos();
                          model.changeColor(index);
                          model.checkWinner(index);
                          if (model.isWinning) {
                            _showCupertinoDialog(context, () => model.reset());
                          }
                        },
                      ))
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }


void _showCupertinoDialog(BuildContext context, Function reset) {
    showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text('Winner!'),
        content: Text('Wish to play another game?'),
        actions: <Widget>[_restartAction(context, reset)],
      ),
    );
  }

  Widget _restartAction(BuildContext context, Function reset) {
    return CupertinoButton(
      onPressed: () {
        Navigator.pop(context);
        reset();
      },
      child: CupertinoDialogAction(
        child: Text(
          'Reset',
          style: TextStyle(fontSize: 10),
        ),
      ),
    );
  }
}