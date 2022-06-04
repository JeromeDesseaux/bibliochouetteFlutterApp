import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import './book_details.dart';
import './book_create.dart';
import '../models/book.dart';
import "../drawer.dart";
import '../models/loan.dart';
import '../MyBullet.dart';
import "../loading.dart";

class BookListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _BookListPageState();
  }
}

class _BookListPageState extends State<BookListPage> {
  User _user;
  TextEditingController controller = new TextEditingController();
  String filter;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        filter = controller.text;
      });
    });
    setState(() {
      _user = FirebaseAuth.instance.currentUser;
    });
  }

  void _addBook() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => new BookCreatePage(uid: this._user.uid),
      ),
    );
  }

  void _showDeleteDialog(bookUID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text("Êtes-vous sûr?"),
          content: new Text("Cette action est irréversible."),
          actions: <Widget>[
            new TextButton(
              child: new Text('Annuler'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            new TextButton(
              child: new Text("Supprimer"),
              onPressed: () {
                FirebaseDatabase.instance
                    .ref()
                    .child("books")
                    .child(this._user.uid)
                    .child(bookUID)
                    .remove();
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Widget _manageDisplay() {
    if (_user != null) {
      return new StreamBuilder<Event>(
        stream: FirebaseDatabase.instance
            .ref()
            .child("books")
            .child(_user.uid)
            .onValue,
        builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
          if (!snapshot.hasData) return LoadingScreen();

          Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
          List<Book> data = new List<Book>();
          if (map != null) {
            map.forEach((i, v) {
              var book = Book.fromJson(new Map<String, dynamic>.from(v), i);
              data.add(book);
              data.sort((a, b) => a.title.compareTo(b.title));
            });
            if (this.filter != null)
              data = data
                  .where((book) => book.title
                      .toLowerCase()
                      .contains(this.filter.toLowerCase()))
                  .toList();
          }
          int bookCount = data.length;
          return new StreamBuilder<Event>(
            stream: FirebaseDatabase.instance
                .ref()
                .child("loans")
                .child(_user.uid)
                .orderByChild("returnDateValidated")
                .equalTo(null)
                .onValue,
            builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
              if (!snapshot.hasData) return LoadingScreen();
              Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
              List<String> loansISBN = [];
              List<Loan> loans = [];
              if (map != null) {
                map.forEach((i, v) {
                  var loan = Loan.fromJson(new Map<String, dynamic>.from(v), i);
                  loansISBN.add(loan.book.uid);
                  loans.add(loan);
                });
              }

              return new Column(
                children: <Widget>[
                  new Container(
                    margin: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 10.0),
                    child: TextFormField(
                      decoration: new InputDecoration(
                          labelText: "Rechercher un titre",
                          prefixIcon: Icon(Icons.search)),
                      controller: controller,
                    ),
                  ),
                  new Expanded(
                    child: new ListView.builder(
                      itemCount: bookCount,
                      itemBuilder: (_, int index) {
                        Book book = data[index];
                        Loan loan;
                        try {
                          loan =
                              loans.firstWhere((l) => l.book.uid == book.uid);
                        } catch (e) {}

                        return new ListTile(
                            leading: new CircleAvatar(
                              backgroundImage: new NetworkImage(book.cover),
                            ),
                            title: new Text(book.title ?? '<No title>'),
                            subtitle: new Text(book.authors),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => new BookDetailsPage(
                                      book: book, uid: _user.uid, loan: loan),
                                ),
                              );
                            },
                            trailing: new Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new MyBullet(
                                  isGreen: loansISBN.contains(book.uid)
                                      ? false
                                      : true,
                                ),
                                new IconButton(
                                  icon: new Icon(Icons.delete),
                                  onPressed: () {
                                    this._showDeleteDialog(book.uid);
                                  },
                                ),
                              ],
                            ));
                      },
                    ),
                  )
                ],
              );
            },
          );
        },
      );
    } else {
      return new Text("Aucun utilisateur connecté. Problème réseau?");
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Bibliochouette"),
      ),
      body: _manageDisplay(),
      drawer: new BibDrawer(user: this._user),
      floatingActionButton: new FloatingActionButton(
          elevation: 0.0,
          child: new Icon(Icons.add),
          backgroundColor: new Color(0xFFE57373),
          onPressed: () {
            _addBook();
          }),
    );
  }
}
