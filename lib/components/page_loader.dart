import 'package:flutter/material.dart';
import 'package:quest/theme/theme.dart';

class PageLoader extends StatelessWidget {
  final bool isLoading;
  final bool hasData;
  final Widget child;

  const PageLoader({
    super.key,
    required this.isLoading,
    required this.hasData,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && !hasData) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryBlue,
          ),
        ),
      );
    }

    return Stack(
      children: [
        child,
        if (isLoading && hasData)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              color: AppTheme.primaryBlue,
              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
            ),
          ),
      ],
    );
  }
}
