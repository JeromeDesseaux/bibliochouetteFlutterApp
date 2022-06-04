import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../components/loan_card.dart';
import '../models/loan.dart';
import './loan_book.dart';
import "../loading.dart";

class LoanListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _LoanListPageState();
  }
}

class _LoanListPageState extends State<LoanListPage> {
  var _user;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        _user = user;
      });
    });
  }

  void _addLoan() {
    // print("add loan");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => new LoanBookPage(user: this._user),
      ),
    );
  }

  void _showDeleteDialog(Loan loan) {
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
                    .child(this._user.uid)
                    .child(loan.uid)
                    .update(loan.toJson());

                // print("DELETE $loanUID");
                // FirebaseDatabase.instance.ref().child("loans").child(this._user.uid).child(loanUID).remove();
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Widget _manageDisplay() {
    if (_user != null) {
      return new StreamBuilder<Event>(
        stream: FirebaseDatabase.instance
            .ref()
            .child("loans")
            .child(_user.uid)
            .orderByChild("returnDateValidated")
            .equalTo(null)
            .onValue,
        builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
          // return StreamBuilder(
          //   stream: FirebaseDatabase.instance.ref().child("loans").child(_user.uid).onValue,

          // );

          if (!snapshot.hasData) return LoadingScreen();

          Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
          var data = [];
          if (map != null) {
            map.forEach((i, v) {
              var loan = Loan.fromJson(new Map<String, dynamic>.from(v), i);
              if (loan.returnDateValidated == null) {
                data.add(loan);
              }
              // data.sort((a,b) => a.username.compareTo(b.username)); TRIER PAR DATE DECROISSANTE
            });
          }
          int bookCount = data.length;
          return Container(
            padding: const EdgeInsets.all(10.0),
            child: new ListView.builder(
              itemCount: bookCount,
              itemBuilder: (_, int index) {
                Loan loan = data[index];
                return Card(
                    child: LoanCard(
                        loan: loan,
                        onDelete: (loan) => this._showDeleteDialog(loan))
                    // child: LoanCard(loan)
                    // child: ListTile(
                    //   leading: new CircleAvatar(
                    //     backgroundImage: new NetworkImage(loan.book.cover),
                    //   ),
                    //   title: new Text(loan.book.title?? '<No title>'),
                    //   subtitle: new Text(loan.user.username),
                    //   onTap: () {
                    //   },
                    //   trailing: new IconButton(
                    //     icon: new Icon(Icons.input),
                    //     onPressed: () {
                    //       this._showDeleteDialog(loan);
                    //     },
                    //   )
                    // )

                    );
              },
            ),
          );
        },
      );
    } else {
      return new Text("FETCHING DATA");
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Emprunts"),
      ),
      body: _manageDisplay(),
      backgroundColor: Color(0xfff3f2f8),
      // drawer: new BibDrawer(user: this._user),
      floatingActionButton: new FloatingActionButton(
          elevation: 0.0,
          child: new Icon(Icons.add),
          backgroundColor: new Color(0xFFE57373),
          onPressed: () {
            _addLoan();
          }),
    );
  }
}
