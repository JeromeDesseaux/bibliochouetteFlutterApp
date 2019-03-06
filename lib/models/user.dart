class User {
  String uid = "";
  String username;
  // update/create date?
  // User type?

  User(
    this.username
  );

  User.fromJson(Map<String, dynamic> json, String _uid):
    uid=_uid,
    username=json["username"];

  Map<String, dynamic> toJson({bool withUID: false}) {
    return {
      'uid': withUID?this.uid:null,
      'username': this.username
    };
  }
}