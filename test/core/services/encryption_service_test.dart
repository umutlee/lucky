import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:all_lucky/core/services/encryption_service.dart';
import 'package:all_lucky/core/models/fortune.dart';

abstract class KeySource {
  String getKey();
}

@GenerateMocks([KeySource])
void main() {
  late EncryptionService encryptionService;
  late MockKeySource mockKeySource;

  setUp(() {
    mockKeySource = MockKeySource();
    when(mockKeySource.getKey()).thenReturn('test-key-12345678901234567890123456789012');
    encryptionService = EncryptionService(keySource: mockKeySource);
  });

  group('EncryptionService', () {
    test('加密字符串測試', () {
      const originalText = '測試文本';
      final encrypted = encryptionService.encryptString(originalText);
      
      expect(encrypted, isNotNull);
      expect(encrypted, isNot(equals(originalText)));
      
      final decrypted = encryptionService.decryptString(encrypted);
      expect(decrypted, equals(originalText));
    });

    test('加密對象測試', () {
      final fortune = Fortune(
        id: '1',
        type: '學習',
        score: 80,
        description: '今天運勢不錯',
        date: DateTime(2024, 1, 1),
        luckyTimes: ['早上', '下午'],
        luckyDirections: ['東', '南'],
        luckyColors: ['紅', '黃'],
        luckyNumbers: [1, 8],
        suggestions: ['早起學習', '閱讀新書'],
        warnings: ['避免熬夜'],
        createdAt: DateTime.now(),
      );

      final encrypted = encryptionService.encryptObject(fortune);
      expect(encrypted, isNotNull);
      
      final decrypted = encryptionService.decryptObject<Fortune>(
        encrypted,
        (json) => Fortune.fromJson(json),
      );
      
      expect(decrypted.id, equals(fortune.id));
      expect(decrypted.type, equals(fortune.type));
      expect(decrypted.score, equals(fortune.score));
      expect(decrypted.description, equals(fortune.description));
      expect(decrypted.date, equals(fortune.date));
      expect(decrypted.luckyTimes, equals(fortune.luckyTimes));
      expect(decrypted.luckyDirections, equals(fortune.luckyDirections));
      expect(decrypted.luckyColors, equals(fortune.luckyColors));
      expect(decrypted.luckyNumbers, equals(fortune.luckyNumbers));
      expect(decrypted.suggestions, equals(fortune.suggestions));
      expect(decrypted.warnings, equals(fortune.warnings));
    });

    test('完整性驗證測試', () {
      const originalText = '測試文本';
      final encrypted = encryptionService.encryptString(originalText);
      final hash = encryptionService.generateHash(encrypted);
      
      expect(encryptionService.verifyIntegrity(encrypted, hash), isTrue);
      
      // 測試數據被篡改的情況
      final tamperedData = encrypted.substring(0, encrypted.length - 1) + '1';
      expect(encryptionService.verifyIntegrity(tamperedData, hash), isFalse);
    });

    test('空數據處理測試', () {
      expect(
        () => encryptionService.encryptString(''),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => encryptionService.decryptString(''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('無效數據解密測試', () {
      expect(
        () => encryptionService.decryptString('invalid-data'),
        throwsA(isA<FormatException>()),
      );
    });

    test('大數據加密測試', () {
      final largeText = List.generate(1000000, (i) => 'test').join();
      final encrypted = encryptionService.encryptString(largeText);
      final decrypted = encryptionService.decryptString(encrypted);
      
      expect(decrypted, equals(largeText));
    });

    test('批量加密測試', () {
      final items = List.generate(100, (i) => 'test-$i');
      final encryptedItems = items.map(
        (item) => encryptionService.encryptString(item),
      ).toList();
      
      final decryptedItems = encryptedItems.map(
        (item) => encryptionService.decryptString(item),
      ).toList();
      
      expect(decryptedItems, equals(items));
    });

    test('密鑰生成測試', () {
      verify(mockKeySource.getKey()).called(1);
      
      when(mockKeySource.getKey()).thenReturn('different-key-12345678901234567890123456789012');
      final newEncryptionService = EncryptionService(keySource: mockKeySource);
      
      const originalText = '測試文本';
      final encrypted1 = encryptionService.encryptString(originalText);
      final encrypted2 = newEncryptionService.encryptString(originalText);
      
      expect(encrypted1, isNot(equals(encrypted2)));
    });

    test('加密結果唯一性測試', () {
      const originalText = '測試文本';
      final encrypted1 = encryptionService.encryptString(originalText);
      final encrypted2 = encryptionService.encryptString(originalText);
      
      expect(encrypted1, isNot(equals(encrypted2))); // 由於 IV 的隨機性
      
      final decrypted1 = encryptionService.decryptString(encrypted1);
      final decrypted2 = encryptionService.decryptString(encrypted2);
      
      expect(decrypted1, equals(originalText));
      expect(decrypted2, equals(originalText));
    });

    test('對象序列化錯誤測試', () {
      final invalidObject = Object();
      
      expect(
        () => encryptionService.encryptObject(invalidObject),
        throwsA(isA<JsonUnsupportedObjectError>()),
      );
    });

    test('對象反序列化錯誤測試', () {
      const originalText = '{"invalid": "json"}';
      final encrypted = encryptionService.encryptString(originalText);
      
      expect(
        () => encryptionService.decryptObject<Fortune>(
          encrypted,
          (json) => Fortune.fromJson(json),
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('加密服務測試', () {
    test('數據加密測試', () {
      const originalData = '測試數據';
      final encryptedData = encryptionService.encrypt(originalData);
      
      // 驗證加密後的數據不等於原始數據
      expect(encryptedData, isNot(equals(originalData)));
      
      // 驗證加密後的數據不為空
      expect(encryptedData, isNotEmpty);
    });

    test('數據解密測試', () {
      const originalData = '測試數據';
      final encryptedData = encryptionService.encrypt(originalData);
      final decryptedData = encryptionService.decrypt(encryptedData);
      
      // 驗證解密後的數據等於原始數據
      expect(decryptedData, equals(originalData));
    });

    test('空數據加密測試', () {
      const originalData = '';
      final encryptedData = encryptionService.encrypt(originalData);
      final decryptedData = encryptionService.decrypt(encryptedData);
      
      // 驗證空數據的加解密
      expect(decryptedData, equals(originalData));
    });

    test('特殊字符加密測試', () {
      const originalData = '!@#\$%^&*()_+{}:"<>?~';
      final encryptedData = encryptionService.encrypt(originalData);
      final decryptedData = encryptionService.decrypt(encryptedData);
      
      // 驗證特殊字符的加解密
      expect(decryptedData, equals(originalData));
    });

    test('中文字符加密測試', () {
      const originalData = '你好世界！123';
      final encryptedData = encryptionService.encrypt(originalData);
      final decryptedData = encryptionService.decrypt(encryptedData);
      
      // 驗證中文字符的加解密
      expect(decryptedData, equals(originalData));
    });

    test('大數據加密測試', () {
      final originalData = 'a' * 1000000; // 1MB 的數據
      final encryptedData = encryptionService.encrypt(originalData);
      final decryptedData = encryptionService.decrypt(encryptedData);
      
      // 驗證大數據的加解密
      expect(decryptedData, equals(originalData));
    });

    test('加密密鑰變更測試', () {
      const originalData = '測試數據';
      final encryptedData = encryptionService.encrypt(originalData);
      
      // 變更密鑰
      encryptionService.updateEncryptionKey('new_key');
      
      // 使用新密鑰加密
      final newEncryptedData = encryptionService.encrypt(originalData);
      
      // 驗證使用不同密鑰加密的結果不同
      expect(newEncryptedData, isNot(equals(encryptedData)));
    });

    test('加密性能測試', () {
      const originalData = '測試數據';
      final stopwatch = Stopwatch()..start();
      
      // 執行 1000 次加密
      for (var i = 0; i < 1000; i++) {
        encryptionService.encrypt(originalData);
      }
      
      stopwatch.stop();
      
      // 驗證加密性能（平均每次加密應小於 1ms）
      expect(stopwatch.elapsedMilliseconds / 1000, lessThan(1));
    });
  });
} 