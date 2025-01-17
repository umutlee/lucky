import 'dart:convert';
import 'package:shared_preferences.dart';
import '../models/api_response.dart';

/// 本地存儲服務
class StorageService {
  final SharedPreferences _prefs;
  
  StorageService(this._prefs);

  // 緩存過期時間(24小時)
  static const Duration _cacheExpiration = Duration(hours: 24);

  // 緩存 API 響應
  Future<void> cacheApiResponse<T>(
    String key,
    ApiResponse<T> response,
  ) async {
    if (!response.isSuccess) return;

    final cacheData = {
      'data': response.data,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await _prefs.setString(
      _getCacheKey(key),
      jsonEncode(cacheData),
    );
  }

  // 獲取緩存的 API 響應
  ApiResponse<T>? getCachedApiResponse<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final cacheJson = _prefs.getString(_getCacheKey(key));
    if (cacheJson == null) return null;

    try {
      final cacheData = jsonDecode(cacheJson) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cacheData['timestamp'] as String);
      
      // 檢查緩存是否過期
      if (DateTime.now().difference(timestamp) > _cacheExpiration) {
        _prefs.remove(_getCacheKey(key));
        return null;
      }

      return ApiResponse.success(
        fromJson(cacheData['data'] as Map<String, dynamic>),
      );
    } catch (e) {
      _prefs.remove(_getCacheKey(key));
      return null;
    }
  }

  // 清除過期緩存
  Future<void> clearExpiredCache() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith('cache_'));
    for (final key in keys) {
      final cacheJson = _prefs.getString(key);
      if (cacheJson == null) continue;

      try {
        final cacheData = jsonDecode(cacheJson) as Map<String, dynamic>;
        final timestamp = DateTime.parse(cacheData['timestamp'] as String);
        
        if (DateTime.now().difference(timestamp) > _cacheExpiration) {
          await _prefs.remove(key);
        }
      } catch (e) {
        await _prefs.remove(key);
      }
    }
  }

  // 保存用戶設置
  Future<void> saveSettings(String key, dynamic value) async {
    if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    } else {
      await _prefs.setString(key, jsonEncode(value));
    }
  }

  // 獲取用戶設置
  T? getSettings<T>(String key) {
    return _prefs.get(key) as T?;
  }

  // 移除用戶設置
  Future<void> removeSettings(String key) async {
    await _prefs.remove(key);
  }

  // 生成緩存 key
  String _getCacheKey(String key) => 'cache_$key';
} 