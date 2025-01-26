import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../../../lib/core/database/database_helper.dart';
import '../../../lib/core/services/sqlite_preferences_service.dart';
import 'sqlite_preferences_service_test.mocks.dart';

@GenerateMocks([Database])
class MockDatabaseHelper extends Mock implements DatabaseHelper {}

void main() {
  late SQLitePreferencesService service;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
    service = SQLitePreferencesService(mockDatabaseHelper);
  });

  group('SQLitePreferencesService', () {
    test('初始化時應該設置默認值', () async {
      when(mockDatabaseHelper.execute(argThat(isA<String>())))
          .thenAnswer((_) async {});
      when(mockDatabaseHelper.query(
        argThat(equals('preferences')),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []);
      when(mockDatabaseHelper.insert(
        argThat(equals('preferences')),
        argThat(isA<Map<String, dynamic>>()),
      )).thenAnswer((_) async => 1);

      await service.init();

      verify(mockDatabaseHelper.execute(argThat(contains('CREATE TABLE IF NOT EXISTS preferences')))).called(1);
      verify(mockDatabaseHelper.query(
        'preferences',
        where: 'key = ?',
        whereArgs: ['daily_notification'],
      )).called(1);
      verify(mockDatabaseHelper.insert('preferences', argThat(isA<Map<String, dynamic>>()))).called(2);
    });

    test('setDailyNotification 應該正確保存值', () async {
      when(mockDatabaseHelper.query(
        argThat(equals('preferences')),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []);
      when(mockDatabaseHelper.insert(
        argThat(equals('preferences')),
        argThat(isA<Map<String, dynamic>>()),
      )).thenAnswer((_) async => 1);

      await service.setDailyNotification(false);

      verify(mockDatabaseHelper.insert('preferences', {
        'key': 'daily_notification',
        'value': 'false',
        'type': 'bool',
        'updated_at': any,
      })).called(1);
    });

    test('setNotificationTime 應該正確保存值', () async {
      const testTime = '10:30';
      when(mockDatabaseHelper.query(
        argThat(equals('preferences')),
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []);
      when(mockDatabaseHelper.insert(
        argThat(equals('preferences')),
        argThat(isA<Map<String, dynamic>>()),
      )).thenAnswer((_) async => 1);

      await service.setNotificationTime(testTime);

      verify(mockDatabaseHelper.insert('preferences', {
        'key': 'notification_time',
        'value': testTime,
        'type': 'string',
        'updated_at': any,
      })).called(1);
    });

    test('clear 應該清除所有設置', () async {
      when(mockDatabaseHelper.delete(argThat(equals('preferences'))))
          .thenAnswer((_) async => 1);
      when(mockDatabaseHelper.insert(
        argThat(equals('preferences')),
        argThat(isA<Map<String, dynamic>>()),
      )).thenAnswer((_) async => 1);

      await service.clear();

      verify(mockDatabaseHelper.delete('preferences')).called(1);
      verify(mockDatabaseHelper.insert('preferences', {
        'key': 'daily_notification',
        'value': 'true',
        'type': 'bool',
        'updated_at': any,
      })).called(1);
      verify(mockDatabaseHelper.insert('preferences', {
        'key': 'notification_time',
        'value': '09:00',
        'type': 'string',
        'updated_at': any,
      })).called(1);
    });

    test('getDailyNotification 應該返回正確的值', () async {
      when(mockDatabaseHelper.query(
        'preferences',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [{
        'key': 'daily_notification',
        'value': 'false',
        'type': 'bool',
      }]);

      final result = await service.getDailyNotification();
      expect(result, false);
    });

    test('getNotificationTime 應該返回正確的值', () async {
      when(mockDatabaseHelper.query(
        'preferences',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [{
        'key': 'notification_time',
        'value': '10:30',
        'type': 'string',
      }]);

      final result = await service.getNotificationTime();
      expect(result, '10:30');
    });

    test('在數據庫錯誤時應該返回默認值', () async {
      when(mockDatabaseHelper.query(
        'preferences',
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenThrow(Exception('Database error'));

      expect(await service.getDailyNotification(), true);
      expect(await service.getNotificationTime(), '08:00');
    });
  });
} 