import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';

class SavedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String verse;
  final List<String> verses;
  final String time;
  final double? width;
  final VoidCallback? onDelete;

  const SavedCard({
    super.key,
    this.title = "Psalms 78 : 1 - 4 ",
    this.subtitle =
        "The Mystery of the cross of Jesus Christ, The Mystery of the cross of Jesus Christ",
    this.verse = "John 3:16",
    this.verses = const ["John 3:16", "Romans 8:28", "Psalm 23:1"],
    this.time = "Today • 2:49pm",

    this.width, // ✅ important for horizontal list
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: width ?? double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: theme.colorScheme.surface,
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
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedChurch,
                          size: 18,
                          color:
                              theme.textTheme.bodyMedium?.color ?? Colors.black,
                          strokeWidth: 1,
                        ),
                        SizedBox(width: 5),
                        SizedBox(
                          width: 200,
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              height: 1,
                              fontWeight: FontWeight.normal,
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                        Spacer(),
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: onDelete,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )
                        else
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedBookmark02,
                            size: 18,
                            color:
                                theme.textTheme.bodyMedium?.color ??
                                Colors.black,
                            strokeWidth: 1,
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
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

                    const SizedBox(height: 5),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '- ',
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

                    /// TIME
                    const SizedBox(height: 1),

                    /// ACTIONS
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
