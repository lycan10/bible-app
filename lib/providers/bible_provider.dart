import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/bible_service.dart';
import '../services/api_service.dart';
import '../services/bible_download_service.dart';

class BibleProvider with ChangeNotifier {
  bool _isLoading = true;
  bool _isDbReady = false;
  double _downloadProgress = 0.0;
  String? _downloadError;

  int _currentBookIndex = 0; // Genesis
  int _currentChapter = 1;
  int _chaptersCount = 50; 
  int _currentVerse = 1;
  List<Map<String, dynamic>> _verses = [];
  double _fontSize = 18.0;

  String _currentTranslation = 't_kjv';
  List<Map<String, dynamic>> _availableTranslations = [];

  // Cross-Reference Settings
  bool _showInlineCrossReferences = true;
  bool _showActionSheetCrossReferences = true;
  bool _enableStudyMode = false;

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
  bool get isDbReady => _isDbReady;
  double get downloadProgress => _downloadProgress;
  String? get downloadError => _downloadError;

  int get currentBookIndex => _currentBookIndex;
  int get currentChapter => _currentChapter;
  int get currentVerse => _currentVerse;
  int get chaptersCount => _chaptersCount;
  List<Map<String, dynamic>> get verses => _verses;
  double get fontSize => _fontSize;

  String get currentTranslation => _currentTranslation;
  List<Map<String, dynamic>> get availableTranslations => _availableTranslations;

  List<dynamic> get bookmarks => _bookmarks;
  List<dynamic> get highlights => _highlights;
  List<dynamic> get notes => _notes;

  bool get showInlineCrossReferences => _showInlineCrossReferences;
  bool get showActionSheetCrossReferences => _showActionSheetCrossReferences;
  bool get enableStudyMode => _enableStudyMode;

  Future<void> setShowInlineCrossReferences(bool value) async {
    _showInlineCrossReferences = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_inline_cross_references', value);
    notifyListeners();
  }

  Future<void> setShowActionSheetCrossReferences(bool value) async {
    _showActionSheetCrossReferences = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_action_sheet_cross_references', value);
    notifyListeners();
  }

  Future<void> setEnableStudyMode(bool value) async {
    _enableStudyMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_study_mode', value);
    notifyListeners();
  }

  BibleProvider() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble('bible_font_size') ?? 18.0;
    
    // Load last read state
    _currentBookIndex = prefs.getInt('last_book') ?? 0;
    _currentChapter = prefs.getInt('last_chapter') ?? 1;
    _currentVerse = prefs.getInt('last_verse') ?? 1;
    _currentTranslation = prefs.getString('last_translation') ?? 't_kjv';

    _showInlineCrossReferences = prefs.getBool('show_inline_cross_references') ?? true;
    _showActionSheetCrossReferences = prefs.getBool('show_action_sheet_cross_references') ?? true;
    _enableStudyMode = prefs.getBool('enable_study_mode') ?? false;

    _isDbReady = await BibleDownloadService.checkIfDbExists();
    if (_isDbReady) {
      await _initializeDbData();
    } else {
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> _initializeDbData() async {
    _isLoading = true;
    notifyListeners();

    await BibleService.getBooks();
    _availableTranslations = await BibleService.getAvailableTranslations();
    
    // Ensure current translation is valid
    if (!_availableTranslations.any((t) => t['table'] == _currentTranslation)) {
      if (_availableTranslations.isNotEmpty) {
        _currentTranslation = _availableTranslations.first['table'];
      }
    }

    await _loadVersesInternal(_currentBookIndex, _currentChapter);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> startDownload(String token) async {
    _downloadError = null;
    _downloadProgress = 0.0;
    notifyListeners();

    await BibleDownloadService.downloadBibleDatabase(
      token,
      onProgress: (progress) {
        _downloadProgress = progress;
        notifyListeners();
      },
      onComplete: () async {
        _isDbReady = true;
        await _initializeDbData();
      },
      onError: (error) {
        _downloadError = error;
        notifyListeners();
      },
    );
  }

  Future<void> setFontSize(double newSize) async {
    _fontSize = newSize;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bible_font_size', newSize);
    notifyListeners();
  }

  Future<void> setTranslation(String translationTable) async {
    if (_currentTranslation != translationTable) {
      _currentTranslation = translationTable;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_translation', translationTable);
      await loadVerses(_currentBookIndex, _currentChapter);
    }
  }

  Future<void> updateCurrentVerse(int verse) async {
    _currentVerse = verse;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_verse', verse);
  }

  Future<void> loadVerses(int bookIndex, int chapterNumber) async {
    _isLoading = true;
    notifyListeners();
    await _loadVersesInternal(bookIndex, chapterNumber);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadVersesInternal(int bookIndex, int chapterNumber) async {
    _currentBookIndex = bookIndex;
    _currentChapter = chapterNumber;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_book', _currentBookIndex);
    await prefs.setInt('last_chapter', _currentChapter);

    _chaptersCount = await BibleService.getChaptersCount(bookIndex, _currentTranslation);
    _verses = await BibleService.getVerses(bookIndex, chapterNumber, _currentTranslation);
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
        _currentTranslation
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
      try {
        await ApiService.deleteBookmark(token, existing.first['id']);
        _bookmarks.removeWhere((b) => b['id'] == existing.first['id']);
        notifyListeners();
        return true;
      } catch (e) {
        return false;
      }
    } else {
      try {
        var res = await ApiService.createBookmark(token, ref);
        if (res['id'] != null) {
          _bookmarks.add(res);
          notifyListeners();
          return true;
        }
        return false;
      } catch (e) {
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
        return false;
      }
    }
    return true;
  }
}
