import 'package:flutter/material.dart';
import '../../../core/models/career_fortune.dart';

/// 事業運勢卡片
class CareerFortuneCard extends StatelessWidget {
  final CareerFortune fortune;
  final VoidCallback? onTap;

  const CareerFortuneCard({
    super.key,
    required this.fortune,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScores(),
                  const SizedBox(height: 16),
                  _buildAdvice(),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildWorkHours(),
                  const SizedBox(height: 8),
                  _buildActivities(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor,
          ],
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.work,
              color: Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '今日事業運勢',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '整體評分：${(fortune.overallScore * 100).toStringAsFixed(0)}分',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScores() {
    return Column(
      children: [
        _buildScoreItem('溝通力', fortune.communicationScore),
        const SizedBox(height: 8),
        _buildScoreItem('領導力', fortune.leadershipScore),
        const SizedBox(height: 8),
        _buildScoreItem('創新力', fortune.innovationScore),
      ],
    );
  }

  Widget _buildScoreItem(String label, double score) {
    final color = _getScoreColor(score);
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(score * 100).toStringAsFixed(0)}%',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.blue;
    if (score >= 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildAdvice() {
    return Text(
      fortune.advice,
      style: const TextStyle(
        fontSize: 16,
        height: 1.6,
      ),
    );
  }

  Widget _buildWorkHours() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 80,
          child: Text(
            '黃金時段',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: fortune.bestWorkHours.map((hour) => Text(hour)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActivities() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 80,
          child: Text(
            '建議活動',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: fortune.suitableActivities.map((activity) => Chip(
              label: Text(activity),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              side: BorderSide(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
} 