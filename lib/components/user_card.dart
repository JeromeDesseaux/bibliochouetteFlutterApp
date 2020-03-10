import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_bibliotheque/MyBullet.dart';
import 'package:gestion_bibliotheque/models/loan.dart';

import '../models/user.dart';

typedef DeleteCallback = void Function(String user);

class UserCard extends StatelessWidget {
  const UserCard({this.user, this.loans, this.onDelete});

  final User user;
  // final FirebaseUser firebaseUser;
  final List<Loan> loans;
  final DeleteCallback onDelete;

  String _getStatus() {
    var loans = this.user.getLoans(this.loans);
    var l = loans.length;
    if(loans!=null){
      int retards = loans.where((loan) => loan.expectedReturnDate < DateTime.now().millisecondsSinceEpoch).length;
      if(retards != 0){
        return "$l emprunt(s) dont $retards en retard";
      } 
    }
    return "Aucun emprunt";
   }

   MaterialColor _getStatusColor() {
     var loans = this.user.getLoans(this.loans);
     if(loans!=null){
      int retards = loans.where((loan) => loan.expectedReturnDate < DateTime.now().millisecondsSinceEpoch).length;
      print(retards);
      return retards > 0 ? Colors.red : Colors.green;
     }
     return Colors.green;
   }

   void _delete() {
     this.onDelete(this.user.uid);
   }

  @override
  Widget build(BuildContext context) {

    final leftSection = new Container(
      child: new MyBullet(isGreen: this.user.getLoans(this.loans).length>0?false:true)
    );

    final rightSection = new Container(
      child: new IconButton(
        icon: new Icon(Icons.delete_outline),
        color: Colors.blueGrey[300],
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
            TextSpan(text: this.user.username),
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
            new Text(user.username,
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



    return InkWell(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        child: new Row(
          children: <Widget>[
            leftSection,
            middleSection,
            rightSection
          ],
        ),
      ),
      onTap: () => print("Container pressed"),
    );


  }

}