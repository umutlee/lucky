import 'dart:convert';
import 'package:dio/dio.dart';
import '../services/database_service.dart';
import '../models/daily_fortune.dart';

/// 運勢數據倉庫
/// 負責處理運勢數據的獲取和緩存
class FortuneRepository {
  /// HTTP 客戶端
  final Dio _dio;
  
  /// DatabaseService 實例
  final DatabaseService _databaseService;
  
  /// API 基礎 URL
  static const String _baseUrl = 'https://api.example.com/v1';
  
  /// 緩存鍵前綴
  static const String _cacheKeyPrefix = 'fortune_';
  
  /// 數據庫表名
  static const String _tableName = 'cache_records';
  
  /// 構造函數
  FortuneRepository(this._dio, this._databaseService);
  
  /// 獲取指定日期的運勢信息
  Future<DailyFortune> getDailyFortune(DateTime date) async {
    final cacheKey = _getCacheKey(date);
    
    // 從數據庫緩存獲取
    final cached = await _databaseService.query(
      _tableName,
      where: 'key = ?',
      whereArgs: [cacheKey],
    );
    
    if (cached.isNotEmpty) {
      try {
        return DailyFortune.fromJson(json.decode(cached.first['value']));
      } catch (e) {
        await _databaseService.delete(
          _tableName,
          where: 'key = ?',
          whereArgs: [cacheKey],
        );
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
    final keys = await _databaseService.query(
      _tableName,
      where: 'expires_at < ?',
      whereArgs: [now.toIso8601String()],
    );
    
    for (final key in keys) {
      await _databaseService.delete(
        _tableName,
        where: 'key = ?',
        whereArgs: [key['key']],
      );
    }
  }
  
  /// 生成緩存鍵
  String _getCacheKey(DateTime date) {
    return '$_cacheKeyPrefix${date.toIso8601String().split('T')[0]}';
  }
  
  /// 緩存運勢數據
  Future<void> _cacheFortune(DateTime date, DailyFortune fortune) async {
    await _databaseService.insert(
      _tableName,
      {
        'key': _getCacheKey(date),
        'value': json.encode(fortune.toJson()),
        'created_at': DateTime.now().toIso8601String(),
        'expires_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
} 