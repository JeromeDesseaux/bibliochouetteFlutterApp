import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:xml/xml.dart' as xml;
import "models/book.dart" as book;

class AmazonRequester {
  String awsSecret;
  String awsID;
  String associateID;

  AmazonRequester(String awsSecret, String awsID, String associateID) {
    this.associateID = associateID;
    this.awsID = awsID;
    this.awsSecret = awsSecret;
  }

  String generateSignature(String stringToSign) {
    var hmac = new Hmac(sha256, this.awsSecret.codeUnits);
    Digest digest = hmac.convert(stringToSign.codeUnits);
    return base64.encode(digest.bytes);
  }

  String getFormattedDatetime() {
    return DateTime.now()
        .toUtc()
        .toString()
        .replaceAll(RegExp(r'\.\d*Z$'), 'Z')
        .replaceAll(RegExp(r'\.\d{3}'), '')
        .split(' ')
        .join('T');
  }

  String generateQueryString(String isbn) {
    String domain = "webservices.amazon.fr";
    var params = new Map<String, String>.from({
      'AWSAccessKeyId': this.awsID,
      'Service': "AWSECommerceService",
      "Operation": "ItemSearch",
      'AssociateTag': this.associateID,
      'SearchIndex': "Books",
      'ResponseGroup': "Images,ItemAttributes,Offers",
      'Keywords': isbn.replaceAll("'", " "),
      "Timestamp": getFormattedDatetime()
    });

    List<String> pairs = new List<String>();

    params
        .forEach((k, v) => {pairs.add("${k}=" + Uri.encodeComponent(v))});

    pairs = pairs..sort((a, b) => a.compareTo(b));

    String unsignedParams = pairs.join('&');

    String toSign = 'GET\n' + domain + '\n/onca/xml\n' + unsignedParams;
    String signature = Uri.encodeQueryComponent(this.generateSignature(toSign));

    String queryString = 'https://' +
        domain +
        '/onca/xml?' +
        unsignedParams +
        '&Signature=' +
        signature;

    print(queryString);

    return queryString;
  }

  Future<book.Book> getBookFromIsbn(String isbn) async {
    String query = this.generateQueryString(isbn);

    http.Response response;
    try {
      response = await http.get(query);
    } catch (e) {
      throw Exception("Impossible d'exécuter la requête");
    }

    if(response.statusCode != 200){
      throw Exception("Paramètres invalides. Vérifier les identifiants AWS.");
    }

    book.Book resBook = new book.Book();
    resBook.isbn = isbn;

    String body = response.body;
    print(body);
    var document = xml.parse(body);
    try {
      String title = document.findAllElements("Title").first.text;
      resBook.title = title;
    } catch (e) {}
    try {
      String pubDate = document.findAllElements("PublicationDate").first.text;
      RegExp regexPubDate = new RegExp(r".+?(?=-)", caseSensitive: false, multiLine: true);
      resBook.publicationYear = regexPubDate.firstMatch(pubDate)[0];
    } catch (e) {}
    try {
      String author = document.findAllElements("Author").first.text;
      resBook.authors = author;
    } catch (e) {}
    try {
      String nbOfPages = document.findAllElements("NumberOfPages").first.text;
      resBook.pageCount = nbOfPages;
    } catch (e) {}
    try {
      String imgURL = document
          .findAllElements("LargeImage")
          .first
          .findAllElements("URL")
          .first
          .text;
      resBook.setCoverUrl(imgURL);
      //resBook.cover = imgURL;
    } catch (e) {}

    return resBook;
  }
}
