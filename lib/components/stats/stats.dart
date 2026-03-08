import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class Stat extends StatelessWidget {
  final dynamic icon;
  final String text;
  final Color? textColor;
  final double? textSize; // ✅ use double, not int
  final double? iconSize; // ✅ use double, not int

  const Stat({
    super.key,
    required this.icon,
    required this.text,
    this.textColor,
    this.textSize,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min, // ✅ prevents unnecessary stretching
      children: [
        HugeIcon(
          icon: icon,
          size: iconSize ?? 14,
          color: const Color(0xff8e8e93),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: textSize ?? 11,
            color: textColor ?? const Color(0xff8e8e93),
          ),
        ),
      ],
    );
  }
}
