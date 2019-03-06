import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:firebase_database/firebase_database.dart';
import '../models/user.dart';
import "../models/book.dart";
import './loan_date.dart';

class LoanUserPage extends StatelessWidget {

  final FirebaseUser user;
  final Book book;

  // In the constructor, require a Todo
  LoanUserPage({Key key, @required this.user,  @required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("BiblioChouette"),
          // actions: <Widget>[
          //   IconButton(
          //       icon: Icon(Icons.camera),
          //       onPressed: () {
          //         print("scan book");
          //       },
          //     ),
          // ],
        ),
        body: _manageDisplay(),
        // drawer: new BibDrawer(user: this._user),
        // floatingActionButton: new FloatingActionButton(
        //   elevation: 0.0,
        //   child: new Icon(Icons.add),
        //   backgroundColor: new Color(0xFFE57373),
        //   //onPressed: (){_addLoan();}
        // ),
      );
  }

  // getAvailableBooks() {
  //   var loans = FirebaseDatabase.instance.reference().child("loans").child(user.uid).orderByChild("returnDateValidated").equalTo(null).onValue;
  //   var books = FirebaseDatabase.instance.reference().child("books").child(user.uid);
  // }

  Widget _manageDisplay() {
    if(user != null){
      return new StreamBuilder<Event>(
          stream: FirebaseDatabase.instance.reference().child("users").child(user.uid).orderByChild("username").onValue,
          builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
            if (!snapshot.hasData) return const Text('No data provided');
            Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
            List<User> users = [];
            int userCount = 0;
            if(map!=null){
              map.forEach((i, v) {
                var user = User.fromJson(new Map<String, dynamic>.from(v), i);
                users.add(user);
                users.sort((a,b) => a.username.compareTo(b.username));
              });
              userCount = users.length;
            }

            if(userCount==0){
              return new ListView(children: <Widget>[
                Text("Aucun utilisateur à qui prêter le livre. Veuillez d'abord en ajouter un.")
              ]);
            }
            
            
            return new ListView.builder(
              itemCount: userCount,
              itemBuilder: (_, int index) {
                User user = users[index];
                return new ListTile(
                  // leading: new CircleAvatar(
                  //   backgroundImage: new NetworkImage(book.cover),
                  // ),
                  title: new Text(user.username?? '<Sans nom>'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => new LoanDatePage(fuser: this.user, book: this.book, loanUser: user),
                      ),
                    );
                  },
                  // trailing: new IconButton(
                  //   icon: new Icon(Icons.input),
                  //   onPressed: () {
                  //     this._showDeleteDialog(loan);
                  //   },
                  // )
                );
              },
            );
          },
        );
    }else{
      return new Text("FETCHING DATA");
    }
  }


}