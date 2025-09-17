import 'package:flutter/material.dart';

import '../models/quiz_result.dart';
import '../services/database_service.dart';

class HighScoresScreen extends StatefulWidget {
  const HighScoresScreen({super.key});

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen> {
  List<QuizResult> highScores = [];
  Map<String, dynamic> statistics = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHighScores();
  }

  Future<void> _loadHighScores() async {
    try {
      final scores = await DatabaseService.instance.getHighScores();
      final stats = await DatabaseService.instance.getStatistics();

      setState(() {
        highScores = scores;
        statistics = stats;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading high scores: $e')));
      }
    }
  }

  Future<void> _clearAllScores() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Scores'),
          content: const Text(
            'Are you sure you want to delete all quiz results? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await DatabaseService.instance.deleteAll();
        _loadHighScores(); // Refresh the list
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('All scores cleared successfully')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error clearing scores: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('High Scores'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (highScores.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear') {
                  _clearAllScores();
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(value: 'clear', child: Text('Clear All Scores')),
                ];
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : highScores.isEmpty
          ? Center(
              child: Text(
                'No high scores yet!\nPlay a quiz to get started.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
            )
          : Column(
              children: [
                // Statistics Card
                if (statistics.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.all(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            'Games Played',
                            statistics['totalGames'].toString(),
                            Icons.quiz,
                          ),
                          _buildStatItem(
                            'Best Score',
                            statistics['bestScore'].toString(),
                            Icons.star,
                          ),
                          _buildStatItem(
                            'Average',
                            statistics['averageScore'].toString(),
                            Icons.trending_up,
                          ),
                        ],
                      ),
                    ),
                  ),
                // High Scores List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: highScores.length,
                    itemBuilder: (context, index) {
                      final result = highScores[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getRankColor(index),
                            child: Text(
                              '${index + 1}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium!.copyWith(color: _getTextColor(index)),
                            ),
                          ),
                          title: Text(
                            'Score: ${result.score}',
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${result.correctAnswers}/${result.totalQuestions} correct • ${result.difficulty.toUpperCase()}',
                              ),
                              Text(
                                _formatDate(result.completedAt),
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(result.correctAnswers / result.totalQuestions * 100).round()}%',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (index < 3)
                                Icon(Icons.emoji_events, color: _getRankColor(index), size: 16),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Theme.of(context).colorScheme.primary;
      case 1:
        return Theme.of(context).colorScheme.secondary;
      case 2:
        return Theme.of(context).colorScheme.tertiary;
      default:
        return Theme.of(context).colorScheme.error;
    }
  }

  Color _getTextColor(int index) {
    switch (index) {
      case 0:
        return Theme.of(context).colorScheme.onPrimary;
      case 1:
        return Theme.of(context).colorScheme.onSecondary;
      case 2:
        return Theme.of(context).colorScheme.onTertiary;
      default:
        return Theme.of(context).colorScheme.onError;
    }
  }
}
