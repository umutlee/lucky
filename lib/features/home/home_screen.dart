import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/fortune_config_provider.dart';
import '../../core/providers/fortune_provider.dart';
import 'widgets/fortune_card_list.dart';
import 'widgets/zodiac_fortune_card.dart';
import 'widgets/horoscope_fortune_card.dart';
import 'widgets/study_fortune_card.dart';
import 'widgets/career_fortune_card.dart';

/// 主頁面
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fortuneData = ref.watch(fortuneProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('吉時萬事通'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: fortuneData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('發生錯誤: $error'),
        ),
        data: (data) {
          final cards = {
            'zodiac': ZodiacFortuneCard(
              zodiac: data.zodiac,
              fortune: data.zodiacFortune,
            ),
            'horoscope': HoroscopeFortuneCard(
              horoscope: data.horoscope,
              fortune: data.horoscopeFortune,
            ),
            'study': StudyFortuneCard(
              fortune: data.studyFortune,
            ),
            'career': CareerFortuneCard(
              fortune: data.careerFortune,
            ),
          };

          return RefreshIndicator(
            onRefresh: () => ref.refresh(fortuneProvider.future),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  FortuneCardList(fortuneCards: cards),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 