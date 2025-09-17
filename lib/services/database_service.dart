import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/quiz_result.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quiz_results.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const integerType = 'INTEGER NOT NULL';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE quiz_results (
        id $idType,
        totalQuestions $integerType,
        correctAnswers $integerType,
        score $integerType,
        completedAt $textType,
        difficulty $textType
      )
    ''');
  }

  /// Insert a quiz result
  Future<QuizResult> create(QuizResult result) async {
    final db = await instance.database;

    final id = await db.insert('quiz_results', result.toMap());
    return result.copyWith(id: id);
  }

  /// Get a quiz result by ID
  Future<QuizResult?> readResult(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      'quiz_results',
      columns: ['id', 'totalQuestions', 'correctAnswers', 'score', 'completedAt', 'difficulty'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return QuizResult.fromMap(maps.first);
    } else {
      return null;
    }
  }

  /// Get all quiz results ordered by score (high to low)
  Future<List<QuizResult>> readAllResults() async {
    final db = await instance.database;

    const orderBy = 'score DESC';
    final result = await db.query('quiz_results', orderBy: orderBy);

    return result.map((json) => QuizResult.fromMap(json)).toList();
  }

  /// Get top high scores with limit
  Future<List<QuizResult>> getHighScores({int limit = 10}) async {
    final db = await instance.database;

    final result = await db.query('quiz_results', orderBy: 'score DESC', limit: limit);

    return result.map((json) => QuizResult.fromMap(json)).toList();
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await instance.database;

    final totalGames =
        Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM quiz_results')) ?? 0;
    final bestScore =
        Sqflite.firstIntValue(await db.rawQuery('SELECT MAX(score) FROM quiz_results')) ?? 0;
    final avgScore = await db.rawQuery('SELECT AVG(score) FROM quiz_results');
    final averageScore = avgScore.isNotEmpty
        ? (avgScore.first.values.first as double?)?.round() ?? 0
        : 0;

    return {'totalGames': totalGames, 'bestScore': bestScore, 'averageScore': averageScore};
  }

  /// Update a quiz result
  Future<int> update(QuizResult result) async {
    final db = await instance.database;

    return db.update('quiz_results', result.toMap(), where: 'id = ?', whereArgs: [result.id]);
  }

  /// Delete a quiz result
  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete('quiz_results', where: 'id = ?', whereArgs: [id]);
  }

  /// Clear all results (for testing or reset)
  Future<int> deleteAll() async {
    final db = await instance.database;   
    return await db.delete('quiz_results');
  }

  /// Close the database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
