import 'package:flutter/material.dart';

class DirectionInfoCard extends StatelessWidget {
  final double direction;

  const DirectionInfoCard({
    super.key,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '當前方位',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  context,
                  '方位角',
                  '${direction.toStringAsFixed(1)}°',
                  Icons.explore,
                ),
                _buildInfoItem(
                  context,
                  '方位',
                  _getDirectionName(direction),
                  Icons.navigation,
                ),
                _buildInfoItem(
                  context,
                  '象限',
                  _getQuadrant(direction),
                  Icons.crop_square,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }

  String _getDirectionName(double angle) {
    final normalizedAngle = ((angle % 360) + 360) % 360;
    
    if (normalizedAngle >= 337.5 || normalizedAngle < 22.5) {
      return '北';
    } else if (normalizedAngle >= 22.5 && normalizedAngle < 67.5) {
      return '東北';
    } else if (normalizedAngle >= 67.5 && normalizedAngle < 112.5) {
      return '東';
    } else if (normalizedAngle >= 112.5 && normalizedAngle < 157.5) {
      return '東南';
    } else if (normalizedAngle >= 157.5 && normalizedAngle < 202.5) {
      return '南';
    } else if (normalizedAngle >= 202.5 && normalizedAngle < 247.5) {
      return '西南';
    } else if (normalizedAngle >= 247.5 && normalizedAngle < 292.5) {
      return '西';
    } else {
      return '西北';
    }
  }

  String _getQuadrant(double angle) {
    final normalizedAngle = ((angle % 360) + 360) % 360;
    
    if (normalizedAngle >= 0 && normalizedAngle < 90) {
      return '第一象限';
    } else if (normalizedAngle >= 90 && normalizedAngle < 180) {
      return '第二象限';
    } else if (normalizedAngle >= 180 && normalizedAngle < 270) {
      return '第三象限';
    } else {
      return '第四象限';
    }
  }
} 