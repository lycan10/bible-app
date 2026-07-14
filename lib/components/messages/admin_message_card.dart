import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/community_provider.dart';
import 'package:quest/components/share/in_app_share_sheet.dart';
import 'package:quest/screens/community/admin_message_screen.dart';
import 'package:quest/components/formatted_text.dart';

class AdminMessageCard extends StatelessWidget {
  final Map<String, dynamic> message;

  const AdminMessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.read<AuthProvider>();
    final communityProvider = context.read<CommunityProvider>();

    final user = message['sender'] ?? {};
    final userName =
        "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim();
    final authorName =
        userName.isEmpty ? (user['username'] ?? 'Admin') : userName;
    final avatarUrl = user['avatarUrl'];

    final text = message['text'] ?? '';
    final imageUrl = message['imageUrl'];
    final videoUrl = message['videoUrl'];
    final videoThumbnail = message['videoThumbnail'];
    final audioUrl = message['audioUrl'];
    final audioThumbnail = message['audioThumbnail'];
    final createdAt = message['createdAt'];

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
        margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          width: 1,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.1,
                ),
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child:
                    avatarUrl == null
                        ? HugeIcon(
                          icon: HugeIcons.strokeRoundedUser,
                          size: 16,
                          color: theme.colorScheme.onSurface,
                        )
                        : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            authorName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xff4a3aff,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'ADMIN',
                            style: TextStyle(
                              color: Color(0xff4a3aff),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (createdAt != null)
                      Text(
                        timeago.format(DateTime.parse(createdAt)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: AppTheme.textColor2,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Media Content First
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 200,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedImage01,
                          size: 40,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    ),
              ),
            ),

          if (videoUrl != null)
            _buildMediaPreview(
              context,
              videoThumbnail,
              HugeIcons.strokeRoundedVideo01,
              true,
            ),

          if (audioUrl != null)
            _buildMediaPreview(
              context,
              audioThumbnail,
              HugeIcons.strokeRoundedMusicNote01,
              false,
            ),

          if (text.isNotEmpty &&
              (imageUrl != null || videoUrl != null || audioUrl != null))
            const SizedBox(height: 12),

          // Text Content (under media, 2 lines max)
          if (text.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 45,
              ), // Roughly 2 lines
              child: FormattedText(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    _actionItem(
                      theme,
                      message['hasLiked'] == true
                          ? Icons.favorite
                          : Icons.favorite_border,
                      "${message['likesCount'] ?? 0}",
                      color:
                          message['hasLiked'] == true
                              ? Colors.red
                              : AppTheme.textColor2,
                      onTap: () async {
                        if (auth.token != null) {
                          await communityProvider.toggleAdminMessageLike(
                            auth.token!,
                            message['id'],
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _actionItem(
                      theme,
                      Icons.chat_bubble_outline,
                      "${message['commentsCount'] ?? 0}",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    AdminMessageScreen(message: message),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _actionItem(
                      theme,
                      Icons.share_outlined,
                      "${message['sharesCount'] ?? 0}",
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder:
                              (context) => InAppShareSheet(
                                shareMessage:
                                    'Check out this message on Quest: https://bible.quest/community/messages/${message['id']}',
                              ),
                        );
                        if (auth.token != null) {
                          communityProvider.shareAdminMessage(
                            auth.token!,
                            message['id'],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  _iconButton(
                    theme,
                    message['hasBookmarked'] == true
                        ? HugeIcons.strokeRoundedBookmarkCheck02
                        : HugeIcons.strokeRoundedBookmark02,
                    message['hasBookmarked'] == true
                        ? Colors.green
                        : AppTheme.textColor2,
                    onTap: () async {
                      if (auth.token != null) {
                        await communityProvider.toggleAdminMessageBookmark(
                          auth.token!,
                          message['id'],
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 6),
                  _iconButton(
                    theme,
                    HugeIcons.strokeRoundedLinkForward,
                    theme.colorScheme.onSurface,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AdminMessageScreen(message: message),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildMediaPreview(
    BuildContext context,
    String? thumbnail,
    dynamic fallbackIcon,
    bool isVideo,
  ) {
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child:
              thumbnail != null
                  ? Image.network(
                    thumbnail,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            _buildFallback(theme, fallbackIcon),
                  )
                  : _buildFallback(theme, fallbackIcon),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedPlay,
            size: 30,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFallback(ThemeData theme, dynamic icon) {
    return Container(
      width: double.infinity,
      height: 150,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
      child: Center(
        child: HugeIcon(
          icon: icon,
          size: 40,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _actionItem(
    ThemeData theme,
    IconData icon,
    String label, {
    Color? color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 14, color: color ?? AppTheme.textColor2),
          ),
          if (label.isNotEmpty && label != "0") ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _iconButton(
    ThemeData theme,
    dynamic icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: HugeIcon(icon: icon, size: 18, color: color, strokeWidth: 1),
      ),
    );
  }
}
