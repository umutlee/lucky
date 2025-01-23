import 'dart:convert';
import 'package:dio/dio.dart';
import '../services/sqlite_preferences_service.dart';
import '../models/career_fortune.dart';

/// 事業運勢數據倉庫
/// 負責處理事業運勢數據的獲取和緩存
class CareerFortuneRepository {
  /// HTTP 客戶端
  final Dio _dio;
  
  /// SQLitePreferencesService 實例
  final SQLitePreferencesService _prefsService;
  
  /// API 基礎 URL
  static const String _baseUrl = 'https://api.example.com/v1';
  
  /// 緩存鍵前綴
  static const String _cacheKeyPrefix = 'career_fortune_';
  
  /// 構造函數
  CareerFortuneRepository(this._dio, this._prefsService);
  
  /// 獲取指定日期的事業運勢
  Future<CareerFortune> getDailyCareerFortune(DateTime date) async {
    final cacheKey = _getCacheKey(date);
    
    // 嘗試從緩存獲取
    final cached = await _prefsService.getValue<String>(cacheKey);
    if (cached != null) {
      try {
        return CareerFortune.fromJson(json.decode(cached));
      } catch (e) {
        // 緩存數據無效，刪除它
        await _prefsService.remove(cacheKey);
      }
    }
    
    try {
      // 從 API 獲取數據
      final response = await _dio.get(
        '$_baseUrl/career-fortune',
        queryParameters: {
          'date': date.toIso8601String().split('T')[0],
        },
      );
      
      if (response.statusCode == 200) {
        final fortune = CareerFortune.fromJson(response.data);
        
        // 保存到緩存
        await _cacheFortune(date, fortune);
        
        return fortune;
      } else {
        throw Exception('獲取事業運勢數據失敗');
      }
    } catch (e) {
      // 如果 API 請求失敗，返回預設數據
      return CareerFortune(
        overallScore: 60,
        workScore: 60,
        communicationScore: 60,
        leadershipScore: 60,
        bestWorkHours: const ['數據加載失敗'],
        suitableActivities: const ['數據加載失敗'],
        careerTips: const ['暫時無法獲取建議'],
        luckyDirection: '暫時無法獲取方位',
        description: '暫時無法獲取運勢信息',
      );
    }
  }
  
  /// 獲取指定月份的事業運勢
  Future<Map<DateTime, CareerFortune>> getMonthCareerFortunes(DateTime date) async {
    final result = <DateTime, CareerFortune>{};
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    
    for (var day = 1; day <= daysInMonth; day++) {
      final currentDate = DateTime(date.year, date.month, day);
      result[currentDate] = await getDailyCareerFortune(currentDate);
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
        final dateStr = key.substring(_cacheKeyPrefix.length);
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
  String _getCacheKey(DateTime date) {
    return '$_cacheKeyPrefix${date.toIso8601String().split('T')[0]}';
  }
  
  /// 緩存運勢數據
  Future<void> _cacheFortune(DateTime date, CareerFortune fortune) async {
    final cacheKey = _getCacheKey(date);
    await _prefsService.setValue(cacheKey, json.encode(fortune.toJson()));
  }
} 