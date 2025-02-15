import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fortune.dart';
import '../utils/logger.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  final logger = Logger('StorageService');
  return StorageService(logger);
});

/// 本地存儲服務
class StorageService {
  final Logger _logger;
  static const String _keyPrefix = 'all_lucky_';
  SharedPreferences? _prefs;

  StorageService(this._logger);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _logger.info('儲存服務初始化成功');
  }

  Future<void> setString(String key, String value) async {
    await _prefs?.setString('$_keyPrefix$key', value);
  }

  Future<String?> getString(String key) async {
    return _prefs?.getString('$_keyPrefix$key');
  }

  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt('$_keyPrefix$key', value);
  }

  Future<int?> getInt(String key) async {
    return _prefs?.getInt('$_keyPrefix$key');
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool('$_keyPrefix$key', value);
  }

  Future<bool?> getBool(String key) async {
    return _prefs?.getBool('$_keyPrefix$key');
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble('$_keyPrefix$key', value);
  }

  Future<double?> getDouble(String key) async {
    return _prefs?.getDouble('$_keyPrefix$key');
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList('$_keyPrefix$key', value);
  }

  Future<List<String>?> getStringList(String key) async {
    return _prefs?.getStringList('$_keyPrefix$key');
  }

  Future<void> setObject<T>(String key, T value) async {
    final jsonString = json.encode(value);
    await setString(key, jsonString);
  }

  Future<T?> getObject<T>(String key, T Function(Map<String, dynamic> json) fromJson) async {
    final jsonString = await getString(key);
    if (jsonString == null) return null;
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    return fromJson(jsonMap);
  }

  Future<void> remove(String key) async {
    await _prefs?.remove('$_keyPrefix$key');
  }

  Future<void> clear() async {
    final keys = await getAllKeys();
    for (final key in keys) {
      await remove(key);
    }
  }

  Future<List<String>> getAllKeys() async {
    final keys = _prefs?.getKeys() ?? <String>{};
    return keys.where((key) => key.startsWith(_keyPrefix)).toList();
  }

  Future<bool> containsKey(String key) async {
    return _prefs?.containsKey('$_keyPrefix$key') ?? false;
  }

  Future<bool> saveData(String key, dynamic value) async {
    try {
      final String fullKey = _keyPrefix + key;
      
      if (value is String) {
        await setString(key, value);
      } else if (value is bool) {
        await setBool(key, value);
      } else if (value is int) {
        await setInt(key, value);
      } else if (value is double) {
        await setDouble(key, value);
      } else if (value is List<String>) {
        await setStringList(key, value);
      } else {
        // 對於複雜對象,轉換為JSON字符串存儲
        await setObject(key, value);
      }
      return true;
    } catch (e, stack) {
      _logger.error('保存數據失敗: $key', e, stack);
      return false;
    }
  }

  T? getData<T>(String key) {
    try {
      final String fullKey = _keyPrefix + key;
      final value = _prefs?.get(fullKey);
      
      if (value == null) {
        return null;
      }

      if (T == String || T == bool || T == int || T == double || T == List<String>) {
        return value as T;
      } else {
        // 對於複雜對象,從JSON字符串解析
        final jsonString = _prefs?.getString(fullKey);
        if (jsonString == null) return null;
        return json.decode(jsonString) as T;
      }
    } catch (e, stack) {
      _logger.error('獲取數據失敗: $key', e, stack);
      return null;
    }
  }

  Future<bool> removeData(String key) async {
    try {
      final String fullKey = _keyPrefix + key;
      await remove(fullKey);
      return true;
    } catch (e, stack) {
      _logger.error('刪除數據失敗: $key', e, stack);
      return false;
    }
  }

  Future<bool> clearAll() async {
    try {
      await clear();
      return true;
    } catch (e, stack) {
      _logger.error('清除所有數據失敗', e, stack);
      return false;
    }
  }

  bool hasKey(String key) {
    try {
      final String fullKey = _keyPrefix + key;
      return _prefs?.containsKey(fullKey) ?? false;
    } catch (e, stack) {
      _logger.error('檢查鍵是否存在失敗: $key', e, stack);
      return false;
    }
  }

  Future<T?> getCachedFortune<T>(String key) async {
    try {
      final jsonString = _prefs?.getString(key);
      if (jsonString == null) return null;
      
      final json = jsonDecode(jsonString);
      if (T == Fortune) {
        return Fortune.fromJson(json) as T;
      }
      return json as T;
    } catch (e, stack) {
      _logger.error('獲取緩存運勢失敗: $key', e, stack);
      return null;
    }
  }

  Future<void> cacheFortune<T>(String key, T data) async {
    try {
      if (data == null) return;
      
      final jsonString = data is Fortune 
          ? jsonEncode(data.toJson())
          : jsonEncode(data);
      await setString(key, jsonString);
    } catch (e, stack) {
      _logger.error('緩存運勢失敗: $key', e, stack);
    }
  }

  Future<void> clearAllCache() async {
    try {
      final keys = await getAllKeys();
      for (final key in keys) {
        await remove(key);
      }
    } catch (e, stack) {
      _logger.error('清除所有緩存失敗', e, stack);
    }
  }

  /// 保存設置
  Future<bool> saveSettings<T>(String key, T value) async {
    try {
      final String fullKey = _keyPrefix + key;
      if (value is String) {
        await setString(key, value);
      } else if (value is bool) {
        await setBool(key, value);
      } else if (value is int) {
        await setInt(key, value);
      } else if (value is double) {
        await setDouble(key, value);
      } else if (value is List<String>) {
        await setStringList(key, value);
      } else {
        final jsonString = json.encode(value);
        await setString(key, jsonString);
      }
      return true;
    } catch (e, stack) {
      _logger.error('保存設置失敗: $key', e, stack);
      return false;
    }
  }

  /// 獲取設置
  T? getSettings<T>(String key) {
    try {
      final String fullKey = _keyPrefix + key;
      final value = _prefs?.get(fullKey);
      
      if (value == null) {
        return null;
      }

      if (T == String || T == bool || T == int || T == double || T == List<String>) {
        return value as T;
      } else {
        final jsonString = _prefs?.getString(fullKey);
        if (jsonString == null) return null;
        return json.decode(jsonString) as T;
      }
    } catch (e, stack) {
      _logger.error('獲取設置失敗: $key', e, stack);
      return null;
    }
  }
} 