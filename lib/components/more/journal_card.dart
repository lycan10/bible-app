import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/components/more/inline_verse_text.dart';
import 'package:quest/screens/notes/view_note_screen.dart';
import 'package:quest/utils/text_parser.dart';

class JournalCard extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final String verse;
  final List<String> verses;
  final List<String> feelings;
  final String time;
  final double? width;
  final Function(String)? onVerseTap;
  final VoidCallback? onEditCompleted;

  const JournalCard({
    super.key,
    required this.id,
    this.title = "The Journey of faith in Modern Times",
    this.subtitle =
        "The Mystery of the cross of Jesus Christ, The Mystery of the cross of Jesus Christ",
    this.verse = "John 3:16",
    this.verses = const ["John 3:16", "Romans 8:28", "Psalm 23:1"],
    this.feelings = const [],
    this.time = "Today • 2:49pm",
    this.width, // ✅ important for horizontal list
    this.onVerseTap,
    this.onEditCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ViewNoteScreen(
                  id: id,
                  title: title,
                  bodyText: subtitle,
                  time: time,
                  verses: verses,
                  feelings: feelings,
                  type: "Journal",
                ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            // width: width ?? double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: theme.colorScheme.surfaceContainer,
              border: Border.all(width: 0.15, color: AppTheme.textColor2),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedLeaf02,
                        size: 20,
                        color: AppTheme.primaryBlue,
                        strokeWidth: 1,
                      ),
                    ),
                    SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// CONTENT
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 15,
                                height: 1.3,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          SizedBox(
                            width: double.infinity,
                            child: InlineVerseText(
                              text: TextParser.extractTextFromDelta(subtitle),
                              onVerseTap: onVerseTap ?? (v) {},
                              maxLines: 2,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 12,
                                height: 1.5,
                                fontWeight: FontWeight.normal,
                                color: theme.colorScheme.onTertiary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 1),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: ' - ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    color: AppTheme.textColor2,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                TextSpan(
                                  text: time,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                    color: theme.textTheme.bodyMedium?.color,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 5),
                          SizedBox(
                            height: 15, // 👈 control divider height
                            child: VerticalDivider(
                              width: 2,
                              thickness: 1,
                              color: AppTheme.textColor2.withValues(alpha: 0.5),
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              feelings.isEmpty
                                  ? "Feelings: none"
                                  : "Feelings: ${feelings.join(', ')}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
