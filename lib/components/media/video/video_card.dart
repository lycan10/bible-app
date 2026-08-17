import 'package:cached_network_image/cached_network_image.dart';
import 'package:quest/services/api_service.dart';
import 'package:flutter/material.dart';

class VideoCard extends StatelessWidget {
  final String title;
  final String author;
  final String likes;
  final String backgroundImage;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const VideoCard({
    super.key,
    required this.title,
    required this.author,
    required this.likes,
    required this.backgroundImage,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 275,
        width: width ?? 204,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              /// 🔹 Background Image
              Builder(
                builder: (context) {
                  final formattedImage =
                      backgroundImage.isNotEmpty
                          ? ApiService.getFullImageUrl(backgroundImage)
                          : '';
                  return formattedImage.isNotEmpty
                      ? (formattedImage.startsWith('http')
                          ? CachedNetworkImage(imageUrl: formattedImage, fit: BoxFit.cover)
                          : Image.asset(formattedImage, fit: BoxFit.cover))
                      : Container(color: Colors.grey.shade800);
                },
              ),

              /// 🔹 Dark overlay for readability
              Container(color: Colors.black.withValues(alpha: 0.55)),

              /// 🔹 Play Button (Centered)
              // Center(
              //   child: Container(
              //     padding: const EdgeInsets.all(8),
              //     decoration: BoxDecoration(
              //       border: Border.all(
              //         width: 0.5,
              //         color: Colors.white.withValues(alpha: 0.9),
              //       ),

              //       shape: BoxShape.circle,
              //     ),
              //     child: const Icon(
              //       Icons.play_arrow_rounded,
              //       size: 28,
              //       color: Colors.white,
              //     ),
              //   ),
              // ),

              /// 🔹 Bottom Content
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 0),

                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              TextSpan(
                                text: author,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 3),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.favorite_border,
                                size: 14,
                                color: Colors.white70,
                              ),
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
                        const SizedBox(height: 11),
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
