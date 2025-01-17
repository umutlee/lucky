import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// API Key 生成工具
class ApiKeyGenerator {
  /// 生成 API Key
  /// 
  /// [environment] 環境標識（dev/test/prod）
  /// [appId] 應用標識
  /// [timestamp] 時間戳（毫秒）
  static String generateKey({
    required String environment,
    required String appId,
    String? timestamp,
  }) {
    // 驗證環境標識
    if (!['dev', 'test', 'prod'].contains(environment)) {
      throw ArgumentError('無效的環境標識：$environment');
    }

    // 驗證應用標識
    if (appId.isEmpty) {
      throw ArgumentError('應用標識不能為空');
    }

    // 使用當前時間戳或指定的時間戳
    final ts = timestamp ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    // 生成隨機鹽值
    final salt = _generateSalt();
    
    // 組合原始字符串
    final raw = '$environment:$appId:$ts:$salt';
    
    // 使用 SHA-256 加密
    final bytes = utf8.encode(raw);
    final hash = sha256.convert(bytes);
    
    // 格式化 API Key
    return '${environment.toUpperCase()}_${hash.toString().substring(0, 32)}';
  }

  /// 驗證 API Key
  /// 
  /// [apiKey] 待驗證的 API Key
  /// [environment] 期望的環境
  static bool validateKey(String apiKey, String environment) {
    // 基本格式驗證
    if (!apiKey.contains('_')) return false;
    
    // 驗證環境標識
    final parts = apiKey.split('_');
    if (parts.length != 2) return false;
    
    final keyEnv = parts[0].toLowerCase();
    if (keyEnv != environment.toLowerCase()) return false;
    
    // 驗證 Key 長度
    if (parts[1].length != 32) return false;
    
    // 驗證 Key 格式（應該只包含十六進制字符）
    final keyPattern = RegExp(r'^[a-f0-9]{32}$');
    return keyPattern.hasMatch(parts[1]);
  }

  /// 生成隨機鹽值
  static String _generateSalt([int length = 16]) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }
} 