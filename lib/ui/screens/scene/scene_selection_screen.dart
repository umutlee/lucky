import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/error_boundary.dart';
import '../../widgets/loading_indicator.dart';
import '../../../core/providers/scene_provider.dart';
import '../../../core/models/scene.dart';
import '../../../core/services/scene_service.dart';

class SceneSelectionScreen extends ConsumerWidget {
  const SceneSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scenes = ref.watch(scenesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('選擇場景'),
        centerTitle: true,
      ),
      body: ErrorBoundary(
        child: scenes.when(
          data: (sceneList) => GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: sceneList.length,
            itemBuilder: (context, index) {
              final scene = sceneList[index];
              return _SceneCard(
                scene: scene,
                index: index,
              );
            },
          ),
          loading: () => const LoadingIndicator(),
          error: (error, stack) => Center(
            child: Text(
              '載入失敗: $error',
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }
}

class _SceneCard extends StatelessWidget {
  final Scene scene;
  final int index;

  const _SceneCard({
    required this.scene,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Hero(
      tag: 'scene_${scene.id}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/scene/detail',
              arguments: scene,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primary.withOpacity(0.1),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: _buildBackground(theme),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        scene.icon,
                        color: theme.colorScheme.primary,
                        size: 32,
                      ),
                      const Spacer(),
                      Text(
                        scene.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scene.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(ThemeData theme) {
    return CustomPaint(
      painter: _SceneBackgroundPainter(
        color: theme.colorScheme.primary.withOpacity(0.05),
        index: index,
      ),
    );
  }
}

class _SceneBackgroundPainter extends CustomPainter {
  final Color color;
  final int index;

  _SceneBackgroundPainter({
    required this.color,
    required this.index,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    switch (index % 4) {
      case 0:
        _drawCirclePattern(canvas, size, paint);
        break;
      case 1:
        _drawWavePattern(canvas, size, paint);
        break;
      case 2:
        _drawDiagonalPattern(canvas, size, paint);
        break;
      case 3:
        _drawDotsPattern(canvas, size, paint);
        break;
    }
  }

  void _drawCirclePattern(Canvas canvas, Size size, Paint paint) {
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      size.width * 0.3,
      paint,
    );
  }

  void _drawWavePattern(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    
    for (var i = 0; i < size.width / 20; i++) {
      path.quadraticBezierTo(
        10 + (i * 20),
        size.height * (0.7 + (i % 2 == 0 ? 0.05 : -0.05)),
        20 + (i * 20),
        size.height * 0.7,
      );
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  void _drawDiagonalPattern(Canvas canvas, Size size, Paint paint) {
    for (var i = 0; i < size.width + size.height; i += 20) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(0, i),
        paint..strokeWidth = 1,
      );
    }
  }

  void _drawDotsPattern(Canvas canvas, Size size, Paint paint) {
    for (var i = 0; i < size.width; i += 20) {
      for (var j = 0; j < size.height; j += 20) {
        canvas.drawCircle(
          Offset(i.toDouble(), j.toDouble()),
          2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SceneBackgroundPainter oldDelegate) => false;
} 