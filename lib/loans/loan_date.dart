import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import "package:flutter/material.dart";
import 'package:firebase_database/firebase_database.dart';
import '../models/loan.dart';
import 'dart:async';
import '../models/user.dart';
import '../models/book.dart';
import 'package:intl/intl.dart';

class LoanDatePage extends StatefulWidget {
  final firebaseAuth.User fuser;
  final Book book;
  final User loanUser;

  LoanDatePage(
      {Key key,
      @required this.fuser,
      @required this.book,
      @required this.loanUser})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _LoanDatePageState(this.fuser, this.book, this.loanUser);
  }
}

class _LoanDatePageState extends State<LoanDatePage> {
  var fuser;
  Book book;
  User loanUser;
  final formKey = new GlobalKey<FormState>();
  String error;

  DateTime _loanDateTime;
  DateTime _returnDateTime;

  final TextEditingController _loanDate = new TextEditingController();
  final TextEditingController _returnDate = new TextEditingController();

  Future _chooseDate(BuildContext context, DateTime initialDate,
      TextEditingController controller, bool isReturnDate) async {
    var now = new DateTime.now();
    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        locale: new Locale("fr", ''),
        firstDate: new DateTime(now.year),
        lastDate: new DateTime(now.year + 2));

    if (result == null) return;

    setState(() {
      controller.text = new DateFormat('dd/MM/yyyy').format(result);
      isReturnDate ? _returnDateTime = result : _loanDateTime = result;
    });
  }

  // In the constructor, require a Todo
  _LoanDatePageState(fuser, book, user) {
    this.fuser = fuser;
    this.loanUser = user;
    this.book = book;
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  String validateDateFormat(String input) {
    Pattern pattern =
        r"^(0?[1-9]|[12][0-9]|3[01])[\/](0?[1-9]|1[012])[\/]\d{4}$";
    RegExp regex = new RegExp(pattern);
    return regex.hasMatch(input)
        ? null
        : "Veuillez indiquer une date valide (jj/dd/aaaa)";
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("BiblioChouette"),
      ),
      body: _manageDisplay(),
    );
  }

  void submit() {
    print(_loanDateTime);
    print(_returnDateTime);
    if (_loanDateTime != null && _returnDateTime != null) {
      if (_loanDateTime.isBefore(_returnDateTime)) {
        Loan submitLoan = new Loan(
            this.book,
            this.loanUser,
            _loanDateTime.millisecondsSinceEpoch,
            _returnDateTime.millisecondsSinceEpoch);
        FirebaseDatabase.instance
            .ref()
            .child("loans")
            .child(this.fuser.uid)
            .push()
            .set(submitLoan.toJson());
        Navigator.popUntil(context, ModalRoute.withName('/'));
      } else {
        setState(() {
          error =
              "La date de retour ne peut être antérieure à celle d'emprunt.";
        });
      }
    } else {
      setState(() {
        error = "Les deux dates sont nécessaires";
      });
    }
  }

  Widget _manageDisplay() {
    return new Container(
        padding: EdgeInsets.all(16.0),
        child: new Column(children: <Widget>[
          new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new Row(children: <Widget>[
                new Expanded(
                  child: new MaterialButton(
                    color: Colors.grey,
                    onPressed: (() {
                      _chooseDate(
                          context, new DateTime.now(), _loanDate, false);
                    }),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Icon(
                          Icons.calendar_today,
                          color: Colors.white70,
                        ),
                        new Text(
                          _loanDate.text == ""
                              ? "Date d'emprunt"
                              : _loanDate.text,
                          style: TextStyle(color: Colors.white70),
                        )
                      ],
                    ),
                  ),
                ),
              ]),
              new Row(children: <Widget>[
                new Expanded(
                  child: new MaterialButton(
                    color: Colors.grey,
                    onPressed: (() {
                      _chooseDate(
                          context,
                          new DateTime.now().add(new Duration(days: 21)),
                          _returnDate,
                          true);
                    }),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Icon(
                          Icons.calendar_today,
                          color: Colors.white70,
                        ),
                        new Text(
                          _returnDate.text == ""
                              ? "Date de retour"
                              : _returnDate.text,
                          style: TextStyle(color: Colors.white70),
                        )
                      ],
                    ),
                  ),
                ),
              ]),
              new Text(
                this.error == null ? "" : this.error,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontFamily: "BadScript"),
              ),
              SizedBox(height: 24.0),
              Material(
                borderRadius: BorderRadius.circular(0.0),
                shadowColor: Colors.lightBlueAccent,
                elevation: 0.0,
                child: MaterialButton(
                  minWidth: 200.0,
                  height: 42.0,
                  onPressed: () {
                    submit();
                  },
                  color: Colors.lightBlueAccent,
                  child: Text('Emprunter',
                      style: TextStyle(color: Colors.white, fontSize: 18.0)),
                ),
              ),
            ],
          )
        ]));
  }
}
