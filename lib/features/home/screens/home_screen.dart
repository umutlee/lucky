import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/fortune_config_provider.dart';
import '../../../core/providers/fortune_provider.dart';
import '../widgets/fortune_card_list.dart';
import '../widgets/zodiac_fortune_card.dart';
import '../widgets/horoscope_fortune_card.dart';
import '../widgets/study_fortune_card.dart';
import '../widgets/career_fortune_card.dart';

/// 主頁面
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayConfig = ref.watch(fortuneDisplayConfigProvider);
    final expandedTypes = ref.watch(expandedFortuneTypesProvider);
    final fortuneData = ref.watch(dailyFortuneProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日運勢'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 導航到設置頁面
            },
          ),
        ],
      ),
      body: fortuneData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('載入失敗：$error'),
        ),
        data: (fortune) {
          final cards = {
            'zodiac': FortuneCardWrapper(
              child: ZodiacFortuneCard(
                zodiac: fortune.zodiac,
                fortune: fortune.zodiacFortune,
                score: fortune.zodiacScore,
                luckyDirections: fortune.luckyDirections,
                luckyColors: fortune.luckyColors,
                luckyNumbers: fortune.luckyNumbers,
              ),
              isExpanded: expandedTypes.contains('zodiac'),
              onTap: () => _toggleExpanded(ref, 'zodiac'),
            ),
            'horoscope': FortuneCardWrapper(
              child: HoroscopeFortuneCard(
                horoscope: fortune.horoscope,
                fortune: fortune.horoscopeFortune,
                score: fortune.horoscopeScore,
                aspectScores: fortune.aspectScores,
                luckyItems: fortune.luckyItems,
                compatibleSigns: fortune.compatibleSigns,
              ),
              isExpanded: expandedTypes.contains('horoscope'),
              onTap: () => _toggleExpanded(ref, 'horoscope'),
            ),
            'study': FortuneCardWrapper(
              child: StudyFortuneCard(
                fortune: fortune.studyFortune,
                onTap: () => _toggleExpanded(ref, 'study'),
              ),
              isExpanded: expandedTypes.contains('study'),
              onTap: () => _toggleExpanded(ref, 'study'),
            ),
            'career': FortuneCardWrapper(
              child: CareerFortuneCard(
                fortune: fortune.careerFortune,
                onTap: () => _toggleExpanded(ref, 'career'),
              ),
              isExpanded: expandedTypes.contains('career'),
              onTap: () => _toggleExpanded(ref, 'career'),
            ),
          };

          return FortuneCardList(
            displayConfig: displayConfig,
            fortuneCards: cards,
          );
        },
      ),
    );
  }

  void _toggleExpanded(WidgetRef ref, String type) {
    ref.read(expandedFortuneTypesProvider.notifier).toggle(type);
  }
} 