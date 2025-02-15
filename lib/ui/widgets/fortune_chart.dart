import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/models/fortune_type.dart';

class FortuneChart extends StatelessWidget {
  final Map<String, double> factors;
  final int overallScore;
  final FortuneType type;

  const FortuneChart({
    super.key,
    required this.factors,
    required this.overallScore,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // 總分展示
        _buildOverallScore(theme),
        const SizedBox(height: 16),
        // 雷達圖
        _buildRadarChart(theme),
        const SizedBox(height: 16),
        // 因素分數列表
        _buildFactorsList(theme),
      ],
    );
  }

  Widget _buildOverallScore(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '整體運勢',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '$overallScore',
            style: theme.textTheme.displayMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _getScoreLevel(overallScore),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChart(ThemeData theme) {
    return SizedBox(
      height: 200,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.circle,
          tickCount: 5,
          ticksTextStyle: const TextStyle(color: Colors.transparent),
          gridBorderData: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
          dataSets: [
            RadarDataSet(
              fillColor: theme.colorScheme.primary.withOpacity(0.2),
              borderColor: theme.colorScheme.primary,
              entryRadius: 3,
              dataEntries: factors.entries.map((e) {
                return RadarEntry(value: e.value);
              }).toList(),
            ),
          ],
          getTitle: (index, angle) {
            return RadarChartTitle(
              text: factors.keys.elementAt(index),
              angle: angle,
            );
          },
          titleTextStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          tickBorderData: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
    );
  }

  Widget _buildFactorsList(ThemeData theme) {
    return Column(
      children: factors.entries.map((entry) {
        return ListTile(
          title: Text(entry.key),
          trailing: Text(
            '${(entry.value * 100).round()}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: LinearProgressIndicator(
            value: entry.value,
            backgroundColor: theme.colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getScoreLevel(int score) {
    return switch (score) {
      >= 90 => '大吉',
      >= 80 => '中吉',
      >= 70 => '小吉',
      >= 60 => '平',
      >= 50 => '凶',
      _ => '大凶',
    };
  }
} 