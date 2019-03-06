import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import './user_edit.dart';
import 'package:intl/intl.dart';
import "../models/loan.dart";
import "../models/user.dart";
import "../MyBullet.dart";

class UserDetailsPage extends StatelessWidget {
  final List<Loan> loans = new List<Loan>();
  final User user;
  final FirebaseUser fuser; 

  UserDetailsPage({@required this.user, @required this.fuser, loans}){
    try{
      List<Loan> returnedBooks = loans.where((test) => test.returnDateValidated!=null).toList(); 
      List<Loan> loanedBooks = loans.where((test) => test.returnDateValidated==null).toList(); 
      loanedBooks.sort((a,b) => a.expectedReturnDate.compareTo(b.expectedReturnDate));
      
      this.loans.addAll(loanedBooks);
      this.loans.addAll(returnedBooks);

    }catch(e){}
    
  }

  void _edit(context) {
    print("edit");
    print(this.fuser.uid);
    print(this.user.uid);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => new UserEditPage(fuser: this.fuser, user: this.user),
      ),
    );

  }

  String getFormattedText(Loan loan){
    var formatter = new DateFormat('dd/MM/yyyy');
    if(loan.returnDateValidated!=null){
      DateTime returnDate = new DateTime.fromMillisecondsSinceEpoch(loan.returnDateValidated);
      return "Rendu le "+formatter.format(returnDate);
    }else{
      DateTime returnDate = new DateTime.fromMillisecondsSinceEpoch(loan.expectedReturnDate);
      return "A rendre le "+formatter.format(returnDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text("${user.username}"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              this._edit(context);
            },
          ),
        ],
      ),
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Container(
            padding: new EdgeInsets.all(10.0),
            child: new Column(
              children: <Widget>[
                new Container(
                  padding: new EdgeInsets.all(16.0),
                  child: new Text(
                    user.username,
                    style: new TextStyle(
                      fontSize: 30.0,
                      color: Colors.blueGrey,
                      fontFamily: 'Norican'
                    ),
                  ),
                ),
              new Text(
                loans.length>0?"Livres empruntés":"Aucun livre emprunté",
                style: new TextStyle(
                  fontSize: 20.0,
                  fontFamily: "Dekko"
                ),
              ),
              new Container(
                padding: EdgeInsets.all(15.0),
                height: 1.0,
                color: Colors.grey,
              ),
              ],
            ),
          ),
          new Expanded(
            child: new ListView.builder(
              itemCount: loans.length,
              itemBuilder: (context, int index) {
                Loan loan = loans[index];
                return new ListTile(
                  leading: new CircleAvatar(
                    backgroundImage: new NetworkImage(loan.book.cover),
                  ),
                  title: new Text(
                    loan.book.title,
                    style: new TextStyle(
                      fontFamily: "Dekko"
                    ),
                  ),
                  subtitle: new Text(
                    getFormattedText(loan)
                  ),
                  trailing: new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new MyBullet(
                        isGreen: loan.returnDateValidated==null?false:true,
                      ),
                    ],
                  )
                );
              },
            )
          )
        ],
      ) 
      
      
      //new ListView(
            // children: <Widget>[
            //   new Container(
            //     padding: const EdgeInsets.all(16.0),
            //     child: new Column(
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: <Widget>[
            //         new Text(
            //           user.username
            //         ),
            //         new Text(
            //           "Livres empruntés",
            //           style: new TextStyle(
            //             fontSize: 20.0
            //           ),
            //         ),
            //       ],
            //     ),

            //   ),
              
            // ],
      );
  }
}