import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/lunar_date.dart';
import '../models/almanac_data.dart';
import '../config/api_config.dart';
import 'storage_service.dart';
import 'api_client.dart';

/// 黃曆服務
class AlmanacService {
  final ApiClient _apiClient;
  final StorageService _storage;

  AlmanacService(this._apiClient, this._storage);

  /// 獲取每日黃曆
  Future<ApiResponse<AlmanacData>> getDailyAlmanac(
    String date, {
    bool forceRefresh = false,
  }) async {
    return _apiClient.get<AlmanacData>(
      ApiConfig.dailyAlmanacEndpoint,
      queryParameters: {'date': date},
      forceRefresh: forceRefresh,
      fromJson: (json) => AlmanacData.fromJson(json),
    );
  }

  /// 獲取月度黃曆
  Future<ApiResponse<List<AlmanacData>>> getMonthAlmanac(
    int year,
    int month, {
    bool forceRefresh = false,
  }) async {
    return _apiClient.get<List<AlmanacData>>(
      ApiConfig.monthAlmanacEndpoint,
      queryParameters: {
        'year': year,
        'month': month,
      },
      forceRefresh: forceRefresh,
      fromJson: (json) {
        final list = json['data'] as List;
        return list.map((e) => AlmanacData.fromJson(e)).toList();
      },
    );
  }

  /// 獲取農曆日期
  Future<ApiResponse<LunarDate>> getLunarDate(
    String date, {
    bool forceRefresh = false,
  }) async {
    return _apiClient.get<LunarDate>(
      ApiConfig.lunarDateEndpoint,
      queryParameters: {'date': date},
      forceRefresh: forceRefresh,
      fromJson: (json) => LunarDate.fromJson(json),
    );
  }

  /// 清除黃曆緩存
  Future<void> clearAlmanacCache() async {
    await _storage.clearAllCache();
  }

  /// 清除過期黃曆緩存
  Future<void> clearExpiredAlmanacCache() async {
    await _storage.clearExpiredCache();
  }
} 