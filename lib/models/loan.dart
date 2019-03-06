import "./book.dart";
import "./user.dart";

class Loan {
  String uid;
  User user;
  Book book;
  int loanDate;
  int expectedReturnDate;
  int returnDateValidated;

  Loan(
    this.book,
    this.user,
    this.loanDate,
    this.expectedReturnDate
  );

  returnBook() {
    this.returnDateValidated = DateTime.now().millisecondsSinceEpoch;
  }

  Loan.fromJson(Map<String, dynamic> json, String _uid):
    uid=_uid,
    user = User.fromJson(new Map<String, dynamic>.from(json['user']), json['user']['uid']),
    book = Book.fromJson(new Map<String, dynamic>.from(json['book']), json['book']['uid']),
    loanDate = json['loanDate'],
    expectedReturnDate = json['expectedReturnDate'],
    returnDateValidated = json['returnDateValidated']!=null?json['returnDateValidated']:null;

  Map<String, dynamic> toJson() =>
    {
      'book': this.book.toJson(withUID: true),
      'user': this.user.toJson(withUID: true),
      'loanDate': this.loanDate,
      'expectedReturnDate': this.expectedReturnDate,
      'returnDateValidated': this.returnDateValidated,
    };
}