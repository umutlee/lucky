import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/fortune.dart';
import '../../../../core/models/fortune_level.dart';
import '../../../../core/models/fortune_type.dart';
import '../../../../core/services/fortune_service.dart';

final dateProvider = Provider<DateTime>((ref) {
  return DateTime.now();
});

final selectedFortuneTypeProvider = StateProvider<FortuneType>((ref) {
  return FortuneType.daily;
});

final fortuneProvider = FutureProvider.family.autoDispose<Fortune, DateTime>((ref, date) {
  final fortuneService = ref.watch(fortuneServiceProvider);
  final fortuneType = ref.watch(selectedFortuneTypeProvider);
  
  switch (fortuneType) {
    case FortuneType.daily:
      return fortuneService.getDailyFortune(date);
    case FortuneType.study:
      return fortuneService.getStudyFortune(date);
    default:
      return fortuneService.getDailyFortune(date);
  }
});

class FortuneCard extends ConsumerWidget {
  final VoidCallback? onTap;

  const FortuneCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final date = ref.watch(dateProvider);
    final fortuneAsync = ref.watch(fortuneProvider(date));

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.8),
                theme.colorScheme.secondary.withOpacity(0.6),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: fortuneAsync.when(
              data: (fortune) => _buildContent(context, fortune, ref),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
              error: (error, stack) => _buildError(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Fortune fortune, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fortune.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '今日運勢評分',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            _buildScoreChip(theme, fortune.overallScore),
          ],
        ),
        const SizedBox(height: 20),
        _buildFortuneTypes(theme, fortune, ref),
        const SizedBox(height: 16),
        if (fortune.description.isNotEmpty) ...[
          Text(
            fortune.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...fortune.luckyElements.map((element) => Chip(
              label: Text(element),
              backgroundColor: Colors.white.withOpacity(0.2),
              labelStyle: TextStyle(
                color: Colors.white,
              ),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreChip(ThemeData theme, int score) {
    final level = FortuneLevel.fromScore(score);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$score',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '分',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            level.displayName,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneTypes(ThemeData theme, Fortune fortune, WidgetRef ref) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final type in FortuneType.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(type.displayName),
                selected: ref.watch(selectedFortuneTypeProvider) == type,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(selectedFortuneTypeProvider.notifier).state = type;
                  }
                },
                backgroundColor: Colors.white.withOpacity(0.2),
                selectedColor: Colors.white,
                labelStyle: TextStyle(
                  color: ref.watch(selectedFortuneTypeProvider) == type
                      ? theme.colorScheme.primary
                      : Colors.white,
                ),
                checkmarkColor: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            '載入失敗',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
} 