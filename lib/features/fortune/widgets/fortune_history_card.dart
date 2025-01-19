import 'package:flutter/material.dart';
import '../../../core/models/fortune.dart';

class FortuneHistoryCard extends StatelessWidget {
  final Fortune fortune;

  const FortuneHistoryCard({
    Key? key,
    required this.fortune,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FortuneDetailScreen(
                date: _formatDate(fortune.date),
                zodiac: fortune.zodiac,
                constellation: fortune.constellation ?? '',
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(fortune.date),
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _buildScoreBadge(fortune.score),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(
                fortune.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.0,
                  height: 1.5,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12.0),
              _buildRecommendationPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBadge(int score) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: _getScoreColor(score).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        '$score分',
        style: TextStyle(
          color: _getScoreColor(score),
          fontWeight: FontWeight.bold,
          fontSize: 14.0,
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  Widget _buildRecommendationPreview() {
    if (fortune.recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Icon(
          Icons.lightbulb_outline,
          size: 16.0,
          color: Colors.amber.shade700,
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            fortune.recommendations.first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        if (fortune.recommendations.length > 1)
          Text(
            '+${fortune.recommendations.length - 1}',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey.shade500,
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }
} 