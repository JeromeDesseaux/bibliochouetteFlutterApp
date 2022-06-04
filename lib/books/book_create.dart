import 'dart:io';

import 'package:barcode_scan2/barcode_scan2.dart';
import "package:flutter/material.dart";
import 'package:gestion_bibliotheque/models/book.dart';
//import "package:http/http.dart" as http;
//import "dart:convert";
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import "package:flutter/services.dart";
import 'package:gestion_bibliotheque/security/secret_loader.dart';
import 'package:gestion_bibliotheque/security/secret.dart';
import 'package:gestion_bibliotheque/amazon_api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
//import 'package:xml/xml.dart' as xml;

class BookCreatePage extends StatefulWidget {
  final String uid;

  BookCreatePage({Key key, @required this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _BookCreatePageState(this.uid);
  }
}

class _BookCreatePageState extends State<BookCreatePage> {
  var book;
  var uuid = new Uuid();
  //final _searchFormKey = GlobalKey<FormState>();
  final _createFormKey = GlobalKey<FormState>();

  var _titleController = TextEditingController();
  var _searchController = TextEditingController();
  var _authorController = TextEditingController();
  var _descriptionController = TextEditingController();
  var _pageCountController = TextEditingController();
  var _publicationYearController = TextEditingController();

  // String _title;
  // String _author;
  Book _book;
  String _defaultCover = "";
  String uid;
  String barcode = "";
  bool _loading = false;
  Secret secrets;

  _BookCreatePageState(String uid) {
    this.uid = uid;
    this._defaultCover =
        "https://d4804za1f1gw.cloudfront.net/wp-content/uploads/sites/30/2018/03/30075855/Rare-Books-Thumbnail-248x300.jpg";
    this._pageCountController.text = "0";
    this._publicationYearController.text = new DateTime.now().year.toString();
    SecretLoader(secretPath: "assets/secrets.json").load().then((secret) {
      this.secrets = secret;
    });
    //this._searchBookByISBN("9782747045223");
  }

  Widget get _loadingView {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }

  Widget _pageToDisplay(BuildContext context) {
    if (this._loading) {
      return _loadingView;
    } else {
      return _homeView(context);
    }
  }

  Future getImageFromCamera() async {
    // for camera
    ImagePicker picker = new ImagePicker();
    var image = await picker.pickImage(
        source: ImageSource.camera, imageQuality: 70, maxHeight: 350);
    var file = File(image.path);
    setState(() {
      _book.setCoverFile(file);
      //_book.imageCover = image;
    });
  }

  ImageProvider getImageComponent() {
    if (this._book.cover != null &&
        this._book.cover != "" &&
        this._book.cover != this._defaultCover) {
      return new Image.network(this._book.cover).image;
    } else if (_book.imageCover != null) {
      return Image.file(_book.imageCover).image;
    }
    return new Image.network(this._defaultCover).image;
  }

