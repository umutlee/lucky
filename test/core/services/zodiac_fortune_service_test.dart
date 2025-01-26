import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:all_lucky/core/models/fortune.dart';
import 'package:all_lucky/core/models/zodiac.dart';
import 'package:all_lucky/core/services/api_client.dart';
import 'package:all_lucky/core/services/zodiac_fortune_service.dart';
import 'package:all_lucky/core/models/api_response.dart';
import 'package:all_lucky/core/services/cache_service.dart';

@GenerateMocks([ApiClient])
import 'zodiac_fortune_service_test.mocks.dart';

void main() {
  late ZodiacFortuneService zodiacFortuneService;
  late MockApiClient mockApiClient;
  late MockCacheService mockCacheService;

  setUp(() {
    mockCacheService = MockCacheService();
    mockApiClient = MockApiClient();
    zodiacFortuneService = ZodiacFortuneService(mockApiClient);
  });

  test('calculateZodiacAffinity should return affinity scores', () {
    final scores = zodiacFortuneService.calculateZodiacAffinity('鼠', '事業');
    expect(scores, isA<Map<String, int>>());
    expect(scores.length, greaterThan(0));
    expect(scores.values.every((score) => score >= 0 && score <= 100), isTrue);
  });

  test('generateZodiacRecommendations should return non-empty recommendations', () {
    final affinityScores = {'鼠': 80, '龍': 60};
    final recommendations = zodiacFortuneService.generateZodiacRecommendations(affinityScores);
    expect(recommendations, isNotEmpty);
  });

  test('enhanceFortuneWithZodiac should enhance fortune with zodiac info', () {
    final fortune = Fortune(
      id: '123',
      type: '事業',
      title: '今日運勢',
      score: 85,
      description: '今天運勢不錯',
      createdAt: DateTime.now(),
      luckyTimes: ['早上', '下午'],
      luckyDirections: ['東', '南'],
      luckyColors: ['紅', '黃'],
      luckyNumbers: [3, 8],
      suggestions: ['建議1', '建議2'],
      warnings: ['警告1']
    );
    
    final affinityScores = {'鼠': 80, '龍': 60};
    final enhanced = zodiacFortuneService.enhanceFortuneWithZodiac(
      fortune, 
      Zodiac.rat,
      affinityScores
    );
    
    expect(enhanced.zodiac, equals('鼠'));
    expect(enhanced.zodiacAffinity, isNotNull);
    expect(enhanced.recommendations, isNotEmpty);
  });

  test('getZodiacFortune should return fortune for zodiac', () async {
    when(mockApiClient.get<Fortune>(
      any,
      fromJson: any,
      queryParameters: any,
    )).thenAnswer((_) async => ApiResponse.success(
      data: Fortune(
        id: '123',
        type: '事業',
        title: '今日運勢',
        score: 85,
        description: '今天運勢不錯',
        createdAt: DateTime.now(),
        luckyTimes: ['早上', '下午'],
        luckyDirections: ['東', '南'],
        luckyColors: ['紅', '黃'],
        luckyNumbers: [3, 8],
        suggestions: ['建議1', '建議2'],
        warnings: ['警告1']
      )
    ));

    final fortune = await zodiacFortuneService.getZodiacFortune(
      zodiac: Zodiac.rat,
      date: DateTime.now()
    );
    
    expect(fortune, isNotNull);
    expect(fortune!.type, equals('事業'));
  });

  test('getDailyFortune should return fortune', () async {
    final date = DateTime.now();
    final mockResponse = ApiResponse<Map<String, dynamic>>.success(
      data: {
        'id': '123',
        'type': '事業',
        'title': '今日運勢',
        'score': 85,
        'description': '今天運勢不錯',
        'luckyTimes': ['早上', '下午'],
        'luckyDirections': ['東', '南'],
        'luckyColors': ['紅', '黃'],
        'luckyNumbers': [3, 8],
        'suggestions': ['多運動', '早睡早起'],
        'warnings': ['避免熬夜'],
        'date': date.toIso8601String(),
      },
    );

    when(mockApiClient.get<Map<String, dynamic>>(
      '/fortune/daily',
      queryParameters: {
        'zodiac': '鼠',
        'date': date.toIso8601String(),
      },
      fromJson: anyNamed('fromJson'),
    )).thenAnswer((_) async => mockResponse);

    final fortune = await zodiacFortuneService.getDailyFortune(Zodiac.rat, date);

    expect(fortune.type, equals('事業'));
    expect(fortune.score, equals(85));
  });

  test('getFortuneHistory should return list of fortunes', () async {
    final startDate = DateTime.now();
    final endDate = startDate.add(Duration(days: 7));
    final mockResponse = ApiResponse<List<dynamic>>.success(
      data: [
        {
          'id': '123',
          'type': '事業',
          'title': '今日運勢',
          'score': 85,
          'description': '今天運勢不錯',
          'luckyTimes': ['早上', '下午'],
          'luckyDirections': ['東', '南'],
          'luckyColors': ['紅', '黃'],
          'luckyNumbers': [3, 8],
          'suggestions': ['多運動', '早睡早起'],
          'warnings': ['避免熬夜'],
          'date': startDate.toIso8601String(),
        }
      ],
    );

    when(mockApiClient.get<List<dynamic>>(
      '/fortune/history',
      queryParameters: {
        'zodiac': '鼠',
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'limit': 7,
      },
      fromJson: anyNamed('fromJson'),
    )).thenAnswer((_) async => mockResponse);

    final fortunes = await zodiacFortuneService.getFortuneHistory(
      Zodiac.rat,
      startDate,
      endDate,
    );

    expect(fortunes.length, equals(1));
    expect(fortunes.first.type, equals('事業'));
    expect(fortunes.first.score, equals(85));
  });
} 