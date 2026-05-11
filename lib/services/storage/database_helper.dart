import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('build_access_history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scan_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        raw_ocr_text TEXT NOT NULL,
        ai_summary TEXT NOT NULL,
        directory_path TEXT NOT NULL,
        created_time INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_created_time ON scan_history (created_time);
    ''');
  }

  Future<bool> insertData(String key, Map<String, dynamic> data) async {
    try {
      final db = await database;
      final id = await db.insert(key, data);
      return id > 0; // Nếu id > 0 nghĩa là đã chèn thành công ít nhất 1 dòng
    } catch (e) {
      print("Lỗi lưu DB: $e");
      return false; // Có lỗi xảy ra
    }
  }

  Future<List<Map<String, dynamic>>> readData(
    String Key,
    String orderBy,
    int limit,
    int offset,
  ) async {
    final db = await database;
    return await db.query(Key, orderBy: orderBy, limit: limit, offset: offset);
  }

  Future<int> deleteOld(String key, int daysToKeep) async {
    final db = await database;
    final cutoffTime = DateTime.now()
        .subtract(Duration(days: daysToKeep))
        .millisecondsSinceEpoch;

    return await db.delete(
      key,
      where: 'created_time < ?',
      whereArgs: [cutoffTime],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  /*
    Future<List<Map<String, dynamic>>> readData(
      String Key,
    String orderBy,
    int limit,
    int offset,
  ) async {
    final db = await database;
    return await db.query(
      'scan_history',
      orderBy: 'created_time DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<int> deleteOldHistory(int daysToKeep) async {
    final db = await database;
    final cutoffTime = DateTime.now()
        .subtract(Duration(days: daysToKeep))
        .toIso8601String();

    return await db.delete(
      'scan_history',
      where: 'created_time < ?',
      whereArgs: [cutoffTime],
    );
  }
  * */
}
