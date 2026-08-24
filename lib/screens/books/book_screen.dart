import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:quest/components/action_pill/action_pill_button.dart';
import 'package:quest/components/reaction_picker.dart';
import 'package:quest/components/stats/stats.dart';
import 'package:quest/components/tile/settings_row_item.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quest/components/share/in_app_share_sheet.dart';
import 'package:quest/components/report_bottom_sheet.dart';
import 'package:quest/screens/books/pdf_viewer_screen.dart';
import 'package:quest/components/formatted_text.dart';
import 'package:quest/utils/date_formatter.dart';

class BookScreen extends StatefulWidget {
  final Map<String, dynamic>? book;
  const BookScreen({super.key, this.book});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  bool _isLoading = true;
  List<dynamic> _comments = [];
  List<dynamic> _reactions = [];
  bool _isSaved = false;
  int _likesCount = 0;
  bool _hasLiked = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (widget.book == null || widget.book!['id'] == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final commentsRes = await ApiService.fetchBookComments(
        token,
        widget.book!['id'],
      );
      final reactionsRes = await ApiService.fetchBookReactions(
        token,
        widget.book!['id'],
      );
      final savedBooksRes = await ApiService.fetchSavedBooks(token);
      final savedBooksList = List<dynamic>.from(savedBooksRes['data'] ?? []);
      final isSaved = savedBooksList.any(
        (b) => b['bookId'] == widget.book!['id'],
      );

      // We can fetch updated book details to get hasLiked and likesCount
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/books/${widget.book!['id']}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      Map<String, dynamic>? updatedBook;
      if (response.statusCode == 200) {
        updatedBook = jsonDecode(response.body);
      }

      if (mounted) {
        setState(() {
          _comments = commentsRes;
          _reactions = reactionsRes;
          _isSaved = isSaved;
          _likesCount =
              updatedBook?['likesCount'] ?? widget.book?['likesCount'] ?? 0;
          _hasLiked = updatedBook?['hasLiked'] ?? false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    if (widget.book == null || widget.book!['id'] == null) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null) return;

    try {
      final newComment = await ApiService.addBookComment(
        token,
        widget.book!['id'],
        _commentController.text.trim(),
      );
      _commentController.clear();

      setState(() {
        _comments.insert(0, newComment);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add comment.")));
    }
  }

  Future<void> _toggleReaction(String emoji) async {
    if (widget.book == null || widget.book!['id'] == null) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    final currentUser = auth.user;
    if (token == null || currentUser == null) return;

    try {
      final res = await ApiService.reactToBook(
        token,
        widget.book!['id'],
        emoji,
      );

      setState(() {
        if (res['added'] == true) {
          _reactions.add(res['reaction']);
        } else {
          _reactions.removeWhere(
            (r) => r['userId'] == currentUser['id'] && r['emoji'] == emoji,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to react.")));
    }
  }

  Future<void> _toggleLike() async {
    if (widget.book == null || widget.book!['id'] == null) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null) return;

    try {
      final res = await ApiService.likeBook(token, widget.book!['id']);

      setState(() {
        if (res['liked'] == true) {
          _hasLiked = true;
          _likesCount++;
        } else {
          _hasLiked = false;
          _likesCount = _likesCount > 0 ? _likesCount - 1 : 0;
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to like.")));
    }
  }

  void _launchUrl() {
    if (widget.book == null || widget.book!['downloadUrl'] == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Download URL not available.")));
      return;
    }

    final url = widget.book!['downloadUrl'];
    final title = widget.book!['title'] ?? 'Book';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(title: title, pdfUrl: url),
      ),
    );
  }

  Future<void> _toggleSave() async {
    if (widget.book == null || widget.book!['id'] == null) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    if (token == null) return;

    try {
      final res = await ApiService.toggleSaveBook(token, widget.book!['id']);
      setState(() {
        _isSaved = res['saved'] == true;
      });
      if (mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? (_isSaved ? "Saved" : "Unsaved")),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save book.")));
    }
  }

  void _shareBook() {
    showInAppShareSheet(
      context,
      shareMessage:
          "Check out this book on Sozo App! ${widget.book?['title'] ?? ''} - ${widget.book?['downloadUrl'] ?? ''}",
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Map<String, int> reactionCountsMap = {};
    for (var r in _reactions) {
      final emoji = r['emoji'] as String?;
      if (emoji != null) {
        reactionCountsMap[emoji] = (reactionCountsMap[emoji] ?? 0) + 1;
      }
    }
    int reactionCount = _reactions.length;

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
                      return Center(
                        child: _PostMenuDialogBox(
                          onShare: _shareBook,
                          onSave: _toggleSave,
                          isSaved: _isSaved,
                          book: widget.book,
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 25),
              Expanded(
                child:
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          50,
                                        ), // half of image width/height
                                        child: Image.asset(
                                          'assets/images/boy.png', // Should be book author avatar if available
                                          width: 42,
                                          height: 42,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.book?['author'] ??
                                                'Unknown Author',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      theme
                                                          .colorScheme
                                                          .onSurface,
                                                  fontSize: 14,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    DateFormatter.formatTimeAgo(
                                      widget.book?['createdAt'],
                                    ),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                      color: AppTheme.textColor2,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                runSpacing: 10,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: _toggleLike,
                                        child: Stat(
                                          icon: HugeIcons.strokeRoundedThumbsUp,
                                          text: "$_likesCount",
                                          iconSize: 18,
                                          textColor:
                                              _hasLiked
                                                  ? AppTheme.primaryBlue
                                                  : AppTheme.textColor2,
                                          iconColor:
                                              _hasLiked
                                                  ? AppTheme.primaryBlue
                                                  : null,
                                          textSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Stat(
                                        icon: HugeIcons.strokeRoundedComment01,
                                        text: "${_comments.length}",
                                        iconSize: 18,
                                        textColor: AppTheme.textColor2,
                                        textSize: 12,
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      ActionPillButton(
                                        icon: HugeIcons.strokeRoundedShare08,
                                        label: "Share",
                                        onTap: _shareBook,
                                      ),
                                      SizedBox(width: 10),
                                      Builder(
                                        builder: (context) {
                                          return GestureDetector(
                                            onTapDown: (details) {
                                              showReactionPicker(
                                                context,
                                                details.globalPosition,
                                                (emoji) {
                                                  _toggleReaction(emoji);
                                                },
                                              );
                                            },
                                            child: Container(
                                              height: 40,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 13,
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Color(
                                                  0xff673aff,
                                                ).withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    reactionCount > 0
                                                        ? "React ($reactionCount)"
                                                        : "React",
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                            0xff673aff,
                                                          ),
                                                          fontSize: 12,
                                                        ),
                                                  ),
                                                  if (reactionCountsMap
                                                      .isNotEmpty) ...[
                                                    const SizedBox(width: 5),
                                                    const VerticalDivider(
                                                      width: 4,
                                                      thickness: 1.5,
                                                      color: Color(0xff673aff),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    ...reactionCountsMap.entries.map(
                                                      (e) => Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              right: 4.0,
                                                            ),
                                                        child: Text(
                                                          "${e.key} ${e.value}",
                                                          style: theme
                                                              .textTheme
                                                              .bodySmall
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color(
                                                                  0xff673aff,
                                                                ),
                                                                fontSize: 13,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 25),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 180,
                                    height: 200,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child:
                                          widget.book != null &&
                                                  widget.book!['imageUrl'] !=
                                                      null
                                              ? CachedNetworkImage(
                                                imageUrl:
                                                    widget.book!['imageUrl'],
                                                fit: BoxFit.cover,
                                              )
                                              : Image.asset(
                                                'assets/images/book.jpeg',
                                                fit: BoxFit.cover,
                                              ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.book?['title'] ?? "Unknown Title",
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),

                              Text(
                                widget.book?['description'] ??
                                    "No description available.",
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.normal,
                                  height: 1.4,
                                  color: AppTheme.textColor2,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 15),
                              GestureDetector(
                                onTap: _launchUrl,
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Read",
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  theme.colorScheme.onSurface,
                                              fontSize: 14,
                                            ),
                                      ),
                                      const SizedBox(width: 5),
                                      HugeIcon(
                                        icon:
                                            HugeIcons
                                                .strokeRoundedArrowUpRight01,
                                        size: 16,
                                        color: Color(0xff673aff),
                                        strokeWidth: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 25),
                              Text(
                                "Comments(${_comments.length})",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 10),
                              Column(
                                children:
                                    _comments
                                        .map(
                                          (comment) =>
                                              CommentItem(comment: comment),
                                        )
                                        .toList(),
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
                                        color: theme.colorScheme.surface,
                                        shape: BoxShape.circle,
                                      ),
                                      child: HugeIcon(
                                        icon: HugeIcons.strokeRoundedAdd01,
                                        size: 22,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface,
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: _commentController,
                                          decoration: InputDecoration(
                                            hintText: "Type a message...",
                                            border: InputBorder.none,
                                            hintStyle: TextStyle(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.5),
                                            ),
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
                                      onTap: _addComment,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryBlue,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const HugeIcon(
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
            ],
          ),
        ),
      ),
    );
  }
}

class CommentItem extends StatefulWidget {
  final Map<String, dynamic> comment;

  const CommentItem({super.key, required this.comment});

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.comment['user'] ?? {};

    return Container(
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
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child:
                        user['avatarUrl'] != null
                            ? CachedNetworkImage(
                              imageUrl: user['avatarUrl'],
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                            )
                            : Image.asset(
                              'assets/images/boy.png',
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                            ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}"
                                .trim()
                                .isEmpty
                            ? "Unknown"
                            : "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        user['username'] != null ? "@${user['username']}" : "",
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: AppTheme.textColor2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                widget.comment['createdAt'] != null
                    ? widget.comment['createdAt'].toString().substring(0, 10)
                    : "",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: AppTheme.textColor2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          /// Comment Text
          LayoutBuilder(
            builder: (context, constraints) {
              final span = TextSpan(
                text: widget.comment['content'] ?? "",
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.6,
                  color: theme.colorScheme.onSurface,
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
                        widget.comment['content'] ?? "",
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.6,
                          color: theme.colorScheme.onSurface,
                        ),
                      )
                      : ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 110),
                        child: FormattedText(
                          widget.comment['content'] ?? "",
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.6,
                            color: theme.colorScheme.onSurface,
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
              Stat(
                icon: HugeIcons.strokeRoundedThumbsUp,
                text: "0",
                iconSize: 18,
                textColor: AppTheme.textColor2,
                textSize: 12,
              ),
              Text(
                " - ",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: AppTheme.textColor2,
                ),
              ),
              Text(
                "Reply",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostMenuDialogBox extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onSave;
  final bool isSaved;
  final dynamic book;

  const _PostMenuDialogBox({
    super.key,
    required this.onShare,
    required this.onSave,
    required this.isSaved,
    required this.book,
  });

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
          children: [
            SizedBox(height: 15),

            SettingsRowItem(
              icon: HugeIcons.strokeRoundedShare08,
              iconBackgroundColor: Colors.transparent,
              title: 'Share this book',
              iconColor: AppTheme.textColor2,
              secondIconColor: Colors.transparent,
              onTap: () {
                Navigator.pop(context);
                onShare();
              },
            ),
            SettingsRowItem(
              icon:
                  isSaved
                      ? HugeIcons.strokeRoundedBookmark02
                      : HugeIcons.strokeRoundedBookmark02,
              iconBackgroundColor: Colors.transparent,
              title: isSaved ? 'Remove from saved books' : 'Save this book',
              iconColor: AppTheme.textColor2,
              secondIconColor: Colors.transparent,
              onTap: onSave,
            ),
            SettingsRowItem(
              icon: HugeIcons.strokeRoundedAlertDiamond,
              iconBackgroundColor: Colors.transparent,
              title: 'Report this book',
              iconColor: AppTheme.textColor2,
              secondIconColor: Colors.transparent,
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder:
                      (context) => ReportBottomSheet(
                        itemType: 'BOOK',
                        itemId: book['id'],
                      ),
                );
              },
            ),
            SettingsRowItem(
              icon: HugeIcons.strokeRoundedDelete01,
              iconBackgroundColor: Colors.transparent,
              title: 'Remove author',
              iconColor: AppTheme.textColor2,
              secondIconColor: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
