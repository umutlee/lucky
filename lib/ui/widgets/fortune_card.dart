import 'package:flutter/material.dart';
import 'package:all_lucky/core/models/fortune.dart';

class FortuneCard extends StatelessWidget {
  final Fortune fortune;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final bool isEnlarged;

  const FortuneCard({
    Key? key,
    required this.fortune,
    this.onTap,
    this.onDoubleTap,
    this.isEnlarged = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      child: Card(
        key: isEnlarged ? const Key('enlarged_fortune_card') : null,
        elevation: isEnlarged ? 8.0 : 4.0,
        margin: EdgeInsets.all(isEnlarged ? 16.0 : 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fortune.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8.0),
              Text(
                fortune.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${fortune.overallScore}分',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    fortune.luckLevel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _getLuckLevelColor(fortune.luckLevel),
                    ),
                  ),
                ],
              ),
              if (isEnlarged) ...[
                const Divider(),
                const SizedBox(height: 8.0),
                Text(
                  '運勢分析',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8.0),
                ...fortune.advice.map((advice) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text('• $advice'),
                )),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLuckyItem(context, '幸運色', fortune.luckyColors.join('、')),
                    _buildLuckyItem(context, '幸運數字', fortune.luckyNumbers.join('、')),
                    _buildLuckyItem(context, '幸運方位', fortune.luckyDirections.join('、')),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLuckyItem(BuildContext context, String title, String content) {
    return Column(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4.0),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Color _getLuckLevelColor(String level) {
    switch (level) {
      case '大吉':
        return Colors.red;
      case '小吉':
        return Colors.orange;
      case '平':
        return Colors.blue;
      case '小凶':
        return Colors.purple;
      case '凶':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
} 