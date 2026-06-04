import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';

class ActionPillButton2 extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final Color? borderColor;
  final double? borderWidth;
  final dynamic icon;

  const ActionPillButton2({
    super.key,
    required this.label,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.borderColor,
    this.borderWidth,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          // border: Border.all(
          //   // width: borderWidth ?? 0,
          //   // color: borderColor ?? Colors.transparent,
          // ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              HugeIcon(
                icon: icon!,
                size: 18,
                color: iconColor ?? AppTheme.greenColor,
                strokeWidth: 1,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: textColor ?? AppTheme.purpleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
