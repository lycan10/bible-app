import 'package:flutter/material.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/services/api_service.dart';

class CircleStuff extends StatelessWidget {
  final String title;
  final String description;
  final double? width;
  final double? titleFont;
  final double? titleWidth;
  final double? descriptionFont;
  final double? height;
  final String? avatarUrl;
  final VoidCallback onTap;

  const CircleStuff({
    super.key,
    required this.title,
    required this.description,
    this.width,
    this.height,
    this.titleFont,
    this.descriptionFont,
    this.titleWidth,
    this.avatarUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: width ?? 80,
            height: height ?? 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(50),
              image: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? DecorationImage(
                      image: ApiService.getFullImageUrl(avatarUrl!).startsWith('http')
                          ? NetworkImage(ApiService.getFullImageUrl(avatarUrl!))
                          : AssetImage(ApiService.getFullImageUrl(avatarUrl!)) as ImageProvider,
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: AssetImage('assets/images/boy.png'),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: titleWidth ?? 100,
            child: Text(
              title,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: titleFont ?? 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: descriptionFont ?? 14,
              color: AppTheme.textColor2,
            ),
          ),
        ],
      ),
    );
  }
}
