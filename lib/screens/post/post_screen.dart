import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:quest/components/action_pill/action_pill_button.dart';
import 'package:quest/screens/post/edit_post_screen.dart';
import 'package:quest/components/stats/stats.dart';
import 'package:quest/components/tile/settings_row_item.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/community_provider.dart';
import 'package:quest/theme/theme.dart';
import '../../components/report_bottom_sheet.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:quest/components/share/in_app_share_sheet.dart';
import 'package:quest/components/user_details/user_profile_card.dart';
import 'package:quest/components/formatted_text.dart';

class PostScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostScreen({super.key, required this.post});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<dynamic> _comments = [];
  bool _isLoadingComments = true;
  bool _isCommenting = false;

  String? _replyingToId;
  String? _replyingToUsername;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    final auth = context.read<AuthProvider>();
    final communityProvider = context.read<CommunityProvider>();
    final comments = await communityProvider.fetchPostComments(
      auth.token!,
      widget.post['id'],
    );
    if (mounted) {
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _addComment() async {
    var text = _commentController.text.trim();
    if (text.isEmpty) return;

    if (_replyingToUsername != null) {
      text = "@$_replyingToUsername $text";
    }

    setState(() {
      _isCommenting = true;
    });

    final auth = context.read<AuthProvider>();
    final communityProvider = context.read<CommunityProvider>();

    final success = await communityProvider.addPostComment(
      auth.token!,
      widget.post['id'],
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

  Future<void> _toggleReaction() async {
    final auth = context.read<AuthProvider>();
    final communityProvider = context.read<CommunityProvider>();
    await communityProvider.reactToPost(auth.token!, widget.post['id'], '👍');
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use the provider's current posts to make sure like count updates immediately for posts
    final communityProvider = context.watch<CommunityProvider>();
    final currentPostIdx = communityProvider.currentPosts.indexWhere(
      (p) => p['id'] == widget.post['id'],
    );
    final post =
        currentPostIdx != -1
            ? communityProvider.currentPosts[currentPostIdx]
            : widget.post;

    final user = post['user'] ?? {};
    final userName =
        "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim();
    final displayName =
        userName.isEmpty ? (user['username'] ?? '') : userName;
    final text = post['text'] ?? '';
    final imageUrl = post['image'];
    final reactionsCount = post['reactions']?.length ?? 0;
    final commentsCount = post['_count']?['comments'] ?? 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            children: [
              TitleOne(
                leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                title: '',
                trailingIcon: HugeIcons.strokeRoundedMoreVertical,
                leadingIconTap: () {
                  Navigator.pop(context);
                },
                trailingIconTap: () {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: "Filter",
                    barrierColor: Colors.black.withValues(alpha: 0.4),
                    transitionDuration: const Duration(milliseconds: 250),
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return Center(child: _PostMenuDialogBox(post: post));
                    },
                  );
                },
              ),
              SizedBox(height: 25),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder:
                                      (context) => UserProfileCard(user: user),
                                );
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 21,
                                    backgroundImage:
                                        user['avatarUrl'] != null
                                            ? NetworkImage(user['avatarUrl'])
                                            : null,
                                    backgroundColor: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.1),
                                    child:
                                        user['avatarUrl'] == null
                                            ? HugeIcon(
                                              icon: HugeIcons.strokeRoundedUser,
                                              size: 20,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            )
                                            : null,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayName,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    theme.colorScheme.onSurface,
                                                fontSize: 14,
                                              ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          user['username'] != null && user['username'].toString().isNotEmpty ? "@${user['username']}" : "",
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontSize: 12,
                                                color: AppTheme.textColor2,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            post['createdAt'] != null
                                ? timeago.format(
                                  DateTime.parse(post['createdAt']),
                                )
                                : "Recently",
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: AppTheme.textColor2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (imageUrl != null) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Image.asset(
                                    'assets/images/user_test.jpg',
                                    fit: BoxFit.cover,
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Stat(
                                icon: HugeIcons.strokeRoundedThumbsUp,
                                text: "$reactionsCount",
                                iconSize: 18,
                                textColor: AppTheme.textColor2,
                                textSize: 12,
                              ),
                              const SizedBox(width: 10),
                              Stat(
                                icon: HugeIcons.strokeRoundedComment01,
                                text: "$commentsCount",
                                iconSize: 18,
                                textColor: AppTheme.textColor2,
                                textSize: 12,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              ActionPillButton(
                                icon: HugeIcons.strokeRoundedShare08,
                                label: "Share",
                                onTap: () {
                                  final link =
                                      'https://quest.vidarave.com/post/${post['id']}';
                                  showInAppShareSheet(
                                    context,
                                    shareMessage:
                                        'Check out this post on Quest! $link',
                                  );
                                },
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                onTap: _toggleReaction,
                                child: Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(
                                      0xff673aff,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "React ($reactionsCount)",
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff673aff),
                                              fontSize: 12,
                                            ),
                                      ),
                                      const SizedBox(width: 5),
                                      const VerticalDivider(
                                        width: 4,
                                        thickness: 1.5,
                                        color: Color(0xff673aff),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "👍",
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff673aff),
                                              fontSize: 13,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (text.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        FormattedText(
                          text.replaceAll(RegExp(r'\n(?!\n)'), '\n\n'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                            color: theme.colorScheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      SizedBox(height: 25),
                      Text(
                        "Comments($commentsCount)",
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 10),
                      if (_isLoadingComments)
                        const Center(child: CircularProgressIndicator())
                      else if (_comments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            "No comments yet. Be the first to reply!",
                          ),
                        )
                      else
                        Column(
                          children:
                              _comments
                                  .map(
                                    (c) => CommentItem(
                                      comment: c,
                                      postId: post['id'],
                                      onReply: _onReply,
                                    ),
                                  )
                                  .toList(),
                        ),
                    ],
                  ),
                ),
              ),

              if (_replyingToUsername != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(color: theme.colorScheme.surface),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Replying to @_replyingToUsername...",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: _cancelReply,
                        child: const Icon(Icons.close, size: 16),
                      ),
                    ],
                  ),
                ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface,
                        shape: BoxShape.circle,
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedAdd01,
                        size: 22,
                        color: theme.colorScheme.surface,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: "Type a message...",
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: 14.0,
                            color: theme.colorScheme.onSurface,
                          ),
                          onSubmitted: (_) => _addComment(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _isCommenting ? null : _addComment,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              _isCommenting
                                  ? Colors.grey
                                  : AppTheme.completedColor,
                          shape: BoxShape.circle,
                        ),
                        child:
                            _isCommenting
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const HugeIcon(
                                  icon: HugeIcons.strokeRoundedSent,
                                  size: 18,
                                  color: Colors.white,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommentItem extends StatefulWidget {
  final Map<String, dynamic> comment;
  final String postId;
  final Function(String, String) onReply;
  final bool isReply;
  final String? rootCommentId;

  const CommentItem({
    super.key,
    required this.comment,
    required this.postId,
    required this.onReply,
    this.isReply = false,
    this.rootCommentId,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool isExpanded = false;

  Future<void> _likeComment() async {
    final auth = context.read<AuthProvider>();
    final communityProvider = context.read<CommunityProvider>();

    // Optimistic UI update
    setState(() {
      List reactions = List.from(widget.comment['reactions'] ?? []);
      final currentUserId = auth.user?['id'];
      final existingIdx = reactions.indexWhere(
        (r) => r['userId'] == currentUserId && r['emoji'] == '👍',
      );

      if (existingIdx != -1) {
        reactions.removeAt(existingIdx);
      } else {
        reactions.add({'userId': currentUserId, 'emoji': '👍'});
      }
      widget.comment['reactions'] = reactions;
    });

    await communityProvider.reactToComment(
      auth.token!,
      widget.postId,
      widget.comment['id'],
      '👍',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final user = widget.comment['user'] ?? {};
    final userName =
        "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim();
    final displayName =
        userName.isEmpty ? (user['username'] ?? '') : userName;
    final replies = widget.comment['replies'] as List<dynamic>? ?? [];

    final reactions = widget.comment['reactions'] as List<dynamic>? ?? [];
    final likesCount = reactions.where((r) => r['emoji'] == '👍').length;

    final authId = context.read<AuthProvider>().user?['id'];
    final cp = context.read<CommunityProvider>();
    final isCommunityAdmin =
        cp.currentCommunity != null &&
        (cp.currentCommunity!['members'] as List<dynamic>? ?? []).any(
          (m) => m['id'] == authId && m['role'] == 'ADMIN',
        );
    final isMe = user['id'] == authId;
    final canDelete = isCommunityAdmin || isMe;

    return Padding(
      padding: EdgeInsets.only(left: widget.isReply ? 30.0 : 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: theme.colorScheme.surface,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => UserProfileCard(user: user),
                          );
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                'assets/images/user_test.jpg',
                                width: 30,
                                height: 30,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    user['username'] != null && user['username'].toString().isNotEmpty ? "@${user['username']}" : "",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 10,
                                      color: AppTheme.textColor2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          widget.comment['createdAt'] != null
                              ? timeago.format(
                                DateTime.parse(widget.comment['createdAt']),
                              )
                              : "Recently",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textColor2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return SafeArea(
                                    child: Wrap(
                                      children: [
                                        if (canDelete)
                                          ListTile(
                                            leading: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            title: const Text(
                                              'Delete Comment',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              final auth =
                                                  context.read<AuthProvider>();
                                              if (auth.token != null) {
                                                await context
                                                    .read<CommunityProvider>()
                                                    .deleteCommunityComment(
                                                      auth.token!,
                                                      widget.comment['id'],
                                                    );
                                              }
                                            },
                                          ),
                                        ListTile(
                                          leading: const Icon(
                                            Icons.report_problem,
                                            color: AppTheme.textColor2,
                                          ),
                                          title: Text(
                                            'Report Comment',
                                            style: TextStyle(color: theme.colorScheme.onSurface),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor: Colors.transparent,
                                              builder: (context) => ReportBottomSheet(
                                                itemType: 'COMMENT',
                                                itemId: widget.comment['id'],
                                                reportedUserId: widget.comment['userId'],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Icon(
                              Icons.more_vert,
                              size: 16,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                /// Comment Text
                LayoutBuilder(
                  builder: (context, constraints) {
                    final span = TextSpan(
                      text: widget.comment['text'] ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.6,
                        color: theme.colorScheme.onSurface,
                        fontSize: 13,
                      ),
                    );

                    final tp = TextPainter(
                      text: span,
                      maxLines: 5,
                      textDirection: TextDirection.ltr,
                    );

                    tp.layout(maxWidth: constraints.maxWidth);

                    final isOverflowing = tp.didExceedMaxLines;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isExpanded
                            ? FormattedText(
                              (widget.comment['text'] ?? '')
                                  .toString()
                                  .replaceAll(RegExp(r'\n(?!\n)'), '\n\n'),
                              style: theme.textTheme.bodySmall?.copyWith(
                                height: 1.6,
                                color: theme.colorScheme.onSurface,
                                fontSize: 13,
                              ),
                            )
                            : ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 110),
                              child: FormattedText(
                                (widget.comment['text'] ?? '')
                                    .toString()
                                    .replaceAll(RegExp(r'\n(?!\n)'), '\n\n'),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  height: 1.6,
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        if (isOverflowing && !isExpanded)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpanded = true;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                "See more",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff673aff),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 12),

                /// Actions
                Row(
                  children: [
                    GestureDetector(
                      onTap: _likeComment,
                      child: Stat(
                        icon: HugeIcons.strokeRoundedThumbsUp,
                        text: "$likesCount",
                        iconSize: 18,
                        textColor: AppTheme.textColor2,
                        textSize: 12,
                      ),
                    ),
                    Text(
                      " - ",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: AppTheme.textColor2,
                      ),
                    ),
                    GestureDetector(
                      onTap:
                          () => widget.onReply(
                            widget.rootCommentId ?? widget.comment['id'],
                            user['username'] ?? '',
                          ),
                      child: Text(
                        "Reply",
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (replies.isNotEmpty)
            ...replies.map(
              (reply) => CommentItem(
                comment: reply,
                postId: widget.postId,
                onReply: widget.onReply,
                isReply: true,
                rootCommentId: widget.rootCommentId ?? widget.comment['id'],
              ),
            ),
        ],
      ),
    );
  }
}

class _PostMenuDialogBox extends StatelessWidget {
  final Map<String, dynamic> post;

  const _PostMenuDialogBox({required this.post});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final isOwner = auth.user?['id'] == post['userId'];

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 15),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                final link = 'https://quest.vidarave.com/post/${post['id']}';
                showInAppShareSheet(
                  context,
                  shareMessage: 'Check out this post on Quest! $link',
                );
              },
              child: SettingsRowItem(
                icon: HugeIcons.strokeRoundedShare08,
                iconBackgroundColor: Colors.transparent,
                title: 'Share this post',
                iconColor: AppTheme.textColor2,
                secondIconColor: Colors.transparent,
              ),
            ),
            if (!isOwner) ...[
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Close the options bottom sheet
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => ReportBottomSheet(
                      itemType: 'POST',
                      itemId: post['id'],
                      reportedUserId: post['userId'],
                    ),
                  );
                },
                child: SettingsRowItem(
                  icon: HugeIcons.strokeRoundedAlertDiamond,
                  iconBackgroundColor: Colors.transparent,
                  title: 'Report this post',
                  iconColor: AppTheme.textColor2,
                  secondIconColor: Colors.transparent,
                ),
              ),
            ],
            if (isOwner) ...[
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPostScreen(post: post),
                    ),
                  );
                },
                child: SettingsRowItem(
                  icon: HugeIcons.strokeRoundedEdit02,
                  iconBackgroundColor: Colors.transparent,
                  title: 'Edit post',
                  iconColor: AppTheme.textColor2,
                  secondIconColor: Colors.transparent,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final provider = context.read<CommunityProvider>();
                  await provider.deletePost(auth.token!, post['id']);
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pop(context); // Go back to community page
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post deleted.')),
                    );
                  }
                },
                child: SettingsRowItem(
                  icon: HugeIcons.strokeRoundedDelete01,
                  iconBackgroundColor: Colors.transparent,
                  title: 'Delete post',
                  iconColor: Colors.red,
                  secondIconColor: Colors.transparent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
