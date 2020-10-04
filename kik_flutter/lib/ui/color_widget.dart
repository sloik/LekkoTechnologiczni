import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ColorWidget extends StatelessWidget {
  final int index;
  final String color;

  ColorWidget(this.color, this.index);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Stack(
        children: <Widget>[
          Container(
            child: Center(child: Text(color, style: TextStyle(fontSize: 38, color: Colors.blue))),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.blue)),
            width: MediaQuery.of(context).size.width * 0.25,
            height: MediaQuery.of(context).size.height * 0.2,
          ),
        ],
      ),
    );
  }
}
