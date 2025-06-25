import 'dart:developer';

import 'package:path/path.dart';
import 'package:q/prayerstatus.dart';
import 'package:sqflite/sqflite.dart';

class PrayerDBHelper {
  static final PrayerDBHelper _instance = PrayerDBHelper._internal();
  factory PrayerDBHelper() => _instance;
  PrayerDBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'prayer_status.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE prayers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            prayerName TEXT,
            date TEXT,
            status TEXT
          )
        ''');
      },
    );
  }

  // Future<void> insertStatus(PrayerStatus status) async {
  //   final db = await database;
  //   await db.insert(
  //     'prayers',
  //     status.toMap(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  //   log('DBHElper Prayer Status Saved:');
  //   log('DBHElper Prayer: ${status.prayerName}');
  //   log('DBHElper Date: ${status.date}');
  //   log('DBHElper Status: ${status.status}');
  // }
  Future<void> insertStatus(PrayerStatus status) async {
    final db = await database;

    // Check if entry exists
    final existing = await db.query(
      'prayers',
      where: 'prayerName = ? AND date = ?',
      whereArgs: [status.prayerName, status.date],
    );

    if (existing.isNotEmpty) {
      // Update existing entry
      await db.update(
        'prayers',
        status.toMap(),
        where: 'prayerName = ? AND date = ?',
        whereArgs: [status.prayerName, status.date],
      );
      log(
        'Prayer status updated: ${status.prayerName}, ${status.date}, ${status.status}, Time updated: ${DateTime.now()}',
      );
    } else {
      // Insert new entry
      await db.insert(
        'prayers',
        status.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      log(
        'Prayer status inserted: ${status.prayerName}, ${status.date}, ${status.status}, Time inserted: ${DateTime.now()}',
      );
    }
  }

  Future<List<PrayerStatus>> getStatusesByDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'prayers',
      where: 'date = ?',
      whereArgs: [date],
    );
    return maps.map((e) => PrayerStatus.fromMap(e)).toList();
  }

  Future<List<PrayerStatus>> fetchAllStatuses() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('prayers');
    final allStatuses = result.map((map) => PrayerStatus.fromMap(map)).toList();
    for (var status in allStatuses) {
      log(
        'Date: ${status.date}, Prayer: ${status.prayerName}, Status: ${status.status}, Time fetched: ${DateTime.now()}',
      );
    }
    return allStatuses;
    // return result.map((map) => PrayerStatus.fromMap(map)).toList();
  }

  Future<void> clearAllStatuses() async {
    final db = await database;
    await db.delete('prayers');
    log('All prayer statuses have been cleared from the database.');
  }
}
