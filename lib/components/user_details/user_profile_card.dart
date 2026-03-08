import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/action_pill/action_pill_button.dart';
import 'package:quest/components/community/community_card_snippet.dart';
import 'package:quest/screens/profileScreen/profile_screen.dart';
import 'package:quest/theme/theme.dart';

class UserProfileCard extends StatelessWidget {
  const UserProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Default country
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
                  child: Image.asset(
                    "assets/images/user_test.jpg",
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
                            TextSpan(text: 'Lenny Daniels\n'),

                            TextSpan(
                              text: '@lenny123',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textColor2,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          StatText(value: "23", label: "Friends"),
                          StatText(value: "14", label: "Badges"),
                          StatText(value: "5", label: "Communities"),
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
                ActionPillButton(
                  icon: HugeIcons.strokeRoundedMessage01,
                  label: "Chat",
                  onTap: () {},
                ),
                SizedBox(width: 10),
                ActionPillButton(
                  icon: HugeIcons.strokeRoundedShare08,
                  label: "Share",
                  onTap: () {},
                ),
                SizedBox(width: 10),
                ActionPillButton(
                  backgroundColor: AppTheme.redColor,
                  icon: HugeIcons.strokeRoundedSecurity,
                  iconColor: Colors.white,
                  textColor: Colors.white,
                  label: "Block",
                  onTap: () {
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: "Block",
                      barrierColor: Colors.black.withValues(alpha: 0.4),
                      transitionDuration: Duration(milliseconds: 250),
                      pageBuilder:
                          (_, __, ___) => Center(child: _BlockUserDialog()),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 25),
            Text(
              "You and Apple are in 3 communities together",
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 13,
                color: AppTheme.textColor2,
              ),
            ),

            SizedBox(height: 25),
            Column(
              children: [
                CommunityCardSnippet(
                  communityName: 'Lekki Christain Youth',
                  description: 'Meet young vibrant youths',
                  communityImage: "assets/images/test.jpg",
                ),
                CommunityCardSnippet(
                  communityName: 'Lekki Christain Youth',
                  description: 'Meet young vibrant youths',
                  communityImage: "assets/images/test.jpg",
                ),
                CommunityCardSnippet(
                  communityName: 'Lekki Christain Youth',
                  description: 'Meet young vibrant youths',
                  communityImage: "assets/images/test.jpg",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockUserDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15),

            Text(
              "Block User",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 16,
              ),
            ),

            SizedBox(height: 10),

            Text(
              "Are you sure you want to block this user? They will not be able to contact you.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textColor2,
                fontSize: 13,
              ),
            ),

            SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.buttonColor2,
                        borderRadius: BorderRadius.circular(50),
                      ),

                      child: Text(
                        "Yes, block account",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.redColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.buttonColor2,
                        borderRadius: BorderRadius.circular(50),
                      ),

                      child: Text(
                        "Cancel",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
