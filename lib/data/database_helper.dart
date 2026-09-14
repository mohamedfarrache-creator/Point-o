import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/time_log.dart';

/// Single SQLite gateway for logs and user preferences.
class DatabaseHelper {
  DatabaseHelper._();
  static final instance = DatabaseHelper._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = join(await getDatabasesPath(), 'pointeo.db');
    _database = await openDatabase(path, version: 1, onCreate: _onCreate);
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE time_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        check_in TEXT NOT NULL,
        check_out TEXT,
        normal_minutes INTEGER NOT NULL DEFAULT 0,
        overtime_minutes INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)');
  }

  Future<int> insertLog(TimeLog log) async {
    final db = await database;
    final values = log.toMap()..remove('id');
    return db.insert('time_logs', values);
  }

  Future<void> updateLog(TimeLog log) async {
    final db = await database;
    await db.update('time_logs', log.toMap()..remove('id'), where: 'id = ?', whereArgs: [log.id]);
  }

  Future<List<TimeLog>> logsForMonth(DateTime month) async {
    final db = await database;
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final rows = await db.query(
      'time_logs',
      where: 'date >= ? AND date < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'check_in DESC',
    );
    return rows.map(TimeLog.fromMap).toList();
  }

  Future<List<TimeLog>> allLogs() async {
    final db = await database;
    final rows = await db.query('time_logs', orderBy: 'check_in DESC');
    return rows.map(TimeLog.fromMap).toList();
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final rows = await db.query('settings', where: 'key = ?', whereArgs: [key], limit: 1);
    return rows.isEmpty ? null : rows.first['value'] as String;
  }
}
