import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/fortune_provider.dart';
import '../../../../core/models/fortune.dart';
import '../../../../core/models/fortune_type.dart';

class FortuneCard extends ConsumerWidget {
  final VoidCallback? onTap;

  const FortuneCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fortuneState = ref.watch(dailyFortuneProvider);

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
            child: Column(
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
                      '今日運勢',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    _buildScoreChip(theme),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFortuneTypes(theme),
                const SizedBox(height: 16),
                Text(
                  '點擊查看詳細運勢分析',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreChip(ThemeData theme) {
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
            '88',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '分',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneTypes(ThemeData theme) {
    final types = [
      (FortuneType.study, Icons.school, '學業運勢'),
      (FortuneType.career, Icons.work, '事業運勢'),
      (FortuneType.love, Icons.favorite, '感情運勢'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: types.map((type) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
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
                type.$2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type.$3,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLuckyItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(FortuneLevel level, ThemeData theme) {
    switch (level) {
      case FortuneLevel.superLucky:
        return Colors.red;
      case FortuneLevel.lucky:
        return Colors.orange;
      case FortuneLevel.smallLucky:
        return Colors.yellow[700]!;
      case FortuneLevel.normal:
        return Colors.blue;
      case FortuneLevel.unlucky:
        return Colors.grey;
    }
  }
} 