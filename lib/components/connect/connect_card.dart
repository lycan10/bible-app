import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';

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
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              /// LEFT CONTENT
              Expanded(
                child: Row(
                  children: [
                    _Avatar(image: imagePath, ontap: () {}),
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
                          color: Colors.black,
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

class _Avatar extends StatelessWidget {
  final String image;
  final VoidCallback ontap;

  const _Avatar({required this.image, required this.ontap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
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
      ),
    );
  }
}
