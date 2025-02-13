import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/scene.dart';
import '../../../core/services/fortune_score_service.dart';
import '../../widgets/fortune_chart.dart';
import '../../widgets/error_boundary.dart';
import '../../widgets/loading_indicator.dart';

class SceneDetailScreen extends ConsumerWidget {
  final Scene scene;

  const SceneDetailScreen({
    super.key,
    required this.scene,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fortuneScore = ref.watch(
      fortuneScoreProvider(
        type: scene.fortuneType,
        date: DateTime.now(),
      ),
    );

    return Scaffold(
      body: ErrorBoundary(
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, theme),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDescription(theme),
                    const SizedBox(height: 24),
                    fortuneScore.when(
                      data: (data) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FortuneChart(
                            factors: data.factors,
                            overallScore: data.score,
                            type: scene.fortuneType,
                          ),
                          const SizedBox(height: 24),
                          _buildSuggestions(theme, data.suggestions),
                          const SizedBox(height: 24),
                          _buildLuckyTimes(theme),
                        ],
                      ),
                      loading: () => const LoadingIndicator(),
                      error: (error, stack) => Center(
                        child: Text(
                          '載入失敗: $error',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: 實現分享功能
        },
        icon: const Icon(Icons.share),
        label: const Text('分享運勢'),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar.large(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Hero(
          tag: 'scene_${scene.id}_title',
          child: Text(
            scene.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        background: Hero(
          tag: 'scene_${scene.id}',
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primary.withOpacity(0.1),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 24,
                  bottom: 24,
                  child: Icon(
                    scene.icon,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '場景說明',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              scene.description,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(ThemeData theme, List<String> suggestions) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '運勢建議',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...suggestions.map((suggestion) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(suggestion),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildLuckyTimes(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '吉時提示',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                '寅時 (3-5點)',
                '卯時 (5-7點)',
                '辰時 (7-9點)',
              ].map((time) => Chip(
                label: Text(time),
                avatar: const Icon(Icons.star, size: 16),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
} 