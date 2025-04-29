import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  Future<void> initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'app.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT,
            name TEXT,
            country TEXT
            
          )
        ''');

        await db.execute('''
          CREATE TABLE ratings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            landmark_id INTEGER,
            stars INTEGER,
            comment TEXT,
            user_name TEXT
          )
        ''');
      },
    );
  }

  // USER METHODS
  Future<void> insertUser(Map<String, dynamic> user) async {
    try {
      await _database?.insert('users', user);
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception("Email already exists.");
      } else {
        throw Exception("Database insertion error: $e");
      }
    }
  }

  Future<bool> isEmailExists(String email) async {
    final db = _database;
    if (db == null) throw Exception('Database is not initialized');

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = _database;
    if (db == null) throw Exception('Database is not initialized');

    return await db.query('users');
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = _database;
    if (db == null) throw Exception('Database is not initialized');

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = _database;
    if (db == null) throw Exception('Database is not initialized');

    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = _database;
    if (db == null) throw Exception('Database is not initialized');

    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // RATINGS METHODS
  Future<void> insertRating(
      int landmarkId, int stars, String comment, String userName) async {
    final db = _database;
    if (db == null) throw Exception('Database is not initialized');

    await db.insert('ratings', {
      'landmark_id': landmarkId,
      'stars': stars,
      'comment': comment,
      'user_name': userName,
    });
  }

  Future<List<Map<String, dynamic>>> getRatingsForLandmark(
      int landmarkId) async {
    final db = _database;
    if (db == null) throw Exception('Database is not initialized');

    return await db.query(
      'ratings',
      where: 'landmark_id = ?',
      whereArgs: [landmarkId],
    );
  }

  Future<int> getRatingCount(int landmarkId) async {
    final db = _database;
    if (db == null) throw Exception('Database is not initialized');

    final result = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM ratings WHERE landmark_id = ?',
      [landmarkId],
    ));
    return result ?? 0;
  }

  ////////////
  ///
  ///
  Future<List<Map<String, dynamic>>> getTopRatedLandmarks() async {
    final db = _database;
    if (db == null) throw Exception('Database is not initialized');

    // 1. قراءة التقييمات من قاعدة البيانات
    final ratingCounts = await db.rawQuery('''
    SELECT landmark_id, COUNT(*) as count
    FROM ratings
    GROUP BY landmark_id
    ORDER BY count DESC
  ''');

    // 2. تحميل بيانات المعالم من ملف JSON
    final jsonString = await rootBundle.loadString('assets/img/landmarks.json');
    final List<dynamic> landmarkList = json.decode(jsonString);

    // 3. ربط التقييمات بالمعالم
    List<Map<String, dynamic>> topLandmarks = [];

    for (var row in ratingCounts) {
      final landmarkId = row['landmark_id'];
      final count = row['count'];

      final matchedLandmark = landmarkList.firstWhere(
        (l) => l['Landmark_Id'] == landmarkId,
        orElse: () => null,
      );

      if (matchedLandmark != null) {
        final landmarkWithCount = Map<String, dynamic>.from(matchedLandmark);
        landmarkWithCount['rating_count'] = count;
        topLandmarks.add(landmarkWithCount);
      }

      if (topLandmarks.length >= 10) break; // نكتفي بأعلى 10 فقط
    }

    return topLandmarks;
  }

  Future<void> updateRating(int id, int stars, String comment) async {
    final db = _database;
    if (db == null) throw Exception('Database is not initialized');

    await db.update(
      'ratings',
      {
        'stars': stars,
        'comment': comment,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
