import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/almanac_provider.dart';
import '../../core/providers/fortune_provider.dart';
import 'widgets/fortune_card.dart';
import 'widgets/lunar_info_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final lunarDate = ref.watch(currentLunarDateProvider);
    final fortune = ref.watch(dailyFortuneProvider(today));

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日運勢'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentLunarDateProvider);
          ref.invalidate(dailyFortuneProvider(today));
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            lunarDate.when(
              data: (data) => LunarInfoCard(lunarDate: data),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('載入農曆資訊失敗: $error'),
                ),
              ),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            fortune.when(
              data: (data) => FortuneCard(fortune: data),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('載入運勢資訊失敗: $error'),
                ),
              ),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 