import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/user_details/user_profile_card.dart';
import 'package:quest/theme/theme.dart';

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
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return UserProfileCard();
              },
            );
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
                    _Avatar(image: userImage),
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
      width: 52,
      height: 52,
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
