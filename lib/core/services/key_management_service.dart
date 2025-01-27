import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';

/// 密鑰管理服務提供者
final keyManagementServiceProvider = Provider<KeyManagementService>((ref) {
  return KeyManagementServiceImpl();
});

/// 密鑰管理服務基類
abstract class KeyManagementService {
  /// 獲取數據庫加密密鑰
  Future<String> getDatabaseKey();
  
  /// 生成新的加密密鑰
  Future<String> generateNewKey();
  
  /// 重置加密密鑰
  Future<void> resetKey();
}

/// 密鑰管理服務實現
class KeyManagementServiceImpl implements KeyManagementService {
  static const String _tag = 'KeyManagementService';
  final _logger = Logger(_tag);
  
  static const String _keyStorageKey = 'database_encryption_key';
  final _secureStorage = const FlutterSecureStorage();
  
  @override
  Future<String> getDatabaseKey() async {
    try {
      // 嘗試獲取現有密鑰
      String? key = await _secureStorage.read(key: _keyStorageKey);
      
      // 如果沒有密鑰，生成新的
      if (key == null) {
        key = await generateNewKey();
        await _secureStorage.write(key: _keyStorageKey, value: key);
      }
      
      return key;
    } catch (e, stackTrace) {
      _logger.error('獲取數據庫密鑰失敗', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<String> generateNewKey() async {
    try {
      final random = Random.secure();
      final values = List<int>.generate(32, (i) => random.nextInt(256));
      final key = base64Url.encode(values);
      
      await _secureStorage.write(key: _keyStorageKey, value: key);
      return key;
    } catch (e, stackTrace) {
      _logger.error('生成新密鑰失敗', e, stackTrace);
      rethrow;
    }
  }
  
  @override
  Future<void> resetKey() async {
    try {
      await _secureStorage.delete(key: _keyStorageKey);
    } catch (e, stackTrace) {
      _logger.error('重置密鑰失敗', e, stackTrace);
      rethrow;
    }
  }
} 