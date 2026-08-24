import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/screens/notification/notification_option_sheet.dart';
import 'package:quest/providers/notification_provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/utils/date_formatter.dart';
import 'package:quest/main.dart';
import 'package:quest/services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with RouteAware {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _fetchData();
  }

  void _fetchData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).fetchNotifications(authProvider.token!);
    }
  }

  dynamic _getIconForType(String type) {
    switch (type) {
      case 'MESSAGE':
      case 'CHAT_MESSAGE':
        return HugeIcons.strokeRoundedMessage02;
      case 'FRIEND_REQUEST':
      case 'FRIEND_ACCEPTED':
      case 'FRIEND':
        return HugeIcons.strokeRoundedUserAdd01;
      case 'SYSTEM':
      default:
        return HugeIcons.strokeRoundedAsterisk02;
    }
  }

  String _getTimeBucket(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inHours < 1) {
      return "New";
    } else if (difference.inHours >= 1 && difference.inHours < 24) {
      if (now.day != createdAt.day) {
        return "Yesterday";
      }
      return "One hour ago"; // Grouping 1-24 hours as per user request
    } else if (difference.inDays >= 1 && difference.inDays < 2) {
      return "Yesterday";
    } else if (difference.inDays >= 2 && difference.inDays <= 7) {
      return "Last week";
    } else {
      return "Older";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Column(
            children: [
              TitleOne(
                leadingIcon: HugeIcons.strokeRoundedCancel01,
                title: 'Notification',
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
                      return const NotificationOptionsSheet();
                    },
                  );
                },
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Consumer<NotificationProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.errorMessage != null) {
                      return Center(
                        child: Text(
                          provider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (provider.notifications.isEmpty) {
                      return const Center(
                        child: Text("You have no notifications."),
                      );
                    }

                    // Group notifications
                    final Map<String, List<dynamic>> groupedNotifications = {
                      "New": [],
                      "One hour ago": [],
                      "Yesterday": [],
                      "Last week": [],
                      "Older": [],
                    };

                    for (var notif in provider.notifications) {
                      final createdAt = DateTime.parse(notif['createdAt']);
                      final bucket = _getTimeBucket(createdAt);
                      groupedNotifications[bucket]?.add(notif);
                    }

                    return SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (groupedNotifications["New"]!.isNotEmpty)
                            NotificationSection(
                              sectionTitle: "New",
                              notifications:
                                  groupedNotifications["New"]!.map((n) {
                                    return NotificationData(
                                      icon: _getIconForType(
                                        n['type'] ?? 'SYSTEM',
                                      ),
                                      title: n['title'] ?? '',
                                      description: n['message'] ?? '',
                                      time: DateFormatter.formatTimeAgo(
                                        n['createdAt'],
                                      ),
                                      id: n['id'],
                                      isRead: provider.isRead(n),
                                      onTap: () {
                                        final token =
                                            Provider.of<AuthProvider>(
                                              context,
                                              listen: false,
                                            ).token;
                                        if (token != null) {
                                          provider.markAsRead(token, n);
                                        }
                                        Map<String, dynamic> payload = Map<String, dynamic>.from(n as Map<String, dynamic>);
                                        if (payload['data'] != null && payload['data'] is String) {
                                          try {
                                            final parsedData = jsonDecode(payload['data']);
                                            if (parsedData is Map<String, dynamic>) {
                                              payload.addAll(parsedData);
                                            }
                                          } catch (e) {
                                            debugPrint('Error decoding notification data: $e');
                                          }
                                        }
                                        navigateFromNotificationPayload(payload);
                                      },
                                    );
                                  }).toList(),
                            ),
                          if (groupedNotifications["One hour ago"]!.isNotEmpty)
                            NotificationSection(
                              sectionTitle: "One hour ago",
                              notifications:
                                  groupedNotifications["One hour ago"]!.map((
                                    n,
                                  ) {
                                    return NotificationData(
                                      icon: _getIconForType(
                                        n['type'] ?? 'SYSTEM',
                                      ),
                                      title: n['title'] ?? '',
                                      description: n['message'] ?? '',
                                      time: DateFormatter.formatTimeAgo(
                                        n['createdAt'],
                                      ),
                                      id: n['id'],
                                      isRead: provider.isRead(n),
                                      onTap: () {
                                        final token =
                                            Provider.of<AuthProvider>(
                                              context,
                                              listen: false,
                                            ).token;
                                        if (token != null) {
                                          provider.markAsRead(token, n);
                                        }
                                        Map<String, dynamic> payload = Map<String, dynamic>.from(n as Map<String, dynamic>);
                                        if (payload['data'] != null && payload['data'] is String) {
                                          try {
                                            final parsedData = jsonDecode(payload['data']);
                                            if (parsedData is Map<String, dynamic>) {
                                              payload.addAll(parsedData);
                                            }
                                          } catch (e) {
                                            debugPrint('Error decoding notification data: $e');
                                          }
                                        }
                                        navigateFromNotificationPayload(payload);
                                      },
                                    );
                                  }).toList(),
                            ),
                          if (groupedNotifications["Yesterday"]!.isNotEmpty)
                            NotificationSection(
                              sectionTitle: "Yesterday",
                              notifications:
                                  groupedNotifications["Yesterday"]!.map((n) {
                                    return NotificationData(
                                      icon: _getIconForType(
                                        n['type'] ?? 'SYSTEM',
                                      ),
                                      title: n['title'] ?? '',
                                      description: n['message'] ?? '',
                                      time: DateFormatter.formatTimeAgo(
                                        n['createdAt'],
                                      ),
                                      id: n['id'],
                                      isRead: provider.isRead(n),
                                      onTap: () {
                                        final token =
                                            Provider.of<AuthProvider>(
                                              context,
                                              listen: false,
                                            ).token;
                                        if (token != null) {
                                          provider.markAsRead(token, n);
                                        }
                                        Map<String, dynamic> payload = Map<String, dynamic>.from(n as Map<String, dynamic>);
                                        if (payload['data'] != null && payload['data'] is String) {
                                          try {
                                            final parsedData = jsonDecode(payload['data']);
                                            if (parsedData is Map<String, dynamic>) {
                                              payload.addAll(parsedData);
                                            }
                                          } catch (e) {
                                            debugPrint('Error decoding notification data: $e');
                                          }
                                        }
                                        navigateFromNotificationPayload(payload);
                                      },
                                    );
                                  }).toList(),
                            ),
                          if (groupedNotifications["Last week"]!.isNotEmpty)
                            NotificationSection(
                              sectionTitle: "Last week",
                              notifications:
                                  groupedNotifications["Last week"]!.map((n) {
                                    return NotificationData(
                                      icon: _getIconForType(
                                        n['type'] ?? 'SYSTEM',
                                      ),
                                      title: n['title'] ?? '',
                                      description: n['message'] ?? '',
                                      time: DateFormatter.formatTimeAgo(
                                        n['createdAt'],
                                      ),
                                      id: n['id'],
                                      isRead: provider.isRead(n),
                                      onTap: () {
                                        final token =
                                            Provider.of<AuthProvider>(
                                              context,
                                              listen: false,
                                            ).token;
                                        if (token != null) {
                                          provider.markAsRead(token, n);
                                        }
                                        Map<String, dynamic> payload = Map<String, dynamic>.from(n as Map<String, dynamic>);
                                        if (payload['data'] != null && payload['data'] is String) {
                                          try {
                                            final parsedData = jsonDecode(payload['data']);
                                            if (parsedData is Map<String, dynamic>) {
                                              payload.addAll(parsedData);
                                            }
                                          } catch (e) {
                                            debugPrint('Error decoding notification data: $e');
                                          }
                                        }
                                        navigateFromNotificationPayload(payload);
                                      },
                                    );
                                  }).toList(),
                            ),
                          if (groupedNotifications["Older"]!.isNotEmpty)
                            NotificationSection(
                              sectionTitle: "Older",
                              notifications:
                                  groupedNotifications["Older"]!.map((n) {
                                    return NotificationData(
                                      icon: _getIconForType(
                                        n['type'] ?? 'SYSTEM',
                                      ),
                                      title: n['title'] ?? '',
                                      description: n['message'] ?? '',
                                      time: DateFormatter.formatTimeAgo(
                                        n['createdAt'],
                                      ),
                                      id: n['id'],
                                      isRead: provider.isRead(n),
                                      onTap: () {
                                        final token =
                                            Provider.of<AuthProvider>(
                                              context,
                                              listen: false,
                                            ).token;
                                        if (token != null) {
                                          provider.markAsRead(token, n);
                                        }
                                        Map<String, dynamic> payload = Map<String, dynamic>.from(n as Map<String, dynamic>);
                                        if (payload['data'] != null && payload['data'] is String) {
                                          try {
                                            final parsedData = jsonDecode(payload['data']);
                                            if (parsedData is Map<String, dynamic>) {
                                              payload.addAll(parsedData);
                                            }
                                          } catch (e) {
                                            debugPrint('Error decoding notification data: $e');
                                          }
                                        }
                                        navigateFromNotificationPayload(payload);
                                      },
                                    );
                                  }).toList(),
                            ),
                        ],
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

class NotificationData {
  final dynamic id;
  final dynamic icon;
  final String title;
  final String description;
  final String time;
  final bool isRead;
  final VoidCallback onTap;

  NotificationData({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    required this.isRead,
    required this.onTap,
  });
}

class NotificationSection extends StatelessWidget {
  final String sectionTitle;
  final List<NotificationData> notifications;

  const NotificationSection({
    super.key,
    required this.sectionTitle,
    required this.notifications,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children:
                notifications.map((n) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: n.onTap,
                      child: NotificationItem(
                        icon: n.icon,
                        title: n.title,
                        description: n.description,
                        time: n.time,
                        isRead: n.isRead,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

class NotificationItem extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String description;
  final Color iconColor;
  final String time;
  final bool isRead;

  const NotificationItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor = const Color(0xfffbfcfb),
    required this.time,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7.5),
                decoration: BoxDecoration(
                  color:
                      iconColor == const Color(0xfffbfcfb)
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : const Color(0xfffbfcfb))
                          : iconColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: HugeIcon(
                  icon: icon,
                  size: 18,
                  color: const Color(0xff8e8e93),
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 13,
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                    children: [
                      TextSpan(text: '$title\n'),
                      TextSpan(
                        text: description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight:
                              isRead ? FontWeight.w400 : FontWeight.w600,
                          color:
                                  isRead
                                      ? Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5)
                                      : (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey.shade300
                                          : Colors.black87),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                color: isRead ? Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.5) : Theme.of(context).primaryColor,
                fontSize: 11,
              ),
            ),
            if (!isRead) ...[
              const SizedBox(height: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
