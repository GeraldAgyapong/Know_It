import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:know_it/services/local_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = LocalStorageService().loadThemeMode();
  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    LocalStorageService().saveThemeMode(_themeMode);
    notifyListeners();
  }

  static final Random random = Random();
  static final Color seedColor = Colors.primaries[random.nextInt(Colors.primaries.length)];
  static const DynamicSchemeVariant dynamicSchemeVariant = DynamicSchemeVariant.vibrant;
  static final TextTheme textTheme = GoogleFonts.chewyTextTheme();

  static ThemeData get lightTheme {
    return ThemeData(colorScheme: getColorScheme(Brightness.light), textTheme: textTheme);
  }

  static ThemeData get darkTheme {
    return ThemeData(colorScheme: getColorScheme(Brightness.dark), textTheme: textTheme);
  }

  static ColorScheme getColorScheme(Brightness brightness) {
    return ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      dynamicSchemeVariant: dynamicSchemeVariant,
    );
  }
}
