import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import "dart:async";
import './register.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _LoginPageState();
  }
}
  
  

class _LoginPageState extends State<LoginPage> {

  final formKey = new GlobalKey<FormState>();

  String _email;
  String _password;
  String _error = "";
  TextEditingController controller = new TextEditingController();

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
        controller: controller,
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
            child: Text('Se connecter', style: TextStyle(color: Colors.white)),
          ),
        ),
      );

      final forgotLabel = FlatButton(
        child: Text(
          'Mot de passe oublié ?',
          style: TextStyle(color: Colors.black54),
        ),
        onPressed: () {
          final FirebaseAuth _auth = FirebaseAuth.instance;
          print(this.controller.text);
          if(this.controller.text!=""){
            print('sending');
            _auth.sendPasswordResetEmail(email: this.controller.text);
          }else{
            setState(() { _error = "L'email doit être renseigné pour envoyer le mail de récupération."; });
          }

        },
      );

      final createAccount = FlatButton(
        child: Text(
          'Créer un compte',
          style: TextStyle(color: Colors.black87),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => new RegisterPage(),
            ),
          );
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
              SizedBox(height: 24.0),
              forgotLabel,
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
      await _auth.signInWithEmailAndPassword(email: _email.trim(), password: _password).catchError((error) {
        setState(() { _error = "Email ou mot de passe invalide"; });
      }).then((authResult) {
        user = authResult.user;
      });
    }
    return user;
  }
}