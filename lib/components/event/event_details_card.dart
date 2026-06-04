import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/action_pill/action_pill_button.dart';
import 'package:quest/components/avatar.dart';
import 'package:quest/theme/theme.dart';

class EventDetailsCard extends StatelessWidget {
  const EventDetailsCard({super.key});

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
          crossAxisAlignment: CrossAxisAlignment.center,
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
            SizedBox(height: 20),
            Text(
              "Tech conference 2026",
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Connect with fellow young Christians in Lekki! Share your faith, grow spiritually, and build lasting friendships in a supportive community. Join us for events, discussions, and opportunities to make a difference together.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 13,
                color: AppTheme.textColor2,
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 58,
                  height: 23,
                  child: Stack(
                    children: const [
                      Positioned(
                        left: 0,
                        child: Avatar(image: 'assets/images/boy.png'),
                      ),
                      Positioned(
                        left: 15,
                        child: Avatar(image: 'assets/images/boy.png'),
                      ),
                      Positioned(
                        left: 30,
                        child: Avatar(image: 'assets/images/boy.png'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  "23 others are attending",
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: AppTheme.textColor2,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.buttonColor2.withValues(alpha: 0.3),
                border: Border.all(width: 0.5, color: AppTheme.buttonColor2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar04,
                    size: 16,
                    color: Color(0xff8e8e93),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '24',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'June 20',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 10, // 👈 controls vertical line height
                    child: VerticalDivider(
                      thickness: 1.5, // 👈 line width
                      color: AppTheme.textColor2.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedClock01,
                    size: 16,
                    color: Color(0xff8e8e93),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '12pm - 3pm',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),
            ActionPillButton(
              backgroundColor: Colors.black,
              textColor: Colors.white,
              label: "Attend Event ",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

