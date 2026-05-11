import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('build_access_history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scan_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        raw_ocr_text TEXT NOT NULL,
        ai_summary TEXT NOT NULL,
        created_time INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_created_time ON scan_history (created_time);
    ''');
  }

  Future<int> insertHistory(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('scan_history', data);
  }

  Future<List<Map<String, dynamic>>> readHistoryPaged(int limit, int offset) async {
    final db = await instance.database;
    return await db.query(
      'scan_history',
      orderBy: 'created_time DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<int> deleteOldHistory(int daysToKeep) async {
    final db = await instance.database;
    final cutoffTime = DateTime.now().subtract(Duration(days: daysToKeep)).millisecondsSinceEpoch;

    return await db.delete(
      'scan_history',
      where: 'created_time < ?',
      whereArgs: [cutoffTime],
    );
  }
}