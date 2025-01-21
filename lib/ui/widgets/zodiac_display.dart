import 'package:flutter/material.dart';
import 'package:all_lucky/core/models/zodiac.dart';
import 'package:all_lucky/core/utils/zodiac_image_helper.dart';

class ZodiacDisplay extends StatelessWidget {
  final Zodiac zodiac;
  final double size;
  final VoidCallback? onTap;

  const ZodiacDisplay({
    super.key,
    required this.zodiac,
    this.size = 100,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        ZodiacImageHelper.getZodiacImage(zodiac),
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
} 