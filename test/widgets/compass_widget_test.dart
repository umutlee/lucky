import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:all_lucky/core/models/compass_direction.dart';
import 'package:all_lucky/core/services/compass_service.dart';
import 'package:all_lucky/ui/widgets/compass_widget.dart';

void main() {
  group('CompassWidget', () {
    testWidgets('顯示加載狀態', (tester) async {
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

    testWidgets('顯示錯誤狀態', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            compassProvider.overrideWith(
              (ref) => Stream.error('測試錯誤'),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CompassWidget(),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('無法獲取指南針數據'), findsOneWidget);
    });

    testWidgets('顯示方位信息', (tester) async {
      final direction = CompassDirection(name: '北', angle: 0.0);
      final streamController = StreamController<CompassDirection>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            compassProvider.overrideWith(
              (ref) => streamController.stream,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CompassWidget(),
            ),
          ),
        ),
      );

      streamController.add(direction);
      await tester.pump();

      expect(find.text('北'), findsOneWidget);
      streamController.close();
    });
  });
} 