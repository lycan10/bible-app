import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/screens/notification/notification_option_sheet.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFBFCFB),
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
                      return NotificationOptionsSheet();
                    },
                  );
                },
              ),

              SizedBox(height: 40),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NotificationSection(
                        sectionTitle: "New",
                        notifications: [
                          NotificationData(
                            icon: HugeIcons.strokeRoundedMessage02,
                            title: "Annie sent a new message",
                            description: "Open new message",
                            time: "Now",
                          ),
                          NotificationData(
                            icon: HugeIcons.strokeRoundedAsterisk02,
                            title: "New Feature released",
                            description: "See latest update",
                            time: "3m ago",
                          ),
                          NotificationData(
                            icon: HugeIcons.strokeRoundedUserAdd01,
                            title: "Lola wants to be your friend",
                            description: "View new connection request",
                            time: "30m ago",
                          ),
                        ],
                      ),

                      NotificationSection(
                        sectionTitle: "One hour ago",
                        notifications: [
                          NotificationData(
                            icon: HugeIcons.strokeRoundedMessage02,
                            title: "Annie sent a new message",
                            description: "Open new message",
                            time: "Now",
                          ),
                          NotificationData(
                            icon: HugeIcons.strokeRoundedAsterisk02,
                            title: "New Feature released",
                            description: "See latest update",
                            time: "3m ago",
                          ),
                          NotificationData(
                            icon: HugeIcons.strokeRoundedUserAdd01,
                            title: "Lola wants to be your friend",
                            description: "View new connection request",
                            time: "30m ago",
                          ),
                        ],
                      ),
                      NotificationSection(
                        sectionTitle: "Yesterday",
                        notifications: [
                          NotificationData(
                            icon: HugeIcons.strokeRoundedMessage02,
                            title: "Annie sent a new message",
                            description: "Open new message",
                            time: "Now",
                          ),
                          NotificationData(
                            icon: HugeIcons.strokeRoundedAsterisk02,
                            title: "New Feature released",
                            description: "See latest update",
                            time: "3m ago",
                          ),
                          NotificationData(
                            icon: HugeIcons.strokeRoundedUserAdd01,
                            title: "Lola wants to be your friend",
                            description: "View new connection request",
                            time: "30m ago",
                          ),
                        ],
                      ),

                      NotificationSection(
                        sectionTitle: "Last week",
                        notifications: [
                          NotificationData(
                            icon: HugeIcons.strokeRoundedMessage02,
                            title: "Annie sent a new message",
                            description: "Open new message",
                            time: "Now",
                          ),
                          NotificationData(
                            icon: HugeIcons.strokeRoundedAsterisk02,
                            title: "New Feature released",
                            description: "See latest update",
                            time: "3m ago",
                          ),
                          NotificationData(
                            icon: HugeIcons.strokeRoundedUserAdd01,
                            title: "Lola wants to be your friend",
                            description: "View new connection request",
                            time: "30m ago",
                          ),
                        ],
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

class NotificationData {
  final dynamic icon;
  final String title;
  final String description;
  final String time;

  NotificationData({
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
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
            color: Colors.black,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children:
                notifications.map((n) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: NotificationItem(
                      icon: n.icon,
                      title: n.title,
                      description: n.description,
                      time: n.time,
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

  const NotificationItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor = const Color(0xfffbfcfb),
    required this.time,
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
                  color: iconColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: HugeIcon(
                  icon: icon,
                  size: 18,
                  color: Color(0xff8e8e93),
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(text: '$title\n'),
                      TextSpan(
                        text: description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
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

        Text(
          time,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black38,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
