import 'package:no_todo_app/model/nodo_item.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class DatabaseHelper {
  //singleton instance
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  final String tableName = 'nodoTbl';
  final String colId = 'id';
  final String colItemName = 'itemName';
  final String colDateCreated = 'dateCreated';

  //singleton database object
  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;

    _db = await initDb();
    return _db;
  }

  //initialize the database for the first run
  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'noToDo_Db.db');
    var ourDb = openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  //Schema for the table
  void _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $tableName($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colItemName TEXT,'
        '$colDateCreated TEXT)');
  }

  //Insert a new NoDoItem
  Future<int> saveNoDoItem(NoDoItem item) async {
    var dbClient = await db;
    int res = await dbClient.insert('$tableName', item.toMap());
    return res;
  }

  //Get all the items
  Future<List> getAllNoDoItems() async {
    var dbClient = await db;
    var result =
        dbClient.rawQuery('SELECT * FROM $tableName ORDER BY $colItemName ASC');
    return result;
  }

  //count of NoDoItems
  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery('SELECT COUNT FROM $tableName'));
  }

  //read an item
  Future<NoDoItem> getNoDoItem(int id) async {
    var dbClient = await db;
    var result =
        await dbClient.rawQuery('SELECT * FROM $tableName WHERE $colId = $id');
    if (result.length == 0) return null;
    return NoDoItem.fromMap(result.first);
  }

  //delete an item
  Future<int> deleteNoDoItem(int id) async {
    var dbClient = await db;
    return await dbClient.delete(tableName, where: '$colId=?', whereArgs: [id]);
  }

  //update an item
  Future<int> updateNoDoItem(NoDoItem user) async {
    var dbClient = await db;
    return await dbClient.update(tableName, user.toMap(),
        where: '$colId=?', whereArgs: [user.id]);
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
