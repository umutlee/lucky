import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:all_lucky/ui/screens/home/widgets/bottom_nav.dart';

void main() {
  group('BottomNav 測試', () {
    testWidgets('應該正確顯示所有導航項目', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav(
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 驗證導航項目文字
      expect(find.text('首頁'), findsOneWidget);
      expect(find.text('場景'), findsOneWidget);
      expect(find.text('我的'), findsOneWidget);

      // 驗證導航項目圖標
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.explore_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('應該正確處理點擊事件', (tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav(
              currentIndex: 0,
              onTap: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 點擊場景標籤
      await tester.tap(find.text('場景'));
      await tester.pumpAndSettle();
      expect(tappedIndex, 1);

      // 點擊我的標籤
      await tester.tap(find.text('我的'));
      await tester.pumpAndSettle();
      expect(tappedIndex, 2);

      // 點擊首頁標籤
      await tester.tap(find.text('首頁'));
      await tester.pumpAndSettle();
      expect(tappedIndex, 0);
    });

    testWidgets('應該正確顯示選中狀態', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNav(
              currentIndex: 1,
              onTap: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 驗證選中項目的圖標
      expect(find.byIcon(Icons.explore), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('應該適應不同主題', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: Scaffold(
            bottomNavigationBar: BottomNav(
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 驗證導航欄存在
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });
} 