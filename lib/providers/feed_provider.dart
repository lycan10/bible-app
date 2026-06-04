import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:share_plus/share_plus.dart';

class FeedProvider with ChangeNotifier {
  Map<String, dynamic>? _dailyVerse;
  Map<String, dynamic>? _feed;
  Map<String, dynamic>? _explore;
  List<dynamic> _friends = [];
  List<dynamic> _badgesProgress = [];
  List<dynamic> _feelingsMetadata = [];
  Map<String, dynamic>? _currentFeeling;

  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get dailyVerse => _dailyVerse;
  Map<String, dynamic>? get feed => _feed;
  Map<String, dynamic>? get explore => _explore;
  List<dynamic> get friends => _friends;
  List<dynamic> get badgesProgress => _badgesProgress;
  List<dynamic> get feelingsMetadata => _feelingsMetadata;
  Map<String, dynamic>? get currentFeeling => _currentFeeling;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load Home dashboard data
  Future<void> loadHomeData(String token, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Parallel requests for faster boot times
      final results = await Future.wait([
        ApiService.fetchDailyVerse(token),
        ApiService.fetchFeed(token),
        ApiService.fetchUserFeeling(token, userId),
      ]);
      _dailyVerse = results[0];
      _feed = results[1];
      _currentFeeling = results[2];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleDailyVerseLike(String token) async {
    if (_dailyVerse == null) return;
    
    // Optimistic update
    final wasLiked = _dailyVerse!['hasLiked'] == true;
    _dailyVerse!['hasLiked'] = !wasLiked;
    _dailyVerse!['likesCount'] = (_dailyVerse!['likesCount'] ?? 0) + (wasLiked ? -1 : 1);
    notifyListeners();

    try {
      final result = await ApiService.toggleDailyVerseLike(token);
      // Sync with server if needed
      if (result['liked'] != _dailyVerse!['hasLiked']) {
        _dailyVerse!['hasLiked'] = result['liked'];
        _dailyVerse!['likesCount'] = (_dailyVerse!['likesCount'] ?? 0) + (result['liked'] ? 1 : -1);
        notifyListeners();
      }
    } catch (e) {
      // Revert optimistic update on error
      _dailyVerse!['hasLiked'] = wasLiked;
      _dailyVerse!['likesCount'] = (_dailyVerse!['likesCount'] ?? 0) + (wasLiked ? 1 : -1);
      notifyListeners();
      debugPrint("Error toggling like: $e");
    }
  }

  Future<void> shareDailyVerse(String token) async {
    if (_dailyVerse == null) return;
    
    final verseText = _dailyVerse!['text'] ?? '';
    final reference = _dailyVerse!['reference'] ?? '';
    final shareContent = '"$verseText" - $reference\n\nRead more on Shalom App!';

    try {
      await Share.share(shareContent);
    } catch (e) {
      debugPrint("Error launching share sheet: $e");
      return;
    }

    // Optimistic update
    _dailyVerse!['sharesCount'] = (_dailyVerse!['sharesCount'] ?? 0) + 1;
    notifyListeners();

    try {
      final result = await ApiService.shareDailyVerse(token);
      _dailyVerse!['sharesCount'] = result['sharesCount'];
      notifyListeners();
    } catch (e) {
      // Revert optimistic update
      _dailyVerse!['sharesCount'] = (_dailyVerse!['sharesCount'] ?? 0) - 1;
      notifyListeners();
      debugPrint("Error sharing verse: $e");
    }
  }

  // Load Explore dashboard data
  Future<void> loadExploreData(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _explore = await ApiService.fetchExplore(token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load feelings metadata
  Future<void> loadFeelingsMetadata() async {
    if (_feelingsMetadata.isNotEmpty) return;
    try {
      _feelingsMetadata = await ApiService.fetchFeelingsMetadata();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading feelings metadata: $e");
    }
  }

  // Update Feeling
  Future<bool> changeFeeling(String token, String feeling, String emoji) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService.updateFeeling(token, feeling, emoji);
      if (res['error'] != null) {
        _errorMessage = res['error'];
        return false;
      }
      _currentFeeling = res;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load Friends & Badges
  Future<void> loadProfileDetails(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        ApiService.fetchFriends(token),
        ApiService.fetchBadgesProgress(token),
      ]);
      _friends = results[0];
      _badgesProgress = results[1];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
