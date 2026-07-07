import 'package:flutter/material.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/components/avatar.dart';

class ConnectCard extends StatelessWidget {
  final String name;
  final String username;
  final String imagePath;

  final VoidCallback? connectTap;

  final Widget? trailing;

  const ConnectCard({
    super.key,
    required this.name,
    required this.username,
    required this.imagePath,
    this.connectTap,

    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              /// LEFT CONTENT
              Expanded(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: CustomAvatar(imageUrl: imagePath, radius: 20.5, hasBorder: true),
                    ),
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
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 2),

                          Text(
                            username,
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

              GestureDetector(
                onTap: connectTap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child:
                      trailing ??
                      Text(
                        "Connect",
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
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
