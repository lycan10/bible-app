import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/stats/stats.dart';
import 'package:quest/theme/theme.dart';

class PostCardShort extends StatelessWidget {
  final String postText;
  final String? postImage;
  final String likes;
  final String author;
  final String comments;
  final String time;
  final String? avatarUrl;
  final VoidCallback onTap;
  final VoidCallback? onAuthorTap;

  const PostCardShort({
    super.key,
    required this.postText,
    this.postImage,
    required this.likes,
    required this.comments,
    required this.time,
    required this.onTap,
    required this.author,
    this.avatarUrl,
    this.onAuthorTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                width: 1,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                /// BODY
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TEXT SIDE
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            postText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),

                          const SizedBox(height: 8),

                          GestureDetector(
                            onTap: onAuthorTap,
                            child: RichText(
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
                          ),

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Stat(
                                    icon: HugeIcons.strokeRoundedThumbsUp,
                                    text: likes,
                                  ),
                                  const SizedBox(width: 10),
                                  Stat(
                                    icon: HugeIcons.strokeRoundedComment01,
                                    text: comments,
                                  ),
                                ],
                              ),

                              Text(
                                time,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 15),

                    /// POST IMAGE
                    if (postImage != null && postImage!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            postImage!.startsWith('http')
                                ? Image.network(
                                  postImage!,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        width: 90,
                                        height: 90,
                                        color: Colors.grey.shade300,
                                        child: const HugeIcon(
                                          icon: HugeIcons.strokeRoundedImage01,
                                          color: Colors.grey,
                                        ),
                                      ),
                                )
                                : Image.asset(
                                  postImage!,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
