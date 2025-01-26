import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:all_lucky/core/services/encryption_service.dart';
import 'package:all_lucky/core/models/fortune.dart';

@GenerateMocks([KeySource])
import 'encryption_service_test.mocks.dart';

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
        description: '今天運勢不錯',
        score: 80,
        type: '學習',
        date: DateTime(2024, 1, 1),
        recommendations: ['早起學習', '閱讀新書'],
        zodiac: '龍',
        zodiacAffinity: {'鼠': 90},
      );

      final encrypted = encryptionService.encryptObject(fortune);
      expect(encrypted, isNotNull);
      
      final decrypted = encryptionService.decryptObject<Fortune>(
        encrypted,
        (json) => Fortune.fromJson(json),
      );
      
      expect(decrypted.id, equals(fortune.id));
      expect(decrypted.description, equals(fortune.description));
      expect(decrypted.score, equals(fortune.score));
      expect(decrypted.type, equals(fortune.type));
      expect(decrypted.date, equals(fortune.date));
      expect(decrypted.recommendations, equals(fortune.recommendations));
      expect(decrypted.zodiac, equals(fortune.zodiac));
      expect(decrypted.zodiacAffinity, equals(fortune.zodiacAffinity));
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
} 