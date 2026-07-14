import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';

class SavedBooksCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String verse;
  final List<String> verses;
  final String author;
  final String? imageUrl;
  final double? width;

  const SavedBooksCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.verse = "",
    this.verses = const [],
    required this.author,
    this.imageUrl,
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
                  SizedBox(height: 8),
                  SizedBox(
                    width: 200,
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
                          text: author,
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
                ],
              ),
              Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: imageUrl != null 
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                    )
                  : Image.asset(
                      "assets/images/book.jpeg",
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
