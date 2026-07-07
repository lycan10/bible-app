import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BibleService {
  static Database? _db;

  // Book names for mapping Book integer to name
  static const List<String> bookNames = [
    "Genesis",
    "Exodus",
    "Leviticus",
    "Numbers",
    "Deuteronomy",
    "Joshua",
    "Judges",
    "Ruth",
    "1 Samuel",
    "2 Samuel",
    "1 Kings",
    "2 Kings",
    "1 Chronicles",
    "2 Chronicles",
    "Ezra",
    "Nehemiah",
    "Esther",
    "Job",
    "Psalms",
    "Proverbs",
    "Ecclesiastes",
    "Song of Solomon",
    "Isaiah",
    "Jeremiah",
    "Lamentations",
    "Ezekiel",
    "Daniel",
    "Hosea",
    "Joel",
    "Amos",
    "Obadiah",
    "Jonah",
    "Micah",
    "Nahum",
    "Habakkuk",
    "Zephaniah",
    "Haggai",
    "Zechariah",
    "Malachi",
    "Matthew",
    "Mark",
    "Luke",
    "John",
    "Acts",
    "Romans",
    "1 Corinthians",
    "2 Corinthians",
    "Galatians",
    "Ephesians",
    "Philippians",
    "Colossians",
    "1 Thessalonians",
    "2 Thessalonians",
    "1 Timothy",
    "2 Timothy",
    "Titus",
    "Philemon",
    "Hebrews",
    "James",
    "1 Peter",
    "2 Peter",
    "1 John",
    "2 John",
    "3 John",
    "Jude",
    "Revelation",
  ];

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "holybible.db");

    // Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      // print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(
        join("assets", "bible", "holybible.db"),
      );
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      // print("Opening existing database");
    }
    // open the database
    return await openDatabase(path, readOnly: true);
  }

  static Future<List<Map<String, dynamic>>> getBooks() async {
    List<Map<String, dynamic>> books = [];
    for (int i = 0; i < bookNames.length; i++) {
      books.add({'index': i, 'name': bookNames[i]});
    }
    return books;
  }

  static Future<int> getChaptersCount(int bookIndex) async {
    final db = await database;
    var result = await db.rawQuery(
      'SELECT MAX(Chapter) as maxChapter FROM bible WHERE Book = ?',
      [bookIndex],
    );
    if (result.isNotEmpty && result.first['maxChapter'] != null) {
      return result.first['maxChapter'] as int;
    }
    return 0;
  }

  static Future<List<Map<String, dynamic>>> getVerses(
    int bookIndex,
    int chapterNumber,
  ) async {
    final db = await database;
    return await db.query(
      'bible',
      columns: ['Versecount', 'verse'],
      where: 'Book = ? AND Chapter = ?',
      whereArgs: [bookIndex, chapterNumber],
      orderBy: 'Versecount ASC',
    );
  }

  static Future<List<Map<String, dynamic>>> searchVerses(String query) async {
    final db = await database;
    return await db.query(
      'bible',
      where: 'verse LIKE ?',
      whereArgs: ['%$query%'],
      limit: 100, // Limit search results to avoid freezing
    );
  }

  static String formatReference(int bookIndex, int chapter, int verse) {
    if (bookIndex >= 0 && bookIndex < bookNames.length) {
      return "${bookNames[bookIndex]} $chapter:$verse";
    }
    return "Unknown Reference";
  }

  // Parse strings like "John 3:16" or "GEN.1.1". Very basic parser.
  static Map<String, int>? parseReference(String refString) {
    try {
      var parts = refString.split(' ');
      if (parts.length >= 2) {
        String bookPart = parts.sublist(0, parts.length - 1).join(' ');
        String cvPart = parts.last;

        var cvParts = cvPart.split(':');
        if (cvParts.length == 2) {
          int chapter = int.parse(cvParts[0]);
          // Handle ranges like "16-18"
          var verseParts = cvParts[1].split('-');
          int verse = int.parse(verseParts[0]);
          int endVerse =
              verseParts.length > 1 ? int.parse(verseParts[1]) : verse;

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
    } catch (e) {
      // print("Error parsing reference: $e");
    }
    return null;
  }

  static Future<String?> getVerseText(String reference) async {
    var parsed = parseReference(reference);
    if (parsed != null) {
      final db = await database;
      var result = await db.query(
        'bible',
        columns: ['Versecount', 'verse'],
        where:
            'Book = ? AND Chapter = ? AND Versecount >= ? AND Versecount <= ?',
        whereArgs: [
          parsed['book'],
          parsed['chapter'],
          parsed['verse'],
          parsed['endVerse'],
        ],
        orderBy: 'Versecount ASC',
      );
      if (result.isNotEmpty) {
        return result
            .map((r) => '[${r['Versecount']}] ${r['verse']}')
            .join(' ');
      }
    }
    return null;
  }
}
