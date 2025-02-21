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
                  title: const Text('運勢預測'),
                  actions: [
                    IconButton(
                      icon: Icon(
                        isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      ),
                      onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
                    ),
                  ],
                ),
                
                // 今日運勢概覽
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '今日運勢',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.primary.withOpacity(0.8),
                                  theme.colorScheme.secondary.withOpacity(0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '選擇場景',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '選擇一個場景來獲取詳細運勢分析',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SceneSelectionScreen(),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    minimumSize: const Size(double.infinity, 50),
                                  ),
                                  child: const Text('開始分析'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 萬年曆視圖
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '萬年曆',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        CalendarView(),
                      ],
                    ),
                  ),
                ),

                // 生肖運勢
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '生肖運勢',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        ZodiacSection(),
                      ],
                    ),
                  ),
                ),

                // 星座運勢
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '星座運勢',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        HoroscopeSection(),
                      ],
                    ),
                  ),
                ),

                // 指南針
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '方位指南',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        CompassSection(),
                      ],
                    ),
                  ),
                ),

                // 底部間距
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
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