import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/models/filter_criteria.dart';
import 'package:all_lucky/core/models/fortune_type.dart';
import 'package:all_lucky/core/providers/filter_provider.dart';
import 'package:all_lucky/features/fortune/widgets/fortune_filter.dart';

void main() {
  group('FortuneFilter', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('初始化測試', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FortuneFilter(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 驗證標題
      expect(find.text('篩選條件'), findsOneWidget);
      expect(find.text('運勢類型'), findsOneWidget);
      expect(find.text('分數範圍'), findsOneWidget);
      expect(find.text('僅顯示吉日'), findsOneWidget);
      expect(find.text('吉利方位'), findsOneWidget);
      expect(find.text('適合活動'), findsOneWidget);
      expect(find.text('日期範圍'), findsOneWidget);
      expect(find.text('排序選項'), findsOneWidget);

      // 驗證重置按鈕
      expect(find.byIcon(Icons.refresh), findsOneWidget);

      // 驗證運勢類型選項
      expect(find.text('每日運勢'), findsOneWidget);
      expect(find.text('學業運勢'), findsOneWidget);
      expect(find.text('事業運勢'), findsOneWidget);
      expect(find.text('愛情運勢'), findsOneWidget);

      // 驗證分數範圍滑塊
      expect(find.byType(RangeSlider), findsOneWidget);

      // 驗證吉日開關
      expect(find.byType(Switch), findsOneWidget);

      // 驗證方位選項
      expect(find.text('東'), findsOneWidget);
      expect(find.text('南'), findsOneWidget);
      expect(find.text('西'), findsOneWidget);
      expect(find.text('北'), findsOneWidget);

      // 驗證活動選項
      expect(find.text('工作'), findsOneWidget);
      expect(find.text('學習'), findsOneWidget);
      expect(find.text('運動'), findsOneWidget);
      expect(find.text('旅遊'), findsOneWidget);
      expect(find.text('投資'), findsOneWidget);
      expect(find.text('交友'), findsOneWidget);
      expect(find.text('購物'), findsOneWidget);
      expect(find.text('娛樂'), findsOneWidget);

      // 驗證日期選擇按鈕
      expect(find.text('選擇日期範圍'), findsOneWidget);

      // 驗證排序選項
      expect(find.byType(DropdownButtonFormField<SortField>), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<SortOrder>), findsOneWidget);
    });

    testWidgets('運勢類型選擇測試', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FortuneFilter(),
              ),
            ),
          ),
        ),
      );

      // 點擊學業運勢
      await tester.tap(find.text('學業運勢'));
      await tester.pumpAndSettle();

      // 驗證狀態更新
      final criteria = container.read(filterCriteriaProvider);
      expect(criteria.fortuneType, equals(FortuneType.study));
    });

    testWidgets('分數範圍測試', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FortuneFilter(),
              ),
            ),
          ),
        ),
      );

      // 找到 RangeSlider
      final finder = find.byType(RangeSlider);
      expect(finder, findsOneWidget);

      // 模擬滑動
      final RangeSlider slider = tester.widget(finder);
      expect(slider.values.start, equals(0.0));
      expect(slider.values.end, equals(100.0));
    });

    testWidgets('吉日開關測試', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FortuneFilter(),
              ),
            ),
          ),
        ),
      );

      // 找到開關
      final finder = find.byType(Switch);
      expect(finder, findsOneWidget);

      // 點擊開關
      await tester.tap(finder);
      await tester.pumpAndSettle();

      // 驗證狀態更新
      final criteria = container.read(filterCriteriaProvider);
      expect(criteria.isLuckyDay, isTrue);
    });

    testWidgets('方位選擇測試', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FortuneFilter(),
              ),
            ),
          ),
        ),
      );

      // 點擊東方
      await tester.tap(find.text('東'));
      await tester.pumpAndSettle();

      // 驗證狀態更新
      final criteria = container.read(filterCriteriaProvider);
      expect(criteria.luckyDirections, contains('東'));
    });

    testWidgets('活動選擇測試', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FortuneFilter(),
              ),
            ),
          ),
        ),
      );

      // 點擊工作
      await tester.tap(find.text('工作'));
      await tester.pumpAndSettle();

      // 驗證狀態更新
      final criteria = container.read(filterCriteriaProvider);
      expect(criteria.activities, contains('工作'));
    });

    testWidgets('日期範圍選擇測試', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FortuneFilter(),
              ),
            ),
          ),
        ),
      );

      // 找到日期選擇按鈕
      expect(find.text('選擇日期範圍'), findsOneWidget);
    });

    testWidgets('FortuneFilter - 排序選項測試', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FortuneFilter(),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 檢查排序欄位下拉選單
      final sortFieldDropdown = find.byType(DropdownButtonFormField<SortField>);
      expect(sortFieldDropdown, findsOneWidget);
      await tester.tap(sortFieldDropdown);
      await tester.pumpAndSettle();

      // 驗證排序欄位選項
      expect(find.text('日期').last, findsOneWidget);
      expect(find.text('分數'), findsOneWidget);
      expect(find.text('類型'), findsOneWidget);

      // 選擇日期並關閉下拉選單
      await tester.tap(find.text('日期').last);
      await tester.pumpAndSettle();

      // 檢查排序順序下拉選單
      final sortOrderDropdown = find.byType(DropdownButtonFormField<SortOrder>);
      expect(sortOrderDropdown, findsOneWidget);
      await tester.tap(sortOrderDropdown);
      await tester.pumpAndSettle();

      // 驗證排序順序選項
      expect(find.text('降序').last, findsOneWidget);
      expect(find.text('升序'), findsOneWidget);

      // 選擇降序並關閉下拉選單
      await tester.tap(find.text('降序').last);
      await tester.pumpAndSettle();

      // 驗證選擇的值
      final criteria = container.read(filterCriteriaProvider);
      expect(criteria.sortField, equals(SortField.date));
      expect(criteria.sortOrder, equals(SortOrder.descending));
    });

    testWidgets('FortuneFilter - 重置功能測試', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FortuneFilter(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 設置初始狀態
      container.read(filterCriteriaProvider.notifier)
        ..updateFortuneType(FortuneType.study)
        ..updateScoreRange(60, 80)
        ..updateLuckyDay(true)
        ..updateLuckyDirections(['東'])
        ..updateActivities(['工作']);
      await tester.pumpAndSettle();

      // 點擊重置按鈕
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // 驗證重置後的狀態
      final criteria = container.read(filterCriteriaProvider);
      expect(criteria.fortuneType, isNull);
      expect(criteria.minScore, isNull);
      expect(criteria.maxScore, isNull);
      expect(criteria.isLuckyDay, isFalse);
      expect(criteria.luckyDirections, isNull);
      expect(criteria.activities, isNull);
      expect(criteria.startDate, isNull);
      expect(criteria.endDate, isNull);
      expect(criteria.sortField, equals(SortField.date));
      expect(criteria.sortOrder, equals(SortOrder.descending));
    });
  });
}