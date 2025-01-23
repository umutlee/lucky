import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/models/fortune.dart';
import '../utils/logger.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService(ref.read(sharedPreferencesProvider), ref.read(loggerProvider)));

/// 本地存儲服務
class StorageService {
  static const String _keyPrefix = 'all_lucky_';
  final SharedPreferences _prefs;
  final Logger _logger;
  
  StorageService(this._prefs, this._logger);

  Future<void> init() async {
    // This method is now empty as the SharedPreferences instance is passed in the constructor
  }

  /// 保存字符串
  Future<bool> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
      return true;
    } catch (e, stackTrace) {
      _logger.error('保存字符串失敗: $key', e, stackTrace);
      return false;
    }
  }

  /// 獲取字符串
  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e, stackTrace) {
      _logger.error('獲取字符串失敗: $key', e, stackTrace);
      return null;
    }
  }

  /// 保存布爾值
  Future<bool> setBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
      return true;
    } catch (e, stackTrace) {
      _logger.error('保存布爾值失敗: $key', e, stackTrace);
      return false;
    }
  }

  /// 獲取布爾值
  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e, stackTrace) {
      _logger.error('獲取布爾值失敗: $key', e, stackTrace);
      return null;
    }
  }

  /// 刪除指定鍵的值
  Future<bool> remove(String key) async {
    try {
      await _prefs.remove(key);
      return true;
    } catch (e, stackTrace) {
      _logger.error('刪除值失敗: $key', e, stackTrace);
      return false;
    }
  }

  /// 清除所有數據
  Future<bool> clear() async {
    try {
      await _prefs.clear();
      return true;
    } catch (e, stackTrace) {
      _logger.error('清除所有數據失敗', e, stackTrace);
      return false;
    }
  }

  Future<bool> saveData(String key, dynamic value) async {
    final String fullKey = _keyPrefix + key;
    
    if (value is String) {
      return await _prefs.setString(fullKey, value);
    } else if (value is bool) {
      return await _prefs.setBool(fullKey, value);
    } else if (value is int) {
      return await _prefs.setInt(fullKey, value);
    } else if (value is double) {
      return await _prefs.setDouble(fullKey, value);
    } else if (value is List<String>) {
      return await _prefs.setStringList(fullKey, value);
    } else {
      // 對於複雜對象,轉換為JSON字符串存儲
      final jsonString = json.encode(value);
      return await _prefs.setString(fullKey, jsonString);
    }
  }

  T? getData<T>(String key) {
    final String fullKey = _keyPrefix + key;
    final value = _prefs.get(fullKey);
    
    if (value == null) {
      return null;
    }

    if (T == String || T == bool || T == int || T == double || T == List<String>) {
      return value as T;
    } else {
      // 對於複雜對象,從JSON字符串解析
      try {
        final jsonString = _prefs.getString(fullKey);
        if (jsonString == null) return null;
        return json.decode(jsonString) as T;
      } catch (e) {
        print('Error decoding JSON for key $key: $e');
        return null;
      }
    }
  }

  Future<bool> removeData(String key) async {
    final String fullKey = _keyPrefix + key;
    return await _prefs.remove(fullKey);
  }

  Future<bool> clearAll() async {
    final allKeys = _prefs.getKeys();
    final appKeys = allKeys.where((key) => key.startsWith(_keyPrefix));
    
    for (final key in appKeys) {
      await _prefs.remove(key);
    }
    
    return true;
  }

  bool hasKey(String key) {
    final String fullKey = _keyPrefix + key;
    return _prefs.containsKey(fullKey);
  }

  Future<T?> getCachedFortune<T>(String key) async {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    
    try {
      final json = jsonDecode(jsonString);
      if (T == Fortune) {
        return Fortune.fromJson(json) as T;
      }
      return json as T;
    } catch (e) {
      return null;
    }
  }

  Future<void> cacheFortune<T>(String key, T data) async {
    if (data == null) return;
    
    try {
      final jsonString = data is Fortune 
          ? jsonEncode(data.toJson())
          : jsonEncode(data);
      await _prefs.setString(key, jsonString);
    } catch (e) {
      // 忽略序列化錯誤
    }
  }

  Future<void> clearAllCache() async {
    final keys = _prefs.getKeys().where((key) => key.startsWith('fortune_'));
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  /// 保存設置
  Future<bool> saveSettings<T>(String key, T value) async {
    try {
      final String fullKey = _keyPrefix + key;
      if (value is String) {
        return await _prefs.setString(fullKey, value);
      } else if (value is bool) {
        return await _prefs.setBool(fullKey, value);
      } else if (value is int) {
        return await _prefs.setInt(fullKey, value);
      } else if (value is double) {
        return await _prefs.setDouble(fullKey, value);
      } else if (value is List<String>) {
        return await _prefs.setStringList(fullKey, value);
      } else {
        final jsonString = json.encode(value);
        return await _prefs.setString(fullKey, jsonString);
      }
    } catch (e, stackTrace) {
      _logger.error('保存設置失敗: $key', e, stackTrace);
      return false;
    }
  }

  /// 獲取設置
  T? getSettings<T>(String key) {
    try {
      final String fullKey = _keyPrefix + key;
      final value = _prefs.get(fullKey);
      
      if (value == null) {
        return null;
      }

      if (T == String || T == bool || T == int || T == double || T == List<String>) {
        return value as T;
      } else {
        final jsonString = _prefs.getString(fullKey);
        if (jsonString == null) return null;
        return json.decode(jsonString) as T;
      }
    } catch (e, stackTrace) {
      _logger.error('獲取設置失敗: $key', e, stackTrace);
      return null;
    }
  }
} 