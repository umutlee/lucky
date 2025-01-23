import 'dart:convert';
import 'package:dio/dio.dart';
import '../services/sqlite_preferences_service.dart';
import '../models/love_fortune.dart';

/// 愛情運勢數據倉庫
/// 負責處理愛情運勢數據的獲取和緩存
class LoveFortuneRepository {
  /// HTTP 客戶端
  final Dio _dio;
  
  /// SQLitePreferencesService 實例
  final SQLitePreferencesService _prefsService;
  
  /// API 基礎 URL
  static const String _baseUrl = 'https://api.example.com/v1';
  
  /// 緩存鍵前綴
  static const String _cacheKeyPrefix = 'love_fortune_';
  
  /// 構造函數
  LoveFortuneRepository(this._dio, this._prefsService);
  
  /// 獲取指定日期的愛情運勢
  Future<LoveFortune> getDailyLoveFortune(DateTime date, {String? zodiacSign}) async {
    final cacheKey = _getCacheKey(date, zodiacSign);
    
    // 嘗試從緩存獲取
    final cached = await _prefsService.getValue<String>(cacheKey);
    if (cached != null) {
      try {
        return LoveFortune.fromJson(json.decode(cached));
      } catch (e) {
        // 緩存數據無效，刪除它
        await _prefsService.remove(cacheKey);
      }
    }
    
    try {
      // 從 API 獲取數據
      final response = await _dio.get(
        '$_baseUrl/love-fortune',
        queryParameters: {
          'date': date.toIso8601String().split('T')[0],
          if (zodiacSign != null) 'zodiac': zodiacSign,
        },
      );
      
      if (response.statusCode == 200) {
        final fortune = LoveFortune.fromJson(response.data);
        
        // 保存到緩存
        await _cacheFortune(date, fortune, zodiacSign);
        
        return fortune;
      } else {
        throw Exception('獲取愛情運勢數據失敗');
      }
    } catch (e) {
      // 如果 API 請求失敗，返回預設數據
      return LoveFortune(
        overallScore: 60,
        romanceScore: 60,
        confessionScore: 60,
        dateScore: 60,
        bestDateHours: const ['數據加載失敗'],
        suitableDateActivities: const ['數據加載失敗'],
        loveTips: const ['暫時無法獲取建議'],
        compatibleZodiacs: const [],
        description: '暫時無法獲取運勢信息',
      );
    }
  }
  
  /// 獲取指定月份的愛情運勢
  Future<Map<DateTime, LoveFortune>> getMonthLoveFortunes(
    DateTime date, {
    String? zodiacSign,
  }) async {
    final result = <DateTime, LoveFortune>{};
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    
    for (var day = 1; day <= daysInMonth; day++) {
      final currentDate = DateTime(date.year, date.month, day);
      result[currentDate] = await getDailyLoveFortune(
        currentDate,
        zodiacSign: zodiacSign,
      );
    }
    
    return result;
  }
  
  /// 清除過期緩存
  Future<void> clearExpiredCache() async {
    final now = DateTime.now();
    final keys = await _prefsService.getKeys();
    final cacheKeys = keys.where((key) => key.startsWith(_cacheKeyPrefix));
    
    for (final key in cacheKeys) {
      try {
        final dateStr = key.substring(_cacheKeyPrefix.length).split('_')[0];
        final date = DateTime.parse(dateStr);
        
        // 如果緩存超過7天，刪除它
        if (now.difference(date).inDays > 7) {
          await _prefsService.remove(key);
        }
      } catch (e) {
        // 無效的緩存鍵，刪除它
        await _prefsService.remove(key);
      }
    }
  }
  
  /// 生成緩存鍵
  String _getCacheKey(DateTime date, String? zodiacSign) {
    final baseKey = '$_cacheKeyPrefix${date.toIso8601String().split('T')[0]}';
    return zodiacSign != null ? '${baseKey}_$zodiacSign' : baseKey;
  }
  
  /// 緩存運勢數據
  Future<void> _cacheFortune(
    DateTime date,
    LoveFortune fortune,
    String? zodiacSign,
  ) async {
    final cacheKey = _getCacheKey(date, zodiacSign);
    await _prefsService.setValue(cacheKey, json.encode(fortune.toJson()));
  }
} 