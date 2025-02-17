import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/ui/screens/home/home_screen.dart';
import 'package:all_lucky/core/providers/theme_provider.dart';
import 'package:all_lucky/ui/screens/home/widgets/calendar_view.dart';
import 'package:all_lucky/ui/screens/home/widgets/fortune_card.dart';
import 'package:all_lucky/ui/screens/home/widgets/zodiac_section.dart';
import 'package:all_lucky/ui/screens/home/widgets/horoscope_section.dart';
import 'package:all_lucky/ui/screens/home/widgets/compass_section.dart';
import 'package:all_lucky/ui/screens/home/widgets/bottom_nav.dart';
import 'package:all_lucky/ui/screens/scene/scene_selection_screen.dart';
import 'package:all_lucky/core/services/zodiac_service.dart';
import 'package:all_lucky/core/services/horoscope_service.dart';
import 'package:all_lucky/core/services/calendar_service.dart';
import 'package:all_lucky/core/services/compass_service.dart';
import 'package:all_lucky/core/models/zodiac.dart';
import 'package:all_lucky/core/models/horoscope.dart';
import 'package:all_lucky/core/models/compass_direction.dart';
import 'package:all_lucky/core/models/lunar_date.dart';
import 'package:all_lucky/core/models/solar_term.dart';
import 'package:all_lucky/core/providers/zodiac_provider.dart';
import 'package:all_lucky/core/providers/horoscope_provider.dart';
import 'package:all_lucky/core/providers/calendar_provider.dart';
import 'package:all_lucky/core/providers/compass_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  ZodiacService,
  HoroscopeService,
  CalendarService,
  CompassService,
])
void main() {
  late MockZodiacService mockZodiacService;
  late MockHoroscopeService mockHoroscopeService;
  late MockCalendarService mockCalendarService;
  late MockCompassService mockCompassService;

  setUp(() {
    mockZodiacService = MockZodiacService();
    mockHoroscopeService = MockHoroscopeService();
    mockCalendarService = MockCalendarService();
    mockCompassService = MockCompassService();

    // 設置基本的 mock 回應
    when(mockZodiacService.calculateZodiac(any)).thenReturn(Zodiac.dragon);
    when(mockZodiacService.getFortuneDescription(Zodiac.dragon))
        .thenAnswer((_) async => '今日運勢不錯');
    when(mockZodiacService.getLuckyElements(Zodiac.dragon))
        .thenAnswer((_) async => ['幸運色：紅色', '幸運數字：8']);

    when(mockHoroscopeService.calculateHoroscope(any))
        .thenReturn(Horoscope.leo);
    when(mockHoroscopeService.getFortuneDescription(Horoscope.leo))
        .thenAnswer((_) async => '星座運勢良好');
    when(mockHoroscopeService.getLuckyElements(Horoscope.leo))
        .thenAnswer((_) async => ['幸運星座：金牛座', '幸運方位：東方']);

    when(mockCalendarService.getLunarDate(any))
        .thenAnswer((_) async => LunarDate(
              heavenlyStem: '甲',
              earthlyBranch: '辰',
              dayZhi: '寅',
              timeZhi: '子',
              wuXing: '木',
              positions: ['東', '南'],
              year: 2024,
              month: 2,
              day: 17,
              isLeapMonth: false,
            ));
    when(mockCalendarService.getSolarTerm(any))
        .thenAnswer((_) async => SolarTerm(
              name: '雨水',
              date: DateTime(2024, 2, 17),
              description: '雨水節氣，萬物復甦',
              element: '木',
            ));
    when(mockCalendarService.getDailyActivities(any))
        .thenAnswer((_) async => DailyActivities(
              good: ['祈福', '開業'],
              bad: ['動土', '安葬'],
            ));
    when(mockCalendarService.getLuckyHours(any))
        .thenAnswer((_) async => ['子時', '午時', '卯時']);

    when(mockCompassService.getDirection(any))
        .thenReturn(CompassPoint.north);
    when(mockCompassService.getDirectionDescription(CompassPoint.north))
        .thenAnswer((_) async => '北方代表事業運');
    when(mockCompassService.getAuspiciousDirections(CompassPoint.north))
        .thenAnswer((_) async => ['東北', '西北']);
  });

  group('主頁面測試', () {
    testWidgets('測試頁面基本渲染', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            zodiacServiceProvider.overrideWithValue(mockZodiacService),
            horoscopeServiceProvider.overrideWithValue(mockHoroscopeService),
            calendarServiceProvider.overrideWithValue(mockCalendarService),
            compassServiceProvider.overrideWithValue(mockCompassService),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pump();

      // 驗證基本UI元素
      expect(find.text('今日運勢'), findsOneWidget);
      expect(find.byType(BottomNav), findsOneWidget);
      expect(find.byType(CalendarView), findsOneWidget);
      expect(find.byType(FortuneCard), findsOneWidget);
      expect(find.byType(ZodiacSection), findsOneWidget);
      expect(find.byType(HoroscopeSection), findsOneWidget);
      expect(find.byType(CompassSection), findsOneWidget);
    });

    testWidgets('測試底部導航切換', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            zodiacServiceProvider.overrideWithValue(mockZodiacService),
            horoscopeServiceProvider.overrideWithValue(mockHoroscopeService),
            calendarServiceProvider.overrideWithValue(mockCalendarService),
            compassServiceProvider.overrideWithValue(mockCompassService),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pump();

      // 初始頁面應該是首頁
      expect(find.text('今日運勢'), findsOneWidget);

      // 點擊切換到場景頁面
      await tester.tap(find.byIcon(Icons.explore));
      await tester.pumpAndSettle();
      expect(find.byType(SceneSelectionScreen), findsOneWidget);

      // 點擊切換到我的頁面
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(find.text('我的頁面開發中...'), findsOneWidget);
    });

    testWidgets('測試主題切換', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            zodiacServiceProvider.overrideWithValue(mockZodiacService),
            horoscopeServiceProvider.overrideWithValue(mockHoroscopeService),
            calendarServiceProvider.overrideWithValue(mockCalendarService),
            compassServiceProvider.overrideWithValue(mockCompassService),
          ],
          child: MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: const HomeScreen(),
          ),
        ),
      );

      await tester.pump();

      // 初始應該是亮色模式
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);

      // 點擊切換到深色模式
      await tester.tap(find.byIcon(Icons.dark_mode));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.light_mode), findsOneWidget);
    });

    testWidgets('測試萬年曆功能', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            zodiacServiceProvider.overrideWithValue(mockZodiacService),
            horoscopeServiceProvider.overrideWithValue(mockHoroscopeService),
            calendarServiceProvider.overrideWithValue(mockCalendarService),
            compassServiceProvider.overrideWithValue(mockCompassService),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pump();

      // 驗證萬年曆顯示
      expect(find.text('甲辰年正月初八'), findsOneWidget);
      expect(find.text('雨水'), findsOneWidget);
      expect(find.text('宜：祈福、開業'), findsOneWidget);
      expect(find.text('忌：動土、安葬'), findsOneWidget);
      expect(find.text('吉時：子時、午時、卯時'), findsOneWidget);
    });

    testWidgets('測試生肖運勢功能', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            zodiacServiceProvider.overrideWithValue(mockZodiacService),
            horoscopeServiceProvider.overrideWithValue(mockHoroscopeService),
            calendarServiceProvider.overrideWithValue(mockCalendarService),
            compassServiceProvider.overrideWithValue(mockCompassService),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pump();

      // 驗證生肖運勢顯示
      expect(find.text('龍'), findsOneWidget);
      expect(find.text('今日運勢不錯'), findsOneWidget);
      expect(find.text('幸運色：紅色'), findsOneWidget);
      expect(find.text('幸運數字：8'), findsOneWidget);
    });

    testWidgets('測試星座運勢功能', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            zodiacServiceProvider.overrideWithValue(mockZodiacService),
            horoscopeServiceProvider.overrideWithValue(mockHoroscopeService),
            calendarServiceProvider.overrideWithValue(mockCalendarService),
            compassServiceProvider.overrideWithValue(mockCompassService),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pump();

      // 驗證星座運勢顯示
      expect(find.text('獅子座'), findsOneWidget);
      expect(find.text('星座運勢良好'), findsOneWidget);
      expect(find.text('幸運星座：金牛座'), findsOneWidget);
      expect(find.text('幸運方位：東方'), findsOneWidget);
    });

    testWidgets('測試指南針功能', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            zodiacServiceProvider.overrideWithValue(mockZodiacService),
            horoscopeServiceProvider.overrideWithValue(mockHoroscopeService),
            calendarServiceProvider.overrideWithValue(mockCalendarService),
            compassServiceProvider.overrideWithValue(mockCompassService),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pump();

      // 驗證指南針顯示
      expect(find.text('北'), findsOneWidget);
      expect(find.text('北方代表事業運'), findsOneWidget);
      expect(find.text('吉利方位：東北、西北'), findsOneWidget);
    });
  });
} 