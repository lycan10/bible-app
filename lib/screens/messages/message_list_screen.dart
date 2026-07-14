import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/chat_provider.dart';
import 'package:quest/components/menu/discover_more.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/section_header.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/screens/messages/message_chat_screen.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/components/avatar.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../components/global_more_menu.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        context.read<ChatProvider>().loadChats(auth.token!);
      }
    });
  }

  void _openMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const GlobalMoreMenu();
      },
    );
  }

  void _navigateToChat(BuildContext context, Map<String, dynamic> chat) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                MessageChatScreen(chatId: chat['id'], friend: chat['friend']),
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
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15, left: 16, right: 16),
          child: Column(
            children: [
              TitleOne(
                leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                title: 'Messages',
                trailingIcon: HugeIcons.strokeRoundedMoreVertical,
                leadingIconTap: () => Navigator.pop(context),
                trailingIconTap: () => _openMenu(context),
              ),
              const SizedBox(height: 25),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return const DiscoverMore();
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedLeftToRightListBullet,
                        size: 22,
                        color: theme.colorScheme.onSurface,
                        strokeWidth: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedSearch01,
                            size: 18,
                            color: AppTheme.textColor2,
                          ),
                          const SizedBox(width: 8),
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
              const SizedBox(height: 20),
              const SectionHeader(title: "Direct Messages", showSeeAll: false),
              Expanded(
                child:
                    chatProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : chatProvider.chats.isEmpty
                        ? const Center(
                          child: Text(
                            "No messages yet. Connect with a friend to chat!",
                          ),
                        )
                        : ListView.builder(
                          itemCount: chatProvider.chats.length,
                          itemBuilder: (context, index) {
                            final chat = chatProvider.chats[index];
                            final friend = chat['friend'] ?? {};
                            final lastMsg = chat['lastMessage'];

                            final friendName =
                                '${friend['firstName'] ?? ''} ${friend['lastName'] ?? ''}'
                                    .trim();
                            final avatarUrl = friend['avatarUrl'];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 5,
                                ),
                                leading: CustomAvatar(
                                  radius: 25,
                                  imageUrl: avatarUrl != null && avatarUrl.toString().isNotEmpty
                                          ? ApiService.getFullImageUrl(avatarUrl)
                                          : null,
                                ),
                                title: Text(
                                  friendName.isNotEmpty
                                      ? friendName
                                      : '@${friend['username'] ?? 'User'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(
                                  lastMsg != null
                                      ? lastMsg['text'] ?? 'Sent an image'
                                      : 'Start chatting!',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: (chat['unreadCount'] != null && chat['unreadCount'] > 0)
                                    ? Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${chat['unreadCount']}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : null,
                                onTap: () {
                                  final auth = context.read<AuthProvider>();
                                  if (auth.token != null) {
                                    context.read<ChatProvider>().markChatAsRead(auth.token!, chat['id']);
                                  }
                                  _navigateToChat(context, chat);
                                },
                              ),
                            ),
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
  const _PostListMenuDialogBox();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
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
              switchValue: true,
            ),
            SettingsSwitchRow(
              icon: HugeIcons.strokeRoundedSmartPhone03,
              title: 'Haptic Feedback',
              subtitle: 'Turn on haptic feedback',
              switchValue: true,
            ),
          ],
        ),
      ),
    );
  }
}
