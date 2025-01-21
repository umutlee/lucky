import 'dart:math' as math;
import 'package:flutter/material.dart';

class CompassDisplay extends StatelessWidget {
  final double direction;
  final List<String> luckyDirections;

  const CompassDisplay({
    super.key,
    required this.direction,
    required this.luckyDirections,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 外圈
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 2,
                    ),
                  ),
                ),
                
                // 方位標記
                ...List.generate(8, (index) {
                  final angle = index * 45.0;
                  final direction = _getDirectionText(angle);
                  final isLucky = luckyDirections.contains(direction);
                  
                  return Transform.rotate(
                    angle: angle * math.pi / 180,
                    child: Transform.translate(
                      offset: Offset(0, -size / 2 + 24),
                      child: Transform.rotate(
                        angle: -angle * math.pi / 180,
                        child: Text(
                          direction,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLucky 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                
                // 指針
                Transform.rotate(
                  angle: -direction * math.pi / 180,
                  child: CustomPaint(
                    size: Size(size * 0.8, size * 0.8),
                    painter: CompassNeedlePainter(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                
                // 中心點
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDirectionText(double angle) {
    switch (angle.toInt()) {
      case 0:
        return '北';
      case 45:
        return '東北';
      case 90:
        return '東';
      case 135:
        return '東南';
      case 180:
        return '南';
      case 225:
        return '西南';
      case 270:
        return '西';
      case 315:
        return '西北';
      default:
        return '';
    }
  }
}

class CompassNeedlePainter extends CustomPainter {
  final Color color;

  CompassNeedlePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final needleLength = size.height / 2;
    
    // 北針（紅色）
    final northPath = Path()
      ..moveTo(center.dx, center.dy - needleLength)
      ..lineTo(center.dx - 8, center.dy)
      ..lineTo(center.dx + 8, center.dy)
      ..close();
    
    canvas.drawPath(northPath, paint..color = Colors.red);
    
    // 南針（白色）
    final southPath = Path()
      ..moveTo(center.dx, center.dy + needleLength)
      ..lineTo(center.dx - 8, center.dy)
      ..lineTo(center.dx + 8, center.dy)
      ..close();
    
    canvas.drawPath(southPath, paint..color = Colors.white);
    canvas.drawPath(
      southPath,
      Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(CompassNeedlePainter oldDelegate) {
    return oldDelegate.color != color;
  }
} 