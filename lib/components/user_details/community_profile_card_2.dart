import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/action_pill/action_pill_button.dart';
import 'package:quest/screens/profileScreen/profile_screen.dart';
import 'package:quest/theme/theme.dart';

class CommunityProfileCard2 extends StatelessWidget {
  const CommunityProfileCard2({super.key});

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
                            TextSpan(text: 'Lekki Christian Youth\n'),

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
                          StatText(value: "23k", label: "Members"),
                          StatText(value: "2", label: "Events"),
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
                    icon: HugeIcons.strokeRoundedShare08,
                    label: "Share community",
                    onTap: () {},
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            Text(
              "Connect with fellow young Christians in Lekki! Share your faith, grow spiritually, and build lasting friendships in a supportive community. Join us for events, discussions, and opportunities to make a difference together.",
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
