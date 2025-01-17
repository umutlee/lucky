import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/daily_fortune.dart';
import '../models/study_fortune.dart';
import '../models/career_fortune.dart';
import '../models/love_fortune.dart';
import '../config/api_config.dart';
import 'storage_service.dart';
import 'api_client.dart';

/// 運勢服務
class FortuneService {
  final ApiClient _apiClient;
  final StorageService _storage;

  FortuneService(this._apiClient, this._storage);

  /// 獲取每日運勢
  Future<ApiResponse<DailyFortune>> getDailyFortune(
    String date, {
    bool forceRefresh = false,
  }) async {
    return _apiClient.get<DailyFortune>(
      ApiConfig.dailyFortuneEndpoint,
      queryParameters: {'date': date},
      forceRefresh: forceRefresh,
      fromJson: (json) => DailyFortune.fromJson(json),
    );
  }

  /// 獲取學業運勢
  Future<ApiResponse<StudyFortune>> getStudyFortune(
    String date, {
    bool forceRefresh = false,
  }) async {
    return _apiClient.get<StudyFortune>(
      ApiConfig.studyFortuneEndpoint,
      queryParameters: {'date': date},
      forceRefresh: forceRefresh,
      fromJson: (json) => StudyFortune.fromJson(json),
    );
  }

  /// 獲取事業運勢
  Future<ApiResponse<CareerFortune>> getCareerFortune(
    String date, {
    bool forceRefresh = false,
  }) async {
    return _apiClient.get<CareerFortune>(
      ApiConfig.careerFortuneEndpoint,
      queryParameters: {'date': date},
      forceRefresh: forceRefresh,
      fromJson: (json) => CareerFortune.fromJson(json),
    );
  }

  /// 獲取愛情運勢
  Future<ApiResponse<LoveFortune>> getLoveFortune(
    String date, {
    bool forceRefresh = false,
  }) async {
    return _apiClient.get<LoveFortune>(
      ApiConfig.loveFortuneEndpoint,
      queryParameters: {'date': date},
      forceRefresh: forceRefresh,
      fromJson: (json) => LoveFortune.fromJson(json),
    );
  }

  /// 清除運勢緩存
  Future<void> clearFortuneCache() async {
    await _storage.clearAllCache();
  }

  /// 清除過期運勢緩存
  Future<void> clearExpiredFortuneCache() async {
    await _storage.clearExpiredCache();
  }
} 