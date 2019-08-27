class Secret {
  final String awsSecret;
  final String awsID;
  final String awsPartner;
  Secret({this.awsSecret = "", this.awsID = "", this.awsPartner = ""});
  factory Secret.fromJson(Map<String, dynamic> jsonMap) {
    return new Secret(
        awsSecret: jsonMap["aws_secret"],
        awsID: jsonMap["aws_id"],
        awsPartner: jsonMap["aws_partner"]);
  }
}
