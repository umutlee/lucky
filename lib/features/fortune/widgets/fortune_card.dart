import 'package:flutter/material.dart';
import '../../../core/models/fortune.dart';

class FortuneCard extends StatelessWidget {
  final Fortune fortune;

  const FortuneCard({
    Key? key,
    required this.fortune,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${fortune.type}運勢',
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildScoreIndicator(fortune.score),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(
              fortune.description,
              style: const TextStyle(
                fontSize: 16.0,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildFortuneDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(int score) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 6.0,
      ),
      decoration: BoxDecoration(
        color: _getScoreColor(score),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getScoreIcon(score),
            size: 18.0,
            color: Colors.white,
          ),
          const SizedBox(width: 4.0),
          Text(
            '$score分',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(int score) {
    if (score >= 80) return Icons.star;
    if (score >= 60) return Icons.thumb_up;
    if (score >= 40) return Icons.thumbs_up_down;
    return Icons.thumb_down;
  }

  Widget _buildFortuneDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem(
          icon: Icons.calendar_today,
          label: '日期',
          value: _formatDate(fortune.date),
        ),
        const SizedBox(height: 8.0),
        _buildDetailItem(
          icon: Icons.pets,
          label: '生肖',
          value: fortune.zodiac,
        ),
        if (fortune.zodiacAffinity.isNotEmpty) ...[
          const SizedBox(height: 8.0),
          _buildDetailItem(
            icon: Icons.favorite,
            label: '最佳相配',
            value: _getBestAffinity(),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.0,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8.0),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14.0,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  String _getBestAffinity() {
    if (fortune.zodiacAffinity.isEmpty) return '無';
    
    final bestMatch = fortune.zodiacAffinity.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    return '${bestMatch.key} (${bestMatch.value}%)';
  }
} 