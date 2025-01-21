import 'dart:convert';
import 'package:dio/dio.dart';
import '../services/database_service.dart';
import '../models/lunar_date.dart';
import '../models/almanac.dart';
import '../services/lunar_calculator.dart';

/// 黃曆數據倉庫
/// 負責處理黃曆數據的存取和緩存
class AlmanacRepository {
  final Dio _dio;
  final DatabaseService _databaseService;
  
  /// 緩存鍵前綴
  static const String _cacheKeyPrefix = 'almanac_';
  static const String _tableName = 'cache_records';
  
  /// 緩存統計
  int _cacheHits = 0;
  int _cacheMisses = 0;
  
  /// 構造函數
  AlmanacRepository(this._dio, this._databaseService);
  
  /// 獲取指定日期的農曆信息
  Future<LunarDate> getLunarDate(DateTime date) async {
    final cacheKey = _getCacheKey(date);
    
    // 從數據庫緩存獲取
    final cached = await _databaseService.query(
      _tableName,
      where: 'key = ?',
      whereArgs: [cacheKey],
    );
    
    if (cached.isNotEmpty) {
      try {
        _cacheHits++;
        return LunarDate.fromJson(json.decode(cached.first['value']));
      } catch (e) {
        await _databaseService.delete(
          _tableName,
          where: 'key = ?',
          whereArgs: [cacheKey],
        );
      }
    }
    
    _cacheMisses++;
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
    await _databaseService.delete(
      _tableName,
      where: 'expires_at < ? AND key LIKE ?',
      whereArgs: [
        DateTime.now().toIso8601String(),
        '$_cacheKeyPrefix%',
      ],
    );
  }
  
  /// 生成緩存鍵
  String _getCacheKey(DateTime date) {
    return '$_cacheKeyPrefix${date.toIso8601String().split('T')[0]}';
  }
  
  /// 緩存農曆日期
  Future<void> _cacheLunarDate(DateTime date, LunarDate lunarDate) async {
    await _databaseService.insert(
      _tableName,
      {
        'key': _getCacheKey(date),
        'value': json.encode(lunarDate.toJson()),
        'created_at': DateTime.now().toIso8601String(),
        'expires_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'type': 'lunar_date',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 獲取黃曆信息
  Future<Almanac> getAlmanac(DateTime date) async {
    final cacheKey = '${_cacheKeyPrefix}almanac_${date.toIso8601String().split('T')[0]}';
    
    // 從數據庫緩存獲取
    final cached = await _databaseService.query(
      _tableName,
      where: 'key = ?',
      whereArgs: [cacheKey],
    );
    
    if (cached.isNotEmpty) {
      try {
        _cacheHits++;
        return Almanac.fromJson(json.decode(cached.first['value']));
      } catch (e) {
        await _databaseService.delete(
          _tableName,
          where: 'key = ?',
          whereArgs: [cacheKey],
        );
      }
    }
    
    _cacheMisses++;
    try {
      // 從 API 獲取數據
      final response = await _dio.get(
        '/almanac',
        queryParameters: {
          'date': date.toIso8601String().split('T')[0],
        },
        options: Options(
          extra: {
            'useCache': true,
            'cacheDuration': const Duration(days: 30),
          },
        ),
      );
      
      final almanac = Almanac.fromJson(response.data);
      
      // 保存到緩存
      await _cacheAlmanac(date, almanac);
      
      return almanac;
    } catch (e) {
      // 如果 API 請求失敗，返回空數據
      return Almanac.empty();
    }
  }

  /// 緩存黃曆數據
  Future<void> _cacheAlmanac(DateTime date, Almanac almanac) async {
    await _databaseService.insert(
      _tableName,
      {
        'key': '${_cacheKeyPrefix}almanac_${date.toIso8601String().split('T')[0]}',
        'value': json.encode(almanac.toJson()),
        'created_at': DateTime.now().toIso8601String(),
        'expires_at': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'type': 'almanac',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Map<String, int> getCacheStats() {
    return {
      'hits': _cacheHits,
      'misses': _cacheMisses,
      'total': _cacheHits + _cacheMisses,
      'hitRate': _calculateHitRate(),
    };
  }

  int _calculateHitRate() {
    final total = _cacheHits + _cacheMisses;
    if (total == 0) return 0;
    return (_cacheHits * 100 ~/ total);
  }

  /// 清理所有緩存
  Future<void> clearAllCache() async {
    await _databaseService.delete(
      _tableName,
      where: 'key LIKE ?',
      whereArgs: ['$_cacheKeyPrefix%'],
    );
    _cacheHits = 0;
    _cacheMisses = 0;
  }
} 