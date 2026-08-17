import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/action_pill/action_pill_button.dart';
import 'package:quest/screens/profileScreen/profile_screen.dart';
import 'package:quest/theme/theme.dart';

class CommunityProfileCard2 extends StatelessWidget {
  final Map<String, dynamic> community;
  final bool isMember;
  final VoidCallback onToggleMembership;

  const CommunityProfileCard2({
    super.key,
    required this.community,
    required this.isMember,
    required this.onToggleMembership,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    50,
                  ), // half of image width/height
                  child:
                      community['image'] != null
                          ? CachedNetworkImage(imageUrl: community['image'],
                            width: 75,
                            height: 75,
                            fit: BoxFit.cover,
                          )
                          : Image.asset(
                            "assets/images/boy.png",
                            width: 75,
                            height: 75,
                            fit: BoxFit.cover,
                          ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 2.5,
                          ),
                          children: [
                            TextSpan(
                              text: "\${community['name'] ?? 'Community'}\\n",
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          StatText(
                            value: "\${community['_count']?['members'] ?? 0}",
                            label: "Members",
                          ),
                          StatText(
                            value: "\${community['_count']?['events'] ?? 0}",
                            label: "Events",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: ActionPillButton(
                    icon:
                        isMember
                            ? HugeIcons.strokeRoundedCheckmarkBadge01
                            : HugeIcons.strokeRoundedUserAdd01,
                    label: isMember ? "Leave community" : "Join community",
                    backgroundColor: isMember ? Colors.white : Colors.black,
                    textColor: isMember ? Colors.black : Colors.white,
                    onTap: onToggleMembership,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ActionPillButton(
                    icon: HugeIcons.strokeRoundedShare08,
                    label: "Share community",
                    onTap: () {},
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            Text(
              community['description'] ?? 'No description available.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 13,
                color: AppTheme.textColor2,
              ),
            ),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
