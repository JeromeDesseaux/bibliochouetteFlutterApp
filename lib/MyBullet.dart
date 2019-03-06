import "package:flutter/material.dart";


class MyBullet extends StatelessWidget{

  final bool isGreen;

  MyBullet({Key key, @required this.isGreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 20.0,
      width: 20.0,
      decoration: new BoxDecoration(
        color: this.isGreen?Colors.greenAccent:Colors.redAccent,
        shape: BoxShape.circle,
      ),
    );
  }
}