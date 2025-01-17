import 'package:flutter/material.dart';
import '../../../core/models/daily_fortune.dart';
import '../../../core/models/study_fortune.dart';
import '../../../core/models/career_fortune.dart';
import '../../../shared/utils/date_converter.dart';

class FortunePreview extends StatelessWidget {
  final DateTime date;
  final DailyFortune? dailyFortune;
  final StudyFortune? studyFortune;
  final CareerFortune? careerFortune;

  const FortunePreview({
    super.key,
    required this.date,
    this.dailyFortune,
    this.studyFortune,
    this.careerFortune,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateConverter.formatDate(date);
    final weekday = DateConverter.getWeekday(date);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$dateStr ($weekday)',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (dailyFortune != null) ...[
              _buildSection('宜', dailyFortune!.goodFor, Colors.green),
              _buildSection('忌', dailyFortune!.badFor, Colors.red),
              if (dailyFortune!.luckyDirection != null || dailyFortune!.wealthDirection != null)
                _buildDirections(
                  dailyFortune!.luckyDirection,
                  dailyFortune!.wealthDirection,
                ),
            ],
            if (studyFortune != null) ...[
              const Divider(),
              Text('學業運勢', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildStudyPreview(studyFortune!),
            ],
            if (careerFortune != null) ...[
              const Divider(),
              Text('事業運勢', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildCareerPreview(careerFortune!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          children: items
              .map((item) => Chip(
                    label: Text(item),
                    backgroundColor: color.withOpacity(0.1),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDirections(String? lucky, String? wealth) {
    return Wrap(
      spacing: 16,
      children: [
        if (lucky != null)
          Text('🎯 吉位：$lucky'),
        if (wealth != null)
          Text('💰 財位：$wealth'),
      ],
    );
  }

  Widget _buildStudyPreview(StudyFortune fortune) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('整體評分：${fortune.overallScore}分'),
        Text('最佳時段：${fortune.bestStudyHours.join("、")}'),
        if (fortune.suitableSubjects.isNotEmpty)
          Text('適合科目：${fortune.suitableSubjects.join("、")}'),
      ],
    );
  }

  Widget _buildCareerPreview(CareerFortune fortune) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('整體評分：${fortune.overallScore}分'),
        Text('最佳時段：${fortune.bestWorkHours.join("、")}'),
        if (fortune.suitableActivities.isNotEmpty)
          Text('適合活動：${fortune.suitableActivities.join("、")}'),
      ],
    );
  }
}