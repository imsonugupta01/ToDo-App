
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String databaseName = 'nabindhakal.db';
  static const int databaseVersion = 1;

  static Future<Database> initDatabase() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, databaseName);

    return openDatabase(
      databasePath,
      version: databaseVersion,
      onCreate: (db, version) async {
        await createTables(db);
      },
    );
  }

  static Future<void> createTables(Database database) async {
    await database.execute("""
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    """);
  }

  static Future<int> createItem(Database database, String? title, String? description) async {
    final data = {'title': title, 'description': description};
    final id = await database.insert('items', data, conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems(Database database) async {
    return database.query('items', orderBy: "id");
  }

  static Future<int> updateItem(Database database, int id, String title, String? description) async {
    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString(),
    };
    final result = await database.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(Database database, int id) async {
    try {
      await database.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      print("Something went wrong when deleting an item: $err");
    }
  }
}
