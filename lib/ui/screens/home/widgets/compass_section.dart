import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../../core/providers/compass_provider.dart';
import '../../../../core/models/compass_direction.dart';
import '../../../../core/utils/direction_helper.dart';

class CompassSection extends ConsumerStatefulWidget {
  const CompassSection({super.key});

  @override
  ConsumerState<CompassSection> createState() => _CompassSectionState();
}

class _CompassSectionState extends ConsumerState<CompassSection> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compassState = ref.watch(compassProvider);
    final direction = compassState.currentDirection;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '方位指南',
                  style: theme.textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    // TODO: 導航到方位詳情頁
                  },
                  child: const Text('查看更多'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 指南針卡片
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // 指南針圖示
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 指南針刻度
                        Transform.rotate(
                          angle: -compassState.heading * (math.pi / 180),
                          child: CustomPaint(
                            size: const Size(180, 180),
                            painter: CompassPainter(theme: theme),
                          ),
                        ),
                        // 指針
                        Container(
                          width: 4,
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.tertiary,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 方位資訊
                  Text(
                    '當前方位: ${direction.toString()}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    compassState.directionDescription ?? '載入中...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  if (compassState.auspiciousDirections != null) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      alignment: WrapAlignment.center,
                      children: compassState.auspiciousDirections!.map((direction) => Chip(
                        label: Text(direction),
                        backgroundColor: theme.colorScheme.surface,
                        labelStyle: TextStyle(
                          color: theme.colorScheme.onSurface,
                        ),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompassPainter extends CustomPainter {
  final ThemeData theme;
  
  CompassPainter({required this.theme});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..color = theme.colorScheme.onSurface
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
      
    // 畫主要方位
    final directions = ['北', '東', '南', '西'];
    for (var i = 0; i < 4; i++) {
      final angle = i * (math.pi / 2);
      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      final x = center.dx + (radius - 30) * math.sin(angle) - textPainter.width / 2;
      final y = center.dy - (radius - 30) * math.cos(angle) - textPainter.height / 2;
      textPainter.paint(canvas, Offset(x, y));
    }
    
    // 畫刻度
    for (var i = 0; i < 360; i += 15) {
      final angle = i * (math.pi / 180);
      final startRadius = i % 90 == 0 ? radius - 20 : (i % 45 == 0 ? radius - 15 : radius - 10);
      final start = Offset(
        center.dx + startRadius * math.sin(angle),
        center.dy - startRadius * math.cos(angle),
      );
      final end = Offset(
        center.dx + radius * math.sin(angle),
        center.dy - radius * math.cos(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 