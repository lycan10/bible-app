import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:quest/components/connect/connect_card.dart';
import 'package:quest/components/media/audio/audio_reel_card.dart';
import 'package:quest/components/media/video/video_card.dart';
import 'package:quest/components/menu/discover_more.dart';
import 'package:quest/components/posts/post_card.dart';
import 'package:quest/components/posts/post_card_short.dart';
import 'package:quest/components/sponsored/sponsored_post.dart';
import 'package:quest/components/sponsored/sponsored_post_card.dart';
import 'package:quest/components/sponsored/sponsored_video.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/section_header.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/screens/media/audio_reel_screen.dart';
import 'package:quest/screens/media/video_reel_screen.dart';

import 'package:quest/screens/post/post_list.dart';
import 'package:quest/screens/post/post_screen.dart';

import 'package:quest/theme/theme.dart';
import 'package:hugeicons/hugeicons.dart';

final List<Widget> connectCards = [
  ConnectCard(
    name: "Ike",
    username: "@alice_smith",
    imagePath: "assets/images/user_test.jpg",
  ),
  ConnectCard(
    name: "Emma",
    username: "@emma_jones",
    imagePath: "assets/images/user_test.jpg",
  ),
  ConnectCard(
    name: "Liam",
    username: "@liam_brown",
    imagePath: "assets/images/user_test.jpg",
  ),
  ConnectCard(
    name: "Olivia",
    username: "@olivia_clark",
    imagePath: "assets/images/user_test.jpg",
  ),
  ConnectCard(
    name: "Noah",
    username: "@noah_davis",
    imagePath: "assets/images/user_test.jpg",
  ),
  ConnectCard(
    name: "Ava",
    username: "@ava_miller",
    imagePath: "assets/images/user_test.jpg",
  ),
  ConnectCard(
    name: "Elijah",
    username: "@elijah_wilson",
    imagePath: "assets/images/user_test.jpg",
  ),
  ConnectCard(
    name: "Sophia",
    username: "@sophia_moore",
    imagePath: "assets/images/user_test.jpg",
  ),
  ConnectCard(
    name: "Mason",
    username: "@mason_taylor",
    imagePath: "assets/images/user_test.jpg",
  ),
  ConnectCard(
    name: "Isabella",
    username: "@isabella_anderson",
    imagePath: "assets/images/user_test.jpg",
  ),
  ConnectCard(
    name: "Logan",
    username: "@logan_thomas",
    imagePath: "assets/images/user_test.jpg",
  ),
  ConnectCard(
    name: "Mia",
    username: "@mia_jackson",
    imagePath: "assets/images/user_test.jpg",
  ),
  ConnectCard(
    name: "Lucas",
    username: "@lucas_white",
    imagePath: "assets/images/user_test.jpg",
  ),
  ConnectCard(
    name: "Charlotte",
    username: "@charlotte_harris",
    imagePath: "assets/images/user_test.jpg",
  ),
  ConnectCard(
    name: "Ethan",
    username: "@ethan_martin",
    imagePath: "assets/images/user_test.jpg",
  ),
];

class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

  void _openMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Filter",
      barrierColor: Colors.black.withOpacity(0.4),
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
        child: Padding(
          padding: const EdgeInsets.only(top: 15, left: 16, right: 16),

          child: ListView(
            children: [
              Column(
                children: [
                  TitleOne(
                    leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                    title: 'Connect',
                    trailingIcon: HugeIcons.strokeRoundedMoreVertical,
                    leadingIconTap: () => Navigator.pop(context),
                    trailingIconTap: () => _openMenu(context),
                  ),

                  SizedBox(height: 30),
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
                                    hintText: "Search messages",
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
                  SizedBox(height: 20),
                  Column(
                    children:
                        connectCards, // this adds all 15 cards in a column
                  ),
                ],
              ),
            ],
          ),
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
