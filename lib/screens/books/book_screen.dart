import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:quest/components/action_pill/action_pill_button.dart';
import 'package:quest/components/stats/stats.dart';
import 'package:quest/components/tile/settings_row_item.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quest/components/share/in_app_share_sheet.dart';
import 'package:quest/screens/books/pdf_viewer_screen.dart';
import 'package:quest/components/formatted_text.dart';

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
      final isSaved = savedBooksList.any((b) => b['bookId'] == widget.book!['id']);

      if (mounted) {
        setState(() {
          _comments = commentsRes;
          _reactions = reactionsRes;
          _isSaved = isSaved;
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

  Future<void> _toggleReaction() async {
    if (widget.book == null || widget.book!['id'] == null) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.token;
    final currentUser = auth.user;
    if (token == null || currentUser == null) return;

    try {
      final res = await ApiService.reactToBook(token, widget.book!['id'], '🤩');

      setState(() {
        if (res['added'] == true) {
          _reactions.add(res['reaction']);
        } else {
          _reactions.removeWhere(
            (r) => r['userId'] == currentUser['id'] && r['emoji'] == '🤩',
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
        builder: (context) => PdfViewerScreen(
          title: title,
          pdfUrl: url,
        ),
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
          SnackBar(content: Text(res['message'] ?? (_isSaved ? "Saved" : "Unsaved"))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save book.")));
    }
  }

  void _shareBook() {
    showInAppShareSheet(
      context,
      shareMessage: "Check out this book on Quest! ${widget.book?['title'] ?? ''} - ${widget.book?['downloadUrl'] ?? ''}",
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    int reactionCount = _reactions.where((r) => r['emoji'] == '🤩').length;

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
                      return Center(child: _PostMenuDialogBox(
                        onShare: _shareBook,
                        onSave: _toggleSave,
                        isSaved: _isSaved,
                      ));
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
                                          'assets/images/user_test.jpg', // Should be book author avatar if available
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
                                    widget.book != null &&
                                            widget.book!['createdAt'] != null
                                        ? widget.book!['createdAt']
                                            .toString()
                                            .substring(0, 10)
                                        : "Today",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                      color: AppTheme.textColor2,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Stat(
                                        icon: HugeIcons.strokeRoundedThumbsUp,
                                        text: "$reactionCount",
                                        iconSize: 18,
                                        textColor: AppTheme.textColor2,
                                        textSize: 12,
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
                                  Row(
                                    children: [
                                      ActionPillButton(
                                        icon: HugeIcons.strokeRoundedShare08,
                                        label: "Share",
                                        onTap: _shareBook,
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
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "React ($reactionCount)",
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                "🤩",
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xff673aff),
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
                                              ? Image.network(
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
                                          color: AppTheme.completedColor,
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
                            ? Image.network(
                              user['avatarUrl'],
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                            )
                            : Image.asset(
                              'assets/images/user_test.jpg',
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

  const _PostMenuDialogBox({
    required this.onShare,
    required this.onSave,
    required this.isSaved,
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
              icon: isSaved ? HugeIcons.strokeRoundedBookmark02 : HugeIcons.strokeRoundedBookmark02,
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
