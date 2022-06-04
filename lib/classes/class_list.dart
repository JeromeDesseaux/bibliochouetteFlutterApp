import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gestion_bibliotheque/classes/class_create.dart';
import 'package:gestion_bibliotheque/components/empty_data.dart';
import 'package:gestion_bibliotheque/models/class.dart';
import '../models/class.dart';
// import "./user_create.dart";
// import "./user_details.dart";
import "../loading.dart";

class ClassListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ClassListPageState();
  }
}

class _ClassListPageState extends State<ClassListPage> {
  User _user;

  @override
  void initState() {
    super.initState();
    setState(() {
      _user = FirebaseAuth.instance.currentUser;
    });
  }

  void _addClass() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => new ClassCreatePage(uid: this._user.uid),
      ),
    );
  }

  void _showDeleteDialog(classUUID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text("Êtes-vous sûr?"),
          content: new Text("Cette action est irréversible."),
          actions: <Widget>[
            new TextButton(
              child: new Text('Annuler'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            new TextButton(
              child: new Text("Supprimer"),
              onPressed: () {
                // print("DELETE $userUID");
                FirebaseDatabase.instance
                    .ref()
                    .child("classes")
                    .child(this._user.uid)
                    .child(classUUID)
                    .remove();
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
            .child("classes")
            .child(_user.uid)
            .onValue,
        builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
          if (!snapshot.hasData) return LoadingScreen();

          Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
          var data = [];
          if (map != null) {
            map.forEach((i, v) {
              var myclass = Class.fromJson(new Map<String, dynamic>.from(v), i);
              data.add(myclass);
              data.sort((a, b) => a.classname.compareTo(b.classname));
            });
          }
          int classesCount = data.length;
          if (classesCount > 0) {
            return new ListView.builder(
              itemCount: classesCount,
              itemBuilder: (_, int index) {
                Class myclass = data[index];
                return new ListTile(
                    // leading: new CircleAvatar(
                    //   backgroundImage: new NetworkImage(book.cover),
                    // ),
                    title: new Text(myclass.classname ?? '<Aucun nom>'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            // builder: (context) => new UserDetailsPage(user: user, fuser: _user, loans: userLoans),
                            ),
                      );
                    },
                    trailing: new Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // new MyBullet(
                        //   isGreen: currentLoans.length==0,
                        // ),
                        new IconButton(
                          icon: new Icon(Icons.delete),
                          onPressed: () {
                            this._showDeleteDialog(myclass.uid);
                          },
                        ),
                      ],
                    ));
              },
            );
          } else {
            return new EmptyData(
              title: "Oopps! Aucun groupe créé pour le moment 😓",
              subtitle: "Cliquez sur le bouton ci-dessous pour en ajouter un.",
            );
          }
          // return StreamBuilder<Event>(
          //   stream: FirebaseDatabase.instance.ref().child("loans").child(_user.uid).onValue,
          //   builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
          //     if (!snapshot.hasData) return LoadingScreen();
          //     Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
          //     List<Loan> loans = [];
          //     if(map != null) {
          //       map.forEach((i, v) {
          //         Loan loan = Loan.fromJson(new Map<String, dynamic>.from(v), i);
          //         loans.add(loan);
          //       });
          //     }

          //   },
          // );
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
        title: new Text("Bibliochouette"),
      ),
      body: _manageDisplay(),
      // drawer: new BibDrawer(user: this._user),
      floatingActionButton: new FloatingActionButton(
          elevation: 0.0,
          child: new Icon(Icons.bookmark),
          backgroundColor: new Color(0xFFE57373),
          onPressed: () {
            _addClass();
          }),
    );
  }
}
