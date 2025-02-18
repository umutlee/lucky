import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/error_boundary.dart';
import 'widgets/calendar_view.dart';
import 'widgets/fortune_card.dart';
import 'widgets/zodiac_section.dart';
import 'widgets/horoscope_section.dart';
import 'widgets/compass_section.dart';
import 'widgets/bottom_nav.dart';
import '../scene/scene_selection_screen.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/fortune_provider.dart';
import '../../../core/providers/zodiac_provider.dart';
import '../../../core/providers/horoscope_provider.dart';
import '../../../core/providers/calendar_provider.dart';
import '../../../core/providers/compass_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    ref.read(fortuneProvider.notifier).loadDailyFortune();
    ref.read(zodiacProvider.notifier).loadZodiacFortune();
    ref.read(horoscopeProvider.notifier).loadHoroscopeFortune();
    ref.read(calendarProvider.notifier).loadCalendarData();
    ref.read(compassProvider.notifier).startTracking();
  }

  @override
  void dispose() {
    ref.read(compassProvider.notifier).stopTracking();
    super.dispose();
  }

  void _onFortuneCardTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SceneSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: ErrorBoundary(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // 首頁內容
            CustomScrollView(
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
                      onTap: _onFortuneCardTap,
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
            
            // 場景選擇頁面
            const SceneSelectionScreen(),
            
            // 我的頁面
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '我的頁面開發中...',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Icon(
                    Icons.construction,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
} 