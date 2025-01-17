import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences.dart';
import '../models/daily_fortune.dart';

/// 運勢數據倉庫
/// 負責處理運勢數據的獲取和緩存
class FortuneRepository {
  /// HTTP 客戶端
  final Dio _dio;
  
  /// SharedPreferences 實例
  final SharedPreferences _prefs;
  
  /// API 基礎 URL
  static const String _baseUrl = 'https://api.example.com/v1';
  
  /// 緩存鍵前綴
  static const String _cacheKeyPrefix = 'fortune_';
  
  /// 構造函數
  FortuneRepository(this._dio, this._prefs);
  
  /// 獲取指定日期的運勢信息
  Future<DailyFortune> getDailyFortune(DateTime date) async {
    final cacheKey = _getCacheKey(date);
    
    // 嘗試從緩存獲取
    final cached = _prefs.getString(cacheKey);
    if (cached != null) {
      try {
        return DailyFortune.fromJson(json.decode(cached));
      } catch (e) {
        // 緩存數據無效，刪除它
        await _prefs.remove(cacheKey);
      }
    }
    
    try {
      // 從 API 獲取數據
      final response = await _dio.get(
        '$_baseUrl/fortune',
        queryParameters: {
          'date': date.toIso8601String().split('T')[0],
        },
      );
      
      if (response.statusCode == 200) {
        final fortune = DailyFortune.fromJson(response.data);
        
        // 保存到緩存
        await _cacheFortune(date, fortune);
        
        return fortune;
      } else {
        throw Exception('Failed to load fortune data');
      }
    } catch (e) {
      // 如果 API 請求失敗，返回空數據
      return DailyFortune(
        goodFor: const ['數據加載失敗'],
        badFor: const ['數據加載失敗'],
        luckyHours: const [],
      );
    }
  }
  
  /// 獲取指定月份的運勢數據列表
  Future<List<DailyFortune>> getMonthFortunes(int year, int month) async {
    final fortunes = <DailyFortune>[];
    final daysInMonth = DateTime(year, month + 1, 0).day;
    
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      fortunes.add(await getDailyFortune(date));
    }
    
    return fortunes;
  }
  
  /// 清除過期緩存
  Future<void> clearExpiredCache() async {
    final now = DateTime.now();
    final keys = _prefs.getKeys().where((key) => key.startsWith(_cacheKeyPrefix));
    
    for (final key in keys) {
      try {
        final dateStr = key.substring(_cacheKeyPrefix.length);
        final date = DateTime.parse(dateStr);
        
        // 如果緩存超過7天，刪除它
        if (now.difference(date).inDays > 7) {
          await _prefs.remove(key);
        }
      } catch (e) {
        // 無效的緩存鍵，刪除它
        await _prefs.remove(key);
      }
    }
  }
  
  /// 生成緩存鍵
  String _getCacheKey(DateTime date) {
    return '$_cacheKeyPrefix${date.toIso8601String().split('T')[0]}';
  }
  
  /// 緩存運勢數據
  Future<void> _cacheFortune(DateTime date, DailyFortune fortune) async {
    final cacheKey = _getCacheKey(date);
    await _prefs.setString(cacheKey, json.encode(fortune.toJson()));
  }
} 