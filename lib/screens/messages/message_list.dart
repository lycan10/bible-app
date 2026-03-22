import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/tile/settings_row_item.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/tile/user_list_tile.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/components/titles/title_two.dart';
import 'package:quest/screens/messages/message_chat_screen.dart';
import 'package:quest/theme/theme.dart';

class MessageList extends StatelessWidget {
  const MessageList({super.key});

  void _navigateToChatScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) => MessageChatScreen(),
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            children: [
              TitleOne(
                leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                title: 'Chat',
                trailingIcon: HugeIcons.strokeRoundedMoreVertical,
                leadingIconTap: () {
                  Navigator.pop(context);
                },
                trailingIconTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return _ChatMenuOption();
                    },
                  );
                },
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 50, // adjust based on your pill height
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 5, // total number of users
                  separatorBuilder: (_, __) => const SizedBox(width: 5),
                  itemBuilder: (context, index) {
                    return UserTagPill(
                      name: "Mark",
                      imagePath: 'assets/images/user_test.jpg',
                      borderColor: AppTheme.buttonColor2,
                      iconColor: AppTheme.textColor2,
                      onTap: () {},
                    );
                  },
                ),
              ),
              SizedBox(height: 15),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "All",
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: "Filter",
                        barrierColor: Colors.black.withValues(alpha: 0.4),
                        transitionDuration: const Duration(milliseconds: 250),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return Center(child: _FilterDialogBox());
                        },
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          "Filters",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 5),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowDown01,
                          size: 20,
                          color: AppTheme.textColor2,
                          strokeWidth: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: 10,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return UserListTile(
                      name: "Mark Stephen $index",
                      message: "Random message from user $index",
                      imagePath: "assets/images/user_test.jpg",
                      trailing: Text(
                        "${index + 1}m",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      onLongPress: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return _ChatPressedOption();
                          },
                        );
                      },
                      onTap: () => _navigateToChatScreen(context),
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

class _ChatMenuOption extends StatelessWidget {
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
            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            iconBackgroundColor: Colors.transparent,
            title: 'Select all',
            iconColor: AppTheme.textColor2,
          ),
          SettingsRowItem(
            icon: HugeIcons.strokeRoundedTickDouble02,
            iconBackgroundColor: Colors.transparent,
            title: 'Mark all as Read',
            iconColor: AppTheme.textColor2,
          ),
          SettingsSwitchRow(
            icon: HugeIcons.strokeRoundedNotification01,
            title: 'Allow chat notifications',
            subtitle: "Turn on or off chat notification",
            switchValue: true,
          ),
        ],
      ),
    );
  }
}

class _ChatPressedOption extends StatelessWidget {
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
            icon: HugeIcons.strokeRoundedMessage02,
            iconBackgroundColor: Colors.transparent,
            title: 'Open Chat',
            iconColor: AppTheme.textColor2,
          ),
          SettingsRowItem(
            icon: HugeIcons.strokeRoundedTickDouble02,
            iconBackgroundColor: Colors.transparent,
            title: 'Mark Read',
            iconColor: AppTheme.textColor2,
          ),
          SettingsRowItem(
            icon: HugeIcons.strokeRoundedUser,
            iconBackgroundColor: Colors.transparent,
            title: 'View Profile',
            iconColor: AppTheme.textColor2,
          ),
          SettingsRowItem(
            icon: HugeIcons.strokeRoundedPin,
            iconBackgroundColor: Colors.transparent,
            title: 'Pin Chat',
            iconColor: AppTheme.textColor2,
          ),
          SettingsRowItem(
            icon: HugeIcons.strokeRoundedDelete01,
            iconBackgroundColor: Colors.transparent,
            title: 'Clear Chat',
            iconColor: AppTheme.textColor2,
          ),
          SettingsRowItem(
            icon: HugeIcons.strokeRoundedRemoveCircle,
            iconBackgroundColor: Colors.transparent,
            title: 'Block Mark',
            iconColor: AppTheme.textColor2,
          ),
        ],
      ),
    );
  }
}

class _FilterDialogBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TitleTwo(
              leadingIcon: HugeIcons.strokeRoundedCancel01,
              title: "Filter by",
            ),

            SizedBox(height: 25),

            GestureDetector(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "All",
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    size: 20,
                    color: AppTheme.textColor2,
                    strokeWidth: 2,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Unread",
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    size: 20,
                    color: AppTheme.textColor2,
                    strokeWidth: 2,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Blocked",
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    size: 20,
                    color: AppTheme.textColor2,
                    strokeWidth: 2,
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

class UserTagPill extends StatelessWidget {
  final String name;
  final String imagePath;

  final Color borderColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const UserTagPill({
    super.key,
    required this.name,
    required this.imagePath,
    required this.borderColor,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(width: 1, color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Optional Leading Icon
            HugeIcon(
              icon: HugeIcons.strokeRoundedPin,
              size: 12,
              color: iconColor,
              strokeWidth: 1,
            ),
            const SizedBox(width: 3),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    50,
                  ), // half of image width/height
                  child: Image.asset(
                    'assets/images/user_test.jpg',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "Mark",
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
