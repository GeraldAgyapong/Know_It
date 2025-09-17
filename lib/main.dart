import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:know_it/constants/constants.dart';
import 'package:know_it/providers/theme_provider.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local database
  await DatabaseService.instance.database;

  // initialize GetStorage for local storage
  await GetStorage.init();

  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, value, child) {
          return MaterialApp(
            title: AppConstants.appName,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: value.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
