import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/titles/title_two.dart';
import 'package:quest/theme/theme.dart';

class CommunityGuidelines extends StatelessWidget {
  final String title;
  final String description;

  const CommunityGuidelines({
    super.key,
    this.title = "Community Guidelines",
    this.description =
        "Connect with fellow young Christians in Lekki! Share your faith, grow spiritually, and build lasting friendships in a supportive community.\n\n"
            "Join us for events, discussions, and opportunities to make a difference together. Build meaningful relationships and grow deeper in your walk with Christ.\n\n"
            "Respect others, encourage one another, and create a safe space where everyone feels valued and heard.\n\n"
            "Stay active, participate in conversations, and be a light within the community."
            "Join us for events, discussions, and opportunities to make a difference together. Build meaningful relationships and grow deeper in your walk with Christ.\n\n"
            "Join us for events, discussions, and opportunities to make a difference together. Build meaningful relationships and grow deeper in your walk with Christ.\n\n"
            "Join us for events, discussions, and opportunities to make a difference together. Build meaningful relationships and grow deeper in your walk with Christ.\n\n",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleTwo(leadingIcon: HugeIcons.strokeRoundedCancel01, title: title),

          const SizedBox(height: 25),

          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 13,
              color: AppTheme.textColor2,
            ),
          ),
        ],
      ),
    );
  }
}
