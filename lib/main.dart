// import 'dart:html';
//import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/delUsers.dart';
import 'package:path/path.dart';
import 'package:flutter_application_1/Models.dart';
import 'package:sqflite/sqflite.dart';
//import 'package:english_words/english_words.dart';

void main() {
  runApp(const myApp());
}

class NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._init();
  static Database? _database;
  NotesDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final doubleType = 'REAL NOT NULL';
    final textType = 'TEXT NOT NULL';
    await db.execute('''CREATE TABLE $tableModels(
      ${ModelFields.id} $idType,
      ${ModelFields.item} $textType,
      ${ModelFields.price} $doubleType
    )''');
  }

  Future<Models> create(Models models) async {
    final db = await instance.database;
    final id = await db.insert(tableModels, models.toJson());
    return models.copy(id: id);
  }

  Future<Models> readModels(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableModels,
      columns: ModelFields.values,
      where: '${ModelFields.id}=?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Models.fromJson(maps.first);
    } else {
      throw Exception('Id $id not found');
    }
  }

  Future<int> updateModels(Models model) async {
    final db = await instance.database;

    return db.update(
      tableModels,
      model.toJson(),
      where: '${ModelFields.id}=?',
      whereArgs: [model.id],
    );
  }

  Future deleteModels(int id) async {
    final db = await instance.database;

    final maps = await db.delete(
      tableModels,
      where: '${ModelFields.id}=?',
      whereArgs: [id],
    );
  }

  Future<int> dropTable() async {
    final db = await instance.database;

    return await db.delete(tableModels);
  }

  Future<List<Models>> readAllModels() async {
    final db = await instance.database;
    final result = await db.query(tableModels);

    return result.map((json) => Models.fromJson(json)).toList();
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}

class myApp extends StatelessWidget {
  const myApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primarySwatch: Colors.amber), home: MyApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  //final wordPair = WordPair.random();
  String title = "Expenses";
  int counting = 49;
  List<Models>? md;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    Model1(3);
  }

  Future Model1(int i) async {
    setState(() => isLoading = true);
    this.md = await NotesDatabase.instance.readAllModels();
    setState(() => isLoading = false);
  }

  Future Modeldel(int i) async {
    setState(() => isLoading = true);
    await NotesDatabase.instance.deleteModels(i);
    setState(() => isLoading = false);
  }

  Future Modeldrop() async {
    setState(() => isLoading = true);
    await NotesDatabase.instance.dropTable();
    setState(() => isLoading = false);
  }

  Future Model2(Models model) async {
    setState(() => isLoading = true);
    await NotesDatabase.instance.create(model);
    setState(() => isLoading = false);
  }

  Future updateModel(Models model) async {
    setState(() => isLoading = true);
    await NotesDatabase.instance.updateModels(model);
    setState(() => isLoading = false);
  }

  late Models mm;
  @override
  Widget build(BuildContext context) {
    //Model2(mm);
    List<Models>? lll;
    //Model1();
    if (md != null) {
      lll = md;
    }
    Future oneOpenDialog(String a, double p, TextInputType t, int id) {
      String item = a;
      double price = p;
      String forPost = '';
      (t == TextInputType.number) ? forPost = p.toString() : forPost = a;
      return showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Add Item'),
                content: TextFormField(
                  initialValue: forPost,
                  keyboardType: t,
                  decoration: InputDecoration(hintText: 'Item Name'),
                  onChanged: (val) {
                    forPost = val;
                  },
                ),
                actions: [
                  TextButton(
                      onPressed: () async {
                        (t == TextInputType.number)
                            ? price = double.parse(forPost)
                            : item = forPost;
                        mm = Models(id: id, item: item, price: price);
                        await updateModel(mm);
                        Navigator.of(context).pop();
                      },
                      child: Text('Done'))
                ],
              ));
    }

    Future openDialog() {
      String item = '...';
      double price = 0.0;
      return showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Add Item'),
                content: Container(
                  height: 100,
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(hintText: 'Item Name'),
                        onChanged: (val) {
                          item = val;
                        },
                      ),
                      TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: 'Price'),
                          onChanged: (val) {
                            price = double.parse(val);
                          }),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () async {
                        mm = Models(item: item, price: price);
                        await Model2(mm);
                        Navigator.of(context).pop();
                      },
                      child: Text('Done'))
                ],
              ));
    }

    List<DataColumn> cols(List<String> str) =>
        str.map((col) => DataColumn(label: Text(col))).toList();
    int no = 0;
    List<DataCell> cells(List<dynamic> str) {
      no++;
      return <DataCell>[
        DataCell(Container(
          width: 20,
          child: Text(
            no.toString(),
          ),
        )),
        DataCell(Container(
          width: 100,
          child: TextFormField(
            textAlign: TextAlign.center,
            keyboardType: TextInputType.none,
            initialValue: str[1],
            onTap: () async {
              await oneOpenDialog(str[1], str[2], TextInputType.name, str[0]);
              await Model1(1);
            },
          ),
        )),
        DataCell(Container(
          width: 80,
          child: TextFormField(
            textAlign: TextAlign.center,
            initialValue: str[2].toString(),
            keyboardType: TextInputType.none,
            // onFieldSubmitted: (val) {
            //   str[2] = val;
            //   final ms = str.asMap();
            //   updateModel(
            //       Models(id: ms[0], item: ms[1], price: double.parse(ms[2])));
            //   Model1(1);
            // },
            onTap: () async {
              await oneOpenDialog(str[1], str[2], TextInputType.number, str[0]);
              await Model1(1);
            },
          ),
        )),
        DataCell(ElevatedButton(
            onPressed: () async {
              await Modeldel(str[0]);
              await Model1(1);
            },
            child: Icon(Icons.delete)))
      ];
    }

    List<DataRow> rows(List<Models>? str) => str!.map((col) {
          final cell = [col.id, col.item, col.price];
          return DataRow(cells: cells(cell));
        }).toList();

    String sumOf(List<Models>? m) {
      double sum = 0;
      for (int i = 0; i < m!.length; i++) {
        sum += m[i].price;
      }

      return sum.toStringAsFixed(2);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('$title'),
        actions: [
          TextButton(
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.black)),
              onPressed: () async {
                await openDialog();
                // Model2(mm);
                Model1(2);
              },
              child: Icon(Icons.add)),
        ],
      ),
      body: Align(
          alignment: Alignment.center,
          child: isLoading
              ? CircularProgressIndicator()
              : ListView(
                  children: [
                    Center(
                        child: Text(
                      'Total \$${sumOf(lll)}',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    )),
                    DataTable(
                      columnSpacing: 20,
                      columns: cols(['No.', 'Item', 'Price', '']),
                      rows: rows(lll),
                    )
                  ],
                )),
      // floatingActionButton: FloatingActionButton(
      //     onPressed: () {
      //       setState(() {
      //         title = "Basi";
      //         //Modeldrop();

      //         //counting++;
      //         if (md != null) {
      //           lll = md;

      //         }
      //       });
      //     },
      //     child: const Icon(Icons.plumbing)),
    );
  }
}
