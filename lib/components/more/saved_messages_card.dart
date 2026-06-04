import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';

class SavedMessagesCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String verse;
  final List<String> verses;
  final String time;
  final double? width;

  const SavedMessagesCard({
    super.key,
    this.title = "The Journey of faith in Modern Times",
    this.subtitle =
        "The Mystery of the cross of Jesus Christ, The Mystery of the cross of Jesus Christ",
    this.verse = "John 3:16",
    this.verses = const ["John 3:16", "Romans 8:28", "Psalm 23:1"],
    this.time = "Today • 2:49pm",

    this.width, // ✅ important for horizontal list
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          // width: width ?? double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: theme.colorScheme.surface,
            border: Border.all(width: 0.15, color: AppTheme.textColor2),
          ),
          clipBehavior: Clip.hardEdge,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// CONTENT
                  SizedBox(
                    width: 200,
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        height: 1.3,
                        fontWeight: FontWeight.normal,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'From: ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textColor2,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                          text: "Author",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      const HugeIcon(
                        icon: HugeIcons.strokeRoundedThumbsUp,
                        size: 16,
                        color: Color(0xff8e8e93),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "385",
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: AppTheme.textColor2,
                        ),
                      ),
                      const SizedBox(height: 5),
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
                                fontSize: 14,
                                color: theme.textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  /// TIME
                  const SizedBox(height: 1),
                ],
              ),
              Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  "assets/images/alucard.png",
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                ),
              ),
              SizedBox(width: 8),
              HugeIcon(
                icon: HugeIcons.strokeRoundedBookmark02,
                size: 18,
                color: theme.textTheme.bodyMedium?.color ?? Colors.black,
                strokeWidth: 1,
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
