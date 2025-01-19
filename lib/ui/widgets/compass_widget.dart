import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/compass_direction.dart';
import '../../core/services/compass_service.dart';

final compassProvider = StreamProvider<CompassDirection>((ref) {
  final service = CompassService();
  return service.directionStream;
});

class CompassWidget extends ConsumerStatefulWidget {
  final double size;
  final void Function(CompassDirection)? onDirectionChanged;

  const CompassWidget({
    super.key,
    this.size = 300,
    this.onDirectionChanged,
  });

  @override
  ConsumerState<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends ConsumerState<CompassWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _lastAngle = 0.0;
  CompassDirection? _lastDirection;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final direction = ref.watch(compassProvider);

    return direction.when(
      data: (data) {
        final angleDiff = (data.degrees - _lastAngle) % 360;
        _lastAngle = data.degrees;

        if (_lastDirection == null ||
            !data.isNear(_lastDirection!, tolerance: 5.0)) {
          _lastDirection = data;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onDirectionChanged?.call(data);
          });
        }

        _controller.forward(from: 0.0);

        return _buildCompass(context, data, angleDiff);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('錯誤: $error', style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  Widget _buildCompass(
    BuildContext context,
    CompassDirection direction,
    double angleDiff,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size,
                height: widget.size,
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
              ...List.generate(8, (index) {
                final angle = index * 45.0;
                final rad = angle * math.pi / 180;
                
                return Transform(
                  transform: Matrix4.identity()
                    ..translate(
                      (widget.size / 2.4) * math.cos(rad),
                      (widget.size / 2.4) * math.sin(rad),
                    ),
                  child: Text(
                    _getDirectionName(angle),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                );
              }),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: (_lastAngle - angleDiff + angleDiff * _controller.value) *
                        math.pi /
                        180,
                    child: child,
                  );
                },
                child: CustomPaint(
                  size: Size(widget.size * 0.8, widget.size * 0.8),
                  painter: CompassNeedlePainter(),
                ),
              ),
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            '當前方位: ${direction.direction}',
            key: ValueKey(direction.direction),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
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
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 