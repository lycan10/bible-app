import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/action_pill/action_pill_button.dart';
import 'package:quest/components/action_pill/action_pill_button_2.dart';
import 'package:quest/components/event/event_details_card.dart';
import 'package:quest/components/event/event_dotted_card.dart';
import 'package:quest/components/posts/post_card.dart';
import 'package:quest/components/posts/post_card_long.dart';
import 'package:quest/components/posts/post_card_short.dart';
import 'package:quest/components/tile/settings_row_item.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/section_header.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/components/today_verse_glass.dart';
import 'package:quest/components/user_details/community_profile_card_2.dart';
import 'package:quest/screens/post/new_post_screen.dart';
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
  // Add other posts...
];

class CommunityIndividualScreen extends StatefulWidget {
  const CommunityIndividualScreen({super.key});

  @override
  State<CommunityIndividualScreen> createState() =>
      _CommunityIndividualScreenState();
}

class _CommunityIndividualScreenState extends State<CommunityIndividualScreen> {
  String selectedTab = "Space";

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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE BAR
                TitleOne(
                  leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                  title: 'Lekki...Community',
                  trailingIcon: HugeIcons.strokeRoundedMoreVertical,
                  leadingIconTap: () => Navigator.pop(context),
                  trailingIconTap: () => _openMenu(context),
                ),
                const SizedBox(height: 25),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Menu / List Icon Button

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

                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return NewPostScreen();
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedAdd01,
                          size: 22,
                          color: Colors.white,
                          strokeWidth: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                /// Community Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        "assets/images/user_test.jpg",
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lekki Christian Youth',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Connect with fellow young Christians in Lekki! Share your faith, grow spiritually, and build lasting friendships...',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textColor2,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return CommunityProfileCard2();
                                },
                              );
                            },
                            child: Text(
                              'See more',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.purpleColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                /// Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionPillButton2(
                        icon: HugeIcons.strokeRoundedGlobe02,
                        iconColor:
                            selectedTab == "Space"
                                ? Colors.white
                                : Colors.black,
                        label: "Space",
                        backgroundColor:
                            selectedTab == "Space"
                                ? Colors.black
                                : Colors.transparent,
                        textColor:
                            selectedTab == "Space"
                                ? Colors.white
                                : AppTheme.textColor2,
                        onTap: () => setState(() => selectedTab = "Space"),
                      ),
                      const SizedBox(width: 10),
                      ActionPillButton2(
                        icon: HugeIcons.strokeRoundedUserGroup,
                        iconColor:
                            selectedTab == "Forum"
                                ? Colors.white
                                : Colors.black,
                        label: "Forum",
                        backgroundColor:
                            selectedTab == "Forum"
                                ? Colors.black
                                : Colors.transparent,
                        textColor:
                            selectedTab == "Forum"
                                ? Colors.white
                                : AppTheme.textColor2,
                        onTap: () => setState(() => selectedTab = "Forum"),
                      ),
                      const SizedBox(width: 10),
                      ActionPillButton2(
                        icon: HugeIcons.strokeRoundedMessage02,
                        iconColor:
                            selectedTab == "Messages"
                                ? Colors.white
                                : Colors.black,
                        label: "Messages",
                        backgroundColor:
                            selectedTab == "Messages"
                                ? Colors.black
                                : Colors.transparent,
                        textColor:
                            selectedTab == "Messages"
                                ? Colors.white
                                : AppTheme.textColor2,
                        onTap: () => setState(() => selectedTab = "Messages"),
                      ),
                      const SizedBox(width: 10),
                      ActionPillButton2(
                        icon: HugeIcons.strokeRoundedCalendar02,
                        iconColor:
                            selectedTab == "Event"
                                ? Colors.white
                                : Colors.black,
                        label: "Event",
                        backgroundColor:
                            selectedTab == "Event"
                                ? Colors.black
                                : Colors.transparent,
                        textColor:
                            selectedTab == "Event"
                                ? Colors.white
                                : AppTheme.textColor2,
                        onTap: () => setState(() => selectedTab = "Event"),
                      ),
                    ],
                  ),
                ),

                if (selectedTab == "Space")
                  Column(
                    children: [
                      const SizedBox(height: 25),
                      TodayVerseGlass(),

                      const SectionHeader(
                        title: "Today's Messages",
                        showSeeAll: false,
                      ),
                      PostCard(),
                      const SectionHeader(title: "Posts", showSeeAll: false),

                      /// POSTS LIST
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          return PostCardLong(
                            userName: post["userName"]!,
                            userImage: post["userImage"]!,
                            postText: post["postText"]!,
                            groupName: post["groupName"]!,
                            postImage: post["postImage"]!,
                            likes: post["likes"]!,
                            comments: post["comments"]!,
                            time: post["time"]!,
                            onTap: () => _navigateToPostScreen(context),
                          );
                        },
                      ),
                    ],
                  ),

                if (selectedTab == "Messages")
                  Column(
                    children: [
                      SizedBox(height: 25),

                      PostCardShort(
                        postText:
                            "Christian fellowship is a beautiful expression...",
                        author: "Lekki Christian Youths",
                        postImage: "assets/images/test.jpg",
                        likes: "370k",
                        comments: "29",
                        time: "Today 3:25pm",
                        onTap: () => _navigateToPostScreen(context),
                      ),
                      PostCardShort(
                        postText:
                            "Christian fellowship is a beautiful expression...",
                        author: "Lekki Christian Youths",
                        postImage: "assets/images/test.jpg",
                        likes: "370k",
                        comments: "29",
                        time: "Today 3:25pm",
                        onTap: () {},
                      ),
                      PostCardShort(
                        postText:
                            "Christian fellowship is a beautiful expression...",
                        author: "Lekki Christian Youths",
                        postImage: "assets/images/test.jpg",
                        likes: "370k",
                        comments: "29",
                        time: "Today 3:25pm",
                        onTap: () {},
                      ),
                      PostCardShort(
                        postText:
                            "Christian fellowship is a beautiful expression...",
                        author: "Lekki Christian Youths",
                        postImage: "assets/images/test.jpg",
                        likes: "370k",
                        comments: "29",
                        time: "Today 3:25pm",
                        onTap: () {},
                      ),
                      PostCardShort(
                        postText:
                            "Christian fellowship is a beautiful expression...",
                        author: "Lekki Christian Youths",
                        postImage: "assets/images/test.jpg",
                        likes: "370k",
                        comments: "29",
                        time: "Today 3:25pm",
                        onTap: () {},
                      ),
                      PostCardShort(
                        postText:
                            "Christian fellowship is a beautiful expression...",
                        author: "Lekki Christian Youths",
                        postImage: "assets/images/test.jpg",
                        likes: "370k",
                        comments: "29",
                        time: "Today 3:25pm",
                        onTap: () {},
                      ),
                    ],
                  ),

                if (selectedTab == "Event")
                  Column(
                    children: [
                      SectionHeader(
                        title: "All event",
                        seeAllText: "Filter",
                        onSeeAllTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return _EventFilterOption();
                            },
                          );
                        },
                      ),
                      SizedBox(height: 5),

                      EventDottedCard(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return EventDetailsCard();
                            },
                          );
                        },
                      ),
                      EventDottedCard(onTap: () {}),
                      EventDottedCard(onTap: () {}),
                      EventDottedCard(onTap: () {}),
                      EventDottedCard(onTap: () {}),
                    ],
                  ),
              ],
            ),
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

class _EventFilterOption extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: AppTheme.textColor2.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          SizedBox(height: 25),
          SettingsRowItem(
            iconBackgroundColor: Colors.transparent,
            title: 'Attending',
            iconColor: AppTheme.textColor2,
          ),
          SettingsRowItem(
            iconBackgroundColor: Colors.transparent,
            title: 'Not attending',
            iconColor: AppTheme.textColor2,
          ),
          SettingsRowItem(
            iconBackgroundColor: Colors.transparent,
            title: 'Upcoming',
            iconColor: AppTheme.textColor2,
          ),
          SettingsRowItem(
            iconBackgroundColor: Colors.transparent,
            title: 'Not interested',
            iconColor: AppTheme.textColor2,
          ),
        ],
      ),
    );
  }
}
