import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/compass_direction.dart';
import '../../core/services/compass_service.dart';

final compassProvider = StreamProvider<CompassDirection>((ref) {
  final service = CompassService();
  return service.directionStream;
});

class CompassWidget extends ConsumerWidget {
  final List<String> luckyDirections;
  final double size;
  final void Function(CompassDirection)? onDirectionChanged;

  const CompassWidget({
    super.key,
    required this.luckyDirections,
    this.size = 300,
    this.onDirectionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final direction = ref.watch(compassProvider);

    return direction.when(
      data: (data) {
        // 當方位變化時調用回調
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onDirectionChanged?.call(data);
        });
        return _buildCompass(context, data);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('錯誤: $error', style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildCompass(BuildContext context, CompassDirection direction) {
    final service = CompassService();
    final nearestLucky = service.getNearestLuckyDirection(direction, luckyDirections);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 背景圓圈
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              // 方位標記
              ...List.generate(8, (index) {
                final angle = index * 45.0;
                final rad = angle * math.pi / 180;
                final isLucky = luckyDirections.contains(_getDirectionName(angle));
                
                return Transform(
                  transform: Matrix4.identity()
                    ..translate(
                      (size / 2.4) * math.cos(rad),
                      (size / 2.4) * math.sin(rad),
                    ),
                  child: Text(
                    _getDirectionName(angle),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isLucky ? Colors.red : Colors.black54,
                    ),
                  ),
                );
              }),
              // 指針
              Transform.rotate(
                angle: direction.degrees * math.pi / 180,
                child: CustomPaint(
                  size: Size(size * 0.8, size * 0.8),
                  painter: CompassNeedlePainter(),
                ),
              ),
              // 中心點
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 當前方位信息
        Text(
          '當前方位: ${direction.direction}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (nearestLucky != null) ...[
          const SizedBox(height: 8),
          Text(
            '最近的吉利方位: ${nearestLucky.direction}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  String _getDirectionName(double angle) {
    const directions = {
      0.0: '北',
      45.0: '東北',
      90.0: '東',
      135.0: '東南',
      180.0: '南',
      225.0: '西南',
      270.0: '西',
      315.0: '西北',
    };
    return directions[angle] ?? '';
  }
}

class CompassNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width / 2 - 10, size.height / 2)
      ..lineTo(size.width / 2 + 10, size.height / 2)
      ..close();

    canvas.drawPath(path, paint);

    paint.color = Colors.black54;
    final backPath = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 - 10, size.height / 2)
      ..lineTo(size.width / 2 + 10, size.height / 2)
      ..close();

    canvas.drawPath(backPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 