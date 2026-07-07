import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/bible_service.dart';
import '../services/api_service.dart';

class BibleProvider with ChangeNotifier {
  bool _isLoading = true;
  int _currentBookIndex = 0; // Genesis
  int _currentChapter = 1;
  int _chaptersCount = 50; // Genesis has 50 chapters
  List<Map<String, dynamic>> _verses = [];
  double _fontSize = 18.0;

  // Backend Sync State
  List<dynamic> _bookmarks = [];
  List<dynamic> _highlights = [];

  int _bookmarksPage = 1;
  bool _hasMoreBookmarks = true;
  bool _isLoadingMoreBookmarks = false;

  int _highlightsPage = 1;
  bool _hasMoreHighlights = true;
  bool _isLoadingMoreHighlights = false;

  bool get hasMoreBookmarks => _hasMoreBookmarks;
  bool get isLoadingMoreBookmarks => _isLoadingMoreBookmarks;

  bool get hasMoreHighlights => _hasMoreHighlights;
  bool get isLoadingMoreHighlights => _isLoadingMoreHighlights;
  final List<dynamic> _notes = [];

  bool get isLoading => _isLoading;
  int get currentBookIndex => _currentBookIndex;
  int get currentChapter => _currentChapter;
  int get chaptersCount => _chaptersCount;
  List<Map<String, dynamic>> get verses => _verses;
  double get fontSize => _fontSize;

  List<dynamic> get bookmarks => _bookmarks;
  List<dynamic> get highlights => _highlights;
  List<dynamic> get notes => _notes;

  BibleProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadFontSize();
    await loadVerses(_currentBookIndex, _currentChapter);
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble('bible_font_size') ?? 18.0;
    notifyListeners();
  }

  Future<void> setFontSize(double newSize) async {
    _fontSize = newSize;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bible_font_size', newSize);
    notifyListeners();
  }

  Future<void> loadVerses(int bookIndex, int chapterNumber) async {
    _isLoading = true;
    notifyListeners();

    _currentBookIndex = bookIndex;
    _currentChapter = chapterNumber;

    _chaptersCount = await BibleService.getChaptersCount(bookIndex);
    _verses = await BibleService.getVerses(bookIndex, chapterNumber);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> nextChapter() async {
    if (_currentChapter < _chaptersCount) {
      await loadVerses(_currentBookIndex, _currentChapter + 1);
    } else if (_currentBookIndex < BibleService.bookNames.length - 1) {
      await loadVerses(_currentBookIndex + 1, 1);
    }
  }

  Future<void> previousChapter() async {
    if (_currentChapter > 1) {
      await loadVerses(_currentBookIndex, _currentChapter - 1);
    } else if (_currentBookIndex > 0) {
      int prevBookChapters = await BibleService.getChaptersCount(
        _currentBookIndex - 1,
      );
      await loadVerses(_currentBookIndex - 1, prevBookChapters);
    }
  }

  // ---- Sync Methods ----

  Future<void> syncData(String token) async {
    try {
      _bookmarksPage = 1;
      _highlightsPage = 1;
      _hasMoreBookmarks = true;
      _hasMoreHighlights = true;

      final bRes = await ApiService.getBookmarks(token, page: 1);
      final hRes = await ApiService.getHighlights(token, page: 1);

      _bookmarks = bRes;
      _highlights = hRes;

      if (bRes.length < 20) _hasMoreBookmarks = false;
      if (hRes.length < 20) _hasMoreHighlights = false;

      notifyListeners();
    } catch (e) {
      // print("Error syncing bible data: $e");
    }
  }

  Future<void> loadMoreBookmarks(String token) async {
    if (_isLoadingMoreBookmarks || !_hasMoreBookmarks) return;
    _isLoadingMoreBookmarks = true;
    notifyListeners();
    try {
      final bRes = await ApiService.getBookmarks(
        token,
        page: _bookmarksPage + 1,
      );
      _bookmarksPage++;
      _bookmarks.addAll(bRes);
      if (bRes.length < 20) _hasMoreBookmarks = false;
    } catch (e) {
      // print("Error loading more bookmarks: $e");
    } finally {
      _isLoadingMoreBookmarks = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreHighlights(String token) async {
    if (_isLoadingMoreHighlights || !_hasMoreHighlights) return;
    _isLoadingMoreHighlights = true;
    notifyListeners();
    try {
      final hRes = await ApiService.getHighlights(
        token,
        page: _highlightsPage + 1,
      );
      _highlightsPage++;
      _highlights.addAll(hRes);
      if (hRes.length < 20) _hasMoreHighlights = false;
    } catch (e) {
      // print("Error loading more highlights: $e");
    } finally {
      _isLoadingMoreHighlights = false;
      notifyListeners();
    }
  }

  bool isBookmarked(int verseCount) {
    String ref = BibleService.formatReference(
      _currentBookIndex,
      _currentChapter,
      verseCount,
    );
    return _bookmarks.any((b) => b['verseRef'] == ref);
  }

  String? getHighlightColor(int verseCount) {
    String ref = BibleService.formatReference(
      _currentBookIndex,
      _currentChapter,
      verseCount,
    );
    for (var h in _highlights) {
      if (h['verseRef'] == ref) {
        return h['color'];
      }
    }
    return null;
  }

  Future<bool> toggleBookmark(String token, int verseCount) async {
    String ref = BibleService.formatReference(
      _currentBookIndex,
      _currentChapter,
      verseCount,
    );
    var existing = _bookmarks.where((b) => b['verseRef'] == ref).toList();
    if (existing.isNotEmpty) {
      // Remove
      try {
        await ApiService.deleteBookmark(token, existing.first['id']);
        _bookmarks.removeWhere((b) => b['id'] == existing.first['id']);
        notifyListeners();
        return true;
      } catch (e) {
        // print("Error deleting bookmark: $e");
        return false;
      }
    } else {
      // Add
      try {
        var res = await ApiService.createBookmark(token, ref);
        if (res['id'] != null) {
          // backend returns the created object directly
          _bookmarks.add(res);
          notifyListeners();
          return true;
        }
        return false;
      } catch (e) {
        // print("Error creating bookmark: $e");
        return false;
      }
    }
  }

  Future<bool> addHighlight(String token, int verseCount, String color) async {
    String ref = BibleService.formatReference(
      _currentBookIndex,
      _currentChapter,
      verseCount,
    );

    // check if it exists, maybe delete old one first
    var existing = _highlights.where((h) => h['verseRef'] == ref).toList();
    for (var h in existing) {
      try {
        await ApiService.deleteHighlight(token, h['id']);
        _highlights.removeWhere((item) => item['id'] == h['id']);
      } catch (_) {}
    }

    try {
      var res = await ApiService.createHighlight(token, ref, color);
      if (res['id'] != null) {
        _highlights.add(res);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      // print("Error creating highlight: $e");
      return false;
    }
  }

  Future<bool> removeHighlight(String token, int verseCount) async {
    String ref = BibleService.formatReference(
      _currentBookIndex,
      _currentChapter,
      verseCount,
    );
    var existing = _highlights.where((h) => h['verseRef'] == ref).toList();
    if (existing.isNotEmpty) {
      try {
        await ApiService.deleteHighlight(token, existing.first['id']);
        _highlights.removeWhere((h) => h['id'] == existing.first['id']);
        notifyListeners();
        return true;
      } catch (e) {
        // print("Error deleting highlight: $e");
        return false;
      }
    }
    return true;
  }
}
