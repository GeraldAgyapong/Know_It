import 'dart:convert';

import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;

import '../models/question.dart';

class QuizService {
  static const String baseUrl = 'https://opentdb.com/api.php';

  /// Fetches questions from Open Trivia Database
  static Future<List<Question>> fetchQuestions({
    int amount = 10,
    String difficulty = 'easy',
    String category = '',
    http.Client? client,
  }) async {
    client ??= http.Client();

    String url = '$baseUrl?amount=$amount&difficulty=$difficulty&type=multiple';
    if (category.isNotEmpty) {
      url += '&category=$category';
    }

    try {
      final response = await client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['response_code'] == 0) {
          List results = data['results'];
          return results.map((json) => Question.fromJson(json)).toList();
        } else {
          throw Exception('API returned error code: ${data['response_code']}');
        }
      } else {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching questions: $e');
    } finally {
      client.close(); // ✅ cleanup
    }
  }

  static String decodeHtml(String htmlString) {
    return HtmlUnescape().convert(htmlString);
  }
}
