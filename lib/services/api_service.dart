import 'dart:convert';
import 'package:http/http.dart' as http;

/// Thrown whenever the server responds with HTTP 401 Unauthorized.
class UnauthorizedException implements Exception {
  const UnauthorizedException();
  @override
  String toString() =>
      'UnauthorizedException: Session expired or invalid token.';
}

class ApiService {
  static String get baseUrl {
    //return 'http://192.168.1.250:8787/api/v1';
    return 'https://bible-app.testimonyismine.workers.dev/api/v1';
  }

  static String getFullImageUrl(String url) {
    if (url.startsWith('http')) return url;
    if (url.startsWith('/api')) {
      final host = baseUrl.replaceAll('/api/v1', '');
      return '$host$url';
    }
    return url;
  }

  /// Register a callback to be invoked whenever any API call returns 401.
  /// Set this once at app startup (e.g. in main.dart) to trigger auto-logout.
  static void Function()? onUnauthorized;

  static Map<String, String> _headers(String? token) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Checks the response status code. Fires [onUnauthorized] and throws
  /// [UnauthorizedException] if the status is 401. Returns the response
  /// unchanged for all other status codes.
  static http.Response _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      onUnauthorized?.call();
      throw const UnauthorizedException();
    }
    return response;
  }

  // POST /auth/otp/send
  static Future<Map<String, dynamic>> sendOtp(String contact) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/otp/send'),
      headers: _headers(null),
      body: jsonEncode({'contact': contact}),
    );
    return jsonDecode(response.body);
  }

  // POST /auth/register
  static Future<Map<String, dynamic>> register({
    required String contact,
    required String code,
    required String password,
    required String firstName,
    required String lastName,
    required String username,
    required String gender,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: _headers(null),
      body: jsonEncode({
        'contact': contact,
        'code': code,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'gender': gender,
      }),
    );
    return jsonDecode(response.body);
  }

  // POST /auth/login
  static Future<Map<String, dynamic>> login({
    required String contact,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(null),
      body: jsonEncode({'contact': contact, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  // POST /auth/password/reset
  static Future<Map<String, dynamic>> resetPassword({
    required String contact,
    required String code,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/password/reset'),
      headers: _headers(null),
      body: jsonEncode({
        'contact': contact,
        'code': code,
        'newPassword': newPassword,
      }),
    );
    return jsonDecode(response.body);
  }

  // GET /auth/username/suggest
  static Future<Map<String, dynamic>> suggestUsernames(String base) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/username/suggest?base=$base'),
      headers: _headers(null),
    );
    return jsonDecode(response.body);
  }

  // POST /users/permissions
  static Future<Map<String, dynamic>> savePermissions(String token) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/users/permissions'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // GET /users/me
  static Future<Map<String, dynamic>> fetchCurrentUser(String token) async {
    final response = _handleResponse(
      await http.get(Uri.parse('$baseUrl/users/me'), headers: _headers(token)),
    );
    return jsonDecode(response.body);
  }

  // PUT /users/me
  static Future<Map<String, dynamic>> updateProfile(
    String token,
    Map<String, dynamic> data,
  ) async {
    final response = _handleResponse(
      await http.put(
        Uri.parse('$baseUrl/users/me'),
        headers: _headers(token),
        body: jsonEncode(data),
      ),
    );
    return jsonDecode(response.body);
  }

  // PUT /users/me/settings
  static Future<Map<String, dynamic>> updateSettings(
    String token,
    Map<String, dynamic> data,
  ) async {
    final response = _handleResponse(
      await http.put(
        Uri.parse('$baseUrl/users/me/settings'),
        headers: _headers(token),
        body: jsonEncode(data),
      ),
    );
    return jsonDecode(response.body);
  }

  // DELETE /users/me
  static Future<Map<String, dynamic>> deleteAccount(String token) async {
    final response = _handleResponse(
      await http.delete(
        Uri.parse('$baseUrl/users/me'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // PATCH /users/me/fcm-token
  static Future<Map<String, dynamic>> updateFCMToken(
    String token,
    String fcmToken,
  ) async {
    final response = _handleResponse(
      await http.patch(
        Uri.parse('$baseUrl/users/me/fcm-token'),
        headers: _headers(token),
        body: jsonEncode({'fcmToken': fcmToken}),
      ),
    );
    return jsonDecode(response.body);
  }

  // PUT /users/me/avatar
  static Future<Map<String, dynamic>> uploadAvatar(
    String token,
    String filePath,
  ) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/users/me/avatar'),
    );
    request.headers.addAll({'Authorization': 'Bearer $token'});
    request.files.add(await http.MultipartFile.fromPath('avatar', filePath));
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    return jsonDecode(responseBody);
  }

  // GET /daily-bread/verse-today
  static Future<Map<String, dynamic>> fetchDailyVerse(String token) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/daily-bread/verse-today'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> toggleDailyVerseLike(String token) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/daily-bread/verse-today/like'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> shareDailyVerse(String token) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/daily-bread/verse-today/share'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // GET /daily-bread/today
  static Future<Map<String, dynamic>> fetchWordCrossPuzzle(String token) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/daily-bread/today'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /daily-bread/submit
  static Future<Map<String, dynamic>> submitWordCrossPuzzle(
    String token,
    String puzzleId,
    String solution,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/daily-bread/submit'),
        headers: _headers(token),
        body: jsonEncode({'puzzleId': puzzleId, 'solution': solution}),
      ),
    );
    return jsonDecode(response.body);
  }

  // GET /feed
  static Future<Map<String, dynamic>> fetchFeed(String token) async {
    final response = _handleResponse(
      await http.get(Uri.parse('$baseUrl/feed'), headers: _headers(token)),
    );
    return jsonDecode(response.body);
  }

  // GET /features
  static Future<Map<String, dynamic>> fetchFeatures() async {
    final response = await http.get(
      Uri.parse('$baseUrl/features'),
      headers: _headers(null),
    );
    return jsonDecode(response.body);
  }

  // GET /explore
  static Future<Map<String, dynamic>> fetchExplore(String token) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/explore/explore'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // GET /feelings/metadata
  static Future<List<dynamic>> fetchFeelingsMetadata() async {
    final response = await http.get(
      Uri.parse('$baseUrl/feelings/metadata'),
      headers: _headers(null),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // PUT /friends/me/feeling
  static Future<Map<String, dynamic>> updateFeeling(
    String token,
    String feeling,
    String emoji,
  ) async {
    final response = _handleResponse(
      await http.put(
        Uri.parse('$baseUrl/friends/me/feeling'),
        headers: _headers(token),
        body: jsonEncode({'feeling': feeling, 'emoji': emoji}),
      ),
    );
    return jsonDecode(response.body);
  }

  // GET /quizzes/solo
  static Future<List<dynamic>> fetchQuizzes(String token) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/quizzes/solo'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // GET /quizzes/solo/:quizId
  static Future<Map<String, dynamic>> fetchQuizDetails(
    String token,
    String quizId,
  ) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/quizzes/solo/$quizId'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /quizzes/solo/:quizId/submit
  static Future<Map<String, dynamic>> submitQuiz(
    String token,
    String quizId,
    List<Map<String, dynamic>> answers,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/quizzes/solo/$quizId/submit'),
        headers: _headers(token),
        body: jsonEncode({'answers': answers}),
      ),
    );
    return jsonDecode(response.body);
  }

  // GET /friends
  static Future<List<dynamic>> fetchFriends(String token) async {
    final response = _handleResponse(
      await http.get(Uri.parse('$baseUrl/friends'), headers: _headers(token)),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // GET /badges/progress
  static Future<List<dynamic>> fetchBadgesProgress(String token) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/badges/progress'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  static Future<Map<String, dynamic>?> fetchUserFeeling(
    String token,
    String userId,
  ) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/friends/$userId/feeling'),
        headers: _headers(token),
      ),
    );
    if (response.body.isEmpty || response.body == 'null') return null;
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // GET /notifications
  static Future<List<dynamic>> fetchNotifications(String token) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // POST /notifications/:id/read
  static Future<void> markNotificationAsRead(String token, String id) async {
    _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/notifications/$id/read'),
        headers: _headers(token),
      ),
    );
  }

  // POST /auth/google
  static Future<Map<String, dynamic>> googleAuth({
    required String email,
    required String firstName,
    required String lastName,
    required String idToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: _headers(null),
      body: jsonEncode({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'idToken': idToken,
      }),
    );
    return jsonDecode(response.body);
  }

  // POST /auth/apple
  static Future<Map<String, dynamic>> appleAuth({
    required String? email,
    required String identityToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/apple'),
      headers: _headers(null),
      body: jsonEncode({'email': email, 'identityToken': identityToken}),
    );
    return jsonDecode(response.body);
  }

  // --- Bible Endpoints ---

  // GET /bible/bookmarks
  static Future<List<dynamic>> getBookmarks(
    String token, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/bible/bookmarks?page=$page&limit=$limit'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // POST /bible/bookmarks
  static Future<Map<String, dynamic>> createBookmark(
    String token,
    String reference,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/bible/bookmarks'),
        headers: _headers(token),
        body: jsonEncode({'reference': reference}),
      ),
    );
    return jsonDecode(response.body);
  }

  // DELETE /bible/bookmarks/:id
  static Future<Map<String, dynamic>> deleteBookmark(
    String token,
    String id,
  ) async {
    final response = _handleResponse(
      await http.delete(
        Uri.parse('$baseUrl/bible/bookmarks/$id'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // GET /bible/highlights
  static Future<List<dynamic>> getHighlights(
    String token, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/bible/highlights?page=$page&limit=$limit'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // POST /bible/highlights
  static Future<Map<String, dynamic>> createHighlight(
    String token,
    String reference,
    String color,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/bible/highlights'),
        headers: _headers(token),
        body: jsonEncode({'reference': reference, 'color': color}),
      ),
    );
    return jsonDecode(response.body);
  }

  // DELETE /bible/highlights/:id
  static Future<Map<String, dynamic>> deleteHighlight(
    String token,
    String id,
  ) async {
    final response = _handleResponse(
      await http.delete(
        Uri.parse('$baseUrl/bible/highlights/$id'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /bible/notes
  static Future<Map<String, dynamic>> createNote(
    String token,
    String reference,
    String note,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/bible/notes'),
        headers: _headers(token),
        body: jsonEncode({'reference': reference, 'note': note}),
      ),
    );
    return jsonDecode(response.body);
  }

  // GET /bible/history
  static Future<List<dynamic>> getHistory(String token) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/bible/history'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // --- Personal Notes Endpoints ---

  // GET /notes
  static Future<List<dynamic>> getPersonalNotes(
    String token, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/notes?page=$page&limit=$limit'),
        headers: _headers(token),
      ),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load notes');
  }

  // POST /notes
  static Future<Map<String, dynamic>> createPersonalNote(
    String token,
    String title,
    String bodyText, {
    List<String> verses = const [],
  }) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/notes'),
        headers: _headers(token),
        body: jsonEncode({
          'title': title,
          'bodyText': bodyText,
          'verses': verses,
        }),
      ),
    );
    return jsonDecode(response.body);
  }

  // PUT /notes/:id
  static Future<Map<String, dynamic>> updatePersonalNote(
    String token,
    String id,
    String title,
    String bodyText, {
    List<String> verses = const [],
    bool? isFavorite,
  }) async {
    final body = {'title': title, 'bodyText': bodyText, 'verses': verses};
    if (isFavorite != null) {
      body['isFavorite'] = isFavorite;
    }
    final response = _handleResponse(
      await http.put(
        Uri.parse('$baseUrl/notes/$id'),
        headers: _headers(token),
        body: jsonEncode(body),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /notes/:id/favorite
  static Future<Map<String, dynamic>> togglePersonalNoteFavorite(
    String token,
    String id,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/notes/$id/favorite'),
        headers: _headers(token),
        body: jsonEncode({}),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /api/v1/media/upload
  static Future<Map<String, dynamic>> uploadMedia(
    String token,
    String filePath,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/media/upload'),
    );
    request.headers.addAll({'Authorization': 'Bearer $token'});
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    return jsonDecode(responseBody);
  }

  // --- Journals Endpoints ---

  // GET /journals
  static Future<List<dynamic>> getJournals(
    String token, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/journals?page=$page&limit=$limit'),
        headers: _headers(token),
      ),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load journals');
  }

  // POST /journals
  static Future<Map<String, dynamic>> createJournal(
    String token,
    String title,
    String bodyText, {
    List<String> verses = const [],
    List<String> feelings = const [],
  }) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/journals'),
        headers: _headers(token),
        body: jsonEncode({
          'title': title,
          'bodyText': bodyText,
          'verses': verses,
          'feelings': feelings,
        }),
      ),
    );
    return jsonDecode(response.body);
  }

  // PUT /journals/:id
  static Future<Map<String, dynamic>> updateJournal(
    String token,
    String id,
    String title,
    String bodyText, {
    List<String> verses = const [],
    List<String> feelings = const [],
  }) async {
    final response = _handleResponse(
      await http.put(
        Uri.parse('$baseUrl/journals/$id'),
        headers: _headers(token),
        body: jsonEncode({
          'title': title,
          'bodyText': bodyText,
          'verses': verses,
          'feelings': feelings,
        }),
      ),
    );
    return jsonDecode(response.body);
  }

  // DELETE /media/file
  static Future<Map<String, dynamic>> deleteMedia(
    String token,
    String fileUrl,
  ) async {
    final response = _handleResponse(
      await http.delete(
        Uri.parse('$baseUrl/media/file'),
        headers: _headers(token),
        body: jsonEncode({'fileUrl': fileUrl}),
      ),
    );
    return jsonDecode(response.body);
  }
}
