class Class {
  String uid = "";
  String classname;
  // update/create date?
  // User type?

  Class(
    this.classname,
    this.uid
  );

  Class.fromJson(Map<String, dynamic> json, String uid):
    uid=uid,
    classname=json["classname"];

  Map<String, dynamic> toJson({bool withUID: false}) {
    return {
      'uid': withUID?this.uid:null,
      'classname': this.classname
    };
  }
}