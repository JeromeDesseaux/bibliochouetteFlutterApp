import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import "package:flutter/material.dart";
import 'package:intl/intl.dart';
import "../models/book.dart";
import "../models/loan.dart";
import "./book_edit.dart";
import "../loans/loan_user.dart";

class BookDetailsPage extends StatelessWidget {
  final Book book;
  final String uid;
  final Loan loan;

  // In the constructor, require a book
  BookDetailsPage({Key key, @required this.book, @required this.uid, this.loan})
      : super(key: key);

  String getPrintableReturnDate() {
    String displayDate = "";
    if (this.loan != null) {
      DateTime returnDate =
          new DateTime.fromMillisecondsSinceEpoch(this.loan.expectedReturnDate);
      var f = new DateFormat('dd-MM-yyyy');
      displayDate = f.format(returnDate);
    }
    return displayDate;
  }

  void _showDeleteDialog(context, user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text("Confirmer le retour?"),
          content: new Text("Cette action est irréversible."),
          actions: <Widget>[
            new TextButton(
              child: new Text('Annuler'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            new TextButton(
              child: new Text("Confirmer"),
              onPressed: () {
                loan.returnBook();
                FirebaseDatabase.instance
                    .ref()
                    .child("loans")
                    .child(user.uid)
                    .child(this.loan.uid)
                    .update(this.loan.toJson());

                // print("DELETE $loanUID");
                // FirebaseDatabase.instance.ref().child("loans").child(this._user.uid).child(loanUID).remove();
                // Navigator.pop(context);
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            )
          ],
        );
      },
    );
  }

  void manageBorrowOrReturn(context) {
    User user = FirebaseAuth.instance.currentUser;
    if (this.loan != null) {
      // Il est emprunté - Afficher la modale
      this._showDeleteDialog(context, user);
      // Navigator.popUntil(context, ModalRoute.withName('/'));
    } else {
      // il est dispo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => new LoanUserPage(user: user, book: book),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${book.title}"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        new BookEditPage(book: book, uid: uid),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: new FloatingActionButton(
            elevation: 0.0,
            child: new Icon(this.loan == null
                ? Icons.business_center
                : Icons.subdirectory_arrow_left),
            backgroundColor: new Color(0xFFE57373),
            onPressed: () {
              this.manageBorrowOrReturn(context);
            }),
        body: new ListView(
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.all(16.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new SizedBox(
                    width: 150.0,
                    height: 300.0,
                    child: Image.network(
                      book.cover,
                      fit: BoxFit.contain,
                    ),
                  ),
                  new Container(
                    height: 4.0,
                  ),
                  new Text(
                    book.authors,
                    style: new TextStyle(
                        fontFamily: "BadScript",
                        fontStyle: FontStyle.normal,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey),
                  ),
                  new Container(
                    height: 8.0,
                  ),
                  new Text(
                    loan == null
                        ? "Disponible"
                        : "Emprunté par " + loan.user.username,
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        fontFamily: "Dekko",
                        fontStyle: FontStyle.italic,
                        fontSize: 20.0,
                        fontWeight: FontWeight.normal,
                        color: loan == null ? Colors.green : Colors.red),
                  ),
                  new Text(
                    loan != null
                        ? "Retour attendu le " + getPrintableReturnDate()
                        : "",
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                      fontFamily: "Dekko",
                      fontStyle: FontStyle.italic,
                      fontSize: 15.0,
                      fontWeight: FontWeight.normal,
                      //color: Colors.red
                    ),
                  ),
                  new Container(
                    padding: EdgeInsets.all(15.0),
                    height: 1.0,
                    color: Colors.grey,
                  ),
                  new Text(book.description,
                      style: new TextStyle(fontFamily: "Dekko", fontSize: 15.0))
                ],
              ),
            ),
          ],
        ));
  }
}
