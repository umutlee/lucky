import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/compass_widget.dart';
import '../../core/services/fortune_direction_service.dart';
import '../../core/models/fortune.dart';

class CompassScreen extends ConsumerWidget {
  final Fortune fortune;
  
  const CompassScreen({
    super.key,
    required this.fortune,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fortuneDirectionService = ref.watch(fortuneDirectionProvider);
    final luckyDirections = fortuneDirectionService.getLuckyDirections(fortune);

    return Scaffold(
      appBar: AppBar(
        title: const Text('方位指南'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${fortune.type}運勢指南',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  fortune.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Center(
                  child: CompassWidget(
                    luckyDirections: luckyDirections,
                    size: MediaQuery.of(context).size.width * 0.8,
                    onDirectionChanged: (direction) {
                      // 當方位變化時更新建議
                      final advice = fortuneDirectionService.getFullDirectionAdvice(
                        fortune,
                        direction,
                        DateTime.now(),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(advice),
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '方位說明',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '紅色標記的方位為今日吉利方位，建議朝向這些方位進行${fortune.type}相關活動。',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '使用說明',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1. 紅色箭頭指向北方\n'
                          '2. 轉動手機直到指針指向目標方位\n'
                          '3. 觀察當前方位是否為吉利方位',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 