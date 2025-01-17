import 'package:flutter/material.dart';
import '../../../core/models/daily_fortune.dart';
import '../../../shared/utils/date_converter.dart';

class FortunePreview extends StatelessWidget {
  final DateTime date;
  final DailyFortune? fortune;

  const FortunePreview({
    super.key,
    required this.date,
    this.fortune,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (fortune == null) {
      return const Center(
        child: Text('無運勢資料'),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  DateConverter.formatSolarDate(date),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(width: 8),
                Text(
                  DateConverter.getWeekday(date),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                _buildSection(
                  context,
                  title: '宜',
                  items: fortune!.goodFor.take(3).toList(),
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  title: '忌',
                  items: fortune!.badFor.take(3).toList(),
                  color: Colors.red,
                ),
                if (fortune!.luckyDirection != null ||
                    fortune!.wealthDirection != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (fortune!.luckyDirection != null)
                        Expanded(
                          child: _buildDirection(
                            context,
                            label: '吉位',
                            value: fortune!.luckyDirection!,
                          ),
                        ),
                      if (fortune!.wealthDirection != null) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDirection(
                            context,
                            label: '財位',
                            value: fortune!.wealthDirection!,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<String> items,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return Chip(
              label: Text(item),
              backgroundColor: color.withOpacity(0.1),
              side: BorderSide(color: color.withOpacity(0.2)),
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDirection(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
} 