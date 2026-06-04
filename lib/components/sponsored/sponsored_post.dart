import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/action_pill/action_pill_button.dart';
import 'package:quest/components/stats/stats.dart';
import 'package:quest/components/tile/settings_row_item.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/theme/theme.dart';

class SponsoredPostScreen extends StatelessWidget {
  const SponsoredPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comments = List.generate(
      5,
      (index) => CommentModel(
        name: "Lola Able",
        username: "@lola.a",
        time: "${index + 1}m",
        message:
            "Building something from scratch is never just about the final product. "
            "It’s about the quiet hours, the tiny improvements, and the lessons learned "
            "along the way. Growth happens in small steps taken daily.",
      ),
    );
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
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
                      return Center(child: _PostMenuDialogBox());
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
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.textColor2.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Sponsored",
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  50,
                                ), // half of image width/height
                                child: Image.asset(
                                  'assets/images/user_test.jpg',
                                  width: 42,
                                  height: 42,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lola Able',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "@lola.a",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: 12,
                                      color: AppTheme.textColor2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            "Today 3:15pm",
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: AppTheme.textColor2,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: GridView.builder(
                          shrinkWrap: true, // ✅ FIX
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 4,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                              ),
                          itemBuilder: (context, index) {
                            if (index < 3) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'assets/images/user_test.jpg',
                                  fit: BoxFit.cover,
                                ),
                              );
                            } else {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset(
                                      'assets/images/user_test.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                    Container(
                                      color: Colors.black.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                    const Center(
                                      child: Text(
                                        "+3",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Stat(
                                icon: HugeIcons.strokeRoundedThumbsUp,
                                text: "20",
                                iconSize: 18,
                                textColor: AppTheme.textColor2,
                                textSize: 12,
                              ),
                              const SizedBox(width: 10),
                              Stat(
                                icon: HugeIcons.strokeRoundedComment01,
                                text: "29",
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
                                onTap: () {},
                              ),
                              SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {},
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
                                        "React (384)",
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
                                        "🤩",
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
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
                      SizedBox(height: 20),
                      // Text Body
                      Text(
                        "Building something from scratch is never just about the final product — it’s about the quiet hours, the tiny improvements, and the lessons learned along the way. Every bug fixed, every design tweak, and every line of code written adds up to something bigger than you first imagined. Growth doesn’t happen in giant leaps; it happens in consistent, intentional steps taken daily. No matter where you are in your journey, remember that progress is progress — even when it feels slow. Stay patient with yourself, celebrate small wins, and keep pushing forward. The version of you that once struggled with what you now find easy is proof that you’re evolving. Keep going — you’re building more than a project, you’re building yourself.",
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.normal,
                          height: 1.6,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 25),
                      Text(
                        "Comments(29)",
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Column(
                        children:
                            comments
                                .map((comment) => CommentItem(comment: comment))
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
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const HugeIcon(
                                icon: HugeIcons.strokeRoundedAdd01,
                                size: 22,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const TextField(
                                  decoration: InputDecoration(
                                    hintText: "Type a message...",
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color:
                                        Colors
                                            .black, // Set the desired font size
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
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

class CommentModel {
  final String name;
  final String username;
  final String message;
  final String time;

  CommentModel({
    required this.name,
    required this.username,
    required this.message,
    required this.time,
  });
}

class CommentItem extends StatefulWidget {
  final CommentModel comment;

  const CommentItem({super.key, required this.comment});

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
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
                    child: Image.asset(
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
                        widget.comment.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        widget.comment.username,
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
                widget.comment.time,
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
                text: widget.comment.message,
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.6,
                  color: Colors.black,
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
                  Text(
                    widget.comment.message,
                    maxLines: isExpanded ? null : 5,
                    overflow:
                        isExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.6,
                      color: Colors.black,
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
                text: "454",
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
                  color: Colors.black,
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
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
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
              title: 'Share this post',
              iconColor: AppTheme.textColor2,
              secondIconColor: Colors.transparent,
            ),
            SettingsRowItem(
              icon: HugeIcons.strokeRoundedFavourite,
              iconBackgroundColor: Colors.transparent,
              title: 'I\'ll like to see more like this',
              iconColor: AppTheme.textColor2,
              secondIconColor: Colors.transparent,
            ),
            SettingsRowItem(
              icon: HugeIcons.strokeRoundedAlertDiamond,
              iconBackgroundColor: Colors.transparent,
              title: 'Report this post',
              iconColor: AppTheme.textColor2,
              secondIconColor: Colors.transparent,
            ),
            SettingsRowItem(
              icon: HugeIcons.strokeRoundedDelete01,
              iconBackgroundColor: Colors.transparent,
              title: 'Delete post',
              iconColor: AppTheme.textColor2,
              secondIconColor: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}
