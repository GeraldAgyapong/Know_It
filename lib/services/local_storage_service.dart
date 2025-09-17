import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;

  LocalStorageService._internal();

  static const String _themeKey = 'theme_mode';
  final GetStorage _box = GetStorage();

  /// Save theme mode
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    String modeString = _themeModeToString(themeMode);
    await _box.write(_themeKey, modeString);
  }

  /// Load theme mode
  ThemeMode loadThemeMode() {
    String? modeString = _box.read<String>(_themeKey);
    if (modeString == null) return ThemeMode.system;
    return _stringToThemeMode(modeString);
  }

  /// Convert ThemeMode to string
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Convert string back to ThemeMode
  ThemeMode _stringToThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
