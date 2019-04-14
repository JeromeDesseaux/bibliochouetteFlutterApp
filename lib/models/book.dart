//import 'package:xml/xml.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
// import 'dart:math';
//import 'dart:async';

class Book {
  String uid = "";
  String title;
  String authors; 
  String description;
  String pageCount;
  String cover = "https://d4804za1f1gw.cloudfront.net/wp-content/uploads/sites/30/2018/03/30075855/Rare-Books-Thumbnail-248x300.jpg";
  String isbn;
  String publicationYear;
  // update/create date?
  // book type?

  Book();

  // Book(
  //   this.title, 
  //   this.authors, 
  //   this.description, 
  //   this.pageCount, 
  //   this.cover,
  //   this.isbn,
  //   this.publicationYear
  // );

  Book.fromJson(Map<String, dynamic> json, String _uid):
    uid=_uid,
    title=json['title'],
    authors=json['authors'],
    description=json['description'],
    pageCount=json['pageCount'],
    cover=json['cover'],
    isbn=json['isbn'],
    publicationYear=json['publicationYear'];

  Map<String, dynamic> toJson({bool withUID: false}){
    String tmpdesc = this.description;
    // var rng = new Random();
    if(withUID){
      tmpdesc = "";
    }
    return {
      'uid': withUID?uid:null,
      'title': title,
      'authors': authors,
      'description': tmpdesc,
      'pageCount': pageCount,
      'cover': cover,
      'isbn': isbn,
      'publicationYear': publicationYear
    };
  }

  Future<Document> getBookDocumentByISBN(String isbn) async {
  try{
    String url = "https://www.amazon.fr/s?k="+isbn;
    http.Response response = await http.get(url, headers: {
       'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36'
    });
    Document document = parser.parse(response.body);
    String bookLink = document.getElementsByClassName("s-result-list").first.getElementsByClassName("a-link-normal").first.attributes['href'];
    http.Response bookPage = await http.get('https://www.amazon.fr'+bookLink, headers: {
       'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36'
    });
    return parser.parse(bookPage.body);
  }catch(e){
    return null;
  }
}

String getTitleFromBook(Document bookPage) {
  String title = "";
  try{
    if(bookPage.getElementById('ebooksProductTitle')==null){
      title = bookPage.getElementById("productTitle").text;
    }else{
      title = bookPage.getElementById("ebooksProductTitle").text;
    }
  }catch(e){
    title = e.toString();
  }
  return title.trim();
}

String getPublicationYearFromBook(Document bookPage) {
  return "";
}

String getAuthors(Document bookPage){
  String authors;
  try{
      List<String> authorsList = new List();

      bookPage.getElementsByClassName("author").forEach((Element elem) {
        try{
          authorsList.add(elem.getElementsByClassName("contributorNameID").first.text);
        }catch(e){
          authorsList.add(elem.getElementsByClassName("a-link-normal").first.text);
        }
      });
      authors = authorsList.join(', ');
    }catch(e){}
    return authors;
}

String getImage(Document bookPage){
  Element cover;
  String coverLink;
  try{
    if(bookPage.getElementById("ebooksImgBlkFront")!=null){
      cover = bookPage.getElementById("ebooksImgBlkFront");
    }else{
      cover = bookPage.getElementById("imgBlkFront");
    }
  }catch(e){
    coverLink = "https://d4804za1f1gw.cloudfront.net/wp-content/uploads/sites/30/2018/03/30075855/Rare-Books-Thumbnail-248x300.jpg";
  }
  if(coverLink==null && cover!=null){
    coverLink = cover.attributes['data-a-dynamic-image'];
    RegExp bookImageLinkRegex = new RegExp(r"(https.*?jpg)",caseSensitive: false, multiLine: false);
    coverLink = bookImageLinkRegex.allMatches(coverLink).elementAt(0).group(1);
  }
  return coverLink;
}

String getDescription(Document bookPage){
  String description = "";
  try{
    String rawDescription = bookPage.getElementById("bookDescription_feature_div").getElementsByTagName("noscript").first.innerHtml; //getElementsByTagName("div").first.text
    RegExp bookDescriptionRegex = new RegExp(r"<div>(.*)<\/div>",caseSensitive: false, multiLine: false);
    String desc = bookDescriptionRegex.allMatches(rawDescription).elementAt(0).group(1);
    var document = parse(desc);
    description = parse(document.body.text).documentElement.text;
  }catch(e){}
  return description.trim();
}

fromAmazonData(String isbn) async {
    Document bookDocument = await getBookDocumentByISBN(isbn);
    if(bookDocument!=null){
      this.title = getTitleFromBook(bookDocument);
      this.authors = getAuthors(bookDocument);
      this.cover = getImage(bookDocument);
      this.description = getDescription(bookDocument);
      this.publicationYear = getPublicationYearFromBook(bookDocument);
    }
}

  // fromAmazonData(String isbn) async {
  //   String url = "https://www.amazon.fr/s/ref=nb_sb_noss?__mk_fr_FR=%C3%85M%C3%85%C5%BD%C3%95%C3%91&url=search-alias%3Daps&field-keywords="+isbn;
  //   http.Response response = await http.get(url);

  //   Document document = parser.parse(response.body);

