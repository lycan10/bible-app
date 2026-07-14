import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';

class OngoingDevotionCard extends StatelessWidget {
  final String title;
  final String author;
  final String imagePath;
  final String likes;
  final String planText;
  final int day;
  final bool isCompleted;
  final VoidCallback? onContinue;

  const OngoingDevotionCard({
    super.key,
    required this.title,
    required this.author,
    required this.imagePath,
    required this.likes,
    required this.planText,
    required this.day,
    this.isCompleted = false,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(width: 0.5, color: AppTheme.buttonColor2),
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 5),

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
                            text: author,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),

                    if (likes.isNotEmpty) ...[
                      Row(
                        children: [
                          const HugeIcon(
                            icon: HugeIcons.strokeRoundedThumbsUp,
                            size: 16,
                            color: Color(0xff8e8e93),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            likes,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                    ],

                    Text(
                      planText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 20),

              /// IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child:
                    imagePath.startsWith('http')
                        ? Image.network(
                          imagePath,
                          width: 95,
                          height: 95,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 95,
                              height: 95,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            );
                          },
                        )
                        : Image.asset(
                          imagePath,
                          width: 95,
                          height: 95,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 95,
                              height: 95,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            );
                          },
                        ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          /// BOTTOM ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// DAY CHIP
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Day',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        fontSize: 13,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Text(
                      '$day',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              /// CONTINUE BUTTON
              GestureDetector(
                onTap: onContinue,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted ? AppTheme.greenColor : AppTheme.purpleColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    isCompleted ? 'Completed' : 'Continue',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
