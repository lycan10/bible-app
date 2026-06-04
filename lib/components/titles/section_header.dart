import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String seeAllText;
  final bool showSeeAll;
  final VoidCallback? onSeeAllTap;
  final Color? titleColor;
  final Color? actionColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.seeAllText = "See all",
    this.showSeeAll = true,
    this.onSeeAllTap,
    this.titleColor,
    this.actionColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Title
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: titleColor ?? theme.textTheme.bodyMedium?.color,
              ),
            ),

            /// Right Action
            InkWell(
              onTap: onSeeAllTap,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showSeeAll)
                    Text(
                      seeAllText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: actionColor ?? AppTheme.textColor2,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(width: 4),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    size: 18,
                    color: actionColor ?? const Color(0xff8e8e93),
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 10),
      ],
    );
  }
}
