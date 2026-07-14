import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

import 'package:quest/screens/community/admin_message_screen.dart';
import 'package:quest/components/formatted_text.dart';

class CommunityMessageCard extends StatelessWidget {
  final Map<String, dynamic> message;

  const CommunityMessageCard({super.key, required this.message});

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr).toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    final timeFormat = DateFormat('h:mma').format(date).toLowerCase();

    if (dateToCheck == today) {
      return 'Today $timeFormat';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday $timeFormat';
    } else {
      final dateFormat = DateFormat('d MMMM, yyyy').format(date);
      return '$dateFormat - $timeFormat';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final user = message['sender'] ?? {};
    final userName =
        "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim();
    final authorName =
        userName.isEmpty ? (user['username'] ?? 'Admin') : userName;

    final text = message['text'] ?? 'Message';
    final imageUrl = message['imageUrl'] ?? message['videoThumbnail'];
    final createdAt = message['createdAt'];
    final likesCount = message['likesCount'] ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminMessageScreen(message: message),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            width: 1,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'From: ',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textColor2.withValues(alpha: 0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        authorName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedThumbsUp,
                        size: 14,
                        color: AppTheme.textColor2,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$likesCount',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textColor2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '—',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textColor2.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (createdAt != null)
                        Text(
                          _formatDate(createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textColor2,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  imageUrl,
                  width: 85,
                  height: 85,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 85,
                    height: 85,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    child: Center(
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedImage01,
                        size: 24,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedMessage02,
                    size: 28,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
