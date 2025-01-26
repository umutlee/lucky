import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/core/models/zodiac.dart';
import 'package:all_lucky/ui/widgets/zodiac_display.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // 設置資源綁定
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (message) async => Uint8List(0),
    );
  });

  group('ZodiacDisplay', () {
    testWidgets('正確顯示生肖圖', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZodiacDisplay(
              zodiac: Zodiac.dragon,
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('點擊時觸發回調', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZodiacDisplay(
              zodiac: Zodiac.dragon,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isTrue);
    });

    testWidgets('使用自定義大小', (tester) async {
      const size = 200.0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ZodiacDisplay(
              zodiac: Zodiac.dragon,
              size: size,
            ),
          ),
        ),
      );

      final image = find.byType(Image).evaluate().first.widget as Image;
      expect(image.width, equals(size));
      expect(image.height, equals(size));
    });
  });
} 