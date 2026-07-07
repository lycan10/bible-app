import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/posts/post_card_long.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/title_one.dart';
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
  {
    "userName": "Grace Williams",
    "userImage": "assets/images/boy.png",
    "postText": "Bible study tonight was inspiring!",
    "groupName": "Women of Faith",
    "postImage": "assets/images/test.jpg",
    "likes": "76k",
    "comments": "13",
    "time": "Today 9:30am",
  },
  {
    "userName": "Daniel Brown",
    "userImage": "assets/images/boy.png",
    "postText": "Trust God even when you don’t understand.",
    "groupName": "Young Disciples",
    "postImage": "assets/images/test.jpg",
    "likes": "65k",
    "comments": "6",
    "time": "Yesterday",
  },
  {
    "userName": "Rebecca Adams",
    "userImage": "assets/images/boy.png",
    "postText": "Worship night was unforgettable!",
    "groupName": "City Worship",
    "postImage": "assets/images/test.jpg",
    "likes": "88k",
    "comments": "21",
    "time": "Yesterday",
  },
  {
    "userName": "Samuel Ojo",
    "userImage": "assets/images/boy.png",
    "postText": "God is faithful in every season.",
    "groupName": "Faith Connect",
    "postImage": "assets/images/test.jpg",
    "likes": "41k",
    "comments": "5",
    "time": "Yesterday",
  },
  {
    "userName": "Esther Collins",
    "userImage": "assets/images/boy.png",
    "postText": "Let love lead everything we do.",
    "groupName": "Kingdom Builders",
    "postImage": "assets/images/test.jpg",
    "likes": "59k",
    "comments": "10",
    "time": "Yesterday",
  },
  {
    "userName": "Joshua Lee",
    "userImage": "assets/images/boy.png",
    "postText": "Keep your faith strong and your heart humble.",
    "groupName": "Youth Revival",
    "postImage": "assets/images/test.jpg",
    "likes": "33k",
    "comments": "7",
    "time": "2 days ago",
  },
];

class PostList extends StatelessWidget {
  const PostList({super.key});

  void _navigateToPostScreen(BuildContext context, Map<String, dynamic> post) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) => PostScreen(post: post),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            children: [
              TitleOne(
                leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                title: 'Post',
                trailingIcon: HugeIcons.strokeRoundedMoreVertical,
                leadingIconTap: () {
                  Navigator.pop(context);
                },
                trailingIconTap: () {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: "Filter",
                    barrierColor: Colors.black.withValues(alpha: 0.4),
                    transitionDuration: const Duration(milliseconds: 250),
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return Center(child: _PostListMenuDialogBox());
                    },
                  );
                },
              ),
              SizedBox(height: 25),
              Expanded(
                child: ListView.builder(
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
                      onTap: () => _navigateToPostScreen(context, post),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostListMenuDialogBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15),
            SettingsSwitchRow(
              icon: HugeIcons.strokeRoundedNotification01,
              title: 'Allow notificationa',
              subtitle: 'Turn on or off',
              switchValue: false,
            ),
            SettingsSwitchRow(
              icon: HugeIcons.strokeRoundedSmartPhone03,
              title: 'Haptic Feedback',
              subtitle: 'Turn on haptick feedback',
              switchValue: false,
            ),
          ],
        ),
      ),
    );
  }
}
