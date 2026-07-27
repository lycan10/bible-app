import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:share_plus/share_plus.dart';

class FeedProvider with ChangeNotifier {
  Map<String, dynamic>? _dailyVerse;
  Map<String, dynamic>? _feed;
  Map<String, dynamic>? _explore;
  List<dynamic> _friends = [];
  List<dynamic> _friendSuggestions = [];
  List<dynamic> _pendingRequests = [];
  List<dynamic> _badgesProgress = [];
  List<dynamic> _feelingsMetadata = [];
  Map<String, dynamic>? _currentFeeling;

  bool _isLoading = false;
  String? _errorMessage;
  String _affirmation = "God loves me, and I know it";

  Map<String, dynamic>? get dailyVerse => _dailyVerse;
  Map<String, dynamic>? get feed => _feed;
  Map<String, dynamic>? get explore => _explore;
  List<dynamic> get friends => _friends;
  List<dynamic> get friendSuggestions => _friendSuggestions;
  List<dynamic> get pendingRequests => _pendingRequests;
  List<dynamic> get badgesProgress => _badgesProgress;
  List<dynamic> get feelingsMetadata => _feelingsMetadata;
  Map<String, dynamic>? get currentFeeling => _currentFeeling;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get affirmation => _affirmation;

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
      _affirmation = _feed?['affirmation'] ?? "God loves me, and I know it";
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
    _dailyVerse!['likesCount'] =
        (_dailyVerse!['likesCount'] ?? 0) + (wasLiked ? -1 : 1);
    notifyListeners();

    try {
      final result = await ApiService.toggleDailyVerseLike(token);
      // Sync with server if needed
      if (result['liked'] != _dailyVerse!['hasLiked']) {
        _dailyVerse!['hasLiked'] = result['liked'];
        _dailyVerse!['likesCount'] =
            (_dailyVerse!['likesCount'] ?? 0) + (result['liked'] ? 1 : -1);
        notifyListeners();
      }
    } catch (e) {
      // Revert optimistic update on error
      _dailyVerse!['hasLiked'] = wasLiked;
      _dailyVerse!['likesCount'] =
          (_dailyVerse!['likesCount'] ?? 0) + (wasLiked ? 1 : -1);
      notifyListeners();
      debugPrint("Error toggling like: $e");
    }
  }

  Future<Map<String, dynamic>> shareDailyVerse(String token) async {
    if (_dailyVerse == null) return {};

    final verseText = _dailyVerse!['text'] ?? '';
    final reference = _dailyVerse!['reference'] ?? '';
    final devotionId = _dailyVerse!['id'];

    String shareContent =
        '"$verseText" - $reference\n\nRead more on Shalom App!';
    if (devotionId != null) {
      final link = 'https://quest.vidarave.com/devotion/$devotionId';
      shareContent =
          '"$verseText" - $reference\n\nRead more on Shalom App! $link';
    }

    try {
      await Share.share(shareContent);
    } catch (e) {
      debugPrint("Error launching share sheet: $e");
      return {};
    }

    // Optimistic update
    _dailyVerse!['sharesCount'] = (_dailyVerse!['sharesCount'] ?? 0) + 1;
    notifyListeners();

    try {
      final result = await ApiService.shareDailyVerse(token);
      _dailyVerse!['sharesCount'] = result['sharesCount'];
      notifyListeners();
      return result;
    } catch (e) {
      // Revert optimistic update
      _dailyVerse!['sharesCount'] = (_dailyVerse!['sharesCount'] ?? 0) - 1;
      notifyListeners();
      debugPrint("Error sharing verse: $e");
      return {};
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
      if (res['affirmation'] != null) {
        _affirmation = res['affirmation'];
      }
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
        ApiService.fetchFriendSuggestions(token),
        ApiService.fetchPendingFriendRequests(token),
      ]);
      _friends = results[0];
      _badgesProgress = results[1];
      _friendSuggestions = results[2];
      _pendingRequests = results[3];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send friend request
  Future<bool> sendFriendRequest(String token, String targetUserId) async {
    try {
      await ApiService.sendFriendRequest(token, targetUserId);
      // Remove from suggestions
      _friendSuggestions.removeWhere((user) => user['id'] == targetUserId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error sending friend request: $e");
      return false;
    }
  }

  // Accept friend request
  Future<bool> acceptFriendRequest(String token, String targetUserId) async {
    try {
      await ApiService.acceptFriendRequest(token, targetUserId);
      final acceptedUser = _pendingRequests.firstWhere(
        (user) => user['id'] == targetUserId,
        orElse: () => null,
      );
      if (acceptedUser != null) {
        _friends.add(acceptedUser);
        _pendingRequests.removeWhere((user) => user['id'] == targetUserId);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error accepting friend request: $e");
      return false;
    }
  }

  // Reject friend request
  Future<bool> rejectFriendRequest(String token, String targetUserId) async {
    try {
      await ApiService.rejectFriendRequest(token, targetUserId);
      _pendingRequests.removeWhere((user) => user['id'] == targetUserId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error rejecting friend request: $e");
      return false;
    }
  }
}
