import "package:flutter/material.dart";
import "../models/user.dart";
import 'package:firebase_database/firebase_database.dart';

class UserCreatePage extends StatefulWidget {

  final String uid;

  UserCreatePage({Key key, @required this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _UserCreatePageState(this.uid);
  }
}
  
  

class _UserCreatePageState extends State<UserCreatePage> {

  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();
  final User _user = new User("");
  String uid;

  _UserCreatePageState(uid){
    this.uid = uid;
  }

  void _save(context) {
    FirebaseDatabase.instance.reference().child("users").child(this.uid).push().set(this._user.toJson());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Créer un utilisateur"),
      ),
      body: new ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: new Form(
                  key: _createFormKey,
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new TextFormField(
                        onSaved: (value) => _user.username=value,
                        decoration: new InputDecoration(
                          labelText: "Nom"
                        ),
                        validator: (value) {
                          if(value.isEmpty)
                            return "Merci d'indiquer un nom d'utilisateur";
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Material(
                          borderRadius: BorderRadius.circular(30.0),
                          shadowColor: Colors.lightBlueAccent.shade100,
                          elevation: 5.0,
                          child: MaterialButton(
                            minWidth: 200.0,
                            height: 42.0,
                            onPressed: () {
                              if(_createFormKey.currentState.validate()){
                                _createFormKey.currentState.save();
                                this._save(context);
                              }
                            },
                            color: Colors.lightBlueAccent,
                            child: Text('Enregistrer', style: TextStyle(color: Colors.white)),
                          ),
                        ),
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