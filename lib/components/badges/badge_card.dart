import 'package:flutter/material.dart';
import 'package:quest/theme/theme.dart';

class BadgeCard extends StatelessWidget {
  final String title;
  final String progressStat;
  final String badgeImage;
  final double progress;

  const BadgeCard({
    super.key,
    required this.title,
    required this.progressStat,
    required this.badgeImage,
    required this.progress,
  });

  ImageProvider _getBadgeImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    }
    // Map backend default seeds to existing assets
    if (imagePath.contains('first_word')) {
      return const AssetImage('assets/images/bronze.png');
    }
    if (imagePath.contains('quiz_master')) {
      return const AssetImage('assets/images/silver.png');
    }
    if (imagePath.contains('streak_builder')) {
      return const AssetImage('assets/images/gold.png');
    }

    final cleanPath =
        imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    if (cleanPath.startsWith('assets/')) {
      return AssetImage(cleanPath);
    }
    return AssetImage('assets/images/$cleanPath');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double size = 60; // Avatar + ring size
    double strokeWidth = 5; // Ring thickness

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 1, color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular progress around avatar
            Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: strokeWidth,
                    color: Colors.grey.shade200,
                  ),
                ),

                // Progress ring
                SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: strokeWidth,
                    color: const Color(0xff00d4ff),
                    backgroundColor: Colors.transparent,
                  ),
                ),

                // Avatar perfectly fits inside the ring
                Container(
                  width: size - strokeWidth,
                  height: size - strokeWidth,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _getBadgeImage(badgeImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  progressStat,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: AppTheme.textColor2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
