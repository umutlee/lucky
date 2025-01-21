import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:all_lucky/core/services/database_service.dart';
import 'package:all_lucky/core/repositories/almanac_repository.dart';
import 'package:all_lucky/core/models/lunar_date.dart';
import 'package:all_lucky/core/models/almanac.dart';

class MockDio extends Mock implements Dio {}
class MockDatabaseService extends Mock implements DatabaseService {}

void main() {
  late MockDio mockDio;
  late MockDatabaseService mockDatabase;
  late AlmanacRepository repository;

  setUp(() {
    mockDio = MockDio();
    mockDatabase = MockDatabaseService();
    repository = AlmanacRepository(mockDio, mockDatabase);
  });

  group('AlmanacRepository', () {
    final testDate = DateTime(2024, 1, 20);
    final testLunarDate = LunarDate(
      year: 2024,
      month: 12,
      day: 10,
      isLeapMonth: false,
    );

    test('應該正確計算並緩存農曆日期', () async {
      // 模擬緩存未命中
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []);

      // 執行
      final result = await repository.getLunarDate(testDate);

      // 驗證
      expect(result.year, equals(testLunarDate.year));
      expect(result.month, equals(testLunarDate.month));
      expect(result.day, equals(testLunarDate.day));
      verify(mockDatabase.insert(any, any, conflictAlgorithm: anyNamed('conflictAlgorithm'))).called(1);
    });

    test('應該從緩存獲取黃曆數據', () async {
      final testAlmanac = Almanac(
        suitableFor: ['祭祀', '結婚'],
        unsuitable: ['搬家', '動土'],
        lunarDate: testLunarDate,
      );

      // 準備緩存數據
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [{
        'value': json.encode(testAlmanac.toJson()),
      }]);

      // 執行
      final result = await repository.getAlmanac(testDate);

      // 驗證
      expect(result.suitableFor, equals(testAlmanac.suitableFor));
      expect(result.unsuitable, equals(testAlmanac.unsuitable));
      verify(mockDatabase.query(any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs'))).called(1);
      verifyNever(mockDio.get(any));
    });

    test('緩存失效時應該從API獲取黃曆數據', () async {
      final testAlmanac = Almanac(
        suitableFor: ['祭祀', '結婚'],
        unsuitable: ['搬家', '動土'],
        lunarDate: testLunarDate,
      );

      // 模擬緩存未命中
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []);

      // 模擬API響應
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: testAlmanac.toJson(),
        statusCode: 200,
      ));

      // 執行
      final result = await repository.getAlmanac(testDate);

      // 驗證
      expect(result.suitableFor, equals(testAlmanac.suitableFor));
      expect(result.unsuitable, equals(testAlmanac.unsuitable));
      verify(mockDatabase.query(any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs'))).called(1);
      verify(mockDio.get(any, queryParameters: anyNamed('queryParameters'), options: anyNamed('options'))).called(1);
      verify(mockDatabase.insert(any, any, conflictAlgorithm: anyNamed('conflictAlgorithm'))).called(1);
    });

    test('API請求失敗時應該返回空數據', () async {
      // 模擬緩存未命中
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []);

      // 模擬API請求失敗
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'Network error',
      ));

      // 執行
      final result = await repository.getAlmanac(testDate);

      // 驗證
      expect(result.suitableFor, isEmpty);
      expect(result.unsuitable, isEmpty);
      verify(mockDatabase.query(any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs'))).called(1);
      verify(mockDio.get(any, queryParameters: anyNamed('queryParameters'), options: anyNamed('options'))).called(1);
      verifyNever(mockDatabase.insert(any, any, conflictAlgorithm: anyNamed('conflictAlgorithm')));
    });

    test('清除過期緩存應該正確執行', () async {
      // 執行
      await repository.clearExpiredCache();

      // 驗證
      verify(mockDatabase.delete(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).called(1);
    });

    test('獲取月份農曆日期列表應該正確執行', () async {
      // 模擬緩存未命中
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []);

      // 執行
      final results = await repository.getMonthLunarDates(2024, 1);

      // 驗證
      expect(results.length, equals(31)); // 1月有31天
      verify(mockDatabase.insert(any, any, conflictAlgorithm: anyNamed('conflictAlgorithm'))).called(31);
    });
  });
} 