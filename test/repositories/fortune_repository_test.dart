import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:all_lucky/core/services/database_service.dart';
import 'package:all_lucky/core/repositories/fortune_repository.dart';
import 'package:all_lucky/core/models/daily_fortune.dart';

@GenerateMocks([Dio, DatabaseService])
void main() {
  late MockDio mockDio;
  late MockDatabaseService mockDatabase;
  late FortuneRepository repository;

  setUp(() {
    mockDio = MockDio();
    mockDatabase = MockDatabaseService();
    repository = FortuneRepository(mockDio, mockDatabase);
  });

  group('FortuneRepository', () {
    final testDate = DateTime(2024, 1, 20);
    final testFortune = DailyFortune(
      goodFor: const ['讀書', '運動'],
      badFor: const ['旅行'],
      luckyHours: const [9, 13, 17],
    );

    test('應該優先使用緩存數據', () async {
      // 準備緩存數據
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => [{
        'value': json.encode(testFortune.toJson()),
      }]);

      // 執行
      final result = await repository.getDailyFortune(testDate);

      // 驗證
      expect(result.goodFor, equals(testFortune.goodFor));
      expect(result.badFor, equals(testFortune.badFor));
      verify(mockDatabase.query(any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs'))).called(1);
      verifyNever(mockDio.get(any));
    });
    
    test('緩存失效時應該請求API', () async {
      // 模擬緩存未命中
      when(mockDatabase.query(
        any,
        where: anyNamed('where'),
        whereArgs: anyNamed('whereArgs'),
      )).thenAnswer((_) async => []);

      // 模擬API響應
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: ''),
                data: testFortune.toJson(),
                statusCode: 200,
              ));

      // 執行
      final result = await repository.getDailyFortune(testDate);

      // 驗證
      expect(result.goodFor, equals(testFortune.goodFor));
      verify(mockDatabase.query(any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs'))).called(1);
      verify(mockDio.get(any, queryParameters: anyNamed('queryParameters'))).called(1);
      verify(mockDatabase.insert(any, any, conflictAlgorithm: anyNamed('conflictAlgorithm'))).called(1);
    });
  });
} 