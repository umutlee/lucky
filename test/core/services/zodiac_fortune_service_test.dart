import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:all_lucky/core/services/api_client.dart';
import 'package:all_lucky/core/services/zodiac_fortune_service.dart';
import 'package:all_lucky/core/models/fortune.dart';
import 'package:all_lucky/core/models/zodiac.dart';
import 'package:all_lucky/core/models/api_response.dart';
import 'package:all_lucky/core/services/cache_service.dart';

@GenerateMocks([], customMocks: [MockSpec<ApiClient>(as: #MockApiClient)])
class MockApiClientBase implements ApiClient {
  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool forceRefresh = false,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return ApiResponse.success(fromJson({
      'id': '1',
      'type': 'daily',
      'title': '今日運勢',
      'score': 85,
      'description': '運勢不錯',
      'date': DateTime.now().toIso8601String(),
      'luckyTimes': ['09:00-11:00'],
      'luckyDirections': ['東'],
      'luckyColors': ['紅'],
      'luckyNumbers': [8],
      'suggestions': ['多運動'],
      'warnings': ['注意休息'],
      'createdAt': DateTime.now().toIso8601String(),
    }));
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
    dynamic options,
  }) async {
    return ApiResponse.success(fromJson?.call({
      'id': '1',
      'type': 'daily',
      'title': '今日運勢',
      'score': 85,
      'description': '運勢不錯',
      'date': DateTime.now().toIso8601String(),
      'luckyTimes': ['09:00-11:00'],
      'luckyDirections': ['東'],
      'luckyColors': ['紅'],
      'luckyNumbers': [8],
      'suggestions': ['多運動'],
      'warnings': ['注意休息'],
      'createdAt': DateTime.now().toIso8601String(),
    }));
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return ApiResponse.success(fromJson?.call({
      'id': '1',
      'type': 'daily',
      'title': '今日運勢',
      'score': 85,
      'description': '運勢不錯',
      'date': DateTime.now().toIso8601String(),
      'luckyTimes': ['09:00-11:00'],
      'luckyDirections': ['東'],
      'luckyColors': ['紅'],
      'luckyNumbers': [8],
      'suggestions': ['多運動'],
      'warnings': ['注意休息'],
      'createdAt': DateTime.now().toIso8601String(),
    }));
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return ApiResponse.success(fromJson?.call({
      'id': '1',
      'type': 'daily',
      'title': '今日運勢',
      'score': 85,
      'description': '運勢不錯',
      'date': DateTime.now().toIso8601String(),
      'luckyTimes': ['09:00-11:00'],
      'luckyDirections': ['東'],
      'luckyColors': ['紅'],
      'luckyNumbers': [8],
      'suggestions': ['多運動'],
      'warnings': ['注意休息'],
      'createdAt': DateTime.now().toIso8601String(),
    }));
  }

  @override
  Future<void> clearCache() async {}
}

void main() {
  late MockApiClient mockApiClient;
  late ZodiacFortuneService zodiacFortuneService;

  setUp(() {
    mockApiClient = MockApiClient();
    zodiacFortuneService = ZodiacFortuneService(mockApiClient);
  });

  group('ZodiacFortuneService', () {
    test('calculateZodiacAffinity should return correct affinity score', () {
      final affinity = zodiacFortuneService.calculateZodiacAffinity('鼠', '事業');
      expect(affinity, isA<Map<String, int>>());
      expect(affinity.values.every((v) => v >= 0 && v <= 100), isTrue);
    });

    test('generateZodiacRecommendations should return valid recommendations', () {
      final recommendations = zodiacFortuneService.generateZodiacRecommendations('鼠', '事業', 80);
      expect(recommendations, isA<List<String>>());
      expect(recommendations.length >= 2 && recommendations.length <= 5, isTrue);
      expect(recommendations.every((r) => r.isNotEmpty), isTrue);
    });

    test('enhanceFortuneWithZodiac should add zodiac information', () {
      final fortune = Fortune(
        id: '1',
        type: 'daily',
        title: '今日運勢',
        score: 85,
        description: '運勢不錯',
        date: DateTime.now(),
        luckyTimes: ['09:00-11:00'],
        luckyDirections: ['東'],
        luckyColors: ['紅'],
        luckyNumbers: [8],
        suggestions: ['多運動'],
        warnings: ['注意休息'],
        createdAt: DateTime.now(),
      );
      
      final enhanced = zodiacFortuneService.enhanceFortuneWithZodiac(fortune, '鼠');
      expect(enhanced.zodiac, equals('鼠'));
      expect(enhanced.recommendations.length, greaterThan(fortune.recommendations.length));
    });

    test('getZodiacFortune should return fortune from API', () async {
      final testDate = DateTime.now();
      when(mockApiClient.get<Fortune>(
        '/zodiac/rat/fortune',
        queryParameters: {'date': testDate.toIso8601String()},
        fromJson: anyNamed('fromJson'),
      )).thenAnswer((_) async => ApiResponse.success(Fortune(
        id: '1',
        type: 'daily',
        title: '今日運勢',
        score: 85,
        description: '運勢不錯',
        date: testDate,
        luckyTimes: ['09:00-11:00'],
        luckyDirections: ['東'],
        luckyColors: ['紅'],
        luckyNumbers: [8],
        suggestions: ['多運動'],
        warnings: ['注意休息'],
        createdAt: testDate,
      )));

      final fortune = await zodiacFortuneService.getZodiacFortune('鼠', testDate);
      expect(fortune, isA<Fortune>());
      expect(fortune.type, equals('daily'));
    });

    test('getDailyFortune should return fortune from API', () async {
      final testDate = DateTime.now();
      when(mockApiClient.get<Fortune>(
        '/fortune/daily',
        queryParameters: {
          'zodiac': '鼠',
          'date': testDate.toIso8601String(),
        },
        fromJson: anyNamed('fromJson'),
      )).thenAnswer((_) async => ApiResponse.success(Fortune(
        id: '1',
        type: 'daily',
        title: '今日運勢',
        score: 85,
        description: '運勢不錯',
        date: testDate,
        luckyTimes: ['09:00-11:00'],
        luckyDirections: ['東'],
        luckyColors: ['紅'],
        luckyNumbers: [8],
        suggestions: ['多運動'],
        warnings: ['注意休息'],
        createdAt: testDate,
      )));

      final fortune = await zodiacFortuneService.getDailyFortune('鼠', testDate);
      expect(fortune, isA<Fortune>());
      expect(fortune.type, equals('daily'));
    });

    test('getFortuneHistory should return list of fortunes from API', () async {
      final testDate = DateTime.now();
      final startDate = testDate.subtract(Duration(days: 7));
      final endDate = testDate;
      
      when(mockApiClient.get<List<Fortune>>(
        '/fortune/history',
        queryParameters: {
          'zodiac': '鼠',
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'limit': 7,
        },
        fromJson: anyNamed('fromJson'),
      )).thenAnswer((_) async => ApiResponse.success([
        Fortune(
          id: '1',
          type: 'daily',
          title: '今日運勢',
          score: 85,
          description: '運勢不錯',
          date: testDate,
          luckyTimes: ['09:00-11:00'],
          luckyDirections: ['東'],
          luckyColors: ['紅'],
          luckyNumbers: [8],
          suggestions: ['多運動'],
          warnings: ['注意休息'],
          createdAt: testDate,
        )
      ]));

      final history = await zodiacFortuneService.getFortuneHistory('鼠', startDate, endDate);
      expect(history, isA<List<Fortune>>());
      expect(history.length, equals(1));
    });

    test('API error should be handled properly', () async {
      final testDate = DateTime.now();
      when(mockApiClient.get<Fortune>(
        '/fortune/daily',
        queryParameters: {
          'zodiac': '鼠',
          'date': testDate.toIso8601String(),
        },
        fromJson: anyNamed('fromJson'),
      )).thenAnswer((_) async => ApiResponse.error('Error'));

      expect(() => zodiacFortuneService.getDailyFortune('鼠', testDate), throwsException);
    });
  });
} 