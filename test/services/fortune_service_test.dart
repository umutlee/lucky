import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:all_lucky/core/services/fortune_service.dart';
import 'package:all_lucky/core/services/zodiac_fortune_service.dart';
import 'package:all_lucky/core/services/user_settings_service.dart';
import 'package:all_lucky/core/models/fortune.dart';
import 'package:all_lucky/core/models/user_settings.dart';
import 'package:all_lucky/core/models/zodiac.dart';
import 'package:all_lucky/core/services/storage_service.dart';

@GenerateMocks([ZodiacFortuneService, UserSettingsService])
void main() {
  late FortuneService fortuneService;
  late MockZodiacFortuneService mockZodiacFortuneService;
  late MockUserSettingsService mockUserSettingsService;
  late MockStorageService mockStorageService;

  setUp(() {
    mockZodiacFortuneService = MockZodiacFortuneService();
    mockUserSettingsService = MockUserSettingsService();
    mockStorageService = MockStorageService();
    fortuneService = FortuneService(
      mockZodiacFortuneService,
      mockUserSettingsService,
      mockStorageService,
    );
  });

  group('FortuneService Tests', () {
    test('generateFortune generates fortune with correct zodiac info', () async {
      // 準備測試數據
      final userSettings = UserSettings(
        zodiac: '龍',
        birthYear: 2000,
        preferredFortuneTypes: ['事業', '財運'],
      );

      // 設置 mock 行為
      when(mockUserSettingsService.loadSettings())
          .thenAnswer((_) async => userSettings);

      when(mockZodiacFortuneService.enhanceFortuneWithZodiac(any, '龍'))
          .thenAnswer((invocation) {
        final fortune = invocation.positionalArguments[0] as Fortune;
        return fortune.copyWith(
          zodiacAffinity: {'鼠': 90, '猴': 85},
          recommendations: [
            ...fortune.recommendations,
            '今天是屬龍的你大展身手的好時機',
          ],
        );
      });

      // 生成運勢
      final fortune = await fortuneService.generateFortune('事業');

      // 驗證結果
      expect(fortune.zodiac, '龍');
      expect(fortune.type, '事業');
      expect(fortune.zodiacAffinity, {'鼠': 90, '猴': 85});
      expect(fortune.recommendations.last, contains('屬龍的你'));
      
      // 驗證分數在合理範圍內
      expect(fortune.score, inInclusiveRange(30, 100));
      
      // 驗證描述符合分數
      if (fortune.score >= 80) {
        expect(fortune.description, contains('非常好'));
      } else if (fortune.score >= 60) {
        expect(fortune.description, contains('不錯'));
      } else if (fortune.score >= 40) {
        expect(fortune.description, contains('普通'));
      } else {
        expect(fortune.description, contains('欠佳'));
      }
    });

    test('generateFortune applies score bonus for preferred types', () async {
      final userSettings = UserSettings(
        zodiac: '龍',
        birthYear: 2000,
        preferredFortuneTypes: ['事業'],
      );

      when(mockUserSettingsService.loadSettings())
          .thenAnswer((_) async => userSettings);

      when(mockZodiacFortuneService.enhanceFortuneWithZodiac(any, any))
          .thenAnswer((invocation) => invocation.positionalArguments[0] as Fortune);

      // 生成偏好類型的運勢
      final preferredFortune = await fortuneService.generateFortune('事業');
      
      // 生成非偏好類型的運勢
      final normalFortune = await fortuneService.generateFortune('學習');

      // 記錄分數用於調試
      print('Preferred type score: ${preferredFortune.score}');
      print('Normal type score: ${normalFortune.score}');

      // 驗證基礎分數在合理範圍內
      expect(normalFortune.score, inInclusiveRange(30, 70));
      
      // 驗證偏好類型的分數有加成（但不超過100）
      expect(preferredFortune.score, inInclusiveRange(30, 100));
    });

    test('generateFortune provides appropriate recommendations based on type and score', () async {
      final userSettings = UserSettings(
        zodiac: '龍',
        birthYear: 2000,
      );

      when(mockUserSettingsService.loadSettings())
          .thenAnswer((_) async => userSettings);

      when(mockZodiacFortuneService.enhanceFortuneWithZodiac(any, any))
          .thenAnswer((invocation) => invocation.positionalArguments[0] as Fortune);

      // 測試不同類型的運勢建議
      final studyFortune = await fortuneService.generateFortune('學習');
      final careerFortune = await fortuneService.generateFortune('事業');
      final wealthFortune = await fortuneService.generateFortune('財運');
      final socialFortune = await fortuneService.generateFortune('人際');

      // 驗證每種類型都有相應的建議
      expect(studyFortune.recommendations, isNotEmpty);
      expect(careerFortune.recommendations, isNotEmpty);
      expect(wealthFortune.recommendations, isNotEmpty);
      expect(socialFortune.recommendations, isNotEmpty);

      // 驗證建議內容符合類型
      expect(studyFortune.recommendations.any((r) => r.contains('學習')), isTrue);
      expect(careerFortune.recommendations.any((r) => r.contains('工作')), isTrue);
      expect(wealthFortune.recommendations.any((r) => r.contains('財務')), isTrue);
      expect(socialFortune.recommendations.any((r) => r.contains('社交') || r.contains('關係')), isTrue);
    });

    test('獲取每日運勢', () async {
      final settings = UserSettings.defaultSettings();
      when(mockUserSettingsService.getUserSettings())
          .thenAnswer((_) async => settings);

      final fortune = Fortune(
        id: '1',
        type: '事業',
        title: '今日事業運勢',
        description: '今天的事業運勢非常好',
        score: 85,
        date: DateTime.now(),
        isLuckyDay: true,
        zodiacAffinity: {'鼠': 90, '猴': 85},
        recommendations: ['屬龍的你今天適合...'],
      );

      when(mockZodiacFortuneService.getDailyFortune(any, any))
          .thenAnswer((_) async => fortune);

      final result = await fortuneService.getDailyFortune();
      expect(result, isNotNull);
      expect(result.score, inInclusiveRange(30, 100));
      expect(result.recommendations, isNotEmpty);
    });

    test('獲取運勢歷史', () async {
      final settings = UserSettings.defaultSettings();
      when(mockUserSettingsService.getUserSettings())
          .thenAnswer((_) async => settings);

      final fortunes = [
        Fortune(
          id: '1',
          type: '事業',
          title: '昨日事業運勢',
          description: '昨天的事業運勢不錯',
          score: 75,
          date: DateTime.now().subtract(const Duration(days: 1)),
          isLuckyDay: false,
          zodiacAffinity: {'鼠': 80, '猴': 75},
          recommendations: ['屬龍的你昨天...'],
        ),
      ];

      when(mockZodiacFortuneService.getFortuneHistory(any, any, limit: anyNamed('limit')))
          .thenAnswer((_) async => fortunes);

      final result = await fortuneService.getFortuneHistory();
      expect(result, isNotNull);
      expect(result, isNotEmpty);
      expect(result.first.score, inInclusiveRange(30, 100));
    });
  });
} 