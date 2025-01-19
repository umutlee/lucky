import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 32),
          Text(
            '諸事大吉',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '為您提供個人化的運勢預測\n讓每一天都充滿好運',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 48),
          _buildFeatureList(context),
        ],
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    final features = [
      {'icon': Icons.auto_awesome, 'text': '準確的運勢預測'},
      {'icon': Icons.compass_calibration, 'text': '方位指南'},
      {'icon': Icons.notifications_active, 'text': '重要時刻提醒'},
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(
                feature['icon'] as IconData,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                feature['text'] as String,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
} 