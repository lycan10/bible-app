import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BibleService {
  static Database? _db;
  static List<String> bookNames = [];

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "bible.db");
    return await openDatabase(path, readOnly: true);
  }

  static Future<List<Map<String, dynamic>>> getAvailableTranslations() async {
    final db = await database;
    try {
      return await db.query('bible_version_key');
    } catch (e) {
      return [
        {'table': 't_kjv', 'abbreviation': 'KJV', 'version': 'King James Version'}
      ];
    }
  }

  static Future<List<Map<String, dynamic>>> getBooks() async {
    final db = await database;
    if (bookNames.isEmpty) {
      try {
        var results = await db.query('key_english', orderBy: 'b ASC');
        bookNames = results.map((r) => r['n'] as String).toList();
      } catch (e) {
        // Fallback
        bookNames = ["Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy", "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel", "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", "Ezra", "Nehemiah", "Esther", "Job", "Psalms", "Proverbs", "Ecclesiastes", "Song of Solomon", "Isaiah", "Jeremiah", "Lamentations", "Ezekiel", "Daniel", "Hosea", "Joel", "Amos", "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk", "Zephaniah", "Haggai", "Zechariah", "Malachi", "Matthew", "Mark", "Luke", "John", "Acts", "Romans", "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians", "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians", "1 Timothy", "2 Timothy", "Titus", "Philemon", "Hebrews", "James", "1 Peter", "2 Peter", "1 John", "2 John", "3 John", "Jude", "Revelation"];
      }
    }
    List<Map<String, dynamic>> books = [];
    for (int i = 0; i < bookNames.length; i++) {
      books.add({'index': i, 'name': bookNames[i]});
    }
    return books;
  }

  static Future<int> getChaptersCount(int bookIndex, String translationTable) async {
    final db = await database;
    var result = await db.rawQuery(
      'SELECT MAX(c) as maxChapter FROM $translationTable WHERE b = ?',
      [bookIndex + 1],
    );
    if (result.isNotEmpty && result.first['maxChapter'] != null) {
      return result.first['maxChapter'] as int;
    }
    return 0;
  }

  static Future<List<Map<String, dynamic>>> getVerses(
    int bookIndex,
    int chapterNumber,
    String translationTable,
  ) async {
    final db = await database;
    var results = await db.query(
      translationTable,
      columns: ['v as Versecount', 't as verse'],
      where: 'b = ? AND c = ?',
      whereArgs: [bookIndex + 1, chapterNumber],
      orderBy: 'v ASC',
    );
    return results;
  }

  static Future<List<Map<String, dynamic>>> searchVerses(String query, String translationTable) async {
    final db = await database;
    return await db.query(
      translationTable,
      columns: ['b as Book', 'c as Chapter', 'v as Versecount', 't as verse'],
      where: 't LIKE ?',
      whereArgs: ['%$query%'],
      limit: 100,
    );
  }

  static String formatReference(int bookIndex, int chapter, int verse) {
    if (bookIndex >= 0 && bookNames.isNotEmpty && bookIndex < bookNames.length) {
      return "${bookNames[bookIndex]} $chapter:$verse";
    }
    return "Unknown Reference";
  }

  static Map<String, int>? parseReference(String refString) {
    try {
      var parts = refString.split(' ');
      if (parts.length >= 2) {
        String bookPart = parts.sublist(0, parts.length - 1).join(' ');
        String cvPart = parts.last;

        var cvParts = cvPart.split(':');
        if (cvParts.length == 2) {
          int chapter = int.parse(cvParts[0]);
          var verseParts = cvParts[1].split('-');
          int verse = int.parse(verseParts[0]);
          int endVerse = verseParts.length > 1 ? int.parse(verseParts[1]) : verse;

          int bookIndex = bookNames.indexWhere(
            (name) => name.toLowerCase() == bookPart.toLowerCase(),
          );
          if (bookIndex != -1) {
            return {
              'book': bookIndex,
              'chapter': chapter,
              'verse': verse,
              'endVerse': endVerse,
            };
          }
        }
      }
    } catch (e) {}
    return null;
  }

  static Future<String?> getVerseText(String reference, String translationTable) async {
    var parsed = parseReference(reference);
    if (parsed != null) {
      final db = await database;
      var result = await db.query(
        translationTable,
        columns: ['v as Versecount', 't as verse'],
        where: 'b = ? AND c = ? AND v >= ? AND v <= ?',
        whereArgs: [
          parsed['book']! + 1,
          parsed['chapter'],
          parsed['verse'],
          parsed['endVerse'],
        ],
        orderBy: 'v ASC',
      );
      if (result.isNotEmpty) {
        return result.map((r) => '[${r['Versecount']}] ${r['verse']}').join(' ');
      }
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getCrossReferences(int bookIndex, int chapter, int verse) async {
    final db = await database;
    // vid format: 1001001 for Book 1, Chapter 1, Verse 1 (or it might be formatted differently, wait, let me check the DB)
    // Wait, earlier I saw 1001001. So book is 1, chapter is 001, verse is 001.
    // So vid = book * 1000000 + chapter * 1000 + verse.
    int b = bookIndex + 1;
    int vid = (b * 1000000) + (chapter * 1000) + verse;
    
    var result = await db.query(
      'cross_reference',
      where: 'vid = ?',
      whereArgs: [vid],
      orderBy: 'r ASC', // rank or relevance
    );
    return result;
  }

  static Future<List<Map<String, dynamic>>> getVersesByVids(List<int> vids, String translationTable) async {
    final db = await database;
    List<Map<String, dynamic>> results = [];
    
    for (int vid in vids) {
      int b = (vid / 1000000).floor();
      int c = ((vid % 1000000) / 1000).floor();
      int v = vid % 1000;
      
      var verseResult = await db.query(
        translationTable,
        columns: ['b as book', 'c as chapter', 'v as Versecount', 't as verse'],
        where: 'b = ? AND c = ? AND v = ?',
        whereArgs: [b, c, v],
      );
      
      if (verseResult.isNotEmpty) {
        var mutableResult = Map<String, dynamic>.from(verseResult.first);
        mutableResult['bookName'] = bookNames.isNotEmpty && (b - 1) < bookNames.length ? bookNames[b - 1] : "Book $b";
        results.add(mutableResult);
      }
    }
    
    return results;
  }
}
