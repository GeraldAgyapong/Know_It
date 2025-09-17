import 'package:flutter/material.dart';
import 'package:know_it/constants/constants.dart';
import 'package:know_it/providers/theme_provider.dart';
import 'package:know_it/screens/high_scores_screen.dart';
import 'package:know_it/screens/quiz_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Switch(
            value: isDarkMode,
            onChanged: themeProvider.toggleTheme,
            thumbIcon: WidgetStatePropertyAll(Icon(Icons.dark_mode)),
            padding: EdgeInsets.only(right: 16),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, size: 100, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 20),
            Text(
              'Welcome to ${AppConstants.appName}',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Test your knowledge with fun trivia questions!',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildDifficultyButton(
              context,
              'Easy Quiz',
              'Start with easy questions',
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.onPrimary,
              'easy',
            ),
            const SizedBox(height: 15),
            _buildDifficultyButton(
              context,
              'Medium Quiz',
              'Challenge yourself!',
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.onSecondary,
              'medium',
            ),
            const SizedBox(height: 15),
            _buildDifficultyButton(
              context,
              'Hard Quiz',
              'For quiz masters only!',
              Theme.of(context).colorScheme.tertiary,
              Theme.of(context).colorScheme.onTertiary,
              'hard',
            ),
            const SizedBox(height: 30),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HighScoresScreen()),
                );
              },
              icon: const Icon(Icons.leaderboard),
              label: const Text('High Scores'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
    Color onColor,
    String difficulty,
  ) {
    return FilledButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizScreen(difficulty: difficulty)),
        );
      },
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: onColor,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
