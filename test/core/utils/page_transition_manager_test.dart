import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/utils/page_transition_manager.dart';

void main() {
  group('PageTransitionManager', () {
    testWidgets('淡入淡出轉場效果測試', (tester) async {
      final route = PageTransitionManager.createRoute<void>(
        page: const Scaffold(),
        type: PageTransitionType.fade,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => route.buildPage(
              context: context,
              animation: const AlwaysStoppedAnimation(0),
              secondaryAnimation: const AlwaysStoppedAnimation(0),
            ),
          ),
        ),
      );

      expect(find.byType(FadeTransition), findsOneWidget);
    });

    testWidgets('滑動轉場效果測試', (tester) async {
      final route = PageTransitionManager.createRoute<void>(
        page: const Scaffold(),
        type: PageTransitionType.slide,
        direction: TransitionDirection.right,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => route.buildPage(
              context: context,
              animation: const AlwaysStoppedAnimation(0),
              secondaryAnimation: const AlwaysStoppedAnimation(0),
            ),
          ),
        ),
      );

      expect(find.byType(SlideTransition), findsOneWidget);
    });

    testWidgets('縮放轉場效果測試', (tester) async {
      final route = PageTransitionManager.createRoute<void>(
        page: const Scaffold(),
        type: PageTransitionType.scale,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => route.buildPage(
              context: context,
              animation: const AlwaysStoppedAnimation(0),
              secondaryAnimation: const AlwaysStoppedAnimation(0),
            ),
          ),
        ),
      );

      expect(find.byType(ScaleTransition), findsOneWidget);
    });

    testWidgets('旋轉轉場效果測試', (tester) async {
      final route = PageTransitionManager.createRoute<void>(
        page: const Scaffold(),
        type: PageTransitionType.rotation,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => route.buildPage(
              context: context,
              animation: const AlwaysStoppedAnimation(0),
              secondaryAnimation: const AlwaysStoppedAnimation(0),
            ),
          ),
        ),
      );

      expect(find.byType(RotationTransition), findsOneWidget);
    });

    testWidgets('滑動並淡入淡出轉場效果測試', (tester) async {
      final route = PageTransitionManager.createRoute<void>(
        page: const Scaffold(),
        type: PageTransitionType.slideAndFade,
        direction: TransitionDirection.left,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => route.buildPage(
              context: context,
              animation: const AlwaysStoppedAnimation(0),
              secondaryAnimation: const AlwaysStoppedAnimation(0),
            ),
          ),
        ),
      );

      expect(find.byType(SlideTransition), findsOneWidget);
      expect(find.byType(FadeTransition), findsOneWidget);
    });

    testWidgets('動畫持續時間測試', (tester) async {
      const duration = Duration(milliseconds: 500);
      final route = PageTransitionManager.createRoute<void>(
        page: const Scaffold(),
        type: PageTransitionType.fade,
        duration: duration,
      );

      expect(route.transitionDuration, duration);
    });

    testWidgets('動畫曲線測試', (tester) async {
      const curve = Curves.easeInOut;
      final route = PageTransitionManager.createRoute<void>(
        page: const Scaffold(),
        type: PageTransitionType.fade,
        curve: curve,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => route.buildPage(
              context: context,
              animation: const AlwaysStoppedAnimation(0),
              secondaryAnimation: const AlwaysStoppedAnimation(0),
            ),
          ),
        ),
      );

      final fadeTransition = tester.widget<FadeTransition>(
        find.byType(FadeTransition),
      );
      expect(fadeTransition.opacity.curve, curve);
    });

    testWidgets('滑動方向測試', (tester) async {
      for (final direction in TransitionDirection.values) {
        final route = PageTransitionManager.createRoute<void>(
          page: const Scaffold(),
          type: PageTransitionType.slide,
          direction: direction,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => route.buildPage(
                context: context,
                animation: const AlwaysStoppedAnimation(0),
                secondaryAnimation: const AlwaysStoppedAnimation(0),
              ),
            ),
          ),
        );

        final slideTransition = tester.widget<SlideTransition>(
          find.byType(SlideTransition),
        );

        final offset = slideTransition.position.value;
        switch (direction) {
          case TransitionDirection.right:
            expect(offset.dx, equals(1.0));
            expect(offset.dy, equals(0.0));
            break;
          case TransitionDirection.left:
            expect(offset.dx, equals(-1.0));
            expect(offset.dy, equals(0.0));
            break;
          case TransitionDirection.up:
            expect(offset.dx, equals(0.0));
            expect(offset.dy, equals(-1.0));
            break;
          case TransitionDirection.down:
            expect(offset.dx, equals(0.0));
            expect(offset.dy, equals(1.0));
            break;
        }
      }
    });

    testWidgets('動畫完成回調測試', (tester) async {
      bool completed = false;
      final route = PageTransitionManager.createRoute<void>(
        page: const Scaffold(),
        type: PageTransitionType.fade,
        onTransitionComplete: () => completed = true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => route.buildPage(
              context: context,
              animation: const AlwaysStoppedAnimation(1),
              secondaryAnimation: const AlwaysStoppedAnimation(0),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(completed, isTrue);
    });
  });
} 