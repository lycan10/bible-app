import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class SettingsRowItem extends StatelessWidget {
  final dynamic icon;
  final Gradient? iconGradient;
  final Color? iconBackgroundColor;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final GestureTapCallback? onTap;
  final Color? secondIconColor;

  const SettingsRowItem({
    super.key,
    this.icon,
    this.iconGradient,
    this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
    this.secondIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (icon != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            iconGradient == null ? iconBackgroundColor : null,
                        gradient: iconGradient,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: HugeIcon(
                        icon: icon!,
                        size: 18,
                        color: iconColor,
                        strokeWidth: 1,
                      ),
                    ),
                  if (icon != null) const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 18,
                color: secondIconColor ?? const Color(0xff8e8e93),
                strokeWidth: 2,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
