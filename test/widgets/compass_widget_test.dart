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
              body: CompassWidget(),
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
              body: CompassWidget(),
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
              body: CompassWidget(),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('當前方位: 東'), findsOneWidget);
    });

    testWidgets('CompassWidget updates direction on stream update',
        (WidgetTester tester) async {
      final direction1 = CompassDirection.fromDegrees(0);
      final direction2 = CompassDirection.fromDegrees(90);
      final streamController = StreamController<CompassDirection>();
      
      final container = ProviderContainer(
        overrides: [
          compassProvider
              .overrideWith((ref) => streamController.stream),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: CompassWidget(),
            ),
          ),
        ),
      );

      streamController.add(direction1);
      await tester.pump();
      expect(find.text('當前方位: 北'), findsOneWidget);

      streamController.add(direction2);
      await tester.pump();
      expect(find.text('當前方位: 東'), findsOneWidget);

      streamController.close();
    });

    testWidgets('CompassWidget calls onDirectionChanged callback',
        (WidgetTester tester) async {
      final direction = CompassDirection.fromDegrees(90);
      CompassDirection? lastDirection;

      final container = ProviderContainer(
        overrides: [
          compassProvider
              .overrideWith((ref) => Stream.value(direction)),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: CompassWidget(
                onDirectionChanged: (direction) {
                  lastDirection = direction;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(lastDirection?.direction, equals('東'));
    });
  });
} 