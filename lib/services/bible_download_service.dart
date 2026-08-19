import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BibleDownloadService {
  static const String _downloadUrl = 'https://quest.vidarave.com/api/v1/media/download/bible.db';

  static Future<bool> checkIfDbExists() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "bible.db");
    return await File(path).exists();
  }

  static Future<void> downloadBibleDatabase(
    String token, {
    required Function(double progress) onProgress,
    required Function() onComplete,
    required Function(String error) onError,
  }) async {
    try {
      var databasesPath = await getDatabasesPath();
      var path = join(databasesPath, "bible.db");

      // Make sure the directory exists
      final dir = Directory(dirname(path));
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Download using Dio
      Dio dio = Dio();
      await dio.download(
        _downloadUrl,
        path,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = received / total;
            onProgress(progress);
          } else {
            // Fallback if total size is unknown
            onProgress(-1);
          }
        },
      );
      
      onComplete();
    } catch (e) {
      onError(e.toString());
    }
  }
}
