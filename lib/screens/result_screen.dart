import 'package:flutter/material.dart';

import '../models/quiz_result.dart';
import 'high_scores_screen.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final QuizResult result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final percentage = (result.correctAnswers / result.totalQuestions * 100).round();

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Results'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getResultIcon(percentage),
                size: 100,
                color: _getResultColor(percentage, context),
              ),
              const SizedBox(height: 20),
              Text(
                _getResultMessage(percentage),
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildResultRow('Score', '${result.score}', context),
                      _buildResultRow(
                        'Correct Answers',
                        '${result.correctAnswers}/${result.totalQuestions}',
                        context,
                      ),
                      _buildResultRow('Percentage', '$percentage%', context),
                      _buildResultRow('Difficulty', result.difficulty.toUpperCase(), context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              FilledButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
                style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Home'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HighScoresScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('View High Scores'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, BuildContext context) {
    return ListTile(title: Text(label), trailing: Text(value));
  }

  IconData _getResultIcon(int percentage) {
    if (percentage >= 80) return Icons.emoji_events;
    if (percentage >= 60) return Icons.thumb_up;
    return Icons.refresh;
  }

  Color _getResultColor(int percentage, BuildContext context) {
    if (percentage >= 80) return Theme.of(context).colorScheme.primary;
    if (percentage >= 60) return Theme.of(context).colorScheme.secondary;
    return Theme.of(context).colorScheme.error;
  }

  String _getResultMessage(int percentage) {
    if (percentage >= 80) return 'Excellent!';
    if (percentage >= 60) return 'Good Job!';
    if (percentage >= 40) return 'Not Bad!';
    return 'Keep Trying!';
  }
}
