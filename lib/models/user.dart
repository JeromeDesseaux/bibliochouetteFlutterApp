import 'package:firebase_database/firebase_database.dart';
import 'package:gestion_bibliotheque/models/class.dart';
import 'package:gestion_bibliotheque/models/loan.dart';

class User {
  String uid = "";
  String username;
  String classUUID = "";
  // update/create date?
  // User type?

  User(this.username);

  User.fromJson(Map<String, dynamic> json, String _uid)
      : uid = _uid,
        username = json["username"],
        classUUID = json["class"] != null ? json["class"] : "";

  Map<String, dynamic> toJson({bool withUID: false}) {
    return {
      'uid': withUID ? this.uid : null,
      'username': this.username,
      'class': this.classUUID,
    };
  }

  Class getClass(userUUID) {
    FirebaseDatabase.instance
        .ref()
        .child("classes")
        .child(userUUID)
        .child(this.classUUID)
        .once()
        .then((result) {
      Map<dynamic, dynamic> map = result.snapshot.value;
      if (map != null) {
        map.forEach((key, json) {
          Class c = Class.fromJson(new Map<String, dynamic>.from(json), key);
          return c;
        });
      }
      return null;
    });
    return null;
  }

  List<Loan> getLoans(List<Loan> allLoans) {
    return allLoans.where((loan) => loan.user.uid == this.uid).toList();
  }
}
