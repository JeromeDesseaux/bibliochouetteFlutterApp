import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:gestion_bibliotheque/classes/class_list.dart';
import "login_page.dart";
import "./books/book_list.dart";
import "users/user_list.dart";
import 'package:firebase_auth/firebase_auth.dart';
import "./loans/loan_list.dart";
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final UserListPage userlist = new UserListPage();
  final ClassListPage classList = new ClassListPage();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Bibliochouette",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: _handleCurrentScreen(),
      routes: {
        "/": (context) => _handleCurrentScreen(),
        '/users': (context) => userlist,
        "/loans": (context) => new LoanListPage(),
        "/classes": (context) => classList,
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate
      ],
      supportedLocales: [new Locale("fr", "FR")],
    );
  }

  Widget _handleCurrentScreen() {
    try {
      return new StreamBuilder<User>(
          stream: FirebaseAuth.instance.onAuthStateChanged,
          builder: (BuildContext context, snapshot) {
            /*if (snapshot.connectionState == ConnectionState.waiting) {
            return new Text("Loading");
          } else {
            if (snapshot.hasData) {
              return new BookListPage();//new MainScreen(firestore: firestore,uuid: snapshot.data.uid);
            }
            return new LoginPage();
          }*/
            if (snapshot.hasData) {
              return new BookListPage(); //new MainScreen(firestore: firestore,uuid: snapshot.data.uid);
            } else {
              return new LoginPage();
            }
          });
    } catch (Exception) {
      return new LoginPage();
    }
  }
}
