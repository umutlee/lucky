import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../core/models/compass_direction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/compass_service.dart';

class CompassWidget extends StatefulWidget {
  final double size;
  final double rotation;
  final String direction;
  final String luckyDirection;
  final bool isCalibrating;
  final VoidCallback? onStartCalibration;
  final VoidCallback? onCancelCalibration;
  final VoidCallback? onResetCalibration;

  const CompassWidget({
    super.key,
    this.size = 300,
    required this.rotation,
    required this.direction,
    required this.luckyDirection,
    this.isCalibrating = false,
    this.onStartCalibration,
    this.onCancelCalibration,
    this.onResetCalibration,
  });

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // 旋轉動畫
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: widget.rotation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    // 縮放動畫
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 70,
      ),
    ]).animate(_controller);

    // 透明度動畫
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.7)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 70,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(CompassWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rotation != widget.rotation) {
      _updateRotation();
    }
  }

  void _updateRotation() {
    _rotationAnimation = Tween<double>(
      begin: _rotationAnimation.value,
      end: widget.rotation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 校準狀態指示器
        if (widget.isCalibrating)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '正在校準指南針...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: widget.onCancelCalibration,
                  child: const Text('取消'),
                ),
              ],
            ),
          ),

        // 指南針主體
        Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 外圈裝飾
                        Container(
                          width: widget.size,
                          height: widget.size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.surface,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                                spreadRadius: _scaleAnimation.value * 2,
                              ),
                            ],
                          ),
                        ),
                        
                        // 刻度和方位
                        Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: CustomPaint(
                            size: Size(widget.size, widget.size),
                            painter: _CompassPainter(
                              theme: theme,
                              luckyDirection: widget.luckyDirection,
                              animationValue: _controller.value,
                            ),
                          ),
                        ),
                        
                        // 中心點
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: _scaleAnimation.value * 1.5,
                              ),
                            ],
                          ),
                        ),
                        
                        // 指針
                        Transform.rotate(
                          angle: -_rotationAnimation.value,
                          child: Container(
                            width: widget.size * 0.8,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary.withOpacity(0),
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withOpacity(0),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.2),
                                  blurRadius: 4,
                                  spreadRadius: _scaleAnimation.value,
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
            ),
            
            // 校準按鈕
            if (!widget.isCalibrating)
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: widget.onStartCalibration,
                  tooltip: '校準指南針',
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),
        
        // 當前方位
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.explore,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '當前方位: ${widget.direction}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              if (!widget.isCalibrating) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: widget.onResetCalibration,
                  tooltip: '重置校準',
                  iconSize: 20,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 8),
        
        // 吉利方位
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.stars,
                color: theme.colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '吉利方位: ${widget.luckyDirection}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompassPainter extends CustomPainter {
  final ThemeData theme;
  final String luckyDirection;
  final double animationValue;

  _CompassPainter({
    required this.theme,
    required this.luckyDirection,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // 畫主要方位
    final directions = ['北', '東', '南', '西'];
    final paint = Paint()
      ..color = theme.colorScheme.onSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final direction = directions[i];
      final isLucky = luckyDirection.contains(direction);
      
      // 畫刻度線
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      
      // 添加動畫效果
      final lineLength = 20 + (animationValue * 5);
      canvas.drawLine(
        Offset(0, -radius + lineLength),
        Offset(0, -radius + 40),
        paint,
      );
      
      // 畫文字
      final textPainter = TextPainter(
        text: TextSpan(
          text: direction,
          style: TextStyle(
            color: isLucky ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            fontSize: 20 + (isLucky ? animationValue * 2 : 0),
            fontWeight: isLucky ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          -textPainter.width / 2,
          -radius + 50,
        ),
      );
      
      canvas.restore();
    }
    
    // 畫次要刻度
    for (var i = 0; i < 360; i += 15) {
      if (i % 90 != 0) {
        final angle = i * math.pi / 180;
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(angle);
        
        final lineLength = i % 45 == 0 ? 35 : 30;
        canvas.drawLine(
          Offset(0, -radius + 20),
          Offset(0, -radius + lineLength + (animationValue * 2)),
          paint..strokeWidth = i % 45 == 0 ? 1.5 : 1,
        );
        
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_CompassPainter oldDelegate) =>
      theme != oldDelegate.theme ||
      luckyDirection != oldDelegate.luckyDirection ||
      animationValue != oldDelegate.animationValue;
} 