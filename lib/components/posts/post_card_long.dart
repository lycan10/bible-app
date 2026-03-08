import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/stats/stats.dart';

class PostCardLong extends StatelessWidget {
  final String userName;
  final String userImage;
  final String postText;
  final String groupName;
  final String postImage;
  final String likes;
  final String comments;
  final String time;
  final VoidCallback onTap;

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
    required this.onTap,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(width: 1, color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                /// HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _Avatar(image: userImage),
                        const SizedBox(width: 10),
                        Text(
                          userName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedMoreVertical,
                      size: 18,
                      color: Colors.black,
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 14,
                              color: Colors.black,
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
                              Text(
                                groupName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
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
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 15),

                    /// POST IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        postImage,
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

class _Avatar extends StatelessWidget {
  final String image;

  const _Avatar({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff00d4ff), Color(0xff4a3aff)],
        ),
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(radius: 10, backgroundImage: AssetImage(image)),
    );
  }
}
