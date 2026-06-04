import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/feature_provider.dart';

class FeatureGuard extends StatelessWidget {
  final String featureKey;
  final Widget child;
  final Widget? fallback;

  const FeatureGuard({
    super.key,
    required this.featureKey,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FeatureProvider>(
      builder: (context, provider, _) {
        if (provider.isFeatureEnabled(featureKey)) {
          return child;
        }
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}
