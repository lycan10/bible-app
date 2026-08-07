import 'package:flutter/material.dart';
import 'package:quest/components/connect/connect_card.dart';
import 'package:quest/components/menu/discover_more.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/section_header.dart';
import 'package:quest/components/titles/title_one.dart';

import 'package:quest/screens/messages/message_chat_screen.dart';
import 'package:quest/providers/chat_provider.dart';

import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/feed_provider.dart';
import 'package:quest/providers/auth_provider.dart';
import '../../components/global_more_menu.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);
      if (authProvider.token != null) {
        feedProvider.loadProfileDetails(authProvider.token!);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedProvider = Provider.of<FeedProvider>(context);
    final suggestions = feedProvider.friendSuggestions;
    final friends = feedProvider.friends;
    final pendingRequests = feedProvider.pendingRequests;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                    //trailingIconTap: () => _openMenu(context),
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

                      /// Search Bar
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
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedSearch01,
                                size: 18,
                                color: theme.colorScheme.onSurface,
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
                  if (suggestions.isEmpty &&
                      friends.isEmpty &&
                      pendingRequests.isEmpty &&
                      feedProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    if (pendingRequests.isNotEmpty) ...[
                      SectionHeader(title: "Friend Requests", seeAllText: ""),
                      ...pendingRequests.map((user) {
                        return ConnectCard(
                          name:
                              '${user['firstName']} ${user['lastName'] ?? ''}'
                                  .trim(),
                          username: '@${user['username']}',
                          imagePath:
                              user['avatarUrl'] ?? 'assets/images/boy.png',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                onPressed: () async {
                                  final authProvider =
                                      Provider.of<AuthProvider>(
                                        context,
                                        listen: false,
                                      );
                                  if (authProvider.token != null) {
                                    bool ok = await feedProvider
                                        .acceptFriendRequest(
                                          authProvider.token!,
                                          user['id'],
                                        );
                                    if (ok && context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Request accepted!'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final authProvider =
                                      Provider.of<AuthProvider>(
                                        context,
                                        listen: false,
                                      );
                                  if (authProvider.token != null) {
                                    bool ok = await feedProvider
                                        .rejectFriendRequest(
                                          authProvider.token!,
                                          user['id'],
                                        );
                                    if (ok && context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Request rejected'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                      SizedBox(height: 20),
                    ],
                    if (friends.isNotEmpty) ...[
                      SectionHeader(title: "Your Friends", seeAllText: ""),
                      ...friends.map((user) {
                        return ConnectCard(
                          name:
                              '${user['firstName']} ${user['lastName'] ?? ''}'
                                  .trim(),
                          username: '@${user['username']}',
                          imagePath:
                              user['avatarUrl'] ?? 'assets/images/boy.png',
                          trailing: IconButton(
                            icon: const Icon(Icons.message, color: Colors.blue),
                            onPressed: () async {
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              if (authProvider.token != null) {
                                final chat = await context
                                    .read<ChatProvider>()
                                    .startChat(authProvider.token!, user['id']);
                                if (chat != null && context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => MessageChatScreen(
                                            chatId: chat['id'],
                                            friend: user,
                                          ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      }),
                      SizedBox(height: 20),
                    ],
                    if (suggestions.isNotEmpty) ...[
                      SectionHeader(
                        title: "Suggested Connections",
                        seeAllText: "",
                      ),
                      ...suggestions.map((user) {
                        return ConnectCard(
                          name:
                              '${user['firstName']} ${user['lastName'] ?? ''}'
                                  .trim(),
                          username: '@${user['username']}',
                          imagePath:
                              user['avatarUrl'] ?? 'assets/images/boy.png',
                          connectTap: () async {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            if (authProvider.token != null) {
                              bool ok = await feedProvider.sendFriendRequest(
                                authProvider.token!,
                                user['id'],
                              );
                              if (ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Friend request sent!'),
                                  ),
                                );
                              }
                            }
                          },
                        );
                      }),
                    ],
                  ],
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
