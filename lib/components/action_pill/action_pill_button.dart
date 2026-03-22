import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ActionPillButton extends StatelessWidget {
  final dynamic icon;
  final String label;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const ActionPillButton({
    super.key,
    this.icon,
    required this.label,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: BoxConstraints(minWidth: 0, maxWidth: double.infinity),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // ✅ center content
          children: [
            if (icon != null) ...[
              HugeIcon(
                icon: icon!,
                size: 18,
                color: iconColor ?? Colors.black,
                strokeWidth: 1,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: textColor ?? Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
