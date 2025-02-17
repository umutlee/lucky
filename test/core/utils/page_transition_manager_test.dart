import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/utils/page_transition_manager.dart';

void main() {
  group('頁面轉場管理器測試', () {
    testWidgets('創建基本轉場', (tester) async {
      final page = const Text('測試頁面');
      final route = PageTransitionManager.createRoute<void>(
        page: page,
        type: PageTransitionType.fade,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => route.buildPage(
              context,
              const AlwaysStoppedAnimation(1.0),
              const AlwaysStoppedAnimation(0.0),
            ),
          ),
        ),
      );

      expect(find.text('測試頁面'), findsOneWidget);
    });

    testWidgets('創建自定義轉場', (tester) async {
      final page = const Text('測試頁面');
      final route = PageTransitionManager.createRoute<void>(
        page: page,
        type: PageTransitionType.slideAndFade,
        direction: TransitionDirection.right,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => route.buildPage(
              context,
              const AlwaysStoppedAnimation(1.0),
              const AlwaysStoppedAnimation(0.0),
            ),
          ),
        ),
      );

      expect(find.text('測試頁面'), findsOneWidget);
    });

    test('檢查默認轉場時間', () {
      expect(
        PageTransitionManager.defaultDuration,
        const Duration(milliseconds: 300),
      );
    });

    test('檢查默認轉場曲線', () {
      expect(
        PageTransitionManager.defaultCurve,
        Curves.easeInOut,
      );
    });

    testWidgets('測試不同類型的轉場效果', (tester) async {
      final transitions = [
        PageTransitionType.fade,
        PageTransitionType.slide,
        PageTransitionType.scale,
        PageTransitionType.rotation,
        PageTransitionType.slideAndFade,
      ];

      for (final type in transitions) {
        final page = Text('測試${type.name}轉場');
        final route = PageTransitionManager.createRoute<void>(
          page: page,
          type: type,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => route.buildPage(
                context,
                const AlwaysStoppedAnimation(1.0),
                const AlwaysStoppedAnimation(0.0),
              ),
            ),
          ),
        );

        expect(find.text('測試${type.name}轉場'), findsOneWidget);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('測試所有方向的偏移量', (tester) async {
      final directions = [
        TransitionDirection.right,
        TransitionDirection.left,
        TransitionDirection.up,
        TransitionDirection.down,
      ];

      final expectedOffsets = [
        const Offset(1.0, 0.0),
        const Offset(-1.0, 0.0),
        const Offset(0.0, -1.0),
        const Offset(0.0, 1.0),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              for (var i = 0; i < directions.length; i++) {
                final route = PageTransitionManager.createRoute<void>(
                  page: const SizedBox(),
                  type: PageTransitionType.slide,
                  direction: directions[i],
                );

                final transition = route.transitionsBuilder(
                  context,
                  const AlwaysStoppedAnimation(0.0),
                  const AlwaysStoppedAnimation(0.0),
                  const SizedBox(),
                ) as SlideTransition;

                expect(
                  transition.position.value,
                  equals(expectedOffsets[i]),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
} 