import 'package:flutter/material.dart';
import '../../../core/models/daily_fortune.dart';

class FortuneCard extends StatelessWidget {
  final DailyFortune fortune;

  const FortuneCard({
    super.key,
    required this.fortune,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日運勢',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: '宜',
              items: fortune.goodFor,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              title: '忌',
              items: fortune.badFor,
              color: Colors.red,
            ),
            if (fortune.luckyDirection != null ||
                fortune.wealthDirection != null) ...[
              const SizedBox(height: 16),
              _buildDirections(context),
            ],
            if (fortune.luckyHours.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildLuckyHours(context),
            ],
            if (fortune.conflictZodiac != null) ...[
              const SizedBox(height: 16),
              _buildConflictZodiac(context),
            ],
          ],
        ),
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
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium,
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
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDirections(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        if (fortune.luckyDirection != null)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '吉位',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  fortune.luckyDirection!,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        if (fortune.wealthDirection != null)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '財位',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  fortune.wealthDirection!,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLuckyHours(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '吉時',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fortune.luckyHours.map((hour) {
            return Chip(
              label: Text(hour),
              backgroundColor: theme.colorScheme.secondaryContainer,
              labelStyle: TextStyle(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConflictZodiac(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '沖煞',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        Text(
          fortune.conflictZodiac!,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ],
    );
  }
} 