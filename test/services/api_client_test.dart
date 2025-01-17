import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import '../../lib/core/services/api_client.dart';
import '../../lib/core/services/storage_service.dart';
import '../../lib/core/config/api_error_codes.dart';
import '../../lib/core/exceptions/api_exception.dart';
import 'mock_api_server.dart';
import 'api_client_test.mocks.dart';

@GenerateMocks([StorageService, Dio])
void main() {
  late ApiClient apiClient;
  late MockStorageService mockStorage;
  late MockDio mockDio;

  setUp(() {
    mockStorage = MockStorageService();
    mockDio = MockDio();
    apiClient = ApiClient(mockStorage, dio: mockDio);
  });

  group('API 請求測試', () {
    test('成功發送 GET 請求', () async {
      final expectedData = {'test': 'data'};
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => MockApiServer.successResponse(data: expectedData));

      final response = await apiClient.get<Map<String, dynamic>>(
        '/test',
        queryParameters: {'key': 'value'},
      );
      
      expect(response.isSuccess, true);
      expect(response.data, equals(expectedData));
      verify(mockDio.get('/test', queryParameters: {'key': 'value'})).called(1);
    });

    test('成功發送 POST 請求', () async {
      final requestData = {'key': 'value'};
      final expectedData = {'result': 'success'};
      
      when(mockDio.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => MockApiServer.successResponse(data: expectedData));

      final response = await apiClient.post<Map<String, dynamic>>(
        '/test',
        data: requestData,
      );
      
      expect(response.isSuccess, true);
      expect(response.data, equals(expectedData));
      verify(mockDio.post('/test', data: requestData)).called(1);
    });
  });

  group('錯誤處理測試', () {
    test('網絡錯誤處理', () async {
      when(mockDio.get(any))
          .thenThrow(MockApiServer.networkException());

      try {
        await apiClient.get('/error');
        fail('應該拋出異常');
      } on ApiException catch (e) {
        expect(e.code, ApiErrorCodes.networkError);
        expect(e.message, isNotEmpty);
      }
    });

    test('無效響應處理', () async {
      when(mockDio.get(any))
          .thenAnswer((_) async => MockApiServer.invalidResponse());

      try {
        await apiClient.get('/invalid');
        fail('應該拋出異常');
      } on ApiException catch (e) {
        expect(e.code, ApiErrorCodes.invalidResponse);
        expect(e.message, isNotEmpty);
      }
    });

    test('超時錯誤處理', () async {
      when(mockDio.get(any))
          .thenThrow(MockApiServer.timeoutException());

      try {
        await apiClient.get('/timeout');
        fail('應該拋出異常');
      } on ApiException catch (e) {
        expect(e.code, ApiErrorCodes.timeoutError);
        expect(e.message, isNotEmpty);
      }
    });
  });

  group('緩存測試', () {
    test('使用緩存數據', () async {
      final cachedData = {'cached': true};
      when(mockStorage.getCachedFortune<Map<String, dynamic>>(any))
          .thenAnswer((_) async => cachedData);

      final response = await apiClient.get<Map<String, dynamic>>(
        '/cached',
        forceRefresh: false,
      );

      expect(response.data, equals(cachedData));
      verify(mockStorage.getCachedFortune(any)).called(1);
      verifyNever(mockDio.get(any));
    });

    test('強制刷新忽略緩存', () async {
      final cachedData = {'cached': true};
      final freshData = {'fresh': true};
      
      when(mockStorage.getCachedFortune<Map<String, dynamic>>(any))
          .thenAnswer((_) async => cachedData);
      when(mockDio.get(any))
          .thenAnswer((_) async => MockApiServer.successResponse(data: freshData));

      final response = await apiClient.get<Map<String, dynamic>>(
        '/cached',
        forceRefresh: true,
      );

      expect(response.data, equals(freshData));
      verifyNever(mockStorage.getCachedFortune(any));
      verify(mockDio.get(any)).called(1);
    });

    test('緩存過期後重新獲取', () async {
      when(mockStorage.getCachedFortune<Map<String, dynamic>>(any))
          .thenAnswer((_) async => null);
      when(mockDio.get(any))
          .thenAnswer((_) async => MockApiServer.successResponse());

      await apiClient.get<Map<String, dynamic>>('/expired');

      verify(mockStorage.getCachedFortune(any)).called(1);
      verify(mockDio.get(any)).called(1);
      verify(mockStorage.cacheFortune(any, any)).called(1);
    });
  });

  group('攔截器測試', () {
    test('請求頭設置', () async {
      when(mockDio.get(any))
          .thenAnswer((_) async => MockApiServer.successResponse());

      await apiClient.get('/headers');

      verify(mockDio.get(
        any,
        options: argThat(
          predicate<Options>((options) =>
              options.headers?['Accept'] == 'application/json' &&
              options.headers?['Content-Type'] == 'application/json'),
          named: 'options',
        ),
      )).called(1);
    });

    test('響應數據轉換', () async {
      final testData = {'key': 'value'};
      when(mockDio.get(any))
          .thenAnswer((_) async => MockApiServer.successResponse(data: testData));

      final response = await apiClient.get<Map<String, dynamic>>(
        '/transform',
        fromJson: (json) => json,
      );

      expect(response.data, equals(testData));
    });
  });
}