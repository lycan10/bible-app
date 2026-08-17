import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/action_pill/action_pill_button.dart';
import 'package:quest/components/avatar.dart';
import 'package:quest/theme/theme.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EventDetailsCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final bool isAttending;
  final VoidCallback onToggleAttend;
  final bool isAdmin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EventDetailsCard({
    super.key,
    required this.event,
    required this.isAttending,
    required this.onToggleAttend,
    this.isAdmin = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: EdgeInsets.only(bottom: 30),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            ClipRRect(
              borderRadius: BorderRadius.circular(
                50,
              ), // half of image width/height
              child:
                  event['imageUrl'] != null
                      ? CachedNetworkImage(
                        imageUrl: event['imageUrl'],
                        width: 75,
                        height: 75,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => _defaultImage(),
                      )
                      : _defaultImage(),
            ),
            SizedBox(width: 10),
            SizedBox(height: 20),
            Text(
              event['title'] ?? "Community Event",
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 20,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              event['description'] ?? "No description available.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 13,
                color: AppTheme.textColor2,
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedLocation01,
                  size: 16,
                  color: Color(0xff8e8e93),
                ),
                const SizedBox(width: 5),
                Text(
                  event['location'] ?? 'No location specified',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: AppTheme.textColor2,
                  ),
                ),
              ],
            ),
            if (event['link'] != null &&
                event['link'].toString().isNotEmpty) ...[
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.link, size: 16, color: Color(0xff8e8e93)),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      event['link'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: theme.colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 58,
                  height: 23,
                  child: Stack(
                    children: const [
                      Positioned(
                        left: 0,
                        child: CustomAvatar(
                          imageUrl: 'assets/images/boy.png',
                          radius: 11.5,
                        ),
                      ),
                      Positioned(
                        left: 15,
                        child: CustomAvatar(
                          imageUrl: 'assets/images/boy.png',
                          radius: 11.5,
                        ),
                      ),
                      Positioned(
                        left: 30,
                        child: CustomAvatar(
                          imageUrl: 'assets/images/boy.png',
                          radius: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  "${(event['attendees'] as List?)?.length ?? 0} attending",
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: AppTheme.textColor2,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.buttonColor2.withValues(alpha: 0.3),
                border: Border.all(width: 0.5, color: AppTheme.buttonColor2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar04,
                    size: 16,
                    color: Color(0xff8e8e93),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${DateTime.tryParse(event['date'] ?? '')?.day ?? ''}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    event['date'] != null
                        ? DateFormat(
                          'MMM yyyy',
                        ).format(DateTime.parse(event['date']))
                        : '',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 10, // 👈 controls vertical line height
                    child: VerticalDivider(
                      thickness: 1.5, // 👈 line width
                      color: AppTheme.textColor2.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedClock01,
                    size: 16,
                    color: Color(0xff8e8e93),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    event['time'] ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),
            ActionPillButton(
              backgroundColor:
                  isAttending
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.1)
                      : theme.colorScheme.onSurface,
              textColor:
                  isAttending
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.surface,
              label: isAttending ? "Unattend Event" : "Attend Event",
              onTap: onToggleAttend,
            ),
            if (isAdmin) ...[
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: ActionPillButton(
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      textColor: theme.colorScheme.onSurface,
                      label: "Edit",
                      onTap: onEdit ?? () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ActionPillButton(
                      backgroundColor: AppTheme.redColor.withValues(alpha: 0.1),
                      textColor: AppTheme.redColor,
                      label: "Delete",
                      onTap: onDelete ?? () {},
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _defaultImage() {
    return Image.asset(
      "assets/images/boy.png",
      width: 75,
      height: 75,
      fit: BoxFit.cover,
    );
  }
}
