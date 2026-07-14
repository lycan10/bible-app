import 'package:flutter/foundation.dart';
import 'package:quest/services/api_service.dart';

class DevotionProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<dynamic> _myPlans = [];
  List<dynamic> get myPlans => _myPlans;

  List<dynamic> _allPlans = [];
  List<dynamic> get allPlans => _allPlans;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  List<dynamic> _searchResults = [];
  List<dynamic> get searchResults => _searchResults;

  String? _error;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<void> loadPlans(String token) async {
    _setLoading(true);
    _setError(null);
    try {
      final results = await Future.wait([
        ApiService.fetchMyDevotionPlans(token),
        ApiService.fetchDevotionPlans(token),
      ]);
      _myPlans = results[0];
      _allPlans = results[1];
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchPlans(String token, String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }
    _setLoading(true);
    _setError(null);
    _isSearching = true;
    try {
      _searchResults = await ApiService.searchDevotionPlans(token, query);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void clearSearch() {
    _isSearching = false;
    _searchResults = [];
    notifyListeners();
  }

  Future<void> subscribeToPlan(String token, String planId) async {
    try {
      await ApiService.subscribeDevotionPlan(token, planId);
      // Reload plans to reflect the new subscription
      await loadPlans(token);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> unsubscribeFromPlan(String token, String planId) async {
    try {
      await ApiService.unsubscribeDevotionPlan(token, planId);
      // Remove from myPlans locally to be optimistic
      _myPlans.removeWhere((item) => item['plan']['id'] == planId);
      notifyListeners();
      await loadPlans(token);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchDayContent(
    String token,
    String planId,
    int dayNum,
  ) async {
    return await ApiService.fetchDevotionDay(token, planId, dayNum);
  }

  Future<Map<String, dynamic>> completeDevotionDay(
    String token,
    String planId,
    int dayNum,
  ) async {
    try {
      final res = await ApiService.completeDevotionDay(token, planId, dayNum);
      // Refresh local plans
      await loadPlans(token);
      return res;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> setReminder(
    String token,
    String planId,
    String time,
    bool enabled,
  ) async {
    try {
      await ApiService.updateDevotionReminder(token, planId, time, enabled);
      // Update locally
      final planIndex = _myPlans.indexWhere((p) => p['plan']['id'] == planId);
      if (planIndex != -1) {
        _myPlans[planIndex]['reminderTime'] = time;
        _myPlans[planIndex]['reminderEnabled'] = enabled;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> likeDevotionDay(String token, String dayId) async {
    try {
      await ApiService.likeDevotionDay(token, dayId);
      // The day's like count increments. Since day content is fetched per screen,
      // the screen can handle the optimistic update locally for better UX.
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<String> shareDevotionPlan(String token, String planId) async {
    try {
      final response = await ApiService.shareDevotionPlan(token, planId);
      return response['shareUrl'] ?? '';
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }
}
