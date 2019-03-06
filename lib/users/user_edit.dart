import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import "../models/user.dart";
import 'package:firebase_database/firebase_database.dart';

class UserEditPage extends StatefulWidget {
  final FirebaseUser fuser;
  final User user;

  UserEditPage({Key key, @required this.fuser, @required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _UserEditPageState(this.fuser, this.user);
  }
}

class _UserEditPageState extends State<UserEditPage> {
  FirebaseUser fuser;
  User user;

  final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();

  // In the constructor, require a book
  _UserEditPageState(fuser, user){
    this.fuser = fuser;
    this.user = user;
  }

  void _save(context) {
    // print(book.uid);
    // print(this.uid);
    FirebaseDatabase.instance.reference().child("users").child(this.fuser.uid).child(user.uid).update(user.toJson());
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
        title: Text("${user.username}"),
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
                      new TextFormField(
                        onSaved: (value) => user.username=value,
                        initialValue: user.username,
                        decoration: new InputDecoration(
                          labelText: "Nom d'utilisateur"
                        ),
                        validator: (value) {
                          if(value.isEmpty)
                            return "Merci d'indiquer un nom d'utilisateur";
                        },
                      ),
                      new RaisedButton(
                        child: new Text("Enregister"),
                        onPressed: () {
                          if(_editFormKey.currentState.validate()){
                            _editFormKey.currentState.save();
                            this._save(context);
                          }
                        },
                      )
                    ],
                  ),
                ),
          ),
        ],
      )
    );
  }
}