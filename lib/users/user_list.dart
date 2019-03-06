import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user.dart';
import "./user_create.dart";
import "./user_details.dart";
import "../models/loan.dart";
import "../MyBullet.dart";
import "../loading.dart";

class UserListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _UserListPageState();
  }
}
  
  

class _UserListPageState extends State<UserListPage> {

  FirebaseUser _user;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        _user = user;
      });
    });
  }

  void _addUser() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => new UserCreatePage(uid: this._user.uid),
      ),
    );
  }

  void _showDeleteDialog(userUID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text("Êtes-vous sûr?"),
          content: new Text("Cette action est irréversible."),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Annuler'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            new FlatButton(
              child: new Text("Supprimer"),
              onPressed: () {
                // print("DELETE $userUID");
                FirebaseDatabase.instance.reference().child("users").child(this._user.uid).child(userUID).remove();
                Navigator.pop(context);
              },
            )
          ],

        );
      },
    );  
  }

  Widget _manageDisplay() {
    if(_user != null){
      return new StreamBuilder<Event>(
          stream: FirebaseDatabase.instance.reference().child("users").child(_user.uid).onValue,
          builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {

            if (!snapshot.hasData) return LoadingScreen();

            Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
            var data = [];
            if(map != null) {
              map.forEach((i, v) {
                var user = User.fromJson(new Map<String, dynamic>.from(v), i);
                data.add(user);
                data.sort((a,b) => a.username.compareTo(b.username));
              });
            }
            int bookCount = data.length;
            return StreamBuilder<Event>(
              stream: FirebaseDatabase.instance.reference().child("loans").child(_user.uid).onValue,
              builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
                if (!snapshot.hasData) return LoadingScreen();
                Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
                List<Loan> loans = [];
                if(map != null) {
                  map.forEach((i, v) {
                    Loan loan = Loan.fromJson(new Map<String, dynamic>.from(v), i);
                    loans.add(loan);
                  });
                }

                return new ListView.builder(
                  itemCount: bookCount,
                  itemBuilder: (_, int index) {
                    User user = data[index];
                    List<Loan> userLoans;
                    List<Loan> currentLoans;
                    try{
                      userLoans = loans.where((loan) => loan.user.uid == user.uid).toList(); 
                      currentLoans = userLoans.where((loan) => loan.returnDateValidated==null).toList();
                    }catch(e){}
                    return new ListTile(
                      // leading: new CircleAvatar(
                      //   backgroundImage: new NetworkImage(book.cover),
                      // ),
                      title: new Text(user.username?? '<No username>'),
                      subtitle: new Text(
                        userLoans.length==0?"Aucun emprunt":userLoans.length.toString()+" emprunts dont "+currentLoans.length.toString()+" en attente."
                        //book.authors
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => new UserDetailsPage(user: user, fuser: _user, loans: userLoans),
                          ),
                        );
                      },
                      trailing: new Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new MyBullet(
                            isGreen: currentLoans.length==0,
                          ),
                          new IconButton(
                            icon: new Icon(Icons.delete),
                            onPressed: () {
                              this._showDeleteDialog(user.uid);
                            },
                          ),
                        ],
                      )
                    );
                  },
                );
              },
            ); 
          },
        );
    }else{
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
          child: new Icon(Icons.person_add),
          backgroundColor: new Color(0xFFE57373),
          onPressed: (){_addUser();}
        ),
      );
    }
}