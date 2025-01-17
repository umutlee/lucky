import 'dart:convert';
import 'package:shared_preferences.dart';
import '../models/lunar_date.dart';
import '../services/lunar_calculator.dart';

/// 黃曆數據倉庫
/// 負責處理黃曆數據的存取和緩存
class AlmanacRepository {
  /// SharedPreferences 實例
  final SharedPreferences _prefs;
  
  /// 緩存鍵前綴
  static const String _cacheKeyPrefix = 'almanac_';
  
  /// 構造函數
  AlmanacRepository(this._prefs);
  
  /// 獲取指定日期的農曆信息
  Future<LunarDate> getLunarDate(DateTime date) async {
    final cacheKey = _getCacheKey(date);
    
    // 嘗試從緩存獲取
    final cached = _prefs.getString(cacheKey);
    if (cached != null) {
      try {
        return LunarDate.fromJson(json.decode(cached));
      } catch (e) {
        // 緩存數據無效，刪除它
        await _prefs.remove(cacheKey);
      }
    }
    
    // 計算農曆日期
    final lunarDate = LunarCalculator.solarToLunar(date);
    
    // 保存到緩存
    await _cacheLunarDate(date, lunarDate);
    
    return lunarDate;
  }
  
  /// 獲取指定月份的農曆日期列表
  Future<List<LunarDate>> getMonthLunarDates(int year, int month) async {
    final dates = <LunarDate>[];
    final daysInMonth = DateTime(year, month + 1, 0).day;
    
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      dates.add(await getLunarDate(date));
    }
    
    return dates;
  }
  
  /// 清除過期緩存
  Future<void> clearExpiredCache() async {
    final now = DateTime.now();
    final keys = _prefs.getKeys().where((key) => key.startsWith(_cacheKeyPrefix));
    
    for (final key in keys) {
      try {
        final dateStr = key.substring(_cacheKeyPrefix.length);
        final date = DateTime.parse(dateStr);
        
        // 如果緩存超過30天，刪除它
        if (now.difference(date).inDays > 30) {
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
  
  /// 緩存農曆日期
  Future<void> _cacheLunarDate(DateTime date, LunarDate lunarDate) async {
    final cacheKey = _getCacheKey(date);
    await _prefs.setString(cacheKey, json.encode(lunarDate.toJson()));
  }
} 