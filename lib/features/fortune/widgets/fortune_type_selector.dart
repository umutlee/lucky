import 'package:flutter/material.dart';
import '../../../core/models/fortune.dart';

class FortuneTypeSelector extends StatelessWidget {
  final FortuneType selectedType;
  final ValueChanged<FortuneType> onTypeChanged;

  const FortuneTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTypeChip(
            context,
            FortuneType.general,
            Icons.auto_awesome,
            theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          _buildTypeChip(
            context,
            FortuneType.love,
            Icons.favorite,
            Colors.pink,
          ),
          const SizedBox(width: 8),
          _buildTypeChip(
            context,
            FortuneType.career,
            Icons.work,
            Colors.indigo,
          ),
          const SizedBox(width: 8),
          _buildTypeChip(
            context,
            FortuneType.wealth,
            Icons.monetization_on,
            Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(
    BuildContext context,
    FortuneType type,
    IconData icon,
    Color color,
  ) {
    final isSelected = selectedType == type;
    final theme = Theme.of(context);

    return FilterChip(
      selected: isSelected,
      showCheckmark: false,
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? theme.colorScheme.onPrimary : color,
      ),
      label: Text(type.name),
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
      ),
      selectedColor: color,
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(
        color: isSelected ? Colors.transparent : color.withOpacity(0.5),
      ),
      onSelected: (selected) {
        if (selected) {
          onTypeChanged(type);
        }
      },
    );
  }
} 