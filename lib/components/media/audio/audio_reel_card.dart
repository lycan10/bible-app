import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AudioReelCard extends StatelessWidget {
  final String title;
  final String duration;
  final String author;
  final String likes;
  final String backgroundImage;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const AudioReelCard({
    super.key,
    required this.title,
    required this.author,
    required this.likes,
    required this.backgroundImage,
    this.onTap,
    this.width,
    this.height,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 275,
        width: width ?? 204,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              /// 🔹 Background Image
              backgroundImage.startsWith('http')
                  ? Image.network(backgroundImage, fit: BoxFit.cover)
                  : Image.asset(backgroundImage, fit: BoxFit.cover),

              /// 🔹 Dark overlay for readability
              Container(color: Colors.black.withValues(alpha: 0.5)),

              /// 🔹 Bottom Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      duration,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'by: ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          TextSpan(
                            text: author,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              size: 16,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              likes,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.5,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),

                            shape: BoxShape.circle,
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedAudioWave01,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
