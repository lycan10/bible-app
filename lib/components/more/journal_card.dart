import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';

class JournalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String verse;
  final List<String> verses;
  final String time;
  final double? width;

  const JournalCard({
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
            color: Colors.white,
            border: Border.all(width: 0.15, color: AppTheme.textColor2),
          ),
          clipBehavior: Clip.hardEdge,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: AppTheme.completedColor.withValues(alpha: 0.08),
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedLeaf02,
                  size: 20,
                  color: AppTheme.completedColor,
                  strokeWidth: 1,
                ),
              ),
              SizedBox(width: 13),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// CONTENT
                  SizedBox(
                    width: 200,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        height: 1.3,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  SizedBox(
                    width: 250,
                    child: Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.normal,
                        color: AppTheme.textColor2,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
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
                                color: Colors.black,
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
                      SizedBox(
                        width: 150,
                        child: Text(
                          "Feelings: pleasant, Happy, good",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),

                  /// TIME
                  const SizedBox(height: 1),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _actionItem(ThemeData theme, IconData icon, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 14, color: AppTheme.textColor2),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _iconButton(dynamic icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: HugeIcon(icon: icon, size: 18, color: color, strokeWidth: 1),
    );
  }
}
