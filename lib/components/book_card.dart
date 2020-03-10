import 'package:flutter/material.dart';

import '../models/book.dart';

class BookCard extends StatefulWidget {
  final Book book;

  BookCard(this.book);

  @override
  _BookCardState createState() => _BookCardState(book);
}

class _BookCardState extends State<BookCard> {
   Book book;

   _BookCardState(this.book);

  @override
  Widget build(BuildContext context) {
    return Text(widget.book.title);
  }
}