  Widget _homeView(BuildContext context) {
    return new ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(16.0),
          child: new Form(
            key: _createFormKey,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Container(
                  //constraints: new BoxConstraints.expand(height: 190.0, width: 130.0),
                  constraints: new BoxConstraints.expand(height: 190.0),
                  padding:
                      new EdgeInsets.only(left: 16.0, bottom: 8.0, right: 16.0),
                  alignment: Alignment.center,
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                          /*image: new Image.network(
                          _book == null ? _defaultCover : _book.cover,
                          fit: BoxFit.contain,
                          height: 142.0,
                          width: 142.0,
                      ).image,*/
                          image: getImageComponent(),
                          fit: BoxFit.fitHeight)),
                  child: new Stack(
                    children: <Widget>[
                      new IconButton(
                        icon: new Icon(
                          Icons.add_a_photo,
                          size: 30.0,
                          color: Colors.white,
                        ),
                        onPressed: this.getImageFromCamera,
                        color: Colors.white,
                      ),
                      /*new IconTheme(
                        data: new IconThemeData(
                          color: Colors.white
                        ),
                        child: new Icon(Icons.camera_enhance, size: 30.0),
                      )*/
                    ],
                  ),
                ),
                /*new Image.network(
                  _book == null ? _defaultCover : _book.cover,
                  fit: BoxFit.contain,
                  height: 142.0,
                  width: 142.0,
                ),*/
                new TextFormField(
                  controller: _titleController,
                  onSaved: (value) => this.setState(() {
                    this._book.title = value;
                  }),
                  // initialValue: _book.title,
                  decoration: new InputDecoration(labelText: "Titre"),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Merci d'indiquer le titre du livre";
                    }
                    return null;
                  },
                ),
                new TextFormField(
                  controller: _authorController,
                  onSaved: (value) => this.setState(() {
                    this._book.authors = value;
                  }),
                  decoration: new InputDecoration(labelText: "Auteur"),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Merci d'indiquer le l'auteur du livre";
                    }
                    return null;
                  },
                ),
                new TextFormField(
                  controller: _pageCountController,
                  onSaved: (value) => this.setState(() {
                    this._book.pageCount = value;
                  }),
                  keyboardType: TextInputType.number,
                  // initialValue: "0",
                  decoration: new InputDecoration(labelText: "Nombre de pages"),
                ),
                new TextFormField(
                  controller: _publicationYearController,
                  onSaved: (value) => this.setState(() {
                    this._book.publicationYear = value;
                  }),
                  keyboardType: TextInputType.number,
                  // initialValue: new DateTime.now().year.toString(),
                  decoration:
                      new InputDecoration(labelText: "Année de publication"),
                ),
                new TextFormField(
                  controller: _descriptionController,
                  onSaved: (value) => this.setState(() {
                    this._book.description = value;
                  }),
                  maxLines: 5,
                  decoration: new InputDecoration(labelText: "Présentation"),
                ),
                SizedBox(height: 24.0),
                Material(
                  borderRadius: BorderRadius.circular(0.0),
                  shadowColor: Colors.lightBlueAccent.shade100,
                  elevation: 0.0,
                  child: MaterialButton(
                    minWidth: 200.0,
                    height: 42.0,
                    onPressed: () {
                      this._save();
                      // handleSignInEmail();
                    },
                    color: Colors.lightBlueAccent,
                    child: Text('Enregistrer',
                        style: TextStyle(color: Colors.white, fontSize: 18.0)),
                  ),
                ),
                // new RaisedButton(
                //   child: new Text("Enregister"),
                //   onPressed: () {
                //     if(_createFormKey.currentState.validate()){
                //       _createFormKey.currentState.save();
                //       this._save();r
                //     }
                //   },
                // )
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    this._book = new Book();
  }

  void _searchBookByISBN(isbn) async {
    // String url = "https://www.googleapis.com/books/v1/volumes?q=isbn$isbn";
    //String url = "https://www.goodreads.com/book/isbn/$isbn?key=GS7pbjfCClZs0Ho3RNVjkg";
    AmazonRequester awsRequester = new AmazonRequester(
        this.secrets.awsSecret, this.secrets.awsID, this.secrets.awsPartner);

    setState(() {
      _loading = true;
    });

    Book b;

    try {
      b = await awsRequester.getBookFromIsbn(isbn);
    } catch (e) {
      this._showAlert(context,
          message: "Requête impossible. Vérifiez votre connexion réseau.");
      //b = new Book();
      //await b.fromAmazonData(isbn);
    }

    // print(url);
    //var response = await http.read(url).timeout(const Duration(seconds: 5));
    // var data = jsonDecode(response.toString());
    // print(data);
    try {
      //var storeDocument = xml.parse(response);
      //print(storeDocument.findAllElements('title').first.text);
      // Book b = Book.fromRequestData(storeDocument);

      if (b.title != null && b.title != "") {
        _titleController.text = b.title;
        _authorController.text = b.authors;
        _descriptionController.text = b.description;
        _pageCountController.text = b.pageCount;
        _publicationYearController.text = b.publicationYear;
        setState(() {
          _book = b;
        });
      } else {
        this._showAlert(context,
            message: "Aucune référence associée à cet ISBN.");
      }
    } catch (e) {
      this._showAlert(context,
          message: "Aucune référence associée à cet ISBN.");
      //print(e.toString());
    } finally {
      setState(() {
        _loading = false;
      });
    }

    // Book b = Book.fromRequestData(data);
  }

  // void _searchBook(title, author) async{
  //   String url = "https://www.googleapis.com/books/v1/volumes?q=inauthor:$author+intitle:$title";
  //   print(url);
  //   //var response = await http.read(url).timeout(const Duration(seconds: 5));
  //   //var data = jsonDecode(response.toString());
  //   //Book b = Book.fromRequestData(data);
  //   Book b;
  //   if(b != null){
  //     _titleController.text = b.title;
  //     _authorController.text = b.authors;
  //     _descriptionController.text = b.description;
  //     _pageCountController.text = b.pageCount;
  //     _publicationYearController.text = b.publicationYear;
  //     setState(() {
  //       _book = b;
  //     });
  //     print("FOUND BOOK... ${_book.title} de ${_book.authors}. Histoire : ${_book.description}");
  //   }else{
  //     print("NO BOOK FOUND!");
  //   }

  // }

  void _save() async {
    final form = _createFormKey.currentState;

    if (form.validate()) {
      setState(() {
        _loading = true;
      });
      form.save();
      if (this._book.imageCover != null) {
        // sauvegarde sur Firebase storage
        try {
          FirebaseStorage _storage = FirebaseStorage.instance;
          Reference reference =
              _storage.ref().child("covers").child(this.uid).child(uuid.v1());
          UploadTask uploadTask = reference.putFile(this._book.imageCover);
          uploadTask.whenComplete(
              () async => this._book.cover = await reference.getDownloadURL());
        } catch (e) {
          setState(() {
            _loading = false;
          });
          this._showAlert(context,
              message:
                  "Impossible de sauvegarder l'image de couverture. Vérifiez votre connexion réseau.");
          return;
        }
      }
      FirebaseDatabase.instance
          .ref()
          .child("books")
          .child(this.uid)
          .push()
          .set(this._book.toJson());
      setState(() {
        _loading = false;
      });
      Navigator.pop(context);
    }
  }

  Future _scan() async {
    try {
      ScanResult barcode = await BarcodeScanner.scan();
      this._searchBookByISBN(barcode);
      setState(() => this.barcode = barcode.rawContent);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  void _showAlert(BuildContext context,
      {String message: "Une erreur est survenue."}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Erreur"),
              content: Text(message),
            ));
  }

  // void _showDialog(context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SimpleDialog(
  //         title: new Text("Recherche de livre"),
  //         children: <Widget>[
  //           new Text("Recherchez un livre par titre et auteur"),
  //           new Form(
  //             key: _searchFormKey,
  //             child: new Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: <Widget>[
  //                 new TextFormField(
  //                   onSaved: (value) => _title=value,
  //                   decoration: new InputDecoration(
  //                     labelText: "Titre"
  //                   ),
  //                   validator: (value) {
  //                     if(value.isEmpty)
  //                       return "Merci d'indiquer le titre du livre";
  //                   },
  //                 ),
  //                 new TextFormField(
  //                   onSaved: (value) => _author=value,
  //                   decoration: new InputDecoration(
  //                     labelText: "Auteur"
  //                   ),
  //                   validator: (value) {
  //                     if(value.isEmpty)
  //                       return "Merci d'indiquer le l'auteur du livre";
  //                   },
  //                 ),
  //                 new Padding(
  //                   padding: const EdgeInsets.symmetric(vertical: 16.0),
  //                   child: new RaisedButton(
  //                     child: new Text("Rechercher"),
  //                     onPressed: () {
  //                       if(_searchFormKey.currentState.validate()){
  //                         _searchFormKey.currentState.save();
  //                         this._searchBook(_title, _author);
  //                       }
  //                     },
  //                   )
  //                 )
  //               ],
  //             ),

  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _search(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Recherche manuelle"),
              content: new Stack(
                children: <Widget>[
                  new TextField(
                    controller: _searchController,
                    decoration: new InputDecoration(
                        hintText: "Indiquez un titre ou ISBN."),
                  )
                ],
              ),
              actions: <Widget>[
                new TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: new Text("Fermer")),
                new TextButton(
                    onPressed: () {
                      if (this._searchController.text != null &&
                          this._searchController.text != "") {
                        Navigator.of(context).pop();
                        this._searchBookByISBN(this._searchController.text);
                      }
                    },
                    child: new Text("Rechercher"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Créer un livre"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                this._search(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.camera),
              onPressed: () {
                this._scan();
                //print("scan book");
              },
            ),
            // action button
            // IconButton(
            //   icon: Icon(Icons.search),
            //   onPressed: () {
            //     // this._searchBook("Nymphéas Noirs", "Michel Bussi");

            //     _showDialog(context);
            //     // print("classic search");
            //   },
            // ),
          ],
        ),
        body: _pageToDisplay(context));
  }
}
