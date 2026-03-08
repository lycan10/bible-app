import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';

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
                    _Avatar(image: communityImage),
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

class _Avatar extends StatelessWidget {
  final String image;

  const _Avatar({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 41,
      height: 41,
      padding: const EdgeInsets.all(0),
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
