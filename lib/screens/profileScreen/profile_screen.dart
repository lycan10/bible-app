import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/action_pill/action_pill_button.dart';
import 'package:quest/components/action_pill/action_pill_button_2.dart';
import 'package:quest/components/badges/badge_card.dart';
import 'package:quest/components/badges/metric_card.dart';
import 'package:quest/components/friends/friend_card_snippet.dart';
import 'package:quest/components/posts/post_card_long.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/screens/post/post_screen.dart';
import 'package:quest/screens/profileScreen/profile_settings.dart';
import 'package:quest/theme/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _navigateToProfileSettings(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) => ProfileSettings(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.scaled,
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToPostScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => PostScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.scaled,
            child: child,
          );
        },
      ),
    );
  }

  String selectedTab = "Posts";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Default country

    final List<Map<String, dynamic>> badges = [
      {
        "title": "Bronze",
        "progress": 0.2,
        "stat": "80% Left",
        "image": "assets/images/bronze.png",
      },
      {
        "title": "Silver",
        "progress": 0.5,
        "stat": "50% Left",
        "image": "assets/images/silver.png",
      },
      {
        "title": "Gold",
        "progress": 0.8,
        "stat": "20% Left",
        "image": "assets/images/gold.png",
      },
      {
        "title": "Platinum",
        "progress": 0.3,
        "stat": "70% Left",
        "image": "assets/images/platinum.png",
      },
      {
        "title": "Diamond",
        "progress": 0.6,
        "stat": "40% Left",
        "image": "assets/images/diamond.png",
      },
      {
        "title": "Master",
        "progress": 0.9,
        "stat": "10% Left",
        "image": "assets/images/ultimate.png",
      },
    ];
    final List<Map<String, dynamic>> metricData = [
      {"title": "Quiz", "stat": "24", "level": "5", "progress": 0.65},
      {"title": "Puzzle", "stat": "12", "level": "3", "progress": 0.40},
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Column(
            children: [
              TitleOne(
                leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                title: 'Profile',
                trailingIcon: HugeIcons.strokeRoundedSettings02,
                leadingIconTap: () {
                  Navigator.pop(context);
                },
                trailingIconTap: () => _navigateToProfileSettings(context),
              ),

              SizedBox(height: 25),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xff00d4ff), Color(0xff4a3aff)],
                              ),

                              borderRadius: BorderRadius.circular(
                                50,
                              ), // matches image roundness
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                50,
                              ), // half of image width/height
                              child: Image.asset(
                                'assets/images/boy.png',
                                width: 62,
                                height: 62,
                                fit: BoxFit.cover,
                              ),
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
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textColor2,
                                              fontSize: 12,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 13),
                                Row(
                                  children: [
                                    ActionPillButton(
                                      icon: HugeIcons.strokeRoundedSettings02,
                                      label: "Edit",
                                      onTap: () {},
                                    ),
                                    SizedBox(width: 10),
                                    ActionPillButton(
                                      icon: HugeIcons.strokeRoundedShare08,
                                      label: "Share",
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                                SizedBox(height: 30),
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

                      SizedBox(height: 30),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ActionPillButton2(
                            label: "Posts",
                            backgroundColor:
                                selectedTab == "Posts"
                                    ? Colors.black
                                    : Colors.transparent,
                            textColor:
                                selectedTab == "Posts"
                                    ? Colors.white
                                    : AppTheme.textColor2,
                            onTap: () {
                              setState(() => selectedTab = "Posts");
                            },
                          ),

                          ActionPillButton2(
                            label: "Friends",
                            backgroundColor:
                                selectedTab == "Friends"
                                    ? Colors.black
                                    : Colors.transparent,
                            textColor:
                                selectedTab == "Friends"
                                    ? Colors.white
                                    : AppTheme.textColor2,
                            onTap: () {
                              setState(() => selectedTab = "Friends");
                            },
                          ),

                          ActionPillButton2(
                            label: "Badges",
                            backgroundColor:
                                selectedTab == "Badges"
                                    ? Colors.black
                                    : Colors.transparent,
                            textColor:
                                selectedTab == "Badges"
                                    ? Colors.white
                                    : AppTheme.textColor2,
                            onTap: () {
                              setState(() => selectedTab = "Badges");
                            },
                          ),

                          ActionPillButton2(
                            label: "Metric",
                            backgroundColor:
                                selectedTab == "Metric"
                                    ? Colors.black
                                    : Colors.transparent,
                            textColor:
                                selectedTab == "Metric"
                                    ? Colors.white
                                    : AppTheme.textColor2,
                            onTap: () {
                              setState(() => selectedTab = "Metric");
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 25),

                      if (selectedTab == "Posts")
                        Column(
                          children: [
                            PostCardLong(
                              userName: "Lenny Olabisi",
                              userImage: "assets/images/boy.png",
                              postText:
                                  "Christian fellowship is a beautiful expression...",
                              groupName: "Lekki Christian Youths",
                              postImage: "assets/images/test.jpg",
                              likes: "370k",
                              comments: "29",
                              time: "Today 3:25pm",
                              onTap: () => _navigateToPostScreen(context),
                            ),
                            PostCardLong(
                              userName: "Lenny Olabisi",
                              userImage: "assets/images/boy.png",
                              postText:
                                  "Christian fellowship is a beautiful expression...",
                              groupName: "Lekki Christian Youths",
                              postImage: "assets/images/test.jpg",
                              likes: "370k",
                              comments: "29",
                              time: "Today 3:25pm",
                              onTap: () {},
                            ),
                            PostCardLong(
                              userName: "Lenny Olabisi",
                              userImage: "assets/images/boy.png",
                              postText:
                                  "Christian fellowship is a beautiful expression...",
                              groupName: "Lekki Christian Youths",
                              postImage: "assets/images/test.jpg",
                              likes: "370k",
                              comments: "29",
                              time: "Today 3:25pm",
                              onTap: () {},
                            ),
                            PostCardLong(
                              userName: "Lenny Olabisi",
                              userImage: "assets/images/boy.png",
                              postText:
                                  "Christian fellowship is a beautiful expression...",
                              groupName: "Lekki Christian Youths",
                              postImage: "assets/images/test.jpg",
                              likes: "370k",
                              comments: "29",
                              time: "Today 3:25pm",
                              onTap: () {},
                            ),
                          ],
                        ),

                      if (selectedTab == "Friends")
                        Column(
                          children: [
                            FriendCardSnippet(
                              userName: '@apple.bees',
                              userImage: "assets/images/boy.png",
                              fullName: "Apple Bees",
                            ),
                            FriendCardSnippet(
                              userName: '@apple.bees',
                              userImage: "assets/images/boy.png",
                              fullName: "Apple Bees",
                            ),
                            FriendCardSnippet(
                              userName: '@apple.bees',
                              userImage: "assets/images/boy.png",
                              fullName: "Apple Bees",
                            ),
                          ],
                        ),

                      if (selectedTab == "Badges")
                        Column(
                          children: [
                            GridView.count(
                              shrinkWrap: true,
                              physics:
                                  NeverScrollableScrollPhysics(), // if inside another scroll view
                              crossAxisCount: 3, // 3 columns
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio:
                                  0.8, // adjust to make cards taller/shorter
                              children:
                                  badges.map((badge) {
                                    return BadgeCard(
                                      title: badge["title"],
                                      progressStat: badge["stat"],
                                      badgeImage: badge["image"]!,
                                      progress: badge["progress"] as double,
                                    );
                                  }).toList(),
                            ),
                            SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,

                                      borderRadius: BorderRadius.circular(
                                        50,
                                      ), // matches image roundness
                                    ),
                                    child: ClipRRect(
                                      // half of image width/height
                                      child: Image.asset(
                                        'assets/images/light_bulb.png',
                                        width: 25,
                                        height: 25,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Unlock Badges',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          "Badges are earn when you stay consistent with you daily usage of Shalom App and completing milestones in your daily devotions, games, and activities",
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontSize: 12,
                                                color: AppTheme.textColor2,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                      if (selectedTab == "Metric")
                        GridView.count(
                          shrinkWrap: true,
                          physics:
                              NeverScrollableScrollPhysics(), // if inside another scroll view
                          crossAxisCount: 2, // 3 columns
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio:
                              0.75, // adjust to make cards taller/shorter
                          children:
                              metricData.map((metric) {
                                return MetricCard(
                                  title: metric["title"] as String,
                                  badgeStat: metric["stat"] as String,
                                  levelStat: metric["level"] as String,
                                  progress: metric["progress"] as double,
                                );
                              }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatText extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  final Color? labelColor;
  final FontWeight? valueWeight;
  final FontWeight? labelWeight;
  final double spacing;

  const StatText({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
    this.labelColor,
    this.valueWeight,
    this.labelWeight,
    this.spacing = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Row(
          children: [
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: valueWeight ?? FontWeight.bold,
                color: valueColor ?? Colors.black,
                fontSize: 14,
              ),
            ),
            SizedBox(width: spacing),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: labelWeight ?? FontWeight.normal,
                color: labelColor ?? Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        SizedBox(width: 8),
      ],
    );
  }
}
