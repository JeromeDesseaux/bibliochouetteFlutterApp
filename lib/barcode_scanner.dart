import "package:flutter/material.dart";

class BarcodeScannerPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Scanner"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Hello World'),
      ),
    );
  }
}