import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/devotion/ongoing_devotion_card.dart';
import 'package:quest/components/menu/discover_more.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/section_header.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/components/titles/title_two.dart';
import 'package:quest/screens/devotion/devotion_article_card.dart';
import 'package:quest/screens/devotion/devotion_screen.dart';

import 'package:quest/theme/theme.dart';

class DevotionListScreen extends StatelessWidget {
  const DevotionListScreen({super.key});

  void _navigateToDevotionScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) => DevotionScreen(),
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

  void _openMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Filter",
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Center(child: _PostListMenuDialogBox());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          children: [
            /// TITLE BAR
            TitleOne(
              leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
              title: 'Devotions',
              trailingIcon: HugeIcons.strokeRoundedMoreVertical,
              leadingIconTap: () => Navigator.pop(context),
              trailingIconTap: () => _openMenu(context),
            ),

            const SizedBox(height: 25),

            // SearchBar(
            //   hintText: "Search communities",
            //   onTap: () {
            //     showModalBottomSheet(
            //       context: context,
            //       isScrollControlled: true,
            //       backgroundColor: Colors.transparent,
            //       builder: (context) {
            //         return DiscoverMore();
            //       },
            //     );
            //   },
            //   onChanged: (value) {
            //     print("Searching: $value");
            //   },
            // ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// Menu / List Icon Button
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return DiscoverMore();
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedLeftToRightListBullet,
                      size: 22,
                      color: Colors.black,
                      strokeWidth: 1,
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                /// Search Bar
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01,
                          size: 18,
                          color: AppTheme.textColor2,
                        ),

                        const SizedBox(width: 8),

                        /// Search Input
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: "Search for books",
                              border: InputBorder.none,
                              isDense: true,
                              hintStyle: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            /// HEADER
            SizedBox(height: 25),
            OngoingDevotionCard(
              title: "Build Your Faith in 2026",
              author: "Shalom",
              imagePath: "assets/images/user_test.jpg",
              likes: "385",
              planText: "- 365 Days Plan",
              day: 4,
              onContinue: () => _navigateToDevotionScreen(context),
            ),
            SectionHeader(title: "Trending now", seeAllText: "See more"),
            DevotionArticleCard(
              title: "Understanding Grace and Forgiveness",
              description:
                  "A weekly email with our favorite articles about design, front-end development, technology, and start",
              author: "Believer's Journal",
              imagePath: "assets/images/user_test.jpg",
              likes: "385",
              tag: "365 Days Plan",
              onTap: () {
                showStartPlanModal(
                  context: context,
                  planTitle: "Understanding Grace and Forgiveness",
                  planImagePath: "assets/images/alucard.png",
                  authorName: "Lola Able",
                  authorHandle: "@lola.a",
                  reminderText: "Set daily reminder",
                  reminderTime: "9:41 AM",
                  onStart: () => _navigateToDevotionScreen(context),
                );
              },
            ),
            SizedBox(height: 10),
            DevotionArticleCard(
              title: "Understanding Grace and Forgiveness",
              description:
                  "A weekly email with our favorite articles about design, front-end development, technology, and start",
              author: "Believer's Journal",
              imagePath: "assets/images/user_test.jpg",
              likes: "385",
              tag: "365 Days Plan",
              onTap: () {
                showStartPlanModal(
                  context: context,
                  planTitle: "Understanding Grace and Forgiveness",
                  planImagePath: "assets/images/alucard.png",
                  authorName: "Lola Able",
                  authorHandle: "@lola.a",
                  reminderText: "Set daily reminder",
                  reminderTime: "9:41 AM",
                  onStart: () => _navigateToDevotionScreen(context),
                );
              },
            ),
            SectionHeader(title: "Suggested for you", seeAllText: "See more"),
            DevotionArticleCard(
              title: "Understanding Grace and Forgiveness",
              description:
                  "A weekly email with our favorite articles about design, front-end development, technology, and start",
              author: "Believer's Journal",
              imagePath: "assets/images/user_test.jpg",
              likes: "385",
              tag: "365 Days Plan",
              onTap: () {
                print("Read tapped");
              },
            ),
            SizedBox(height: 10),
            DevotionArticleCard(
              title: "Understanding Grace and Forgiveness",
              description:
                  "A weekly email with our favorite articles about design, front-end development, technology, and start",
              author: "Believer's Journal",
              imagePath: "assets/images/user_test.jpg",
              likes: "385",
              tag: "365 Days Plan",
              onTap: () {
                print("Read tapped");
              },
            ),
            DevotionArticleCard(
              title: "Understanding Grace and Forgiveness",
              description:
                  "A weekly email with our favorite articles about design, front-end development, technology, and start",
              author: "Believer's Journal",
              imagePath: "assets/images/user_test.jpg",
              likes: "385",
              tag: "365 Days Plan",
              onTap: () {
                print("Read tapped");
              },
            ),
            SizedBox(height: 10),
            DevotionArticleCard(
              title: "Understanding Grace and Forgiveness",
              description:
                  "A weekly email with our favorite articles about design, front-end development, technology, and start",
              author: "Believer's Journal",
              imagePath: "assets/images/user_test.jpg",
              likes: "385",
              tag: "365 Days Plan",
              onTap: () {
                print("Read tapped");
              },
            ),
            DevotionArticleCard(
              title: "Understanding Grace and Forgiveness",
              description:
                  "A weekly email with our favorite articles about design, front-end development, technology, and start",
              author: "Believer's Journal",
              imagePath: "assets/images/user_test.jpg",
              likes: "385",
              tag: "365 Days Plan",
              onTap: () {
                print("Read tapped");
              },
            ),
            SizedBox(height: 10),
            DevotionArticleCard(
              title: "Understanding Grace and Forgiveness",
              description:
                  "A weekly email with our favorite articles about design, front-end development, technology, and start",
              author: "Believer's Journal",
              imagePath: "assets/images/user_test.jpg",
              likes: "385",
              tag: "365 Days Plan",
              onTap: () {
                print("Read tapped");
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PostListMenuDialogBox extends StatelessWidget {
  const _PostListMenuDialogBox();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(height: 15),
            SettingsSwitchRow(
              icon: HugeIcons.strokeRoundedAiVideo,
              title: 'Auto Scroll',
              subtitle: 'Turn on video autoplay',
              switchValue: false,
            ),
            SettingsSwitchRow(
              icon: HugeIcons.strokeRoundedNotification01,
              title: 'Allow notifications',
              subtitle: 'Turn on or off',
              switchValue: false,
            ),
            SettingsSwitchRow(
              icon: HugeIcons.strokeRoundedSmartPhone03,
              title: 'Haptic Feedback',
              subtitle: 'Turn on haptic feedback',
              switchValue: false,
            ),
          ],
        ),
      ),
    );
  }
}

class MediaCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String author;
  final String likes;
  final VoidCallback? onTap;

  const MediaCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.author,
    required this.likes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 215,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              /// 🔹 Background Image
              Image.asset(imagePath, fit: BoxFit.cover),

              /// 🔹 Gradient Overlay (better UI)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),

              /// 🔹 Bottom Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// LEFT CONTENT
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4),

                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'From: ',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 12,
                                      color: Colors.white70,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  TextSpan(
                                    text: author,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 6),

                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white30,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.favorite_border,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  likes,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      /// PLAY BUTTON
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.5,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
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

/// Reusable function to show the Start Plan modal
void showStartPlanModal({
  required BuildContext context,
  required String planTitle,
  required String planImagePath,
  required String authorName,
  required String authorHandle,
  String reminderText = "Set daily reminder",
  String reminderTime = "9:41 AM",
  required VoidCallback onStart,
}) {
  final theme = Theme.of(context);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            TitleTwo(
              leadingIcon: HugeIcons.strokeRoundedCancel01,
              title: 'Start Plan',
            ),
            const SizedBox(height: 20),

            // Plan Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                planImagePath,
                width: 62,
                height: 62,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 5),

            // Plan Title
            SizedBox(
              width: 300,
              child: Text(
                planTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 19,
                ),
              ),
            ),
            const SizedBox(height: 3),

            // Duration
            Text(
              '365 days',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),

            // Author Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    'assets/images/user_test.jpg', // optional: make dynamic
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      authorHandle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: AppTheme.textColor2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Reminder Row
            Row(
              children: [
                // Reminder (expanded)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff673aff).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      reminderText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff673aff),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Reminder time
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    reminderTime,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Start button
            GestureDetector(
              onTap: onStart,
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      "Start",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      );
    },
  );
}
