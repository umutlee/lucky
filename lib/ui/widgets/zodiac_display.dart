import 'package:flutter/material.dart';
import 'package:all_lucky/core/utils/zodiac_image_helper.dart';

class ZodiacDisplay extends StatelessWidget {
  final String zodiac;
  final double size;
  final bool isInteractive;
  final VoidCallback? onTap;
  final String? description;

  const ZodiacDisplay({
    super.key,
    required this.zodiac,
    this.size = 120,
    this.isInteractive = false,
    this.onTap,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      ZodiacImageHelper.getZodiacImage(zodiac),
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    if (isInteractive) {
      image = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: image,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(child: image),
        ),
        if (description != null) ...[
          const SizedBox(height: 8),
          Text(
            description!,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
} 