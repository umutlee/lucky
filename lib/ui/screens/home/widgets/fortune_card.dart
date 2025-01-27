import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/fortune_provider.dart';
import '../../../../core/models/fortune.dart';

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
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 運勢標題
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '今日運勢',
                    style: theme.textTheme.titleLarge,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getLevelColor(fortuneState.level, theme),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      fortuneState.level.toString(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 運勢描述
              Text(
                fortuneState.description,
                style: theme.textTheme.bodyLarge,
              ),
              
              const SizedBox(height: 16),
              
              // 幸運提示
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildLuckyItem(
                    context,
                    icon: Icons.color_lens,
                    label: '幸運色',
                    value: fortuneState.luckyColor,
                  ),
                  _buildLuckyItem(
                    context,
                    icon: Icons.format_list_numbered,
                    label: '幸運數字',
                    value: fortuneState.luckyNumber.toString(),
                  ),
                  _buildLuckyItem(
                    context,
                    icon: Icons.explore,
                    label: '幸運方位',
                    value: fortuneState.luckyDirection,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 運勢建議
              Text(
                '今日建議',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...fortuneState.recommendations.map((recommendation) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(recommendation),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
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