import 'package:flutter/material.dart';

class FortuneLoadingCard extends StatelessWidget {
  const FortuneLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 200,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在計算運勢...'),
            ],
          ),
        ),
      ),
    );
  }
} 