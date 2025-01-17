import 'package:flutter/material.dart';
import '../../../core/models/study_fortune.dart';

class StudyFortuneCard extends StatelessWidget {
  final StudyFortune fortune;

  const StudyFortuneCard({
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
                  Icons.school,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '今日學業運勢',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildScoreSection(context),
            const Divider(height: 32),
            _buildAdviceSection(context),
            if (fortune.bestStudyHours.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildStudyHoursSection(context),
            ],
            if (fortune.suitableSubjects.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSubjectsSection(context),
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
            description: '學習效率${fortune.overallScore}%',
          ),
        ),
        Expanded(
          child: _buildScoreIndicator(
            context,
            label: '記憶力',
            score: fortune.memoryScore,
            description: '記憶效果${fortune.memoryScore}%',
          ),
        ),
        Expanded(
          child: _buildScoreIndicator(
            context,
            label: '考試運',
            score: fortune.examScore,
            description: '考試表現${fortune.examScore}%',
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
          '學習建議',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fortune.studyTips.map((tip) {
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

  Widget _buildStudyHoursSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最佳學習時段',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fortune.bestStudyHours.map((hour) {
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

  Widget _buildSubjectsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '適合科目',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: fortune.suitableSubjects.map((subject) {
            return Chip(
              label: Text(subject),
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