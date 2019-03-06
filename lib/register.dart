import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import "dart:async";
// import "./login_page.dart";

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _RegisterPageState();
  }
}
  
  

class _RegisterPageState extends State<RegisterPage> {

  final formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _passwordConfirm;
  String _error = "";

  @override
    Widget build(BuildContext context) {

      final logo = Hero(
        tag: 'hero',
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 68.0,
          child: Image.asset('assets/images/logo.png'),
        ),
      );


      final email = TextFormField(
        keyboardType: TextInputType.emailAddress,
        onSaved: (value) => _email = value,
        validator: (value) => value.isEmpty? "L'e-mail ne peut être vide":null,
        autofocus: false,
        // initialValue: 'mon.adresse@email.com',
        decoration: InputDecoration(
          hintText: 'Email',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final password = TextFormField(
        autofocus: false,
        // initialValue: 'some password',
        obscureText: true,
        onSaved: (value) => _password = value,
        validator: (value) => value.isEmpty? "Le mot de passe ne peut être vide":null,
        decoration: InputDecoration(
          hintText: 'Mot de passe',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final passwordConfirm = TextFormField(
        autofocus: false,
        // initialValue: 'some password',
        obscureText: true,
        onSaved: (value) => _passwordConfirm = value,
        validator: (value) => value.isEmpty? "Le mot de passe ne peut être vide":null,
        decoration: InputDecoration(
          hintText: 'Confirmation du mot de passe',
          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
        ),
      );

      final loginButton = Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Material(
          borderRadius: BorderRadius.circular(30.0),
          shadowColor: Colors.lightBlueAccent.shade100,
          elevation: 5.0,
          child: MaterialButton(
            minWidth: 200.0,
            height: 42.0,
            onPressed: () {
              handleSignInEmail();
            },
            color: Colors.lightBlueAccent,
            child: Text('Créer un compte', style: TextStyle(color: Colors.white)),
          ),
        ),
      );

      final createAccount = FlatButton(
        child: Text(
          'Connexion',
          style: TextStyle(color: Colors.black87),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      );

      final loginForm = new Form(
        key: formKey,
        child: new Column(
          children: <Widget>[
            SizedBox(height: 48.0),
            email,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 8.0),
            passwordConfirm
          ],
        ),
      );

      final errorMessage = new Text(
        this._error,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontFamily: "BadScript"
        ),
      );


      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Bibliochouette"),
        ),
        body: Center(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            children: <Widget>[
              logo,
              loginForm,
              SizedBox(height: 10.0),
              errorMessage,
              SizedBox(height: 24.0),
              loginButton,
              createAccount,
            ],
          ),
        )
      );
    }

  Future<FirebaseUser> handleSignInEmail() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final form = formKey.currentState;
    FirebaseUser user;

    if(form.validate()){
      form.save();
      print(this._password);
      if(this._password==this._passwordConfirm){
        await _auth.createUserWithEmailAndPassword(email: _email.trim(), password: _password).catchError((error) {
          setState(() { _error = "Adresse email invalide"; });
        });
        Navigator.popUntil(context, ModalRoute.withName('/'));
        // await _auth.signInWithEmailAndPassword(email: _email.trim(), password: _password);
        //user.sendEmailVerification();
      }else{
        setState(() { _error = "Les deux mots de passe ne correspondent pas."; });
      }
    }
    return user;
  }
}