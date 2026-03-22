import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ImageRowTile extends StatelessWidget {
  final dynamic icon;
  final Gradient? iconGradient;
  final Color? iconBackgroundColor;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final GestureTapCallback? onTap;
  final Color? secondIconColor;

  const ImageRowTile({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    this.subtitle,
    this.onTap,
    required this.iconColor,
    this.iconGradient,
    this.secondIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      10,
                    ), // half of image width/height
                    child: Image.asset(
                      'assets/images/user_test.jpg',
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 0),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        SizedBox(
                          width: 260,
                          child: Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 18,
                color: secondIconColor ?? Color(0xff8e8e93),
                strokeWidth: 2,
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
