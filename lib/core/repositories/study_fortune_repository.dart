import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences.dart';
import '../models/study_fortune.dart';

/// 學業運勢數據倉庫
/// 負責處理學業運勢數據的獲取和緩存
class StudyFortuneRepository {
  /// HTTP 客戶端
  final Dio _dio;
  
  /// SharedPreferences 實例
  final SharedPreferences _prefs;
  
  /// API 基礎 URL
  static const String _baseUrl = 'https://api.example.com/v1';
  
  /// 緩存鍵前綴
  static const String _cacheKeyPrefix = 'study_fortune_';
  
  /// 構造函數
  StudyFortuneRepository(this._dio, this._prefs);
  
  /// 獲取指定日期的學業運勢
  Future<StudyFortune> getDailyStudyFortune(DateTime date) async {
    final cacheKey = _getCacheKey(date);
    
    // 嘗試從緩存獲取
    final cached = _prefs.getString(cacheKey);
    if (cached != null) {
      try {
        return StudyFortune.fromJson(json.decode(cached));
      } catch (e) {
        // 緩存數據無效，刪除它
        await _prefs.remove(cacheKey);
      }
    }
    
    try {
      // 從 API 獲取數據
      final response = await _dio.get(
        '$_baseUrl/study-fortune',
        queryParameters: {
          'date': date.toIso8601String().split('T')[0],
        },
      );
      
      if (response.statusCode == 200) {
        final fortune = StudyFortune.fromJson(response.data);
        
        // 保存到緩存
        await _cacheFortune(date, fortune);
        
        return fortune;
      } else {
        throw Exception('獲取學業運勢數據失敗');
      }
    } catch (e) {
      // 如果 API 請求失敗，返回預設數據
      return StudyFortune(
        overallScore: 60,
        efficiencyScore: 60,
        memoryScore: 60,
        examScore: 60,
        bestStudyHours: const ['數據加載失敗'],
        suitableSubjects: const ['數據加載失敗'],
        studyTips: const ['暫時無法獲取建議'],
        luckyDirection: '暫時無法獲取方位',
        description: '暫時無法獲取運勢信息',
      );
    }
  }
  
  /// 獲取指定月份的學業運勢
  Future<Map<DateTime, StudyFortune>> getMonthStudyFortunes(DateTime date) async {
    final result = <DateTime, StudyFortune>{};
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    
    for (var day = 1; day <= daysInMonth; day++) {
      final currentDate = DateTime(date.year, date.month, day);
      result[currentDate] = await getDailyStudyFortune(currentDate);
    }
    
    return result;
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
  Future<void> _cacheFortune(DateTime date, StudyFortune fortune) async {
    final cacheKey = _getCacheKey(date);
    await _prefs.setString(cacheKey, json.encode(fortune.toJson()));
  }
} 