import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lib/ui/widgets/compass_widget.dart';
import '../../lib/core/models/compass_direction.dart';

void main() {
  group('CompassWidget Tests', () {
    testWidgets('CompassWidget displays loading state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CompassWidget(
                luckyDirections: ['東', '南'],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('CompassWidget displays error state',
        (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          compassProvider.overrideWith((ref) => Stream.error('測試錯誤')),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CompassWidget(
                luckyDirections: ['東', '南'],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('錯誤: 測試錯誤'), findsOneWidget);
    });

    testWidgets('CompassWidget displays compass with direction',
        (WidgetTester tester) async {
      final direction = CompassDirection.fromDegrees(90);
      final container = ProviderContainer(
        overrides: [
          compassProvider
              .overrideWith((ref) => Stream.value(direction)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CompassWidget(
                luckyDirections: ['東', '南'],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // 驗證方位文字是否顯示
      expect(find.text('當前方位: 東'), findsOneWidget);

      // 驗證吉利方位標記
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.style?.color == Colors.red &&
              widget.data == '東',
        ),
        findsOneWidget,
      );
    });

    testWidgets('CompassWidget displays nearest lucky direction',
        (WidgetTester tester) async {
      final direction = CompassDirection.fromDegrees(45); // 東北
      final container = ProviderContainer(
        overrides: [
          compassProvider
              .overrideWith((ref) => Stream.value(direction)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CompassWidget(
                luckyDirections: ['東'],
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('最近的吉利方位: 東'), findsOneWidget);
    });

    testWidgets('CompassWidget respects size parameter',
        (WidgetTester tester) async {
      const testSize = 200.0;
      final direction = CompassDirection.fromDegrees(0);
      final container = ProviderContainer(
        overrides: [
          compassProvider
              .overrideWith((ref) => Stream.value(direction)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CompassWidget(
                luckyDirections: ['北'],
                size: testSize,
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final sizedBox = tester.widget<SizedBox>(
        find.byWidgetPredicate((widget) => widget is SizedBox),
      );

      expect(sizedBox.width, equals(testSize));
      expect(sizedBox.height, equals(testSize));
    });
  });
} 