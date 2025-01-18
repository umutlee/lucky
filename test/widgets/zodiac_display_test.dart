import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/ui/widgets/zodiac_display.dart';

void main() {
  group('ZodiacDisplay Widget Tests', () {
    testWidgets('renders correctly with basic properties', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZodiacDisplay(
              zodiac: '龍',
              size: 100,
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(ClipOval), findsOneWidget);
    });

    testWidgets('shows description when provided', (tester) async {
      const description = '這是龍年';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZodiacDisplay(
              zodiac: '龍',
              description: description,
            ),
          ),
        ),
      );

      expect(find.text(description), findsOneWidget);
    });

    testWidgets('handles tap when interactive', (tester) async {
      bool wasTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZodiacDisplay(
              zodiac: '龍',
              isInteractive: true,
              onTap: () => wasTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(wasTapped, true);
    });

    testWidgets('does not show InkWell when not interactive', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZodiacDisplay(
              zodiac: '龍',
              isInteractive: false,
            ),
          ),
        ),
      );

      expect(find.byType(InkWell), findsNothing);
    });
  });
} 