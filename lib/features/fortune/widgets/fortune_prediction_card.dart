import 'package:flutter/material.dart';
import '../../../core/models/fortune.dart';

class FortunePredictionCard extends StatelessWidget {
  final Fortune fortune;

  const FortunePredictionCard({
    super.key,
    required this.fortune,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 運勢評分
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    '運勢指數',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildScoreIndicator(context, fortune.score),
                  const SizedBox(height: 16),
                  Text(
                    _getScoreDescription(fortune.score),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 運勢描述
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '運勢解析',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    fortune.description,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 建議事項
          if (fortune.recommendations.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今日建議',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ...fortune.recommendations.map((recommendation) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                recommendation,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            
          const SizedBox(height: 16),
          
          // 相配生肖
          if (fortune.zodiacAffinity.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '相配生肖',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildZodiacAffinityChart(context),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreIndicator(BuildContext context, double score) {
    final theme = Theme.of(context);
    final color = _getScoreColor(score);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 120,
          width: 120,
          child: CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 12,
            backgroundColor: theme.colorScheme.surfaceVariant,
            color: color,
          ),
        ),
        Text(
          score.round().toString(),
          style: theme.textTheme.headlineLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildZodiacAffinityChart(BuildContext context) {
    final theme = Theme.of(context);
    final sortedAffinity = fortune.zodiacAffinity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedAffinity.take(3).map((entry) {
        final percentage = entry.value.toDouble();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: theme.colorScheme.surfaceVariant,
                color: _getScoreColor(percentage),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Text(
                '$percentage%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) {
      return Colors.green;
    } else if (score >= 60) {
      return Colors.blue;
    } else if (score >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getScoreDescription(double score) {
    if (score >= 80) {
      return '大吉';
    } else if (score >= 60) {
      return '吉';
    } else if (score >= 40) {
      return '平';
    } else {
      return '凶';
    }
  }
} 