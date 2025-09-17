import 'package:flutter_test/flutter_test.dart';
import 'package:know_it/models/quiz_result.dart';
import 'package:know_it/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseService db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = DatabaseService.instance;
    await db.deleteAll(); // clean DB before each test
  });

  tearDownAll(() async {
    await db.close();
  });

  group('DatabaseService Tests', () {
    test('should create and retrieve quiz result', () async {
      final result = QuizResult(
        totalQuestions: 10,
        correctAnswers: 8,
        score: 80,
        completedAt: DateTime.now(),
        difficulty: 'medium',
      );

      final created = await db.create(result);
      expect(created.id, isNotNull);

      final fetched = await db.readResult(created.id!);
      expect(fetched, isNotNull);
      expect(fetched!.score, equals(80));
      expect(fetched.difficulty, equals('medium'));
    });

    test('should get high scores in correct order', () async {
      final results = [
        QuizResult(
          totalQuestions: 10,
          correctAnswers: 5,
          score: 50,
          completedAt: DateTime.now(),
          difficulty: 'easy',
        ),
        QuizResult(
          totalQuestions: 10,
          correctAnswers: 8,
          score: 80,
          completedAt: DateTime.now(),
          difficulty: 'medium',
        ),
        QuizResult(
          totalQuestions: 10,
          correctAnswers: 10,
          score: 100,
          completedAt: DateTime.now(),
          difficulty: 'hard',
        ),
      ];

      for (var r in results) {
        await db.create(r);
      }

      final highScores = await db.getHighScores(limit: 3);

      expect(highScores.length, 3);
      expect(highScores[0].score, 100);
      expect(highScores[1].score, 80);
      expect(highScores[2].score, 50);
    });

    test('should calculate statistics correctly', () async {
      final results = [
        QuizResult(
          totalQuestions: 10,
          correctAnswers: 5,
          score: 50,
          completedAt: DateTime.now(),
          difficulty: 'easy',
        ),
        QuizResult(
          totalQuestions: 10,
          correctAnswers: 7,
          score: 70,
          completedAt: DateTime.now(),
          difficulty: 'medium',
        ),
        QuizResult(
          totalQuestions: 10,
          correctAnswers: 9,
          score: 90,
          completedAt: DateTime.now(),
          difficulty: 'hard',
        ),
      ];

      for (var r in results) {
        await db.create(r);
      }

      final stats = await db.getStatistics();

      expect(stats['totalGames'], 3);
      expect(stats['bestScore'], 90);
      expect(stats['averageScore'], (50 + 70 + 90) ~/ 3);
    });

    test('should update quiz result', () async {
      final result = QuizResult(
        totalQuestions: 10,
        correctAnswers: 6,
        score: 60,
        completedAt: DateTime.now(),
        difficulty: 'easy',
      );

      final created = await db.create(result);

      final updatedResult = created.copyWith(score: 95, correctAnswers: 9);
      final rowsAffected = await db.update(updatedResult);

      expect(rowsAffected, 1);

      final fetched = await db.readResult(created.id!);
      expect(fetched, isNotNull);
      expect(fetched!.score, equals(95));
      expect(fetched.correctAnswers, equals(9));
    });

    test('should delete quiz result', () async {
      final result = QuizResult(
        totalQuestions: 10,
        correctAnswers: 4,
        score: 40,
        completedAt: DateTime.now(),
        difficulty: 'easy',
      );

      final created = await db.create(result);

      final rowsDeleted = await db.delete(created.id!);
      expect(rowsDeleted, 1);

      final fetched = await db.readResult(created.id!);
      expect(fetched, isNull);
    });

    test('should clear all results with deleteAll', () async {
      final results = [
        QuizResult(
          totalQuestions: 10,
          correctAnswers: 5,
          score: 50,
          completedAt: DateTime.now(),
          difficulty: 'easy',
        ),
        QuizResult(
          totalQuestions: 10,
          correctAnswers: 7,
          score: 70,
          completedAt: DateTime.now(),
          difficulty: 'medium',
        ),
      ];

      for (var r in results) {
        await db.create(r);
      }

      final allBefore = await db.readAllResults();
      expect(allBefore.length, 2);

      final rowsDeleted = await db.deleteAll();
      expect(rowsDeleted, greaterThan(0));

      final allAfter = await db.readAllResults();
      expect(allAfter, isEmpty);
    });

    test('should close database', () async {
      final result = QuizResult(
        totalQuestions: 10,
        correctAnswers: 5,
        score: 50,
        completedAt: DateTime.now(),
        difficulty: 'easy',
      );

      await db.create(result);

      // Close DB
      await db.close();

      // Try to query again - should throw DatabaseException
      expect(() async => await db.readAllResults(), throwsA(isA<DatabaseException>()));
    });
  });
}
