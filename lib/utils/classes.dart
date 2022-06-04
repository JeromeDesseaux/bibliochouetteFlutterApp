import 'package:firebase_database/firebase_database.dart';
import 'package:gestion_bibliotheque/models/class.dart';
import 'package:gestion_bibliotheque/models/loan.dart';
import 'package:gestion_bibliotheque/models/user.dart';

Future<List<Class>> getClasses(userId) async {
  List<Class> classes = [];
  await FirebaseDatabase.instance
      .ref()
      .child("classes")
      .child(userId)
      .once()
      .then((snapshot) {
    Map<dynamic, dynamic> map = snapshot.snapshot.value;
    if (map != null) {
      map.forEach((key, json) {
        Class c = Class.fromJson(new Map<String, dynamic>.from(json), key);
        classes.add(c);
      });
    }
    classes.add(new Class("Défaut", ""));
  });
  return classes;
}

Future<List<User>> getUsers(userId) async {
  List<User> classes = [];
  await FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(userId)
      .once()
      .then((snapshot) {
    Map<dynamic, dynamic> map = snapshot.snapshot.value;
    if (map != null) {
      map.forEach((key, json) {
        User c = User.fromJson(new Map<String, dynamic>.from(json), key);
        classes.add(c);
      });
    }
  });
  return classes;
}

Future<List<Loan>> getLoans(userId) async {
  List<Loan> classes = [];
  await FirebaseDatabase.instance
      .ref()
      .child("loans")
      .child(userId)
      .once()
      .then((snapshot) {
    Map<dynamic, dynamic> map = snapshot.snapshot.value;
    if (map != null) {
      map.forEach((key, json) {
        Loan c = Loan.fromJson(new Map<String, dynamic>.from(json), key);
        classes.add(c);
      });
    }
  });
  return classes;
}
