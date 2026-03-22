import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/circle_stuff.dart';
import 'package:quest/components/menu/discover_more.dart';
import 'package:quest/components/tile/community_image_tile.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/section_header.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/components/user_details/community_profile_card.dart';
import 'package:quest/screens/community/community_individual_screen.dart';
import 'package:quest/screens/post/post_screen.dart';
import 'package:quest/theme/theme.dart';

final List<Map<String, String>> posts = [
  {
    "userName": "Lenny Olabisi",
    "userImage": "assets/images/boy.png",
    "postText":
        "Christian fellowship is a beautiful expression of faith and unity.",
    "groupName": "Lekki Christian Youths",
    "postImage": "assets/images/test.jpg",
    "likes": "370k",
    "comments": "29",
    "time": "Today 3:25pm",
  },
  {
    "userName": "Sarah Johnson",
    "userImage": "assets/images/boy.png",
    "postText": "Sunday service was powerful today. Feeling blessed!",
    "groupName": "Faith Builders",
    "postImage": "assets/images/test.jpg",
    "likes": "120k",
    "comments": "15",
    "time": "Today 1:10pm",
  },
  {
    "userName": "Michael Ade",
    "userImage": "assets/images/boy.png",
    "postText": "Prayer changes everything. Never stop believing.",
    "groupName": "Prayer Warriors",
    "postImage": "assets/images/test.jpg",
    "likes": "92k",
    "comments": "8",
    "time": "Today 12:05pm",
  },
  {
    "userName": "David Smith",
    "userImage": "assets/images/boy.png",
    "postText": "Grateful for another day to serve God.",
    "groupName": "Global Fellowship",
    "postImage": "assets/images/test.jpg",
    "likes": "54k",
    "comments": "4",
    "time": "Today 10:40am",
  },
];

class CommunityListScreen extends StatelessWidget {
  const CommunityListScreen({super.key});

  void _navigateToPostScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) => const PostScreen(),
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

  void _navigateToCommunityScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const CommunityIndividualScreen(),
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
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Center(child: _PostListMenuDialogBox());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          children: [
            /// TITLE BAR
            TitleOne(
              leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
              title: 'Communities',
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
                              hintText: "Search communities",
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
            const SectionHeader(
              title: "Your communities",
              seeAllText: 'see more',
            ),

            const SizedBox(height: 15),

            /// COMMUNITY LIST
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: CircleStuff(
                      onTap: () => _navigateToCommunityScreen(context),
                      width: 100,
                      height: 100,
                      title: 'Lekki Christians',
                      description: '2898',
                    ),
                  );
                },
              ),
            ),
            const SectionHeader(
              title: "Communities in Lekki",
              seeAllText: 'see more',
            ),

            /// POSTS
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: 2,
              itemBuilder: (context, index) {
                final post = posts[index];

                return CommunityImageTile(
                  name: "Lekki Christain Youth $index",
                  message: "Random message from user $index",
                  imagePath: "assets/images/user_test.jpg",
                  trailing: Text(
                    "${index + 1}m",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  // onLongPress: () {
                  //   showModalBottomSheet(
                  //     context: context,
                  //     isScrollControlled: true,
                  //     backgroundColor: Colors.transparent,
                  //     builder: (context) {
                  //       return _ChatPressedOption();
                  //     },
                  //   );
                  // },
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) {
                        return CommunityProfileCard();
                      },
                    );
                  },
                );
              },
            ),
            const SectionHeader(
              title: "Suggested communities",
              seeAllText: 'see more',
            ),

            /// POSTS
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];

                return CommunityImageTile(
                  name: "Lekki Christain Youth $index",
                  message: "Random message from user $index",
                  imagePath: "assets/images/user_test.jpg",
                  trailing: Text(
                    "${index + 1}m",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  // onLongPress: () {
                  //   showModalBottomSheet(
                  //     context: context,
                  //     isScrollControlled: true,
                  //     backgroundColor: Colors.transparent,
                  //     builder: (context) {
                  //       return _ChatPressedOption();
                  //     },
                  //   );
                  // },
                  onTap: () => _navigateToCommunityScreen(context),
                );
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
