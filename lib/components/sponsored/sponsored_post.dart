import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';

class SponsoredPost extends StatelessWidget {
  const SponsoredPost({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          /// IMAGE + SPONSORED BADGE
          SizedBox(
            height: 250,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    "assets/images/user_test.jpg",
                    fit: BoxFit.cover,
                  ),
                ),

                /// Sponsored badge
                Positioned(
                  top: 15,
                  left: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Sponsored",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// CONTENT
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "The Mystery of the cross of Christ",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 6),

                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'by: ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: AppTheme.textColor2,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      TextSpan(
                        text: "author",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "- Today • 2:49pm",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: AppTheme.textColor2,
                  ),
                ),

                const SizedBox(height: 12),

                /// ACTIONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _actionItem(theme, Icons.favorite_border, "370k"),
                        const SizedBox(width: 12),
                        _actionItem(theme, Icons.chat_bubble_outline, "29"),
                        const SizedBox(width: 12),
                        _actionItem(theme, Icons.share_outlined, "5k"),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedBookmark02,
                            size: 20,
                            color: AppTheme.textColor2,
                            strokeWidth: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedLinkForward,
                            size: 20,
                            color: Colors.black,
                            strokeWidth: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionItem(ThemeData theme, IconData icon, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 14, color: AppTheme.textColor2),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
