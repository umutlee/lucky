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
      elevation: 0,
      child: InkWell(
        onTap: onTap,
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: fortuneAsync.when(
              data: (fortune) => _buildContent(context, fortune, ref),
              loading: () => const Center(
                child: CircularProgressIndicator(),
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
    final selectedType = ref.watch(selectedFortuneTypeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              fortune.title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const Spacer(),
            _buildScoreChip(theme, fortune.overallScore),
          ],
        ),
        const SizedBox(height: 16),
        _buildFortuneTypes(theme, fortune, ref),
        const SizedBox(height: 16),
        if (selectedType == FortuneType.study) ...[
          Text(
            fortune.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...fortune.advice.map((advice) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              advice,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )).toList(),
        ] else ...[
          Text(
            fortune.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '點擊查看詳細運勢分析',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$score分',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            level.displayName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneTypes(ThemeData theme, Fortune fortune, WidgetRef ref) {
    final selectedType = ref.watch(selectedFortuneTypeProvider);
    final types = [
      (Icons.school, '學業運勢', fortune.scores['study'] ?? 0),
      (Icons.work, '事業運勢', fortune.scores['career'] ?? 0),
      (Icons.favorite, '感情運勢', fortune.scores['love'] ?? 0),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: types.map((type) {
        final isSelected = type.$2 == '學業運勢' && selectedType == FortuneType.study;
        return GestureDetector(
          onTap: () {
            if (type.$2 == '學業運勢') {
              ref.read(selectedFortuneTypeProvider.notifier).state = 
                selectedType == FortuneType.study ? FortuneType.daily : FortuneType.study;
            }
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  type.$1,
                  color: isSelected 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                type.$2,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${type.$3}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildError(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          color: theme.colorScheme.error,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          '無法加載運勢數據',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '請稍後重試',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        IconButton(
          onPressed: () {
            // TODO: 實現重試功能
          },
          icon: const Icon(Icons.refresh),
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }
} 