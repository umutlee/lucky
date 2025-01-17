import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/fortune_provider.dart';
import '../../../core/providers/fortune_config_provider.dart';
import '../widgets/fortune_card_list.dart';
import '../widgets/zodiac_fortune_card.dart';
import '../widgets/horoscope_fortune_card.dart';
import '../widgets/study_fortune_card.dart';
import '../widgets/career_fortune_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final fortuneData = ref.watch(fortuneProvider);
    final studyFortune = ref.watch(studyFortuneProvider(today));
    final careerFortune = ref.watch(careerFortuneProvider(today));
    final displayConfig = ref.watch(fortuneDisplayConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('吉時萬事通'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(fortuneProvider);
          ref.invalidate(studyFortuneProvider(today));
          ref.invalidate(careerFortuneProvider(today));
        },
        child: fortuneData.when(
          data: (data) {
            final cards = {
              if (displayConfig.isVisible('zodiac'))
                'zodiac': ZodiacFortuneCard(fortune: data['zodiac']),
              if (displayConfig.isVisible('horoscope'))
                'horoscope': HoroscopeFortuneCard(fortune: data['horoscope']),
              if (displayConfig.isVisible('study'))
                'study': studyFortune.when(
                  data: (fortune) => fortune != null 
                    ? StudyFortuneCard(fortune: fortune)
                    : const SizedBox.shrink(),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('無法載入學業運勢'),
                ),
              if (displayConfig.isVisible('career'))
                'career': careerFortune.when(
                  data: (fortune) => fortune != null
                    ? CareerFortuneCard(fortune: fortune)
                    : const SizedBox.shrink(),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('無法載入事業運勢'),
                ),
            };

            return FortuneCardList(
              displayConfig: displayConfig,
              fortuneCards: cards,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('載入失敗: $error'),
          ),
        ),
      ),
    );
  }
} 