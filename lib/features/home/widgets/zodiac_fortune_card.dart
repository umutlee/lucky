import 'package:flutter/material.dart';
import '../../../core/models/zodiac_info.dart';

/// 生肖運勢卡片
class ZodiacFortuneCard extends StatelessWidget {
  final ChineseZodiac zodiac;
  final String fortune;
  final double score;
  final List<String> luckyDirections;
  final List<String> luckyColors;
  final List<String> luckyNumbers;

  const ZodiacFortuneCard({
    super.key,
    required this.zodiac,
    required this.fortune,
    required this.score,
    this.luckyDirections = const [],
    this.luckyColors = const [],
    this.luckyNumbers = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildZodiacInfo(),
                const SizedBox(height: 16),
                _buildFortune(),
                if (luckyDirections.isNotEmpty || 
                    luckyColors.isNotEmpty || 
                    luckyNumbers.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildLuckyInfo(),
                ],
              ],
            ),
          ),
        ],
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
            zodiac.color.withOpacity(0.8),
            zodiac.color,
          ],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.9),
            child: Image.asset(
              zodiac.imagePath,
              width: 32,
              height: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${zodiac.name}年運勢',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '今日評分：${(score * 100).toStringAsFixed(0)}分',
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

  Widget _buildZodiacInfo() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: zodiac.traits.map((trait) => Chip(
        label: Text(trait),
        backgroundColor: zodiac.color.withOpacity(0.1),
        side: BorderSide(color: zodiac.color.withOpacity(0.2)),
      )).toList(),
    );
  }

  Widget _buildFortune() {
    return Text(
      fortune,
      style: const TextStyle(
        fontSize: 16,
        height: 1.6,
      ),
    );
  }

  Widget _buildLuckyInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (luckyDirections.isNotEmpty)
          _buildLuckySection('吉位', luckyDirections),
        if (luckyColors.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildLuckySection('吉色', luckyColors),
        ],
        if (luckyNumbers.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildLuckySection('吉數', luckyNumbers),
        ],
      ],
    );
  }

  Widget _buildLuckySection(String title, List<String> items) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 48,
          child: Text(
            title,
            style: TextStyle(
              color: zodiac.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: items.map((item) => Text(item)).toList(),
          ),
        ),
      ],
    );
  }
} 