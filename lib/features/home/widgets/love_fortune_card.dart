import 'package:flutter/material.dart';
import '../../../core/models/love_fortune.dart';

class LoveFortuneCard extends StatelessWidget {
  final LoveFortune fortune;

  const LoveFortuneCard({
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
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '今日愛情運勢',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildScoreSection(context),
            const Divider(height: 32),
            _buildAdviceSection(context),
            if (fortune.bestDateHours.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDateHoursSection(context),
            ],
            if (fortune.compatibleZodiacs.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildCompatibleZodiacsSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSection(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildScoreIndicator(
            context,
            label: '桃花指數',
            score: fortune.romanceScore,
            description: fortune.romanceLevel,
          ),
        ),
        Expanded(
          child: _buildScoreIndicator(
            context,
            label: '告白指數',
            score: fortune.confessionScore,
            description: fortune.confessionAdvice,
          ),
        ),
        Expanded(
          child: _buildScoreIndicator(
            context,
            label: '約會指數',
            score: fortune.dateScore,
            description: '約會運勢${fortune.dateScore}%',
          ),
        ),
      ],
    );
  }

  Widget _buildScoreIndicator(
    BuildContext context, {
    required String label,
    required int score,
    required String description,
  }) {
    final theme = Theme.of(context);
    final color = _getScoreColor(score);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: score / 100,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            Text(
              '$score',
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAdviceSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日建議',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fortune.loveTips.map((tip) {
            return Chip(
              label: Text(tip),
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

  Widget _buildDateHoursSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最佳約會時段',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fortune.bestDateHours.map((hour) {
            return Chip(
              label: Text(hour),
              backgroundColor: theme.colorScheme.tertiaryContainer,
              labelStyle: TextStyle(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCompatibleZodiacsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日速配星座',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fortune.compatibleZodiacs.map((zodiac) {
            return Chip(
              label: Text(zodiac),
              backgroundColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.red;
    if (score >= 80) return Colors.orange;
    if (score >= 70) return Colors.green;
    if (score >= 60) return Colors.blue;
    return Colors.grey;
  }
} 