  //   // String bookLink = document.getElementById("result_0").getElementsByClassName("a-link-normal").first.attributes['href'];
  //   String bookLink = document.getElementsByClassName("s-result-list").first.getElementsByTagName("div").first.getElementsByClassName("a-link-normal").first.attributes['href'];
  //   http.Response bookPage = await http.get(bookLink);
  //   Document bookDocument  = parser.parse(bookPage.body);

  //   try{
  //     String bookTitle = bookDocument.getElementById("title").getElementsByTagName('span').first.text;
  //     if(bookTitle.isEmpty){
  //       bookTitle = bookDocument.getElementById("productTitle").text;
  //     }
  //     this.title = bookTitle;
  //   }catch(e){}

  //   try{
  //     String publicationYear = bookDocument.getElementById("title").getElementsByTagName('span').last.text;
  //     RegExp publicationYearRegex = new RegExp(r"(\d+)(?!.*\d)",caseSensitive: false, multiLine: false);
  //     this.publicationYear = publicationYearRegex.stringMatch(publicationYear).toString();
  //   }catch(e){}

  //   try{
  //     List<String> authors = new List();
  //     // String bookAuthor = bookDocument.getElementsByClassName("contributorNameID").first.text;
  //     bookDocument.getElementById("booksTitle").getElementsByClassName("author").forEach((Element elem) {
  //       String authorText = elem.getElementsByClassName("a-link-normal").first.text;
  //       if(authorText.toLowerCase().contains("consulter la page")){
  //         authorText = authorText.replaceAll("Consulter la page ", "");
  //         authorText = authorText.replaceAll(" d'Amazon", "");
  //       }
  //       authors.add(authorText);
  //     });
  //     this.authors = authors.join(', ');
  //   }catch(e){}

  //   try{
  //     RegExp bookImageLinkRegex = new RegExp(r"(https.*?jpg)",caseSensitive: false, multiLine: false);
  //     String bookImageLink = bookDocument.getElementsByClassName("frontImage").first.attributes['data-a-dynamic-image'];
  //     String link = bookImageLinkRegex.allMatches(bookImageLink).elementAt(0).group(1);
  //     this.cover = link;
  //   }catch(e){
  //     this.cover = "https://d4804za1f1gw.cloudfront.net/wp-content/uploads/sites/30/2018/03/30075855/Rare-Books-Thumbnail-248x300.jpg";
  //   }


  //   try{
      
  //     //   print(bookDocument.getElementsByClassName("productDescriptionWrapper").first.innerHtml);
  //     // if(bookDocument.getElementsByClassName("productDescriptionWrapper").first!=null){
  //     // }else{
  //     RegExp bookDescriptionRegex = new RegExp(r"<div>(.*)<\/div>",caseSensitive: false, multiLine: false);
  //     String bookDescription = bookDocument.getElementById("bookDescription_feature_div").getElementsByTagName("noscript").first.text;
  //     String desc = bookDescriptionRegex.allMatches(bookDescription).elementAt(0).group(1);
  //     var document = parse(desc);
  //     String parsedString = parse(document.body.text).documentElement.text;

  //     this.description = parsedString;
  //     // }
      
  //   }catch(e){}

  //   try{
  //     List<Element> details = bookDocument.getElementById('detail_bullets_id').getElementsByTagName("li");
  //     RegExp pagesRegex = new RegExp(r"\d+",caseSensitive: false, multiLine: false);
  //     RegExp isbnRegex = new RegExp(r"\s(.*)",caseSensitive: false, multiLine: false);
  //     for(Element elem in details){
  //       String html = elem.innerHtml.toString().toLowerCase();
  //       if(html.contains('poche:')||html.contains('broché:')||html.contains("nombre de pages de l'édition imprimée")){
  //         this.pageCount = pagesRegex.stringMatch(elem.text).toString();
  //       }
  //       if(html.contains('isbn-13')){
  //         this.isbn = isbnRegex.stringMatch(elem.text).toString().replaceAll("-", "");
  //       }
  //     }
  //   }catch(e){}

  //   if(this.isbn==null){
  //     this.isbn = isbn;
  //   }

  // }

  // Book.fromRequestData(XmlDocument storeDocument){
  //   try{
  //     title=storeDocument.findAllElements('isbn13').first.text;
  //   }catch(e){}
  //   try{
  //     title=storeDocument.findAllElements('title').first.text;
  //   }catch(e){}
  //   try{
  //     authors=storeDocument.findAllElements('authors').first.findAllElements("name").map((element) => element.text).join(', ');
  //   }catch(e){}
  //   try{
  //     description=storeDocument.findAllElements('description').first.text;
  //   }catch(e){}
  //   try{
  //     pageCount=storeDocument.findAllElements('num_pages').first.text;
  //   }catch(e){}
  //   try{
  //     cover = storeDocument.findAllElements('image_url').first.text;
  //   }catch(e) {
  //     cover = "https://d4804za1f1gw.cloudfront.net/wp-content/uploads/sites/30/2018/03/30075855/Rare-Books-Thumbnail-248x300.jpg";
  //   }
  //   try{
  //     publicationYear= storeDocument.findAllElements('publication_year').first.text;
  //   }
  //   catch(e){
  //     publicationYear= "2018";
  //   }
  // }
    // publicationYear=data['items'][0]['volumeInfo']["publishedDate"].substr(0, data['item'][0]["volumeInfo"]["publishedDate"].indexOf('-'));
}