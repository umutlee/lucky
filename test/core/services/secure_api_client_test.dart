import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:all_lucky/core/services/secure_api_client.dart';
import 'package:all_lucky/core/services/encryption_service.dart';

@GenerateMocks([
  Dio,
  EncryptionService,
])
import 'secure_api_client_test.mocks.dart';

void main() {
  late SecureApiClient apiClient;
  late MockDio mockDio;
  late MockEncryptionService mockEncryptionService;

  setUp(() {
    mockDio = MockDio();
    mockEncryptionService = MockEncryptionService();
    apiClient = SecureApiClient(mockEncryptionService, dio: mockDio);
  });

  group('SecureApiClient', () {
    test('GET 請求測試', () async {
      const path = '/api/fortune';
      final responseData = {'status': 'success', 'data': 'encrypted_data'};
      final decryptedData = {'fortune': '今日運勢不錯'};
      
      when(mockDio.get<Map<String, dynamic>>(
        path,
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      ));
      
      when(mockEncryptionService.decrypt('encrypted_data'))
          .thenReturn(jsonEncode(decryptedData));
      
      final result = await apiClient.get<Map<String, dynamic>>(path);
      
      expect(result, equals(decryptedData));
      verify(mockDio.get<Map<String, dynamic>>(path, options: anyNamed('options'))).called(1);
      verify(mockEncryptionService.decrypt('encrypted_data')).called(1);
    });

    test('POST 請求測試', () async {
      const path = '/api/fortune/save';
      final requestData = {'type': '學習', 'score': 85};
      final encryptedRequestData = 'encrypted_request_data';
      final responseData = {'status': 'success', 'data': 'encrypted_response'};
      final decryptedResponse = {'id': '123', 'message': '保存成功'};
      
      when(mockEncryptionService.encrypt(jsonEncode(requestData)))
          .thenReturn(encryptedRequestData);
      
      when(mockDio.post<Map<String, dynamic>>(
        path,
        data: {'data': encryptedRequestData},
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      ));
      
      when(mockEncryptionService.decrypt('encrypted_response'))
          .thenReturn(jsonEncode(decryptedResponse));
      
      final result = await apiClient.post<Map<String, dynamic>>(
        path,
        data: requestData,
      );
      
      expect(result, equals(decryptedResponse));
      verify(mockEncryptionService.encrypt(jsonEncode(requestData))).called(1);
      verify(mockDio.post<Map<String, dynamic>>(
        path,
        data: {'data': encryptedRequestData},
        options: anyNamed('options'),
      )).called(1);
      verify(mockEncryptionService.decrypt('encrypted_response')).called(1);
    });

    test('請求失敗處理測試', () async {
      const path = '/api/fortune';
      
      when(mockDio.get<Map<String, dynamic>>(
        path,
        options: anyNamed('options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: path),
        error: '網絡錯誤',
      ));
      
      expect(
        () => apiClient.get<Map<String, dynamic>>(path),
        throwsA(isA<DioException>()),
      );
    });

    test('解密失敗處理測試', () async {
      const path = '/api/fortune';
      final responseData = {'status': 'success', 'data': 'invalid_encrypted_data'};
      
      when(mockDio.get<Map<String, dynamic>>(
        path,
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      ));
      
      when(mockEncryptionService.decrypt('invalid_encrypted_data'))
          .thenThrow(FormatException('解密失敗'));
      
      expect(
        () => apiClient.get<Map<String, dynamic>>(path),
        throwsA(isA<FormatException>()),
      );
    });

    test('API Key 生成測試', () async {
      const path = '/api/fortune';
      final responseData = {'status': 'success', 'data': 'encrypted_data'};
      final decryptedData = {'fortune': '今日運勢不錯'};
      
      when(mockDio.get<Map<String, dynamic>>(
        path,
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      ));
      
      when(mockEncryptionService.decrypt('encrypted_data'))
          .thenReturn(jsonEncode(decryptedData));
      
      await apiClient.get<Map<String, dynamic>>(path);
      
      verify(mockDio.get<Map<String, dynamic>>(
        path,
        options: argThat(
          predicate<Options>((options) => 
            options.headers?['X-API-Key'] != null &&
            options.headers?['X-API-Key'].isNotEmpty
          ),
        ),
      )).called(1);
    });

    test('請求重試測試', () async {
      const path = '/api/fortune';
      const maxRetries = 3;
      
      when(mockDio.get<Map<String, dynamic>>(
        path,
        options: anyNamed('options'),
      )).thenAnswer((_) async {
        throw DioException(
          requestOptions: RequestOptions(path: path),
          error: '網絡錯誤',
        );
      });
      
      try {
        await apiClient.get<Map<String, dynamic>>(path);
      } catch (e) {
        verify(mockDio.get<Map<String, dynamic>>(
          path,
          options: anyNamed('options'),
        )).called(maxRetries);
      }
    });

    test('請求超時測試', () async {
      const path = '/api/fortune';
      
      when(mockDio.get<Map<String, dynamic>>(
        path,
        options: anyNamed('options'),
      )).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 31));
        return Response(
          data: {'status': 'success'},
          statusCode: 200,
          requestOptions: RequestOptions(path: path),
        );
      });
      
      expect(
        () => apiClient.get<Map<String, dynamic>>(path),
        throwsA(isA<DioException>()),
      );
    });
  });
} 