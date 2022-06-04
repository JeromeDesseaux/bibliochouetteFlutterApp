import "package:flutter/material.dart";
import 'package:gestion_bibliotheque/models/class.dart';
import 'package:gestion_bibliotheque/utils/classes.dart';
import "../models/user.dart";
import "../models/class.dart";
import 'package:firebase_database/firebase_database.dart';

class UserCreatePage extends StatefulWidget {
  final String uid;
  final List<Class> classes;

  UserCreatePage({Key key, @required this.uid, this.classes}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _UserCreatePageState(this.uid);
  }
}

class _UserCreatePageState extends State<UserCreatePage> {
  final GlobalKey<FormState> _createFormKey = GlobalKey<FormState>();
  final User _user = new User("");

  List<Class> classes = [];
  String uid;
  var selectedClass;

  @override
  void initState() {
    super.initState();
    this._getClasses();
  }

  _UserCreatePageState(uid) {
    this.uid = uid;
  }

  void _getClasses() async {
    List<Class> classes = [];
    await getClasses(this.uid).then((c) => classes = c);
    // await FirebaseDatabase.instance.ref().child("classes").child(this.uid).once().then((snapshot ) {
    //   Map<dynamic,dynamic> map = snapshot.value;
    //   map.forEach((key, json) {
    //     Class c = Class.fromJson(new Map<String, dynamic>.from(json), key);
    //     classes.add(c);
    //   });
    //   classes.add(new Class("Défaut", ""));
    // });
    setState(() {
      this.classes = classes;
    });
  }

  void _save(context) {
    FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(this.uid)
        .push()
        .set(this._user.toJson());
    Navigator.pop(context, true);
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
                      onSaved: (value) => _user.username = value,
                      decoration: new InputDecoration(labelText: "Nom"),
                      validator: (value) {
                        if (value.isEmpty)
                          return "Merci d'indiquer un nom d'utilisateur";
                      },
                    ),
                    new DropdownButton<String>(
                      value:
                          selectedClass, //"-M23VpPGo6FLvkJ5Njja",//selectedClass!=null?selectedClass.classname:classes[0].classname,
                      items: classes.map((Class classe) {
                        return new DropdownMenuItem<String>(
                          value: classe.uid,
                          child: new Text(classe.classname),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        this._user.classUUID = newValue;
                        setState(() {
                          selectedClass = newValue;
                        });
                        print(this._user.toJson());
                      },
                      isExpanded: true,
                      elevation: 16,
                      hint: Text("Classe de l'élève"),
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
                            if (_createFormKey.currentState.validate()) {
                              _createFormKey.currentState.save();
                              this._save(context);
                            }
                          },
                          color: Colors.lightBlueAccent,
                          child: Text('Enregistrer',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
