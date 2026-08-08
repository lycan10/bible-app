import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/user_details/user_profile_card.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/components/avatar.dart';

class FriendCardSnippet extends StatelessWidget {
  final String userName;
  final String fullName;
  final String userImage;

  const FriendCardSnippet({
    super.key,
    required this.userName,
    required this.userImage,
    required this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            UserProfileCard.show(context);
          },
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(width: 1, color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomAvatar(imageUrl: userImage, radius: 26.0, hasBorder: true),
                    const SizedBox(width: 10),
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(text: '$fullName\n'),
                          TextSpan(
                            text: userName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textColor2,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
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
        const SizedBox(height: 10),
      ],
    );
  }
}
