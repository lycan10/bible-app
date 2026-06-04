import 'package:flutter/material.dart';
import 'package:quest/services/api_service.dart';

class FeatureProvider extends ChangeNotifier {
  Map<String, bool> _features = {};
  bool _isLoading = true;

  Map<String, bool> get features => _features;
  bool get isLoading => _isLoading;

  /// Check if a specific feature is enabled.
  /// Defaults to true if the feature hasn't been loaded or is missing,
  /// to ensure we don't accidentally hide features if the network fails.
  bool isFeatureEnabled(String key) {
    if (!_features.containsKey(key)) {
      return true; // Default to true
    }
    return _features[key] ?? true;
  }

  Future<void> loadFeatures() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.fetchFeatures();
      // print('Features: $response');
      if (response.isNotEmpty) {
        _features = Map<String, bool>.from(response);
      }
    } catch (e) {
      // print('Error loading features: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
