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

  const SettingsRowItem({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    this.subtitle,
    this.onTap,
    required this.iconColor,
    this.iconGradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconGradient == null ? iconBackgroundColor : null,
                      gradient: iconGradient,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: HugeIcon(
                      icon: icon,
                      size: 19,
                      color: iconColor,
                      strokeWidth: 2,
                    ),
                  ),

                  const SizedBox(width: 6),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 0),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 18,
                color: const Color(0xff8e8e93),
                strokeWidth: 2,
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
