import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';

class SavedMessagesCard extends StatelessWidget {
  final String title;
  final String authorName;
  final String? messageImage;
  final int likesCount;
  final String time;
  final double? width;

  const SavedMessagesCard({
    super.key,
    required this.title,
    required this.authorName,
    this.messageImage,
    required this.likesCount,
    required this.time,
    this.width,
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
                          text: authorName,
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
                        likesCount.toString(),
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
                child: messageImage != null && messageImage!.startsWith('http')
                    ? Image.network(
                        messageImage!,
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          "assets/images/boy.png",
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                        ),
                      )
                    : Image.asset(
                        "assets/images/boy.png",
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
