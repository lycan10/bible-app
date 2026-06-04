import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class TitleTwo extends StatelessWidget {
  final dynamic leadingIcon;
  final String title;
  // final VoidCallback leadingIconTap;

  const TitleTwo({
    super.key,
    required this.leadingIcon,
    required this.title,
    // required this.leadingIconTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// Center Title (TRUE center)
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          /// Leading Icon (LEFT)
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: HugeIcon(
                  icon: leadingIcon,
                  size: 22,
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
