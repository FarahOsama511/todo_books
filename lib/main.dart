import 'package:flutter/material.dart';
import 'package:Farah/book_provider.dart';
import 'package:Farah/data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await BookProvider.instance.open();
  } catch (e) {
    print('Error opening database: $e');
  }
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Books> bookList = [];

  @override
  void initState() {
    super.initState();
    _loadInitialBooks();
  }

  Future<void> _loadInitialBooks() async {
    List<Books> initialBooks = [
      Books(
          id: 1,
          name: "habits",
          Author: "Farah",
          url:
              "https://th.bing.com/th/id/OIP.3DxsW8C7tQZCrSu0HwNAYwHaE7?w=240&h=180&c=7&r=0&o=5&dpr=1.3&pid=1.7"),
      Books(
          id: 2,
          name: "Engineering",
          Author: "Mohamed",
          url:
              "https://th.bing.com/th/id/OIP.KXwYcZ6l4pEkE2TZ6wkEFgHaF-?w=228&h=183&c=7&r=0&o=5&dpr=1.3&pid=1.7"),
    ];

    for (Books book in initialBooks) {
      await BookProvider.instance.insert(book);
    }

    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final books = await BookProvider.instance.getbook();
    setState(() {
      bookList = books;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          "Available Books",
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _ShowAddBookBottomSheet(context);
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Books>>(
        future: BookProvider.instance.getbook(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            bookList = snapshot.data!;
            return ListView.builder(
              itemCount: bookList.length,
              itemBuilder: (context, index) {
                Books book = bookList[index];
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListTile(
                    title: Text(
                      book.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black),
                    ),
                    subtitle: Text("Author:${book.Author}"),
                    trailing: IconButton(
                      onPressed: () async {
                        bool? confirmDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                  title: const Text(
                                    "Delete Book",
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  content: const Text(
                                    "Are you sure you want to delete yhis book?",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 20),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 15),
                                        )),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text(
                                          "Yes",
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 15),
                                        )),
                                  ]);
                            });

                        if (confirmDelete == true) {
                          setState(() {
                            bookList.removeAt(index);
                          });
                          await BookProvider.instance.delete(book.id!);
                        }
                      },
                      icon: const Icon(
                        Icons.delete_forever,
                        size: 25,
                      ),
                    ),
                    leading: book.url != null && book.url!.isNotEmpty
                        ? Image.network(
                            book.url!,
                            // width: 50,
                            // height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image);
                            },
                          )
                        : const Icon(Icons.image_not_supported),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No Books items found.'));
          }
        },
      ),
    );
  }

  void _ShowAddBookBottomSheet(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController authorController = TextEditingController();
    TextEditingController urlController = TextEditingController();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              right: 10,
              left: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: "Book title",
                    hintStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(
                    hintText: "Book Author",
                    hintStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    hintText: "Image url",
                    hintStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty &&
                        authorController.text.isNotEmpty) {
                      await BookProvider.instance.insert(Books(
                          name: nameController.text,
                          Author: authorController.text,
                          url: urlController.text));
                      _loadBooks();
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text("Add"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
