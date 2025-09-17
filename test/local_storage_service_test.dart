import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:know_it/services/local_storage_service.dart';

void main() {
  late LocalStorageService storage;

  setUp(() async {
    // Each test gets its own isolated storage container
    await GetStorage.init('test_storage');
    storage = LocalStorageService();
  });

  tearDown(() async {
    // Clear test storage after each test
    await GetStorage('test_storage').erase();
  });

  group('LocalStorageService ThemeMode persistence', () {
    test('Default load should return ThemeMode.system when nothing is saved', () {
      final mode = storage.loadThemeMode();
      expect(mode, ThemeMode.system);
    });

    test('Save and load ThemeMode.light', () async {
      await storage.saveThemeMode(ThemeMode.light);
      final mode = storage.loadThemeMode();
      expect(mode, ThemeMode.light);
    });

    test('Save and load ThemeMode.dark', () async {
      await storage.saveThemeMode(ThemeMode.dark);
      final mode = storage.loadThemeMode();
      expect(mode, ThemeMode.dark);
    });

    test('Save and load ThemeMode.system', () async {
      await storage.saveThemeMode(ThemeMode.system);
      final mode = storage.loadThemeMode();
      expect(mode, ThemeMode.system);
    });

    test('Invalid stored value should fall back to ThemeMode.system', () async {
      final box = GetStorage('test_storage');
      await box.write('theme_mode', 'invalid_value');

      final mode = storage.loadThemeMode();
      expect(mode, ThemeMode.system);
    });
  });
}
