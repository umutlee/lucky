import 'package:flutter/material.dart';
import '../../../core/models/fortune.dart';

class FortuneList extends StatelessWidget {
  final List<Fortune> fortunes;

  const FortuneList({
    super.key,
    required this.fortunes,
  });

  @override
  Widget build(BuildContext context) {
    if (fortunes.isEmpty) {
      return const Center(
        child: Text('沒有符合條件的運勢數據'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: fortunes.length,
      itemBuilder: (context, index) {
        final fortune = fortunes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getFortuneTypeLabel(fortune.type),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${fortune.score}分',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(fortune.score),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('日期：${_formatDate(fortune.date)}'),
                if (fortune.isLuckyDay) ...[
                  const SizedBox(height: 4),
                  const Text(
                    '吉日',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text('適合活動：${fortune.suitableActivities.join('、')}'),
                const SizedBox(height: 4),
                Text('吉利方位：${fortune.luckyDirections.join('、')}'),
                if (fortune.description != null) ...[
                  const SizedBox(height: 8),
                  Text('詳細說明：${fortune.description}'),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _getFortuneTypeLabel(FortuneType type) {
    switch (type) {
      case FortuneType.overall:
        return '總運';
      case FortuneType.study:
        return '學業運';
      case FortuneType.career:
        return '事業運';
      case FortuneType.love:
        return '愛情運';
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) {
      return Colors.red;
    } else if (score >= 60) {
      return Colors.orange;
    } else if (score >= 40) {
      return Colors.blue;
    } else {
      return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
} 