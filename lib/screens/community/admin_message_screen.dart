import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/community_provider.dart';
import 'package:quest/theme/theme.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:quest/components/formatted_text.dart';
import 'package:quest/components/share/in_app_share_sheet.dart';
import 'package:quest/screens/messages/new_message_screen.dart';

class AdminMessageScreen extends StatefulWidget {
  final Map<String, dynamic> message;
  const AdminMessageScreen({super.key, required this.message});

  @override
  State<AdminMessageScreen> createState() => _AdminMessageScreenState();
}

class _AdminMessageScreenState extends State<AdminMessageScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<dynamic> _comments = [];
  bool _isLoadingComments = true;
  bool _isCommenting = false;
  final List<String> _myReactions = [];

  String? _replyingToId;
  String? _replyingToUsername;

  final List<String> _quickReplies = [
    "Beautiful message",
    "Wonderful",
    "Inspiring thoughts",
    "Amazing ideas",
  ];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final auth = context.read<AuthProvider>();
    final communityProvider = context.read<CommunityProvider>();
    final comments = await communityProvider.fetchAdminMessageComments(
      auth.token!,
      widget.message['id'],
    );
    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _addComment([String? presetText]) async {
    var text = presetText ?? _commentController.text.trim();
    if (text.isEmpty) return;

    if (_replyingToUsername != null) {
      text = "@$_replyingToUsername $text";
    }

    setState(() {
      _isCommenting = true;
    });

    final auth = context.read<AuthProvider>();
    final communityProvider = context.read<CommunityProvider>();

    final success = await communityProvider.addAdminMessageComment(
      auth.token!,
      widget.message['id'],
      text,
      parentId: _replyingToId,
    );

    if (mounted) {
      setState(() {
        _isCommenting = false;
      });
      if (success) {
        _commentController.clear();
        _cancelReply();
        _loadComments();
      }
    }
  }

  void _onReply(String commentId, String username) {
    setState(() {
      _replyingToId = commentId;
      _replyingToUsername = username;
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingToId = null;
      _replyingToUsername = null;
    });
  }

  void _deleteMessage() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Message'),
            content: const Text(
              'Are you sure you want to delete this message?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      if (auth.token == null) return;
      final provider = context.read<CommunityProvider>();
      final success = await provider.deleteAdminMessage(
        auth.token!,
        widget.message['id'],
      );
      if (success) {
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete message')),
          );
        }
      }
    }
  }

  void _editMessage() async {
    final provider = context.read<CommunityProvider>();
    final activeMessage = provider.adminMessages.firstWhere(
      (m) => m['id'] == widget.message['id'],
      orElse: () => widget.message,
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => NewMessageScreen(
            communityId: activeMessage['communityId'] ?? '',
            initialMessage: activeMessage,
          ),
    );
  }

  void _showEmojiPicker(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "React to this message",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildEmojiOption("👍"),
                    _buildEmojiOption("❤️"),
                    _buildEmojiOption("😂"),
                    _buildEmojiOption("😮"),
                    _buildEmojiOption("😢"),
                    _buildEmojiOption("🙏"),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  Widget _buildEmojiOption(String emoji) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        final auth = context.read<AuthProvider>();
        if (auth.token == null) return;
        final provider = context.read<CommunityProvider>();
        final success = await provider.reactToAdminMessage(
          auth.token!,
          widget.message['communityId'],
          widget.message['id'],
          emoji,
        );
        if (success && mounted) {
          setState(() {
            if (_myReactions.contains(emoji)) {
              _myReactions.remove(emoji);
            } else {
              _myReactions.add(emoji);
            }
          });
        }
      },
      child: Text(emoji, style: const TextStyle(fontSize: 32)),
    );
  }

  Widget _buildMediaPreview(
    BuildContext context,
    String? thumbnailUrl,
    dynamic iconData,
    bool isVideo,
  ) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          image:
              thumbnailUrl != null
                  ? DecorationImage(
                    image: NetworkImage(thumbnailUrl),
                    fit: BoxFit.cover,
                  )
                  : null,
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(icon: iconData, size: 32, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<CommunityProvider>();
    final activeMessage = provider.adminMessages.firstWhere(
      (m) => m['id'] == widget.message['id'],
      orElse: () => widget.message,
    );
    final user = activeMessage['sender'] ?? {};
    final userName =
        "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim();
    final authorName =
        userName.isEmpty ? (user['username'] ?? 'Admin') : userName;
    final authorHandle = "@${user['username'] ?? 'admin'}";
    final avatarUrl = user['avatarUrl'];

    final title = activeMessage['title'] as String?;
    final text = activeMessage['text'] ?? '';
    final imageUrl = activeMessage['imageUrl'];
    final videoUrl = activeMessage['videoUrl'];
    final audioUrl = activeMessage['audioUrl'];
    final videoThumbnail = activeMessage['videoThumbnail'];
    final audioThumbnail = activeMessage['audioThumbnail'];

    final createdAt = activeMessage['createdAt'];

    final likesCount = activeMessage['likesCount'] ?? 0;
    final commentsCount = activeMessage['commentsCount'] ?? 0;
    final bookmarksCount = activeMessage['bookmarksCount'] ?? 0;
    final hasBookmarked = activeMessage['hasBookmarked'] == true;
    final hasLiked = activeMessage['hasLiked'] == true;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (context.read<AuthProvider>().user?['id'] ==
              activeMessage['senderId'])
            PopupMenuButton<String>(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedMoreVerticalCircle01,
                color: theme.colorScheme.onSurface,
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  _editMessage();
                } else if (value == 'delete') {
                  _deleteMessage();
                }
              },
              itemBuilder:
                  (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                        backgroundImage:
                            avatarUrl != null ? NetworkImage(avatarUrl) : null,
                        child:
                            avatarUrl == null
                                ? HugeIcon(
                                  icon: HugeIcons.strokeRoundedUser,
                                  size: 24,
                                  color: theme.colorScheme.onSurface,
                                )
                                : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authorName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              authorHandle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.textColor2,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (createdAt != null)
                        Text(
                          timeago.format(DateTime.parse(createdAt)),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textColor2,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const HugeIcon(
                                icon: HugeIcons.strokeRoundedAdd01,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else if (videoUrl != null) ...[
                    _buildMediaPreview(
                      context,
                      videoThumbnail,
                      HugeIcons.strokeRoundedPlay,
                      true,
                    ),
                    const SizedBox(height: 16),
                  ] else if (audioUrl != null) ...[
                    _buildMediaPreview(
                      context,
                      audioThumbnail,
                      HugeIcons.strokeRoundedMusicNote01,
                      false,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Action Row
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final auth = context.read<AuthProvider>();
                          if (auth.token == null) return;
                          await context
                              .read<CommunityProvider>()
                              .toggleAdminMessageLike(
                                auth.token!,
                                activeMessage['id'],
                              );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedFavourite,
                              size: 20,
                              color:
                                  hasLiked ? Colors.red : AppTheme.textColor2,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              likesCount >= 1000
                                  ? "${(likesCount / 1000).toStringAsFixed(1)}k"
                                  : likesCount.toString(),
                              style: TextStyle(
                                color: AppTheme.textColor2,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final auth = context.read<AuthProvider>();
                          if (auth.token == null) return;
                          await context
                              .read<CommunityProvider>()
                              .toggleAdminMessageBookmark(
                                auth.token!,
                                activeMessage['id'],
                              );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon:
                                  hasBookmarked
                                      ? HugeIcons.strokeRoundedBookmarkCheck02
                                      : HugeIcons.strokeRoundedBookmark02,
                              size: 20,
                              color:
                                  hasBookmarked
                                      ? Colors.green
                                      : AppTheme.textColor2,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              bookmarksCount >= 1000
                                  ? "${(bookmarksCount / 1000).toStringAsFixed(1)}k"
                                  : bookmarksCount.toString(),
                              style: TextStyle(
                                color: AppTheme.textColor2,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedComment01,
                            size: 20,
                            color: AppTheme.textColor2,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            commentsCount.toString(),
                            style: TextStyle(
                              color: AppTheme.textColor2,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          showInAppShareSheet(
                            context,
                            shareMessage:
                                "https://quest.app/message/${activeMessage['id']}",
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Share",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedShare01,
                                size: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showEmojiPicker(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _myReactions.isEmpty
                                ? "React 😊"
                                : "Reacted ${_myReactions.join(' ')}",
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (title != null && title.isNotEmpty) ...[
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  if (text.isNotEmpty)
                    FormattedText(
                      text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),

                  const SizedBox(height: 24),
                  Text(
                    'Comments (${activeMessage['commentsCount'] ?? 0})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_isLoadingComments)
                    const Center(child: CircularProgressIndicator())
                  else if (_comments.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          "No comments yet. Be the first to reply!",
                          style: TextStyle(color: AppTheme.textColor2),
                        ),
                      ),
                    )
                  else
                    ..._comments.map((comment) => _buildCommentNode(comment)),
                ],
              ),
            ),
          ),

          // Quick Replies
          if (!_isCommenting)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickReplies.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _addComment(_quickReplies[index]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.05,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            _quickReplies[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 8),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentNode(
    Map<String, dynamic> comment, {
    bool isReply = false,
    String? rootCommentId,
  }) {
    final theme = Theme.of(context);
    final u = comment['user'] ?? {};
    final uname = "${u['firstName'] ?? ''} ${u['lastName'] ?? ''}".trim();
    final name = uname.isEmpty ? (u['username'] ?? 'User') : uname;
    final handle = "@${u['username'] ?? 'user'}";
    final avatar = u['avatarUrl'];
    final time =
        comment['createdAt'] != null
            ? timeago.format(DateTime.parse(comment['createdAt']))
            : '';

    return Padding(
      padding: EdgeInsets.only(bottom: 24, left: isReply ? 40 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: isReply ? 16 : 20,
                backgroundColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.1,
                ),
                backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                child:
                    avatar == null
                        ? HugeIcon(
                          icon: HugeIcons.strokeRoundedUser,
                          size: isReply ? 16 : 20,
                          color: theme.colorScheme.onSurface,
                        )
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isReply ? 13 : 15,
                                ),
                              ),
                              Text(
                                handle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textColor2,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          time,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textColor2,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    FormattedText(
                      comment['text'] ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: isReply ? 13 : 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final auth = context.read<AuthProvider>();
                            if (auth.token == null) return;
                            await context
                                .read<CommunityProvider>()
                                .toggleAdminMessageCommentLike(
                                  auth.token!,
                                  widget.message['communityId'],
                                  comment['id'],
                                );
                            _loadComments();
                          },
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedThumbsUp,
                                size: 16,
                                color: AppTheme.textColor2,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (comment['likesCount'] ?? 0).toString(),
                                style: TextStyle(
                                  color: AppTheme.textColor2,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text("—", style: TextStyle(color: AppTheme.textColor2)),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap:
                              () => _onReply(
                                rootCommentId ?? comment['id'],
                                u['username'] ?? name,
                              ),
                          child: Text(
                            "Reply",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textColor2,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment['replies'] != null &&
              (comment['replies'] as List).isNotEmpty)
            ...((comment['replies'] as List).map(
              (reply) => _buildCommentNode(
                reply,
                isReply: true,
                rootCommentId: rootCommentId ?? comment['id'],
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
        child: Column(
          children: [
            if (_replyingToUsername != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      "Replying to @$_replyingToUsername",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                borderRadius:
                    _replyingToUsername != null
                        ? const BorderRadius.vertical(
                          bottom: Radius.circular(30),
                        )
                        : BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedAdd01,
                      color: theme.colorScheme.onSurface,
                      size: 24,
                    ),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      maxLines: 4,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: "Type a message",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  if (_isCommenting)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedSent,
                        color: AppTheme.primaryBlue,
                        size: 24,
                      ),
                      onPressed: () {
                        _addComment();
                      },
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
