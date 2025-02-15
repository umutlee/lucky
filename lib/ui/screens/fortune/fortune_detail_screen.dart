import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/fortune_type.dart';
import '../../../core/services/fortune_score_service.dart';
import '../../widgets/fortune_chart.dart';
import '../../widgets/error_boundary.dart';
import '../../widgets/loading_indicator.dart';

class FortuneDetailScreen extends ConsumerWidget {
  final FortuneType type;
  final DateTime date;
  final String? zodiac;
  final String? targetZodiac;

  const FortuneDetailScreen({
    super.key,
    required this.type,
    required this.date,
    this.zodiac,
    this.targetZodiac,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fortuneScore = ref.watch(
      fortuneScoreProvider((
        type: type,
        date: date,
        zodiac: zodiac,
        targetZodiac: targetZodiac,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(type)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: 實現分享功能
            },
          ),
        ],
      ),
      body: ErrorBoundary(
        child: fortuneScore.when(
          data: (data) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 運勢圖表
                FortuneChart(
                  factors: data.factors,
                  overallScore: data.score,
                  type: type,
                ),
                const SizedBox(height: 24),
                
                // 運勢建議
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '運勢建議',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        ...data.suggestions.map((suggestion) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.tips_and_updates,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(suggestion),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 吉時提示
                if (_shouldShowLuckyHours(type)) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '吉時提示',
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          _buildLuckyHours(theme),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          loading: () => const LoadingIndicator(),
          error: (error, stack) => Center(
            child: Text(
              '載入失敗: $error',
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle(FortuneType type) {
    return switch (type) {
      FortuneType.study => '學業運勢',
      FortuneType.career => '事業運勢',
      FortuneType.love => '感情運勢',
      _ => '整體運勢',
    };
  }

  bool _shouldShowLuckyHours(FortuneType type) {
    return switch (type) {
      FortuneType.study || FortuneType.career => true,
      _ => false,
    };
  }

  Widget _buildLuckyHours(ThemeData theme) {
    final luckyHours = switch (type) {
      FortuneType.study => ['寅時 (3-5點)', '卯時 (5-7點)', '辰時 (7-9點)'],
      FortuneType.career => ['巳時 (9-11點)', '午時 (11-13點)', '未時 (13-15點)'],
      _ => <String>[],
    };

    return Column(
      children: luckyHours.map((hour) {
        return ListTile(
          leading: const Icon(Icons.schedule),
          title: Text(hour),
          dense: true,
        );
      }).toList(),
    );
  }
}

/// 運勢評分提供者
final fortuneScoreProvider = FutureProvider.family<({
  int score,
  Map<String, double> factors,
  List<String> suggestions,
}), ({
  FortuneType type,
  DateTime date,
  String? zodiac,
  String? targetZodiac,
})>((ref, params) async {
  final fortuneScoreService = ref.watch(fortuneScoreServiceProvider);
  return fortuneScoreService.calculateFortuneScore(
    type: params.type,
    date: params.date,
    zodiac: params.zodiac,
    targetZodiac: params.targetZodiac,
  );
}); 