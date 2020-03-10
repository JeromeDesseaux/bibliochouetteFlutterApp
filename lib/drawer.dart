import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";



class BibDrawer extends StatelessWidget{

  final user;

  BibDrawer({Key key, @required this.user}) : super(key: key);

  @override
  Widget build(context) {
    return new Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: new Container(
                  child: new Column(
                    children: <Widget>[
                      new CircleAvatar(
                        radius: 50.0,
                        backgroundImage: new AssetImage("assets/images/logo.png"),
                        backgroundColor: Colors.white,
                      ),
                      new Text(
                        this.user.email,
                        style: new TextStyle(
                          fontFamily: "Dekko",
                          fontStyle: FontStyle.normal,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        )
                      )
                    ],
                  ),
                ),
                decoration: BoxDecoration(
                  
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage("assets/images/drawer.jpeg")
                  ),
                  color: Colors.white30,
                ),
              ),
              // ListTile(
              //   title: Text("Bibliothèque"),
              //   onTap: () {
              //     print("Go to biblio");
              //   },
              // ),
              ListTile(
                title: new Row(
                  children: <Widget>[
                    new Padding(
                      padding: EdgeInsets.all(5.0),
                      child: new Icon(
                        Icons.person,
                        color: Colors.grey,
                      ),
                    ),
                    new Text("Mes utilisateurs"),
                  ],
                ), 
                
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context,"/users");
                  // Navigator.of(context).pushNamedAndRemoveUntil('/users', (Route<dynamic> route) => false);
                },
              ),
              ListTile(
                title: new Row(
                  children: <Widget>[
                    new Padding(
                      padding: EdgeInsets.all(5.0),
                      child: new Icon(
                        Icons.send,
                        color: Colors.grey,
                      ),
                    ),
                    new Text("Suivi des emprunts"),
                  ],
                ), 
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context,"/loans");
                  // Navigator.of(context).pushNamedAndRemoveUntil('/users', (Route<dynamic> route) => false);
                },
              ),
              ListTile(
                title: new Row(
                  children: <Widget>[
                    new Padding(
                      padding: EdgeInsets.all(5.0),
                      child: new Icon(
                        Icons.bookmark,
                        color: Colors.grey,
                      ),
                    ),
                    new Text("Gérer mes groupes"),
                  ],
                ), 
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context,"/classes");
                  // Navigator.of(context).pushNamedAndRemoveUntil('/users', (Route<dynamic> route) => false);
                },
              ),
              ListTile(
                title: new Row(
                  children: <Widget>[
                    new Padding(
                      padding: EdgeInsets.all(5.0),
                      child: new Icon(
                        Icons.exit_to_app,
                        color: Colors.grey,
                      ),
                    ),
                    new Text("Déconnexion"),
                  ],
                ), 
                onTap: () {
                  FirebaseAuth.instance.signOut();
                },
              ),
              
            ],
          ),
        );
  }
}