import 'package:flutter/material.dart';
import '../../../core/models/study_fortune.dart';
import '../../../core/models/career_fortune.dart';
import '../../../core/models/love_fortune.dart';
import '../../../shared/utils/date_converter.dart';

class FortunePreview extends StatelessWidget {
  final DateTime date;
  final StudyFortune? studyFortune;
  final CareerFortune? careerFortune;
  final LoveFortune? loveFortune;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;

  const FortunePreview({
    super.key,
    required this.date,
    this.studyFortune,
    this.careerFortune,
    this.loveFortune,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在計算運勢...'),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              '運勢計算失敗',
              style: theme.textTheme.titleMedium,
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateConverter.formatSolarDate(date),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (studyFortune != null) ...[
              _buildFortuneItem(
                context,
                '學業運勢',
                studyFortune!.overallScore,
                studyFortune!.description,
              ),
              const SizedBox(height: 8),
            ],
            if (careerFortune != null) ...[
              _buildFortuneItem(
                context,
                '事業運勢',
                careerFortune!.overallScore,
                careerFortune!.description,
              ),
              const SizedBox(height: 8),
            ],
            if (loveFortune != null) ...[
              _buildFortuneItem(
                context,
                '愛情運勢',
                loveFortune!.overallScore,
                loveFortune!.description,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFortuneItem(
    BuildContext context,
    String title,
    int score,
    String description,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Text(
              '$score分',
              style: theme.textTheme.titleMedium?.copyWith(
                color: _getScoreColor(context, score),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: theme.textTheme.bodyMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getScoreColor(BuildContext context, int score) {
    final theme = Theme.of(context);
    
    if (score >= 90) return theme.colorScheme.primary;
    if (score >= 80) return theme.colorScheme.secondary;
    if (score >= 70) return theme.colorScheme.tertiary;
    if (score >= 60) return theme.colorScheme.outline;
    return theme.colorScheme.error;
  }
}