import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class NavigationCards extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String description;
  final Color iconColor;
  final String time;

  const NavigationCards({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    this.iconColor = const Color(0xfffbfcfb),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7.5),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: HugeIcon(
                  icon: icon,
                  size: 18,
                  color: const Color(0xff8e8e93),
                  strokeWidth: 2,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(text: '$title\n'),
                      TextSpan(
                        text: description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        if (time.isNotEmpty)
          Text(
            time,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black38,
              fontSize: 11,
            ),
          ),
      ],
    );
  }
}
