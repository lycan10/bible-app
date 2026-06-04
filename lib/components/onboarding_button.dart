import 'package:flutter/material.dart';

class OnboardingButton extends StatelessWidget {
  final String title;
  final Color? backgroungColor;
  final GestureTapCallback ontap;
  final bool isLoading;
  const OnboardingButton({
    super.key,
    required this.title,
    required this.ontap,
    this.backgroungColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isLoading ? null : ontap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: backgroungColor ?? Colors.black,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
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
