import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';

class PostCard extends StatelessWidget {
  final String title;
  final String author;
  final String time;
  final String image;
  final String likes;
  final String comments;
  final String shares;
  final double? width;
  final VoidCallback? onAuthorTap;

  const PostCard({
    super.key,
    this.title = "The Mystery of the cross of Jesus Christ",
    this.author = "author",
    this.time = "Today • 2:49pm",
    this.image = "assets/images/user_test.jpg",
    this.likes = "370k",
    this.comments = "29",
    this.shares = "5k",
    this.width, // ✅ important for horizontal list
    this.onAuthorTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          Image.asset(
            image,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          /// CONTENT
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 15,
                    height: 1.3,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 6),

                /// AUTHOR
                GestureDetector(
                  onTap: onAuthorTap,
                  child: Text.rich(
                    TextSpan(
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
                          text: author,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                /// TIME
                Text(
                  time,
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
                    Flexible(
                      child: Row(
                        children: [
                          _actionItem(theme, Icons.favorite_border, likes),
                          const SizedBox(width: 8),
                          _actionItem(
                            theme,
                            Icons.chat_bubble_outline,
                            comments,
                          ),
                          const SizedBox(width: 8),
                          _actionItem(theme, Icons.share_outlined, shares),
                        ],
                      ),
                    ),

                    Row(
                      children: [
                        _iconButton(
                          HugeIcons.strokeRoundedBookmark02,
                          AppTheme.textColor2,
                        ),
                        const SizedBox(width: 6),
                        _iconButton(
                          HugeIcons.strokeRoundedLinkForward,
                          Colors.black,
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
        const SizedBox(width: 4),
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

  Widget _iconButton(dynamic icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: HugeIcon(icon: icon, size: 18, color: color, strokeWidth: 1),
    );
  }
}
