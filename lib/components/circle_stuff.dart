import 'package:flutter/material.dart';
import 'package:quest/theme/theme.dart';

class CircleStuff extends StatelessWidget {
  final String title;
  final String description;
  final double? width;
  final double? titleFont;
  final double? titleWidth;
  final double? descriptionFont;
  final double? height;

  const CircleStuff({
    super.key,
    required this.title,
    required this.description,
    this.width,
    this.height,
    this.titleFont,
    this.descriptionFont,
    this.titleWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: width ?? 80,
          height: height ?? 80,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        SizedBox(height: 5),
        SizedBox(
          width: titleWidth ?? 100,
          child: Text(
            title,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: titleFont ?? 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          description,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: descriptionFont ?? 14,
            color: AppTheme.textColor2,
          ),
        ),
      ],
    );
  }
}
