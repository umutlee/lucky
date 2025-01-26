import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:matcher/matcher.dart' as matcher;
import '../../../lib/core/database/database_helper.dart';
import '../../../lib/core/services/sqlite_preferences_service.dart';
import 'sqlite_preferences_service_test.mocks.dart';

class MockDatabaseHelperBase implements DatabaseHelper {
  @override
  Future<Database> get database => throw UnimplementedError();

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) {
    throw UnimplementedError();
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) {
    throw UnimplementedError();
  }

  @override
  Future<bool> init() {
    throw UnimplementedError();
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> values, {ConflictAlgorithm? conflictAlgorithm}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> query(String table, {bool? distinct, List<String>? columns, String? where, List<Object?>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset}) {
    throw UnimplementedError();
  }

  @override
  Future<int> update(String table, Map<String, dynamic> values, {String? where, List<Object?>? whereArgs}) {
    throw UnimplementedError();
  }
}

@GenerateMocks([MockDatabaseHelperBase])
void main() {
  late SQLitePreferencesService service;
  late MockMockDatabaseHelperBase mockDatabaseHelper;

  setUp(() {
    mockDatabaseHelper = MockMockDatabaseHelperBase();
    service = SQLitePreferencesService(mockDatabaseHelper);

    // 設置基本的 mock 行為
    when(mockDatabaseHelper.init()).thenAnswer((_) async => true);
    when(mockDatabaseHelper.insert(
      any,
      any,
      conflictAlgorithm: anyNamed('conflictAlgorithm'),
    )).thenAnswer((_) async => 1);
    when(mockDatabaseHelper.query(
      any,
      distinct: anyNamed('distinct'),
      columns: anyNamed('columns'),
      where: anyNamed('where'),
      whereArgs: anyNamed('whereArgs'),
      groupBy: anyNamed('groupBy'),
      having: anyNamed('having'),
      orderBy: anyNamed('orderBy'),
      limit: anyNamed('limit'),
      offset: anyNamed('offset'),
    )).thenAnswer((_) async => []);
  });

  group('SQLitePreferencesService', () {
    test('初始化時應該設置默認值', () async {
      when(mockDatabaseHelper.execute(any))
          .thenAnswer((_) async {});
      when(mockDatabaseHelper.query(
        'preferences',
        limit: 1,
      )).thenAnswer((_) async => []);

      await service.init();

      verify(mockDatabaseHelper.init()).called(1);
      verify(mockDatabaseHelper.query(
        'preferences',
        limit: 1,
      )).called(1);
      verify(mockDatabaseHelper.insert(
        'preferences',
        {
          'key': 'daily_notification',
          'value': 'true',
          'type': 'bool',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      )).called(1);
      verify(mockDatabaseHelper.insert(
        'preferences',
        {
          'key': 'notification_time',
          'value': '09:00',
          'type': 'string',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      )).called(1);
    });

    test('setDailyNotification 應該正確保存值', () async {
      await service.setDailyNotification(false);

      verify(mockDatabaseHelper.insert(
        'preferences',
        {
          'key': 'daily_notification',
          'value': 'false',
          'type': 'bool',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      )).called(1);
    });

    test('setNotificationTime 應該正確保存值', () async {
      const testTime = '10:30';
      await service.setNotificationTime(testTime);

      verify(mockDatabaseHelper.insert(
        'preferences',
        {
          'key': 'notification_time',
          'value': testTime,
          'type': 'string',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      )).called(1);
    });

    test('clear 應該清除所有設置', () async {
      when(mockDatabaseHelper.delete(any))
          .thenAnswer((_) async => 1);

      await service.clear();

      verify(mockDatabaseHelper.delete('preferences')).called(1);
      verify(mockDatabaseHelper.insert(
        'preferences',
        {
          'key': 'daily_notification',
          'value': 'true',
          'type': 'bool',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      )).called(1);
      verify(mockDatabaseHelper.insert(
        'preferences',
        {
          'key': 'notification_time',
          'value': '09:00',
          'type': 'string',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      )).called(1);
    });

    test('getDailyNotification 應該返回正確的值', () async {
      when(mockDatabaseHelper.query(
        'preferences',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: ['daily_notification'],
      )).thenAnswer((_) async => [{
        'value': 'false',
      }]);

      final result = await service.getDailyNotification();
      expect(result, false);
    });

    test('getNotificationTime 應該返回正確的值', () async {
      when(mockDatabaseHelper.query(
        'preferences',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: ['notification_time'],
      )).thenAnswer((_) async => [{
        'value': '10:30',
      }]);

      final result = await service.getNotificationTime();
      expect(result, '10:30');
    });

    test('在數據庫錯誤時應該返回默認值', () async {
      when(mockDatabaseHelper.query(
        'preferences',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: ['daily_notification'],
      )).thenThrow(Exception('Database error'));

      when(mockDatabaseHelper.query(
        'preferences',
        columns: ['value'],
        where: 'key = ?',
        whereArgs: ['notification_time'],
      )).thenThrow(Exception('Database error'));

      expect(await service.getDailyNotification(), true);
      expect(await service.getNotificationTime(), '08:00');
    });
  });
} 