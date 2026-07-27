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
  final String? status;
  final VoidCallback? onTap;

  const DevotionArticleCard({
    super.key,
    required this.title,
    required this.description,
    required this.author,
    required this.imagePath,
    required this.likes,
    required this.tag,
    this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: AppTheme.buttonColor2),
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child:
                    imagePath.startsWith('http')
                        ? Image.network(
                          imagePath,
                          width: 62,
                          height: 62,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 62,
                              height: 62,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, color: Colors.grey, size: 20),
                            );
                          },
                        )
                        : Image.asset(
                          imagePath,
                          width: 62,
                          height: 62,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 62,
                              height: 62,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, color: Colors.grey, size: 20),
                            );
                          },
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
                    color: theme.colorScheme.onSurface,
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
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

                if (status == 'PENDING_REVIEW') ...[
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PENDING REVIEW',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 6),

                /// BOTTOM ROW
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (likes.isNotEmpty) ...[
                            const HugeIcon(
                              icon: HugeIcons.strokeRoundedThumbsUp,
                              size: 16,
                              color: Color(0xff8e8e93),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                likes,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: AppTheme.textColor2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              ' - $tag',
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    /// READ BUTTON
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          border: Border.all(
                            width: 1,
                            color: theme.colorScheme.onSurface,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Read',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
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
