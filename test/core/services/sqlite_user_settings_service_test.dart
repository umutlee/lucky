import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../../../lib/core/database/database_helper.dart';
import '../../../lib/core/services/sqlite_user_settings_service.dart';
import '../../../lib/core/models/user_settings.dart';
import '../../../lib/core/models/zodiac.dart';
import 'sqlite_user_settings_service_test.mocks.dart';

@GenerateMocks([Database])
class MockDatabaseHelper extends Mock implements DatabaseHelper {}

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
      when(mockDatabaseHelper.execute(argThat(isA<String>())))
          .thenAnswer((_) async {});
      when(mockDatabaseHelper.query(
        argThat(equals('user_settings')),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => []);
      when(mockDatabaseHelper.insert(
        argThat(equals('user_settings')),
        argThat(isA<Map<String, dynamic>>()),
      )).thenAnswer((_) async => 1);

      await service.init();

      verify(mockDatabaseHelper.execute(argThat(contains('CREATE TABLE IF NOT EXISTS user_settings')))).called(1);
      verify(mockDatabaseHelper.insert('user_settings', argThat(isA<Map<String, dynamic>>()))).called(1);
    });

    test('getUserSettings should return null when no settings exist', () async {
      when(mockDatabaseHelper.query(
        argThat(equals('user_settings')),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => []);

      final result = await service.getUserSettings();

      expect(result, isNull);
    });

    test('getUserSettings should return UserSettings when settings exist', () async {
      final testData = {
        'id': 1,
        'zodiac': 'rabbit',
        'chinese_zodiac': '兔',
        'daily_notification': 0,
        'notification_time': '10:30',
        'updated_at': DateTime.now().toIso8601String(),
      };

      when(mockDatabaseHelper.query(
        argThat(equals('user_settings')),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => [testData]);

      final result = await service.getUserSettings();

      expect(result, isNotNull);
      expect(result!.zodiac, equals(Zodiac.rabbit));
      expect(result.chineseZodiac, equals('兔'));
      expect(result.dailyNotification, isFalse);
      expect(result.notificationTime, equals('10:30'));
    });

    test('updateUserZodiac should update zodiac', () async {
      final testData = {
        'id': 1,
        'zodiac': 'rabbit',
        'chinese_zodiac': '兔',
        'daily_notification': 1,
        'notification_time': '09:00',
        'updated_at': DateTime.now().toIso8601String(),
      };

      when(mockDatabaseHelper.query(
        argThat(equals('user_settings')),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => [testData]);
      when(mockDatabaseHelper.delete(argThat(equals('user_settings'))))
          .thenAnswer((_) async => 1);
      when(mockDatabaseHelper.insert(
        argThat(equals('user_settings')),
        argThat(isA<Map<String, dynamic>>()),
      )).thenAnswer((_) async => 1);

      await service.setZodiac(Zodiac.rabbit);

      verify(mockDatabaseHelper.delete('user_settings')).called(1);
      verify(mockDatabaseHelper.insert('user_settings', argThat(predicate((Map<String, dynamic> map) =>
          map['zodiac'] == 'rabbit' && map['chinese_zodiac'] == '兔')))).called(1);
    });

    test('updateBirthYear should throw ArgumentError for invalid year', () async {
      expect(() => service.updateBirthYear(1800), throwsArgumentError);
    });

    test('updateNotificationTime should throw ArgumentError for invalid time format', () async {
      expect(() => service.updateNotificationTime('25:00'), throwsArgumentError);
      expect(() => service.updateNotificationTime('09:60'), throwsArgumentError);
      expect(() => service.updateNotificationTime('invalid'), throwsArgumentError);
    });

    test('completeOnboarding should update both onboarding and first launch flags', () async {
      final testData = {
        'id': 1,
        'zodiac': 'rabbit',
        'chinese_zodiac': '兔',
        'daily_notification': 1,
        'notification_time': '09:00',
        'updated_at': DateTime.now().toIso8601String(),
      };

      when(mockDatabaseHelper.query(
        argThat(equals('user_settings')),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => [testData]);
      when(mockDatabaseHelper.delete(argThat(equals('user_settings'))))
          .thenAnswer((_) async => 1);
      when(mockDatabaseHelper.insert(
        argThat(equals('user_settings')),
        argThat(isA<Map<String, dynamic>>()),
      )).thenAnswer((_) async => 1);

      await service.setDailyNotification(false);

      verify(mockDatabaseHelper.insert('user_settings', argThat(predicate((Map<String, dynamic> map) =>
          map['daily_notification'] == 0)))).called(1);
    });

    test('updatePreferredFortuneTypes should encode list correctly', () async {
      final testData = {
        'id': 1,
        'zodiac': 'rabbit',
        'chinese_zodiac': '兔',
        'daily_notification': 1,
        'notification_time': '09:00',
        'updated_at': DateTime.now().toIso8601String(),
      };

      when(mockDatabaseHelper.query(
        argThat(equals('user_settings')),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => [testData]);
      when(mockDatabaseHelper.delete(argThat(equals('user_settings'))))
          .thenAnswer((_) async => 1);
      when(mockDatabaseHelper.insert(
        argThat(equals('user_settings')),
        argThat(isA<Map<String, dynamic>>()),
      )).thenAnswer((_) async => 1);

      final types = ['daily', 'weekly', 'monthly'];
      await service.updatePreferredFortuneTypes(types);

      verify(mockDatabaseHelper.insert('user_settings', argThat(predicate((Map<String, dynamic> map) =>
          map['preferred_fortune_types'] == jsonEncode(types))))).called(1);
    });
  });
} 