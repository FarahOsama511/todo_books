import 'package:Farah/book_provider.dart';

class Books {
  int? id;
  String? url;
  late String name;
  late String Author;

  Books({this.id, required this.name, required this.Author, this.url});

  Books.fromMap(Map<String, dynamic> map) {
    if (map[columnId] != null) {
      this.id = map[columnId];
    }
    this.name = map[columnName];
    this.url = map[columnImageurl] ?? "https://example.com/default_image.png";

    this.Author = map[columnAuthor];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    if (id != null) {
      map[columnId] = this.id;
    }
    map[columnName] = this.name;

    map[columnAuthor] = this.Author;
    if (url != null) {
      map[columnImageurl] = this.url;
    }

    return map;
  }
}
