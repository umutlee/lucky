import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../core/models/compass_direction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/compass_service.dart';

class CompassWidget extends ConsumerWidget {
  final double size;
  final CompassDirection? initialDirection;
  final ValueChanged<CompassDirection>? onDirectionChanged;

  const CompassWidget({
    super.key,
    this.size = 300,
    this.initialDirection,
    this.onDirectionChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compassState = ref.watch(compassProvider);

    return compassState.when(
      data: (direction) {
        onDirectionChanged?.call(direction);
        return _buildCompass(context, direction);
      },
      error: (error, stackTrace) => Center(
        child: Text('無法獲取方位數據: $error'),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildCompass(BuildContext context, CompassDirection direction) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          direction.name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        Transform.rotate(
          angle: direction.angle * math.pi / 180,
          child: Image.asset(
            'assets/images/compass.png',
            width: size * 0.8,
            height: size * 0.8,
          ),
        ),
      ],
    );
  }
}

class _CompassArrowPainter extends CustomPainter {
  final Color color;

  _CompassArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width * 0.4, size.height * 0.2)
      ..lineTo(size.width * 0.45, size.height * 0.2)
      ..lineTo(size.width * 0.45, size.height * 0.8)
      ..lineTo(size.width * 0.55, size.height * 0.8)
      ..lineTo(size.width * 0.55, size.height * 0.2)
      ..lineTo(size.width * 0.6, size.height * 0.2)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CompassArrowPainter oldDelegate) => color != oldDelegate.color;
} 