import 'package:flutter/material.dart';

class EmptyData extends StatelessWidget {
  const EmptyData({this.title,this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return 
      new Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: Colors.red[800],
                  fontWeight: FontWeight.w300,
                  fontSize: 16
                ),
              ),
              SizedBox(height: 10),
              Text(subtitle)
            ],
          )
        )
      );

  }
}