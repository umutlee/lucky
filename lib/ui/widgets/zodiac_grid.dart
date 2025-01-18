import 'package:flutter/material.dart';
import 'package:all_lucky/core/utils/zodiac_image_helper.dart';
import 'package:all_lucky/ui/widgets/zodiac_display.dart';

class ZodiacGrid extends StatelessWidget {
  final double itemSize;
  final bool isInteractive;
  final void Function(String zodiac)? onZodiacTap;
  final Map<String, String>? descriptions;

  const ZodiacGrid({
    super.key,
    this.itemSize = 100,
    this.isInteractive = false,
    this.onZodiacTap,
    this.descriptions,
  });

  @override
  Widget build(BuildContext context) {
    final zodiacs = ['鼠', '牛', '虎', '兔', '龍', '蛇', '馬', '羊', '猴', '雞', '狗', '豬'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: zodiacs.length,
      itemBuilder: (context, index) {
        final zodiac = zodiacs[index];
        return ZodiacDisplay(
          zodiac: zodiac,
          size: itemSize,
          isInteractive: isInteractive,
          onTap: onZodiacTap != null ? () => onZodiacTap!(zodiac) : null,
          description: descriptions?[zodiac],
        );
      },
    );
  }
} 