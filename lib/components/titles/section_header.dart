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
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// Title
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : (titleColor ?? theme.textTheme.bodyMedium?.color),
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
                        color: theme.colorScheme.onTertiary,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(width: 4),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    size: 18,
                    color: actionColor ?? theme.colorScheme.onTertiary,
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
