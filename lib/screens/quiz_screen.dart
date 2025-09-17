import 'package:flutter/material.dart';

import '../models/question.dart';
import '../models/quiz_result.dart';
import '../services/database_service.dart';
import '../services/quiz_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String difficulty;

  const QuizScreen({super.key, required this.difficulty});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  int correctAnswers = 0;
  bool isLoading = true;
  String? selectedAnswer;
  bool showFeedback = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final fetchedQuestions = await QuizService.fetchQuestions(
        amount: 10,
        difficulty: widget.difficulty,
      );

      setState(() {
        questions = fetchedQuestions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading questions: $e')));
      }
    }
  }

  void _selectAnswer(String answer) {
    if (showFeedback) return;

    setState(() {
      selectedAnswer = answer;
      showFeedback = true;

      if (answer == questions[currentQuestionIndex].correctAnswer) {
        correctAnswers++;
        score += _getScoreForDifficulty();
      }
    });

    // Auto-advance after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  int _getScoreForDifficulty() {
    switch (widget.difficulty) {
      case 'easy':
        return 10;
      case 'medium':
        return 20;
      case 'hard':
        return 30;
      default:
        return 10;
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswer = null;
        showFeedback = false;
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final result = QuizResult(
      totalQuestions: questions.length,
      correctAnswers: correctAnswers,
      score: score,
      completedAt: DateTime.now(),
      difficulty: widget.difficulty,
    );

    try {
      await DatabaseService.instance.create(result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving result: $e')));
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ResultScreen(result: result)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.difficulty.toUpperCase()} Quiz'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.difficulty.toUpperCase()} Quiz'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: Text('No questions available. Please try again.')),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.difficulty.toUpperCase()} Quiz'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: (currentQuestionIndex + 1) / questions.length),
            const SizedBox(height: 20),
            Text(
              'Question ${currentQuestionIndex + 1} of ${questions.length}',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Score: $score',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    QuizService.decodeHtml(currentQuestion.question),
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion.allAnswers.length,
                itemBuilder: (context, index) {
                  final answer = currentQuestion.allAnswers[index];
                  final isSelected = selectedAnswer == answer;
                  final isCorrect = answer == currentQuestion.correctAnswer;

                  Color? buttonColor;
                  Color? textColor;
                  if (showFeedback) {
                    if (isCorrect) {
                      buttonColor = Theme.of(context).colorScheme.primary;
                      textColor = Theme.of(context).colorScheme.onPrimary;
                    } else if (isSelected && !isCorrect) {
                      buttonColor = Theme.of(context).colorScheme.error;
                      textColor = Theme.of(context).colorScheme.onError;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: OutlinedButton(
                      onPressed: () => _selectAnswer(answer),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: textColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(QuizService.decodeHtml(answer)),
                    ),
                  );
                },
              ),
            ),
            if (!showFeedback)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: FilledButton.tonal(
                  onPressed: _nextQuestion,
                  style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: Text(
                    currentQuestionIndex < questions.length - 1 ? 'Next Question' : 'Finish Quiz',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
