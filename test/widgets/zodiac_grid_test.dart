import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/ui/widgets/zodiac_grid.dart';
import 'package:all_lucky/ui/widgets/zodiac_display.dart';

void main() {
  group('ZodiacGrid Widget Tests', () {
    testWidgets('renders all 12 zodiac signs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ZodiacGrid(),
            ),
          ),
        ),
      );

      expect(find.byType(ZodiacDisplay), findsNWidgets(12));
    });

    testWidgets('handles tap on zodiac when interactive', (tester) async {
      String? tappedZodiac;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ZodiacGrid(
                isInteractive: true,
                onZodiacTap: (zodiac) => tappedZodiac = zodiac,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell).first);
      expect(tappedZodiac, '鼠');
    });

    testWidgets('shows descriptions when provided', (tester) async {
      final descriptions = {
        '龍': '龍年大吉',
        '虎': '虎虎生威',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ZodiacGrid(
                descriptions: descriptions,
              ),
            ),
          ),
        ),
      );

      expect(find.text('龍年大吉'), findsOneWidget);
      expect(find.text('虎虎生威'), findsOneWidget);
    });

    testWidgets('respects itemSize parameter', (tester) async {
      const itemSize = 80.0;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ZodiacGrid(
                itemSize: itemSize,
              ),
            ),
          ),
        ),
      );

      final firstZodiacDisplay = tester.widget<ZodiacDisplay>(
        find.byType(ZodiacDisplay).first,
      );
      expect(firstZodiacDisplay.size, itemSize);
    });
  });
} 