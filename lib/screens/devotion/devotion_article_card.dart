import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';

class DevotionArticleCard extends StatelessWidget {
  final String title;
  final String description;
  final String author;
  final String imagePath;
  final String likes;
  final String tag; // e.g. "365 Days Plan"
  final VoidCallback? onTap;

  const DevotionArticleCard({
    super.key,
    required this.title,
    required this.description,
    required this.author,
    required this.imagePath,
    required this.likes,
    required this.tag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: AppTheme.buttonColor2),
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: imagePath.startsWith('http')
                ? Image.network(
                    imagePath,
                    width: 62,
                    height: 62,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    imagePath,
                    width: 62,
                    height: 62,
                    fit: BoxFit.cover,
                  ),
          ),

          const SizedBox(width: 10),

          /// CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 5),

                /// DESCRIPTION
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: AppTheme.textColor2,
                  ),
                ),

                const SizedBox(height: 5),

                /// AUTHOR
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'From: ',
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

                const SizedBox(height: 6),

                /// BOTTOM ROW
                Row(
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedThumbsUp,
                      size: 16,
                      color: Color(0xff8e8e93),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      likes,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: AppTheme.textColor2,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Text(
                      ' - $tag',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),

                    const Spacer(),

                    /// READ BUTTON
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Read',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
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
}
