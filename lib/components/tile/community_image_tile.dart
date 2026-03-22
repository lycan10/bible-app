import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';

class CommunityImageTile extends StatelessWidget {
  final String name;
  final String message;
  final String imagePath;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;

  const CommunityImageTile({
    super.key,
    required this.name,
    required this.message,
    required this.imagePath,
    this.onTap,
    this.onLongPress,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            /// LEFT CONTENT
            Expanded(
              child: Row(
                children: [
                  _Avatar(image: imagePath),
                  const SizedBox(width: 10),

                  /// TEXT AREA
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              name,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            trailing ??
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedArrowRight01,
                                  size: 18,
                                  color: AppTheme.textColor2,
                                  strokeWidth: 2,
                                ),
                          ],
                        ),

                        const SizedBox(height: 2),

                        Text(
                          message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textColor2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// TRAILING (customizable)
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String image;

  const _Avatar({required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 41,
      height: 41,
      padding: const EdgeInsets.all(0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff00d4ff), Color(0xff4a3aff)],
        ),
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(radius: 10, backgroundImage: AssetImage(image)),
    );
  }
}
