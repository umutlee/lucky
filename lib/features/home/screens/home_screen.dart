import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/fortune_provider.dart';
import '../../../core/providers/fortune_config_provider.dart';
import '../widgets/fortune_card_list.dart';
import '../widgets/study_fortune_card.dart';
import '../widgets/career_fortune_card.dart';
import '../widgets/love_fortune_card.dart';
import '../widgets/fortune_loading_card.dart';
import '../widgets/fortune_error_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
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
          ref.invalidate(studyFortuneProvider(today));
          ref.invalidate(careerFortuneProvider(today));
          ref.invalidate(loveFortuneProvider(today));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: [
                if (displayConfig.isVisible('study'))
                  Consumer(
                    builder: (context, ref, _) {
                      final studyFortune = ref.watch(studyFortuneProvider(today));
                      return studyFortune.when(
                        data: (fortune) => StudyFortuneCard(fortune: fortune),
                        loading: () => const FortuneLoadingCard(),
                        error: (error, _) => FortuneErrorCard(
                          message: error.toString(),
                        ),
                      );
                    },
                  ),
                if (displayConfig.isVisible('career'))
                  Consumer(
                    builder: (context, ref, _) {
                      final careerFortune = ref.watch(careerFortuneProvider(today));
                      return careerFortune.when(
                        data: (fortune) => CareerFortuneCard(fortune: fortune),
                        loading: () => const FortuneLoadingCard(),
                        error: (error, _) => FortuneErrorCard(
                          message: error.toString(),
                        ),
                      );
                    },
                  ),
                if (displayConfig.isVisible('love'))
                  Consumer(
                    builder: (context, ref, _) {
                      final loveFortune = ref.watch(loveFortuneProvider(today));
                      return loveFortune.when(
                        data: (fortune) => LoveFortuneCard(fortune: fortune),
                        loading: () => const FortuneLoadingCard(),
                        error: (error, _) => FortuneErrorCard(
                          message: error.toString(),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 