import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/utils/logger.dart';

final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

/// 加密服務
class EncryptionService {
  static const String _tag = 'EncryptionService';
  final _logger = Logger(_tag);
  
  late final Key _key;
  late final IV _iv;
  late final Encrypter _encrypter;
  
  EncryptionService() {
    _initializeEncryption();
  }
  
  void _initializeEncryption() {
    try {
      // 使用設備特定信息和應用ID生成密鑰
      final keySource = _generateKeySource();
      final keyBytes = sha256.convert(utf8.encode(keySource)).bytes;
      _key = Key(Uint8List.fromList(keyBytes));
      
      // 生成初始化向量
      _iv = IV.fromLength(16);
      
      // 創建加密器
      _encrypter = Encrypter(AES(_key));
      
      _logger.info('加密服務初始化成功');
    } catch (e, stackTrace) {
      _logger.error('加密服務初始化失敗', e, stackTrace);
      rethrow;
    }
  }
  
  /// 加密數據
  String encrypt(String data) {
    try {
      final encrypted = _encrypter.encrypt(data, iv: _iv);
      return encrypted.base64;
    } catch (e, stackTrace) {
      _logger.error('加密失敗', e, stackTrace);
      rethrow;
    }
  }
  
  /// 解密數據
  String decrypt(String encryptedData) {
    try {
      final encrypted = Encrypted.fromBase64(encryptedData);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e, stackTrace) {
      _logger.error('解密失敗', e, stackTrace);
      rethrow;
    }
  }
  
  /// 加密對象
  String encryptObject(Map<String, dynamic> data) {
    try {
      final jsonString = jsonEncode(data);
      return encrypt(jsonString);
    } catch (e, stackTrace) {
      _logger.error('對象加密失敗', e, stackTrace);
      rethrow;
    }
  }
  
  /// 解密對象
  Map<String, dynamic> decryptObject(String encryptedData) {
    try {
      final jsonString = decrypt(encryptedData);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e, stackTrace) {
      _logger.error('對象解密失敗', e, stackTrace);
      rethrow;
    }
  }
  
  /// 生成密鑰源
  String _generateKeySource() {
    // TODO: 使用設備特定信息和應用ID生成唯一的密鑰源
    // 這裡需要實現一個安全的方式來生成密鑰源
    return 'temporary_key_source';
  }
  
  /// 驗證加密數據的完整性
  bool verifyIntegrity(String encryptedData, String hash) {
    try {
      final computedHash = sha256.convert(utf8.encode(encryptedData)).toString();
      return computedHash == hash;
    } catch (e, stackTrace) {
      _logger.error('完整性驗證失敗', e, stackTrace);
      return false;
    }
  }
  
  /// 生成數據的哈希值
  String generateHash(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }
} 