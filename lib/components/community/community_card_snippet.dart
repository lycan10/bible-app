import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/components/avatar.dart';

class CommunityCardSnippet extends StatelessWidget {
  final String communityName;
  final String description;
  final String communityImage;

  const CommunityCardSnippet({
    super.key,
    required this.communityName,
    required this.description,
    required this.communityImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(width: 1, color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomAvatar(imageUrl: communityImage, radius: 20.5, hasBorder: true),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          communityName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),

                        Text(
                          description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textColor2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  size: 18,
                  color: AppTheme.textColor2,
                  strokeWidth: 2,
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
