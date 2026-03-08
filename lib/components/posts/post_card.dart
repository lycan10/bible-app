import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 320,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.white,
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            /// IMAGE + SPONSORED BADGE
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
              child: Image.asset(
                "assets/images/user_test.jpg",
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            /// CONTENT
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "The Mystery of the cross of Jesus Christ",
                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      height: 1.3,
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
                          const SizedBox(width: 10),
                          _actionItem(theme, Icons.chat_bubble_outline, "29"),
                          const SizedBox(width: 10),
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
                              size: 18,
                              color: AppTheme.textColor2,
                              strokeWidth: 1,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedLinkForward,
                              size: 18,
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
