import 'package:flutter/material.dart';

class OnboardingButton extends StatelessWidget {
  final String title;
  final Color? backgroungColor;
  final GestureTapCallback ontap;
  const OnboardingButton({
    super.key,
    required this.title,
    required this.ontap,
    this.backgroungColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: ontap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: backgroungColor ?? Colors.black,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
