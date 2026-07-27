import 'package:flutter/foundation.dart';
import 'package:quest/services/api_service.dart';

class MediaProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _error;
  String? get error => _error;

  List<dynamic> _videos = [];
  List<dynamic> get videos => _videos;

  String? _nextCursor;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  List<dynamic> _videoCategories = [];
  List<dynamic> get videoCategories => _videoCategories;

  String? _videoSearchQuery;
  String? get videoSearchQuery => _videoSearchQuery;

  Map<String, dynamic>? _continueWatching;
  Map<String, dynamic>? get continueWatching => _continueWatching;

  List<dynamic> _audio = [];
  List<dynamic> get audio => _audio;

  String? _nextAudioCursor;
  bool _hasMoreAudios = true;
  bool get hasMoreAudios => _hasMoreAudios;

  bool _isLoadingMoreAudios = false;
  bool get isLoadingMoreAudios => _isLoadingMoreAudios;

  List<dynamic> _audioCategories = [];
  List<dynamic> get audioCategories => _audioCategories;

  String? _audioSearchQuery;
  String? get audioSearchQuery => _audioSearchQuery;

  Map<String, dynamic>? _continueListening;
  Map<String, dynamic>? get continueListening => _continueListening;

  String? _token;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  /// Initial load — clears existing data and fetches first page of videos.
  Future<void> loadVideoData(String token, {String? search}) async {
    _token = token;
    _videoSearchQuery = search;
    _setLoading(true);
    _setError(null);
    _videos = [];
    _nextCursor = null;
    _hasMore = true;

    try {
      final results = await Future.wait([
        ApiService.fetchVideos(token, limit: 10, search: _videoSearchQuery),
        ApiService.fetchVideoCategories(token),
        ApiService.fetchContinueWatching(token),
      ]);

      final page = results[0] as Map<String, dynamic>;
      _videos = List<dynamic>.from(page['items'] as List? ?? []);
      _nextCursor = page['nextCursor'] as String?;
      _hasMore = (page['hasMore'] as bool?) ?? false;
      _videoCategories = results[1] as List<dynamic>;
      _continueWatching = results[2] as Map<String, dynamic>?;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Append the next page of videos to the existing list.
  Future<void> loadMoreVideos() async {
    if (_isLoadingMore || !_hasMore || _nextCursor == null || _token == null)
      return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final page = await ApiService.fetchVideos(
        _token!,
        cursor: _nextCursor,
        search: _videoSearchQuery,
        limit: 10,
      );

      final newItems = List<dynamic>.from(page['items'] as List? ?? []);
      _videos = [..._videos, ...newItems];
      _nextCursor = page['nextCursor'] as String?;
      _hasMore = (page['hasMore'] as bool?) ?? false;
    } catch (e) {
      debugPrint('Failed to load more videos: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadAudioData(String token, {String? search}) async {
    _token = token;
    _audioSearchQuery = search;
    _setLoading(true);
    _setError(null);
    _audio = [];
    _nextAudioCursor = null;
    _hasMoreAudios = true;

    try {
      final results = await Future.wait([
        ApiService.fetchAudio(token, limit: 10, search: _audioSearchQuery),
        ApiService.fetchAudioCategories(token),
        ApiService.fetchContinueListening(token),
      ]);

      final page = results[0] as Map<String, dynamic>;
      _audio = List<dynamic>.from(page['items'] as List? ?? []);
      _nextAudioCursor = page['nextCursor'] as String?;
      _hasMoreAudios = (page['hasMore'] as bool?) ?? false;

      _audioCategories = results[1] as List<dynamic>;
      _continueListening = results[2] as Map<String, dynamic>?;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreAudios() async {
    if (_isLoadingMoreAudios || !_hasMoreAudios || _nextAudioCursor == null || _token == null)
      return;

    _isLoadingMoreAudios = true;
    notifyListeners();

    try {
      final page = await ApiService.fetchAudio(
        _token!,
        cursor: _nextAudioCursor,
        search: _audioSearchQuery,
        limit: 10,
      );

      final newItems = List<dynamic>.from(page['items'] as List? ?? []);
      _audio = [..._audio, ...newItems];
      _nextAudioCursor = page['nextCursor'] as String?;
      _hasMoreAudios = (page['hasMore'] as bool?) ?? false;
    } catch (e) {
      debugPrint('Failed to load more audios: $e');
    } finally {
      _isLoadingMoreAudios = false;
      notifyListeners();
    }
  }

  Future<void> likeVideo(String token, String videoId) async {
    try {
      final res = await ApiService.likeVideo(token, videoId);
      final index = _videos.indexWhere((v) => v['id'] == videoId);
      if (index != -1) {
        _videos[index]['likes'] = res['likes'] ?? _videos[index]['likes'];
        _videos[index]['hasLiked'] = res['hasLiked'];
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<Map<String, dynamic>> trackVideoPlayback(
    String token,
    String videoId,
    int progressSeconds,
    bool completed,
  ) async {
    try {
      return await ApiService.trackVideoPlayback(
        token,
        videoId,
        progressSeconds,
        completed,
      );
    } catch (e) {
      debugPrint("Failed to track video playback: $e");
      return {};
    }
  }

  Future<void> likeAudio(String token, String audioId) async {
    try {
      await ApiService.likeAudio(token, audioId);
      final index = _audio.indexWhere((a) => a['id'] == audioId);
      if (index != -1) {
        _audio[index]['likes'] = (_audio[index]['likes'] ?? 0) + 1;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<Map<String, dynamic>> trackAudioPlayback(
    String token,
    String audioId,
    int progressSeconds,
    bool completed,
  ) async {
    try {
      return await ApiService.trackAudioPlayback(
        token,
        audioId,
        progressSeconds,
        completed,
      );
    } catch (e) {
      debugPrint("Failed to track audio playback: $e");
      return {};
    }
  }
}
