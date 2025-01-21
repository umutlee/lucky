import 'package:flutter/material.dart';

class LuckyDirectionIndicator extends StatelessWidget {
  final double currentDirection;
  final List<String> luckyDirections;

  const LuckyDirectionIndicator({
    super.key,
    required this.currentDirection,
    required this.luckyDirections,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentDirectionName = _getDirectionName(currentDirection);
    final isLuckyDirection = luckyDirections.contains(currentDirectionName);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isLuckyDirection ? Icons.star : Icons.star_border,
                  color: isLuckyDirection 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '吉利方位',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: luckyDirections.map((direction) {
                final isCurrentDirection = direction == currentDirectionName;
                
                return Chip(
                  avatar: Icon(
                    isCurrentDirection ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 18,
                    color: isCurrentDirection 
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.primary,
                  ),
                  label: Text(direction),
                  labelStyle: TextStyle(
                    color: isCurrentDirection 
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                  ),
                  backgroundColor: isCurrentDirection 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                  side: BorderSide(
                    color: isCurrentDirection 
                      ? Colors.transparent
                      : theme.colorScheme.outline,
                  ),
                );
              }).toList(),
            ),
            if (isLuckyDirection) ...[
              const SizedBox(height: 16),
              Text(
                '當前方位為吉利方位！',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getLuckyDirectionDescription(currentDirectionName),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
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

  String _getLuckyDirectionDescription(String direction) {
    switch (direction) {
      case '東':
        return '東方代表生發、成長，適合開展新事業、學習新知識。';
      case '南':
        return '南方代表旺盛、熱情，適合社交活動、表達自我。';
      case '西':
        return '西方代表收斂、沉穩，適合總結經驗、深入思考。';
      case '北':
        return '北方代表儲藏、蓄勢，適合積累資源、養精蓄銳。';
      case '東北':
        return '東北方代表起始、突破，適合開創新局、突破瓶頸。';
      case '東南':
        return '東南方代表擴展、成長，適合拓展人脈、增進關係。';
      case '西南':
        return '西南方代表和諧、穩定，適合維護關係、保持平衡。';
      case '西北':
        return '西北方代表智慧、遠見，適合規劃未來、制定策略。';
      default:
        return '';
    }
  }
} 