import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/utils/api_key_generator.dart';

void main() {
  group('ApiKeyGenerator Tests', () {
    test('生成有效的 API Key', () {
      final key = ApiKeyGenerator.generateKey(
        environment: 'test',
        appId: 'com.alllucky.app',
      );

      expect(key.startsWith('TEST_'), true);
      expect(key.length, 37); // 'TEST_' + 32 字符的哈希
    });

    test('驗證有效的 API Key', () {
      final key = ApiKeyGenerator.generateKey(
        environment: 'dev',
        appId: 'com.alllucky.app',
      );

      expect(ApiKeyGenerator.validateKey(key, 'dev'), true);
    });

    test('驗證無效的 API Key', () {
      expect(ApiKeyGenerator.validateKey('INVALID_KEY', 'dev'), false);
      expect(ApiKeyGenerator.validateKey('DEV_123', 'dev'), false);
      expect(ApiKeyGenerator.validateKey('PROD_' + 'a' * 32, 'dev'), false);
    });

    test('不同環境生成不同的 Key', () {
      final devKey = ApiKeyGenerator.generateKey(
        environment: 'dev',
        appId: 'com.alllucky.app',
      );

      final prodKey = ApiKeyGenerator.generateKey(
        environment: 'prod',
        appId: 'com.alllucky.app',
      );

      expect(devKey != prodKey, true);
    });

    test('相同參數生成不同的 Key（因為時間戳和鹽值）', () {
      final key1 = ApiKeyGenerator.generateKey(
        environment: 'test',
        appId: 'com.alllucky.app',
      );

      final key2 = ApiKeyGenerator.generateKey(
        environment: 'test',
        appId: 'com.alllucky.app',
      );

      expect(key1 != key2, true);
    });

    test('無效的環境標識拋出異常', () {
      expect(
        () => ApiKeyGenerator.generateKey(
          environment: 'invalid',
          appId: 'com.alllucky.app',
        ),
        throwsArgumentError,
      );
    });

    test('空的應用標識拋出異常', () {
      expect(
        () => ApiKeyGenerator.generateKey(
          environment: 'dev',
          appId: '',
        ),
        throwsArgumentError,
      );
    });
  });
} 