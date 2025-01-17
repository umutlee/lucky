import 'package:flutter/material.dart';
import '../../../core/models/zodiac_info.dart';

/// 星座運勢卡片
class HoroscopeFortuneCard extends StatelessWidget {
  final Horoscope horoscope;
  final String fortune;
  final double score;
  final Map<String, double> aspectScores; // 各方面運勢評分
  final List<String> luckyItems;          // 開運物品
  final List<String> compatibleSigns;     // 速配星座

  const HoroscopeFortuneCard({
    super.key,
    required this.horoscope,
    required this.fortune,
    required this.score,
    this.aspectScores = const {},
    this.luckyItems = const [],
    this.compatibleSigns = const [],
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
                _buildHoroscopeInfo(),
                const SizedBox(height: 16),
                if (aspectScores.isNotEmpty) ...[
                  _buildAspectScores(),
                  const SizedBox(height: 16),
                ],
                _buildFortune(),
                if (luckyItems.isNotEmpty || compatibleSigns.isNotEmpty) ...[
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
            horoscope.color.withOpacity(0.8),
            horoscope.color,
          ],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.9),
            child: Image.asset(
              horoscope.imagePath,
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
                  '${horoscope.name}運勢',
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

  Widget _buildHoroscopeInfo() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: horoscope.traits.map((trait) => Chip(
        label: Text(trait),
        backgroundColor: horoscope.color.withOpacity(0.1),
        side: BorderSide(color: horoscope.color.withOpacity(0.2)),
      )).toList(),
    );
  }

  Widget _buildAspectScores() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: aspectScores.entries.map((entry) {
        final score = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                child: Text(
                  entry.key,
                  style: TextStyle(
                    color: horoscope.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score,
                    backgroundColor: horoscope.color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(horoscope.color),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(score * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: horoscope.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
        if (luckyItems.isNotEmpty)
          _buildLuckySection('開運物', luckyItems),
        if (compatibleSigns.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildLuckySection('速配星座', compatibleSigns),
        ],
      ],
    );
  }

  Widget _buildLuckySection(String title, List<String> items) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            title,
            style: TextStyle(
              color: horoscope.color,
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