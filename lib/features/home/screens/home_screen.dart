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
import '../widgets/fortune_skeleton_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    // 預加載運勢數據
    Future.microtask(() {
      final today = DateTime.now();
      ref.read(studyFortuneProvider(today));
      ref.read(careerFortuneProvider(today));
      ref.read(loveFortuneProvider(today));
    });
  }

  @override
  Widget build(BuildContext context) {
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
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (displayConfig.isVisible('study'))
                    Consumer(
                      builder: (context, ref, _) {
                        final studyFortune = ref.watch(studyFortuneProvider(today));
                        return studyFortune.when(
                          data: (fortune) {
                            _isFirstLoad = false;
                            return StudyFortuneCard(fortune: fortune);
                          },
                          loading: () => _isFirstLoad 
                            ? const FortuneSkeleton(type: '學業運勢')
                            : const FortuneLoadingCard(),
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
                          data: (fortune) {
                            _isFirstLoad = false;
                            return CareerFortuneCard(fortune: fortune);
                          },
                          loading: () => _isFirstLoad 
                            ? const FortuneSkeleton(type: '事業運勢')
                            : const FortuneLoadingCard(),
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
                          data: (fortune) {
                            _isFirstLoad = false;
                            return LoveFortuneCard(fortune: fortune);
                          },
                          loading: () => _isFirstLoad 
                            ? const FortuneSkeleton(type: '愛情運勢')
                            : const FortuneLoadingCard(),
                          error: (error, _) => FortuneErrorCard(
                            message: error.toString(),
                          ),
                        );
                      },
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 