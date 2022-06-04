import "package:flutter/material.dart";
import "../models/book.dart";
import 'package:firebase_database/firebase_database.dart';

class BookEditPage extends StatefulWidget {
  final String uid;
  final Book book;

  BookEditPage({Key key, @required this.book, @required this.uid})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _BookEditPageState(this.book, this.uid);
  }
}

class _BookEditPageState extends State<BookEditPage> {
  Book book;
  String uid;

  final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();

  // In the constructor, require a book
  _BookEditPageState(book, uid) {
    this.book = book;
    this.uid = uid;
  }

  void _save(context) {
    // print(book.uid);
    // print(this.uid);
    FirebaseDatabase.instance
        .ref()
        .child("books")
        .child(this.uid)
        .child(book.uid)
        .update(book.toJson());
    Navigator.pop(context);
    // Navigator.pop(context);
    // Navigator.push(
    //   context,
    //   new MaterialPageRoute(builder: (context) => new BookDetailsPage(book: book, uid: uid)),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("${book.title}"),
        ),
        body: new ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: new Form(
                key: _editFormKey,
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new Image.network(
                      book == null ? "" : book.cover,
                      fit: BoxFit.contain,
                      height: 142.0,
                      width: 142.0,
                    ),
                    new TextFormField(
                      onSaved: (value) => book.title = value,
                      initialValue: book.title,
                      decoration: new InputDecoration(labelText: "Titre"),
                      validator: (value) {
                        if (value.isEmpty)
                          return "Merci d'indiquer le titre du livre";
                      },
                    ),
                    new TextFormField(
                      onSaved: (value) => book.authors = value,
                      initialValue: book.authors,
                      decoration: new InputDecoration(labelText: "Auteur"),
                      validator: (value) {
                        if (value.isEmpty)
                          return "Merci d'indiquer le l'auteur du livre";
                      },
                    ),
                    new TextFormField(
                      onSaved: (value) => book.pageCount = value,
                      initialValue: book.pageCount,
                      keyboardType: TextInputType.number,
                      // initialValue: "0",
                      decoration:
                          new InputDecoration(labelText: "Nombre de pages"),
                    ),
                    new TextFormField(
                      onSaved: (value) => book.publicationYear = value,
                      initialValue: book.publicationYear,
                      keyboardType: TextInputType.number,
                      // initialValue: new DateTime.now().year.toString(),
                      decoration: new InputDecoration(
                          labelText: "Année de publication"),
                    ),
                    new TextFormField(
                      onSaved: (value) => book.description = value,
                      initialValue: book.description,
                      maxLines: 5,
                      decoration:
                          new InputDecoration(labelText: "Présentation"),
                    ),
                    SizedBox(height: 24.0),
                    Material(
                      borderRadius: BorderRadius.circular(0.0),
                      shadowColor: Colors.lightBlueAccent.shade100,
                      elevation: 0.0,
                      child: MaterialButton(
                        minWidth: 200.0,
                        height: 42.0,
                        onPressed: () {
                          if (_editFormKey.currentState.validate()) {
                            _editFormKey.currentState.save();
                            this._save(context);
                          }
                          // handleSignInEmail();
                        },
                        color: Colors.lightBlueAccent,
                        child: Text('Enregistrer',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0)),
                      ),
                    ),
                    // new RaisedButton(
                    //   child: new Text("Enregister"),
                    //   onPressed: () {
                    //     if(_editFormKey.currentState.validate()){
                    //       _editFormKey.currentState.save();
                    //       this._save(context);
                    //     }
                    //   },
                    // )
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
