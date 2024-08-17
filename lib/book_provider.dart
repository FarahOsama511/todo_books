import 'package:Farah/data.dart';
import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';

final String columnId = "id";
final String columnName = "name";
final String columnImageurl = "url";
final String columnAuthor = "Author";
final String booktable = "todo_table";

class BookProvider {
  static final BookProvider instance = BookProvider._internal();

  factory BookProvider() {
    return instance;
  }

  BookProvider._internal();
  late Database db;
  Future open() async {
    db = await openDatabase(
      join(await getDatabasesPath(), "book.db"),
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
            "create table $booktable($columnId INTEGER PRIMARY KEY AUTOINCREMENT, $columnName TEXT NOT NULL,$columnAuthor TEXT NOT NULL,$columnImageurl TEXT NOT NULL)");
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              "ALTER TABLE $booktable ADD COLUMN $columnImageurl TEXT");
        }
      },
    );
  }

  Future<Books> insert(Books book) async {
    book.id = await db.insert(booktable, book.toMap());
    return book;
  }

  Future<List<Books>> getbook() async {
    List<Map<String, dynamic>> bookMaps = await db.query(booktable);
    if (bookMaps.isEmpty) {
      return [];
    } else {
      List<Books> todos =
          bookMaps.map((element) => Books.fromMap(element)).toList();
      return todos;
    }
  }

  Future<int> delete(int id) async {
    return await db.delete(booktable, where: "$columnId=?", whereArgs: [id]);
  }

  Future<int> update(Books book) async {
    return await db.update(booktable, book.toMap(),
        where: "$columnId=?", whereArgs: [book.id]);
  }
}
