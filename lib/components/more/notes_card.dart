import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/components/more/inline_verse_text.dart';
import 'package:quest/screens/notes/view_note_screen.dart';
import 'package:quest/utils/text_parser.dart';

class NotesCard extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final String verse;
  final List<String> verses;
  final String time;
  final double? width;
  final bool isFavorite;
  final Function(String)? onVerseTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onEditCompleted;

  const NotesCard({
    super.key,
    required this.id,
    this.title = "The Mystery of the cross of Jesus Christ",
    this.subtitle =
        "The Mystery of the cross of Jesus Christ, The Mystery of the cross of Jesus Christ",
    this.verse = "John 3:16",
    this.verses = const ["John 3:16", "Romans 8:28", "Psalm 23:1"],
    this.time = "Today • 2:49pm",
    this.width, // ✅ important for horizontal list
    this.isFavorite = false,
    this.onVerseTap,
    this.onFavoriteTap,
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
                  type: "Note",
                ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: width ?? double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: theme.colorScheme.surfaceContainer,
              border: Border.all(width: 0.15, color: AppTheme.textColor2),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// CONTENT
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TITLE
                      SizedBox(
                        width: 200,
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            height: 1,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: InlineVerseText(
                          text: TextParser.extractTextFromDelta(subtitle),
                          onVerseTap: onVerseTap ?? (v) {},
                          maxLines: 2,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 13,
                            height: 1.5,
                            fontWeight: FontWeight.normal,
                            color: theme.colorScheme.onTertiary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '- ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    color: theme.textTheme.bodyMedium?.color,
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
                          GestureDetector(
                            onTap: onFavoriteTap,
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedFavourite,
                              size: 18,
                              color:
                                  isFavorite
                                      ? Colors.red
                                      : Colors.grey.shade400,
                              strokeWidth: isFavorite ? 2 : 1,
                            ),
                          ),
                        ],
                      ),

                      /// TIME
                      const SizedBox(height: 1),

                      /// ACTIONS
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
