import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class GameService {
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('auth_user');
    if (userStr != null) {
      try {
        final user = jsonDecode(userStr);
        return user['id']?.toString();
      } catch (_) {}
    }
    return null;
  }

  static Future<Map<String, dynamic>> fetchWordMatchQuestions(
    String difficulty,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${ApiService.baseUrl}/games/play/word-match?difficulty=$difficulty',
      ),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load Word Match questions');
    }
  }

  static Future<Map<String, dynamic>> fetchWordCrossQuestions(
    String difficulty,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${ApiService.baseUrl}/games/play/word-cross?difficulty=$difficulty',
      ),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load Word Cross questions');
    }
  }

  static Future<Map<String, dynamic>> fetchBibleQuizQuestions(int level) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/games/play/bible-quiz?level=$level'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load Bible Quiz questions');
    }
  }

  static Future<int> fetchBibleQuizMaxLevel() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/games/play/bible-quiz/max-level'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['maxLevel'] as int? ?? 302;
    } else {
      return 302;
    }
  }

  static Future<void> submitScore(
    String gameType,
    String difficulty,
    int score,
  ) async {
    final userId = await _getUserId();
    if (userId == null) return;

    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/games/score'),
      headers: await _getAuthHeaders(),
      body: json.encode({
        'userId': userId,
        'gameType': gameType,
        'difficulty': difficulty,
        'score': score,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit score');
    }
  }

  static Future<Map<String, dynamic>> fetchScores(String gameType) async {
    final userId = await _getUserId();
    if (userId == null) return {'topScore': 0, 'lastScore': 0};

    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/games/score/$userId?gameType=$gameType'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch scores');
    }
  }
}
