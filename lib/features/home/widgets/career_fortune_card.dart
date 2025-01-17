import 'package:flutter/material.dart';
import '../../../core/models/career_fortune.dart';

class CareerFortuneCard extends StatelessWidget {
  final CareerFortune fortune;

  const CareerFortuneCard({
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
                  Icons.work,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '今日事業運勢',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildScoreSection(context),
            const Divider(height: 32),
            _buildAdviceSection(context),
            if (fortune.bestWorkHours.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildWorkHoursSection(context),
            ],
            if (fortune.suitableActivities.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildActivitiesSection(context),
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
            label: '整體運勢',
            score: fortune.overallScore,
            description: '工作效率${fortune.overallScore}%',
          ),
        ),
        Expanded(
          child: _buildScoreIndicator(
            context,
            label: '溝通指數',
            score: fortune.communicationScore,
            description: '人際關係${fortune.communicationScore}%',
          ),
        ),
        Expanded(
          child: _buildScoreIndicator(
            context,
            label: '領導力',
            score: fortune.leadershipScore,
            description: '團隊協作${fortune.leadershipScore}%',
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
          '工作建議',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fortune.careerTips.map((tip) {
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

  Widget _buildWorkHoursSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最佳工作時段',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fortune.bestWorkHours.map((hour) {
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

  Widget _buildActivitiesSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '適合活動',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fortune.suitableActivities.map((activity) {
            return Chip(
              label: Text(activity),
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