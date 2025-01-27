import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/error_boundary.dart';
import 'widgets/calendar_view.dart';
import 'widgets/fortune_card.dart';
import 'widgets/zodiac_section.dart';
import 'widgets/horoscope_section.dart';
import 'widgets/compass_section.dart';
import 'widgets/bottom_nav.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: ErrorBoundary(
        child: CustomScrollView(
          slivers: [
            // 頂部應用欄
            SliverAppBar(
              floating: true,
              title: const Text('今日運勢'),
              actions: [
                IconButton(
                  icon: Icon(
                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  ),
                  onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
                ),
              ],
            ),
            
            // 萬年曆視圖
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CalendarView(),
              ),
            ),

            // 運勢卡片
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: FortuneCard(
                  onTap: () {
                    // TODO: 導航到運勢詳情頁
                  },
                ),
              ),
            ),

            // 生肖區塊
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: ErrorBoundary(
                  child: ZodiacSection(),
                ),
              ),
            ),

            // 星座區塊
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: ErrorBoundary(
                  child: HoroscopeSection(),
                ),
              ),
            ),

            // 指南針區塊
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: ErrorBoundary(
                  child: CompassSection(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
} 