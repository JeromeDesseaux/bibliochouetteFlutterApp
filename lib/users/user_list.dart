import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gestion_bibliotheque/components/empty_data.dart';
import 'package:gestion_bibliotheque/components/user_card.dart';
import 'package:gestion_bibliotheque/models/class.dart';
import 'package:gestion_bibliotheque/utils/classes.dart';
import '../models/user.dart';
import "./user_create.dart";
import "./user_details.dart";
import "../models/loan.dart";
import "../MyBullet.dart";
import "../loading.dart";
import 'package:grouped_list/grouped_list.dart';

class UserListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _UserListPageState();
  }
}
  
  

class _UserListPageState extends State<UserListPage> {

  FirebaseUser _user;
  List<Class> classes = new List<Class>();
  List<User> users = new List<User>();
  List<Loan> loans = new List<Loan>();

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        _user = user;
      });
      this._getClasses(user);
      this._getUsers(user);
      this._getLoans(user);
    });
  }

  void _getClasses(user) async {
    List<Class> classes = new List<Class>();
    await getClasses(user.uid).then((c) => classes = c);
    setState(() {
      this.classes = classes;
    });
  }

  void _getUsers(user) async {
    List<User> users = new List<User>();
    await getUsers(user.uid).then((c) => users = c);
    setState(() {
      this.users = users;
    });
  }

  void _getLoans(user) async {
    List<Loan> loans = new List<Loan>();
    await getLoans(user.uid).then((c) => loans = c);
    setState(() {
      this.loans = loans;
    });
  }

  void refreshData() {
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        _user = user;
      });
      this._getClasses(user);
      this._getUsers(user);
      this._getLoans(user);
    });
  }

  void _addUser() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => new UserCreatePage(uid: this._user.uid),
      ),
    ).then((onValue) => onValue?this.refreshData():null);
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
                Navigator.pop(context,true);
                this.refreshData();
              },
            )
          ],

        );
      },
    );
  }

  List<Widget> _buildTiles() {
    List<Widget> expansionsTiles = [];
    if(this.users != null && this.users.length > 0 ) {
      this.classes.forEach((classe) {
        List<Widget> children = new List<Widget>();
        var users = this.users.where((user) => user.classUUID == classe.uid || user.getClass(_user.uid) == null);
        var lu = users.length;
        users.forEach((user) {
          children.add(UserCard(loans: this.loans, user: user, onDelete: this._showDeleteDialog,));
          // children.add(ListTile(title: Text(user.username)));
        });
        var w = ExpansionTile(
          key: PageStorageKey<Class>(classe),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                classe.classname,
                style: TextStyle(
                  color: Colors.blueGrey[700],
                  fontSize: 18,
                  fontWeight: FontWeight.w300
                ),
              ),
              Text(
                lu<=1?"$lu élève":"$lu élèves",
                style: TextStyle(
                  color: Colors.blue[400],
                  fontSize: 13,
                  fontWeight: FontWeight.w200
                ),
              )
            ]
          ),
          children: children.toList(),
        );
        expansionsTiles.add(w);
      });
      return expansionsTiles;
    }
    return null;
  }

  Widget _manageDisplay() {
    if(users.length > 0){
      return new Container( 
              padding: const EdgeInsets.all(10.0),
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: this._buildTiles()
              )
            );
    }else{
      return new EmptyData(
        title: "Oopps! Aucun utilisateur créé pour le moment 😓",
        subtitle: "Cliquez sur le bouton ci-dessous pour en ajouter un."
      );
    }
  }

  @override
    Widget build(BuildContext context) {
      print(classes);
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Bibliochouette"),
        ),
        body: _manageDisplay(),
        backgroundColor: Color(0xfff3f2f8),
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