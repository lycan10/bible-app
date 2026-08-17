import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/stats/stats.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/components/avatar.dart';
import 'package:quest/components/formatted_text.dart';

class PostCardLong extends StatelessWidget {
  final String userName;
  final String userImage;
  final String postText;
  final String groupName;
  final String postImage;
  final String likes;
  final String comments;
  final String time;
  final String verificationBadge;
  final VoidCallback onTap;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onMoreTap;

  const PostCardLong({
    super.key,
    required this.userName,
    required this.userImage,
    required this.postText,
    required this.groupName,
    required this.postImage,
    required this.likes,
    required this.comments,
    required this.time,
    this.verificationBadge = 'NONE',
    required this.onTap,
    this.onAvatarTap,
    this.onMoreTap,
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
                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: onAvatarTap,
                      child: Row(
                        children: [
                          CustomAvatar(
                            imageUrl: userImage,
                            radius: 14.0,
                            hasBorder: true,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            userName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              color: AppTheme.textColor2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (verificationBadge == 'BLUE') ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 14,
                            ),
                          ] else if (verificationBadge == 'GOLD') ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              color: Colors.amber,
                              size: 14,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (onMoreTap != null)
                      GestureDetector(
                        onTap: onMoreTap,
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedMoreVertical,
                          size: 18,
                          color: theme.colorScheme.onSurface,
                          strokeWidth: 3,
                        ),
                      )
                    else
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedMoreVertical,
                        size: 18,
                        color: theme.colorScheme.onSurface,
                        strokeWidth: 3,
                      ),
                  ],
                ),

                const SizedBox(height: 15),

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
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 14,
                              color: theme.colorScheme.tertiary,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const HugeIcon(
                                icon: HugeIcons.strokeRoundedUserGroup,
                                size: 16,
                                color: Color(0xff8e8e93),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  groupName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: AppTheme.textColor2,
                                  ),
                                ),
                              ),
                            ],
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
                                  color: AppTheme.textColor2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (postImage.isNotEmpty) ...[
                      const SizedBox(width: 15),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            postImage.startsWith('http')
                                ? CachedNetworkImage(imageUrl: postImage,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                )
                                : Image.asset(
                                  postImage,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
