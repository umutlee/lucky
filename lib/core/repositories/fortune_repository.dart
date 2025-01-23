import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fortune.dart';
import '../services/sqlite_preferences_service.dart';
import '../providers/dio_provider.dart';
import 'dart:convert';

final fortuneRepositoryProvider = Provider<FortuneRepository>((ref) {
  return FortuneRepository(
    ref.watch(dioProvider),
    ref.watch(sqlitePreferencesServiceProvider),
  );
});

class FortuneRepository {
  final Dio _dio;
  final SQLitePreferencesService _prefsService;
  static const _baseUrl = 'https://api.example.com/fortunes';
  static const _cachePrefix = 'fortune_list_';
  static const _cacheExpiry = Duration(minutes: 30);

  FortuneRepository(this._dio, this._prefsService);

  Future<List<Fortune>> getFortunes({
    int page = 1,
    int pageSize = 20,
  }) async {
    final cacheKey = '${_cachePrefix}${page}_$pageSize';
    
    // 嘗試從緩存中獲取數據
    final cachedData = await _prefsService.getValue<String>(cacheKey);
    if (cachedData != null) {
      final List<dynamic> jsonList = json.decode(cachedData);
      return jsonList.map((json) => Fortune.fromJson(json)).toList();
    }

    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      final List<dynamic> jsonList = response.data['data'];
      final fortunes = jsonList.map((json) => Fortune.fromJson(json)).toList();

      // 緩存數據
      await _prefsService.setValue(
        cacheKey,
        json.encode(jsonList),
        expiryDuration: _cacheExpiry,
      );

      return fortunes;
    } catch (e) {
      throw Exception('獲取運勢列表失敗: $e');
    }
  }

  Future<void> clearCache() async {
    final keys = await _prefsService.getKeys();
    for (final key in keys) {
      if (key.startsWith(_cachePrefix)) {
        await _prefsService.remove(key);
      }
    }
  }
}