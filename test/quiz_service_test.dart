import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:know_it/services/quiz_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'quiz_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('QuizService Tests', () {
    test('fetchQuestions should return list of questions', () async {
      final client = MockClient();

      // Sample API response
      final mockResponse = {
        'response_code': 0,
        'results': [
          {
            'category': 'General Knowledge',
            'type': 'multiple',
            'difficulty': 'easy',
            'question': 'What&#039;s 2+2?',
            'correct_answer': '4',
            'incorrect_answers': ['3', '5', '6'],
          },
        ],
      };

      when(client.get(any)).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      // Inject the mock client
      final questions = await QuizService.fetchQuestions(client: client);

      expect(questions, isNotEmpty);
      expect(questions.first.correctAnswer, equals('4'));
      expect(questions.first.question, equals("What's 2+2?")); // decoded
    });

    test('fetchQuestions should throw exception on API error', () async {
      final client = MockClient();

      final mockResponse = {'response_code': 1, 'results': []};

      when(client.get(any)).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

      expect(() => QuizService.fetchQuestions(client: client), throwsException);
    });
  });
}
