import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/models/zodiac.dart';
import 'package:all_lucky/ui/widgets/zodiac_grid.dart';

void main() {
  group('ZodiacGrid', () {
    testWidgets('顯示所有生肖圖標', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZodiacGrid(
              onZodiacSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(ZodiacDisplay), findsNWidgets(12));
    });

    testWidgets('點擊生肖時觸發回調', (tester) async {
      Zodiac? selectedZodiac;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZodiacGrid(
              onZodiacSelected: (zodiac) => selectedZodiac = zodiac,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ZodiacDisplay).first);
      expect(selectedZodiac, isNotNull);
    });

    testWidgets('使用自定義圖標大小', (tester) async {
      const iconSize = 80.0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZodiacGrid(
              onZodiacSelected: (_) {},
              iconSize: iconSize,
            ),
          ),
        ),
      );

      final zodiacDisplay = tester.widget<ZodiacDisplay>(find.byType(ZodiacDisplay).first);
      expect(zodiacDisplay.size, iconSize);
    });
  });
} 