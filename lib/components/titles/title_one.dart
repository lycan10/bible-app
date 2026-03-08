import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class TitleOne extends StatelessWidget {
  final dynamic leadingIcon;
  final String title;
  final dynamic trailingIcon;
  final GestureTapCallback leadingIconTap;
  final GestureTapCallback trailingIconTap;

  const TitleOne({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.trailingIcon,
    required this.leadingIconTap,
    required this.trailingIconTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: leadingIconTap,
          child: Container(
            padding: EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ),
            child: HugeIcon(
              icon: leadingIcon,
              size: 22,
              color: Colors.black,
              strokeWidth: 1,
            ),
          ),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: trailingIconTap,
          child: Container(
            padding: EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
            ),
            child: HugeIcon(
              icon: trailingIcon,
              size: 22,
              color: Colors.black,
              strokeWidth: 2,
            ),
          ),
        ),
      ],
    );
  }
}
