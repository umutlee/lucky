import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../lib/core/database/database_helper.dart';
import '../../../lib/core/services/sqlite_user_settings_service.dart';
import '../../../lib/core/models/user_settings.dart';
import '../../../lib/core/models/zodiac.dart';

@GenerateMocks([DatabaseHelper, Database])
void main() {
  late SQLiteUserSettingsService service;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
    service = SQLiteUserSettingsService(mockDatabaseHelper);
  });

  group('SQLiteUserSettingsService', () {
    test('init should create table and initialize default settings if needed', () async {
      when(mockDatabase.execute(any)).thenAnswer((_) async {});
      when(mockDatabase.query(any, limit: anyNamed('limit'))).thenAnswer((_) async => []);
      when(mockDatabase.insert(any, any)).thenAnswer((_) async => 1);

      await service.init();

      verify(mockDatabase.execute(argThat(contains('CREATE TABLE IF NOT EXISTS user_settings')))).called(1);
      verify(mockDatabase.query('user_settings', limit: 1)).called(1);
      verify(mockDatabase.insert('user_settings', any)).called(1);
    });

    test('getUserSettings should return null when no settings exist', () async {
      when(mockDatabase.query(any, limit: anyNamed('limit'))).thenAnswer((_) async => []);

      final result = await service.getUserSettings();

      expect(result, isNull);
    });

    test('getUserSettings should return UserSettings when settings exist', () async {
      final testData = {
        'zodiac': 'Zodiac.rat',
        'birth_year': 2000,
        'notifications_enabled': 1,
        'location_permission_granted': 0,
        'onboarding_completed': 1,
        'terms_accepted': 1,
        'privacy_accepted': 0,
        'is_first_launch': 0,
        'preferred_fortune_types': '["daily", "weekly"]',
        'notification_time': '09:00',
        'selected_language': 'zh_TW',
        'selected_theme': 'light',
      };

      when(mockDatabase.query(any, limit: anyNamed('limit'))).thenAnswer((_) async => [testData]);

      final result = await service.getUserSettings();

      expect(result, isNotNull);
      expect(result!.zodiac, equals(Zodiac.rat));
      expect(result.birthYear, equals(2000));
      expect(result.notificationsEnabled, isTrue);
      expect(result.locationPermissionGranted, isFalse);
      expect(result.onboardingCompleted, isTrue);
      expect(result.termsAccepted, isTrue);
      expect(result.privacyAccepted, isFalse);
      expect(result.isFirstLaunch, isFalse);
      expect(result.preferredFortuneTypes, equals(['daily', 'weekly']));
      expect(result.notificationTime, equals('09:00'));
      expect(result.selectedLanguage, equals('zh_TW'));
      expect(result.selectedTheme, equals('light'));
    });

    test('updateUserZodiac should update zodiac', () async {
      final testData = {
        'zodiac': 'Zodiac.rat',
        'birth_year': 2000,
        'notifications_enabled': 1,
      };

      when(mockDatabase.query(any, limit: anyNamed('limit'))).thenAnswer((_) async => [testData]);
      when(mockDatabase.delete(any)).thenAnswer((_) async => 1);
      when(mockDatabase.insert(any, any)).thenAnswer((_) async => 1);

      await service.updateUserZodiac(Zodiac.ox);

      verify(mockDatabase.delete('user_settings')).called(1);
      verify(mockDatabase.insert('user_settings', argThat(predicate((Map<String, dynamic> map) =>
          map['zodiac'] == 'Zodiac.ox')))).called(1);
    });

    test('updateBirthYear should throw ArgumentError for invalid year', () async {
      expect(() => service.updateBirthYear(1800), throwsArgumentError);
      expect(() => service.updateBirthYear(2100), throwsArgumentError);
    });

    test('updateNotificationTime should throw ArgumentError for invalid time format', () async {
      expect(() => service.updateNotificationTime('25:00'), throwsArgumentError);
      expect(() => service.updateNotificationTime('09:60'), throwsArgumentError);
      expect(() => service.updateNotificationTime('invalid'), throwsArgumentError);
    });

    test('completeOnboarding should update both onboarding and first launch flags', () async {
      final testData = {
        'zodiac': 'Zodiac.rat',
        'birth_year': 2000,
        'onboarding_completed': 0,
        'is_first_launch': 1,
      };

      when(mockDatabase.query(any, limit: anyNamed('limit'))).thenAnswer((_) async => [testData]);
      when(mockDatabase.delete(any)).thenAnswer((_) async => 1);
      when(mockDatabase.insert(any, any)).thenAnswer((_) async => 1);

      await service.completeOnboarding();

      verify(mockDatabase.insert('user_settings', argThat(predicate((Map<String, dynamic> map) =>
          map['onboarding_completed'] == 1 && map['is_first_launch'] == 0)))).called(1);
    });

    test('updatePreferredFortuneTypes should encode list correctly', () async {
      final testData = {
        'zodiac': 'Zodiac.rat',
        'birth_year': 2000,
        'preferred_fortune_types': '[]',
      };

      when(mockDatabase.query(any, limit: anyNamed('limit'))).thenAnswer((_) async => [testData]);
      when(mockDatabase.delete(any)).thenAnswer((_) async => 1);
      when(mockDatabase.insert(any, any)).thenAnswer((_) async => 1);

      final types = ['daily', 'weekly', 'monthly'];
      await service.updatePreferredFortuneTypes(types);

      verify(mockDatabase.insert('user_settings', argThat(predicate((Map<String, dynamic> map) =>
          map['preferred_fortune_types'] == '["daily","weekly","monthly"]')))).called(1);
    });
  });
} 