import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/tile/settings_row_item.dart';
import 'package:quest/components/user_details/user_profile_card.dart';
import 'package:quest/theme/theme.dart';

class GroupMessageScreen extends StatelessWidget {
  const GroupMessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            /// 🔹 Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      size: 24,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // if online, name should be green, if offline, name should be grey, if blocked, name is red
                          Text(
                            "Mark Stephen",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return UserProfileCard();
                            },
                          );
                        },
                        child: const CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage(
                            "assets/images/user_test.jpg",
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: "Filter",
                            barrierColor: Colors.black.withValues(alpha: 0.4),
                            transitionDuration: const Duration(
                              milliseconds: 250,
                            ),
                            pageBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                            ) {
                              return Center(child: _ChatMenuDialogBox());
                            },
                          );
                        },
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedMoreVertical,
                          size: 24,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// 🔹 Messages
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                children: const [
                  ChatBubble(message: "Hey! How are you?", isMe: false),
                  ChatBubble(
                    message: "I'm good! Working on the app.",
                    isMe: true,
                  ),
                  ChatBubble(message: "Nice 🔥 It looks great!", isMe: false),
                  ChatBubble(message: "Thanks! Almost done.", isMe: true),
                ],
              ),
            ),

            /// 🔹 Message Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedAdd01,
                      size: 22,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black, // Set the desired font size
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.completedColor,
                      shape: BoxShape.circle,
                    ),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedSent,
                      size: 18,
                      color: Colors.white,
                    ),
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

class _ChatMenuDialogBox extends StatelessWidget {
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

            SettingsRowItem(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return UserProfileCard();
                  },
                );
              },
              icon: HugeIcons.strokeRoundedUser,
              iconBackgroundColor: Colors.transparent,
              title: 'View profile',
              iconColor: AppTheme.textColor2,
            ),
            SettingsRowItem(
              icon: HugeIcons.strokeRoundedPin,
              iconBackgroundColor: Colors.transparent,
              title: 'Pin chat',
              iconColor: AppTheme.textColor2,
            ),
            SettingsRowItem(
              icon: HugeIcons.strokeRoundedDelete01,
              iconBackgroundColor: Colors.transparent,
              title: 'Clear chat',
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
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isMe ? Colors.black : AppTheme.buttonColor2,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Text(
          message,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isMe ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
