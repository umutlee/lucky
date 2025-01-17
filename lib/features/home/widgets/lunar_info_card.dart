import 'package:flutter/material.dart';
import '../../../core/models/lunar_date.dart';

class LunarInfoCard extends StatelessWidget {
  final LunarDate lunarDate;

  const LunarInfoCard({
    super.key,
    required this.lunarDate,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '農曆日期',
                  style: theme.textTheme.titleLarge,
                ),
                if (lunarDate.solarTerm != null)
                  Chip(
                    label: Text(lunarDate.solarTerm!),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${lunarDate.year}年 ${lunarDate.month}月 ${lunarDate.day}日',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${lunarDate.heavenlyStem}${lunarDate.earthlyBranch}年 ${lunarDate.zodiac}',
              style: theme.textTheme.titleMedium,
            ),
            if (lunarDate.festival != null) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(lunarDate.festival!),
                backgroundColor: theme.colorScheme.tertiaryContainer,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 