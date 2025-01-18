import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:all_lucky/core/services/user_settings_service.dart';
import 'package:all_lucky/core/models/user_settings.dart';

void main() {
  late UserSettingsService service;

  setUp(() {
    service = UserSettingsService();
    SharedPreferences.setMockInitialValues({});
  });

  group('UserSettingsService Tests', () {
    test('loadSettings returns default settings when no settings saved', () async {
      final settings = await service.loadSettings();
      expect(settings.zodiac, '龍');
      expect(settings.enableNotifications, true);
      expect(settings.preferredFortuneTypes, ['日常', '事業', '學習', '財運', '人際']);
    });

    test('saveSettings and loadSettings work correctly', () async {
      final initialSettings = UserSettings(
        zodiac: '虎',
        birthYear: 1998,
        enableNotifications: false,
        preferredFortuneTypes: ['事業', '財運'],
      );

      await service.saveSettings(initialSettings);
      final loadedSettings = await service.loadSettings();

      expect(loadedSettings.zodiac, '虎');
      expect(loadedSettings.birthYear, 1998);
      expect(loadedSettings.enableNotifications, false);
      expect(loadedSettings.preferredFortuneTypes, ['事業', '財運']);
    });

    test('calculateZodiac returns correct zodiac for birth year', () {
      expect(service.calculateZodiac(2024), '龍');
      expect(service.calculateZodiac(2023), '兔');
      expect(service.calculateZodiac(2022), '虎');
      expect(service.calculateZodiac(1998), '虎');
    });

    test('isValidZodiac validates zodiac correctly', () {
      expect(service.isValidZodiac('龍'), true);
      expect(service.isValidZodiac('無效'), false);
    });

    test('isValidBirthYear validates birth year correctly', () {
      final currentYear = DateTime.now().year;
      expect(service.isValidBirthYear(currentYear), true);
      expect(service.isValidBirthYear(currentYear - 50), true);
      expect(service.isValidBirthYear(currentYear + 1), false);
      expect(service.isValidBirthYear(currentYear - 121), false);
    });

    test('updateUserZodiac updates zodiac correctly', () async {
      await service.updateUserZodiac('虎');
      final settings = await service.loadSettings();
      expect(settings.zodiac, '虎');
    });

    test('updateUserZodiac throws error for invalid zodiac', () async {
      expect(() => service.updateUserZodiac('無效'), throwsArgumentError);
    });

    test('updateBirthYear updates birth year and zodiac correctly', () async {
      await service.updateBirthYear(1998);
      final settings = await service.loadSettings();
      expect(settings.birthYear, 1998);
      expect(settings.zodiac, '虎');
    });

    test('updateBirthYear throws error for invalid birth year', () async {
      final currentYear = DateTime.now().year;
      expect(() => service.updateBirthYear(currentYear + 1), throwsArgumentError);
    });

    test('updateNotificationSettings updates notification settings correctly', () async {
      await service.updateNotificationSettings(false);
      final settings = await service.loadSettings();
      expect(settings.enableNotifications, false);
    });

    test('updatePreferredFortuneTypes updates fortune types correctly', () async {
      final newTypes = ['事業', '財運'];
      await service.updatePreferredFortuneTypes(newTypes);
      final settings = await service.loadSettings();
      expect(settings.preferredFortuneTypes, newTypes);
    });
  });
} 