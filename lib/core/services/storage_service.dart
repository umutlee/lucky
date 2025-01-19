import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

class StorageService {
  static const String _keyPrefix = 'all_lucky_';
  late SharedPreferences _prefs;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
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
} 