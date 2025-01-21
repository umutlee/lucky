import 'package:flutter/material.dart';
import '../../core/models/zodiac.dart';
import 'zodiac_display.dart';

class ZodiacGrid extends StatelessWidget {
  final double iconSize;
  final Function(Zodiac)? onZodiacSelected;

  const ZodiacGrid({
    super.key,
    this.iconSize = 80.0,
    this.onZodiacSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: Zodiac.values.map((zodiac) {
        return GestureDetector(
          onTap: () => onZodiacSelected?.call(zodiac),
          child: ZodiacDisplay(
            zodiac: zodiac,
            size: iconSize,
          ),
        );
      }).toList(),
    );
  }
} 