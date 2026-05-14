import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/circle_stuff.dart';
import 'package:quest/components/media/video/video_card.dart';
import 'package:quest/components/menu/discover_more.dart';
import 'package:quest/components/tile/community_image_tile.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/section_header.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/components/user_details/community_profile_card.dart';
import 'package:quest/screens/books/book_screen.dart';
import 'package:quest/screens/community/community_individual_screen.dart';
import 'package:quest/screens/explore/explore_screen.dart';
import 'package:quest/screens/post/post_screen.dart';
import 'package:quest/screens/media/video_reel_screen.dart';
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

class BooksListScreen extends StatelessWidget {
  const BooksListScreen({super.key});

  void _navigateToBookScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => BookScreen(),
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
              title: 'Books',
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
            SectionHeader(title: "Sponsored", seeAllText: "See more"),
            SizedBox(
              height: 200,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),

                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return BooksReelCard(
                    title: 'The Battle',
                    author: 'Joyce Meyer',
                    likes: '300k',
                    backgroundImage: 'assets/images/book.jpeg',
                    onTap: () {
                      _navigateToBookScreen(context);
                    },
                  );
                },
              ),
            ),
            SectionHeader(title: "Best Sellers", seeAllText: "See all"),
            SizedBox(
              height: 200,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),

                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return BooksReelCard(
                    title: 'The Battle',
                    author: 'Joyce Meyer',
                    likes: '300k',
                    backgroundImage: 'assets/images/book.jpeg',
                    onTap: () {},
                  );
                },
              ),
            ),
            SectionHeader(title: "More Books", seeAllText: "See all"),
            GridView.builder(
              shrinkWrap: true, // ✅ IMPORTANT
              physics:
                  const NeverScrollableScrollPhysics(), // ✅ disables inner scroll
              itemCount: 10,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                return BooksReelCard(
                  title: 'The Battle',
                  author: 'Joyce Meyer',
                  likes: '300k',
                  backgroundImage: 'assets/images/book.jpeg',
                  onTap: () {},
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
