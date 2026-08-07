import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/components/formatted_text.dart';

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
    this.image = "assets/images/boy.png",
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
                FormattedText(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: onAuthorTap,
                      child: Text(
                        author,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: AppTheme.textColor2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// ACTIONS (Likes, Comments, Shares)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _actionItem(HugeIcons.strokeRoundedThumbsUp, likes),
                    _actionItem(HugeIcons.strokeRoundedComment01, comments),
                    _actionItem(HugeIcons.strokeRoundedShare08, shares),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedBookmark02,
                      size: 20,
                      color: Colors.grey.shade600,
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

  /// Action Item Widget
  Widget _actionItem(dynamic icon, String count) {
    return Row(
      children: [
        HugeIcon(icon: icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
