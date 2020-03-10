import 'package:flutter/material.dart';

import '../models/loan.dart';

typedef DeleteCallback = void Function(Loan loan);

class LoanCard extends StatelessWidget {
  const LoanCard({this.loan,this.onDelete});

  final Loan loan;
  final DeleteCallback onDelete;

  String _getStatus() {
     return this.loan.expectedReturnDate < DateTime.now().millisecondsSinceEpoch ? "En retard" : "En cours";
   }

   MaterialColor _getStatusColor() {
     return this.loan.expectedReturnDate < DateTime.now().millisecondsSinceEpoch ? Colors.red : Colors.green;
   }

   void _delete() {
     this.onDelete(this.loan);
   }

  @override
  Widget build(BuildContext context) {

    final leftSection = new Container(
      child: new CircleAvatar(
        backgroundImage: new NetworkImage(loan.book.cover),
        backgroundColor: Colors.lightGreen,
        radius: 24.0,
      ),
    );

    final rightSection = new Container(
      child: new IconButton(
        icon: new Icon(Icons.input),
        color: Colors.blue[200],
        // onPressed: () => this.onDelete(this.loan),
        onPressed: _delete,
      ),
    );

    final bottomRow = new Container(
      child:RichText(
        text: TextSpan(
          text: 'Status : ',
          style: new TextStyle(
            fontSize: 14.0,
            color: Colors.black54
          ),
          children: <TextSpan>[
            TextSpan(text: this._getStatus(), style: TextStyle(fontWeight: FontWeight.bold, color: this._getStatusColor())),
          ],
        ),
      )
    );

    final loanBy = new Container(
      child: RichText(
        text: TextSpan(
          text: 'Emprunté par : ',
          style: new TextStyle(
            fontSize: 14.0,
            color: Colors.black54
          ),
          children: <TextSpan>[
            TextSpan(text: this.loan.user.username),
          ],
        ),
      )
    );

    final middleSection = new Expanded(
      child: new Container(
        padding: new EdgeInsets.only(left: 14.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            new Text(loan.book.title,
              style: new TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 16.0,
              ),),
              loanBy,
              bottomRow
            // new Text("Hi whatsp?", style:
            //   new TextStyle(color: Colors.grey),),
          ],
        ),
      ),
    );



    return Container(
      padding: const EdgeInsets.all(10.0),
      child: new Row(
        children: <Widget>[
          leftSection,
          middleSection,
          rightSection
        ],
      ),
    );


  }

}