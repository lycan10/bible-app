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
    return 'http://192.168.1.250:8787/api/v1';
    // return 'https://quest.vidarave.com/api/v1';
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

  // GET /communities/:id/verse-today
  static Future<Map<String, dynamic>> fetchCommunityDailyVerse(
    String token,
    String communityId,
  ) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/communities/$communityId/verse-today'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /communities/:id/verse-today/like
  static Future<Map<String, dynamic>> toggleCommunityDailyVerseLike(
    String token,
    String communityId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/communities/$communityId/verse-today/like'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /communities/:id/verse-today/share
  static Future<Map<String, dynamic>> shareCommunityDailyVerse(
    String token,
    String communityId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/communities/$communityId/verse-today/share'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /admin/communities/:id/verse-override
  static Future<Map<String, dynamic>> overrideCommunityDailyVerse(
    String token,
    String communityId,
    Map<String, dynamic> data,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/admin/communities/$communityId/verse-override'),
        headers: _headers(token),
        body: jsonEncode(data),
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

  // GET /games/overview
  static Future<Map<String, dynamic>> fetchGamesOverview(String token) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/games/overview'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /games/daily-bread/share
  static Future<Map<String, dynamic>> shareDailyBread(String token) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/games/daily-bread/share'),
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

  // GET /friends/suggestions
  static Future<List<dynamic>> fetchFriendSuggestions(String token) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/friends/suggestions'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // GET /books
  static Future<List<dynamic>> fetchBooks(String token) async {
    final response = _handleResponse(
      await http.get(Uri.parse('$baseUrl/books'), headers: _headers(token)),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // GET /books/:id/comments
  static Future<List<dynamic>> fetchBookComments(
    String token,
    String bookId,
  ) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/books/$bookId/comments'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // POST /books/:id/comments
  static Future<Map<String, dynamic>> addBookComment(
    String token,
    String bookId,
    String content,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/books/$bookId/comments'),
        headers: _headers(token),
        body: jsonEncode({'content': content}),
      ),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // GET /books/:id/reactions
  static Future<List<dynamic>> fetchBookReactions(
    String token,
    String bookId,
  ) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/books/$bookId/reactions'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // POST /books/:id/react
  static Future<Map<String, dynamic>> reactToBook(
    String token,
    String bookId,
    String emoji,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/books/$bookId/react'),
        headers: _headers(token),
        body: jsonEncode({'emoji': emoji}),
      ),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // GET /books/saved
  static Future<Map<String, dynamic>> fetchSavedBooks(
    String token, {
    int page = 1,
    int limit = 20,
    String search = '',
  }) async {
    final queryParams = {
      'page': '$page',
      'limit': '$limit',
      if (search.isNotEmpty) 'search': search,
    };
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/books/saved').replace(queryParameters: queryParams),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // POST /books/:id/save
  static Future<Map<String, dynamic>> toggleSaveBook(
    String token,
    String bookId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/books/$bookId/save'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // POST /friends/:userId/request
  static Future<Map<String, dynamic>> sendFriendRequest(
    String token,
    String targetUserId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/friends/$targetUserId/request'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /friends/:userId/accept
  static Future<Map<String, dynamic>> acceptFriendRequest(
    String token,
    String targetUserId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/friends/$targetUserId/accept'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /friends/:userId/reject
  static Future<Map<String, dynamic>> rejectFriendRequest(
    String token,
    String targetUserId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/friends/$targetUserId/reject'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // GET /friends/requests/pending
  static Future<List<dynamic>> fetchPendingFriendRequests(String token) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/friends/requests/pending'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // GET /friends/requests/sent
  static Future<List<dynamic>> fetchSentFriendRequests(String token) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/friends/requests/sent'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // --- Communities Endpoints ---

  // GET /communities
  static Future<List<dynamic>> fetchCommunities(
    String token, {
    String? query,
  }) async {
    final url =
        query != null && query.isNotEmpty
            ? '$baseUrl/communities?q=${Uri.encodeComponent(query)}'
            : '$baseUrl/communities';
    final response = _handleResponse(
      await http.get(Uri.parse(url), headers: _headers(token)),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // POST /communities
  static Future<Map<String, dynamic>> createCommunity(
    String token,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/communities'),
      headers: _headers(token),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // GET /communities/recommended
  static Future<List<dynamic>> fetchRecommendedCommunities(
    String token, {
    String? query,
  }) async {
    final url =
        query != null && query.isNotEmpty
            ? '$baseUrl/communities/recommended?q=${Uri.encodeComponent(query)}'
            : '$baseUrl/communities/recommended';
    final response = _handleResponse(
      await http.get(Uri.parse(url), headers: _headers(token)),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // GET /communities/search
  static Future<List<dynamic>> searchCommunities(
    String token,
    String query,
  ) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse(
          '$baseUrl/communities/search?q=${Uri.encodeComponent(query)}',
        ),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // GET /communities/:id
  static Future<Map<String, dynamic>> fetchCommunityDetails(
    String token,
    String id,
  ) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/communities/$id'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // GET /communities/:id/members
  static Future<List<dynamic>> fetchCommunityMembers(
    String token,
    String id,
  ) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/communities/$id/members'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // POST /communities/:id/join
  static Future<Map<String, dynamic>> updateCommunitySettings(
    String token,
    String communityId, {
    bool? isForumDisabledGlobally,
  }) async {
    final response = _handleResponse(
      await http.put(
        Uri.parse('$baseUrl/communities/$communityId/settings'),
        headers: _headers(token),
        body: jsonEncode({
          if (isForumDisabledGlobally != null)
            'isForumDisabledGlobally': isForumDisabledGlobally,
        }),
      ),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> moderateCommunityMember(
    String token,
    String communityId,
    String userId, {
    bool? isSuspended,
    bool? canPostForum,
  }) async {
    final response = _handleResponse(
      await http.put(
        Uri.parse('$baseUrl/communities/$communityId/members/$userId/moderate'),
        headers: _headers(token),
        body: jsonEncode({
          if (isSuspended != null) 'isSuspended': isSuspended,
          if (canPostForum != null) 'canPostForum': canPostForum,
        }),
      ),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> joinCommunity(
    String token,
    String id,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/communities/$id/join'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /communities/:id/leave
  static Future<Map<String, dynamic>> leaveCommunity(
    String token,
    String id,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/communities/$id/leave'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // GET /communities/:id/posts
  static Future<List<dynamic>> fetchCommunityPosts(
    String token,
    String id, {
    String? cursor,
  }) async {
    final uri =
        cursor != null
            ? '$baseUrl/communities/$id/posts?cursor=$cursor'
            : '$baseUrl/communities/$id/posts';
    final response = _handleResponse(
      await http.get(Uri.parse(uri), headers: _headers(token)),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // GET /communities/posts/all
  static Future<List<dynamic>> fetchGlobalPosts(
    String token, {
    String? cursor,
  }) async {
    final uri =
        cursor != null
            ? '$baseUrl/communities/posts/all?cursor=$cursor'
            : '$baseUrl/communities/posts/all';
    final response = _handleResponse(
      await http.get(Uri.parse(uri), headers: _headers(token)),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // GET /communities/me/messages
  static Future<Map<String, dynamic>> fetchMyAdminMessages(
    String token, {
    String? cursor,
  }) async {
    final uri =
        cursor != null
            ? '$baseUrl/communities/me/messages?cursor=$cursor'
            : '$baseUrl/communities/me/messages';
    final response = _handleResponse(
      await http.get(Uri.parse(uri), headers: _headers(token)),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // DELETE /communities/forum/messages/:id
  static Future<bool> deleteForumMessage(String token, String messageId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/communities/forum/messages/$messageId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return true;
    }
    throw Exception('Failed to delete forum message');
  }

  // DELETE /communities/messages/:id
  static Future<bool> deleteAdminMessage(String token, String messageId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/communities/messages/$messageId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return true;
    }
    throw Exception('Failed to delete admin message');
  }

  // PUT /communities/messages/:id
  static Future<bool> updateAdminMessage(
    String token,
    String messageId,
    String text, {
    String? imageUrl,
    String? videoUrl,
    String? audioUrl,
    String? videoThumbnail,
    String? audioThumbnail,
  }) async {
    final Map<String, dynamic> body = {'text': text};
    if (imageUrl != null || videoUrl != null || audioUrl != null) {
      body['imageUrl'] = imageUrl;
      body['videoUrl'] = videoUrl;
      body['audioUrl'] = audioUrl;
      body['videoThumbnail'] = videoThumbnail;
      body['audioThumbnail'] = audioThumbnail;
    } else {
      // If we are clearing media, we can pass nulls explicitly if we want,
      // but in Dart jsonEncode automatically includes null values if the key exists.
      // So if the caller explicitly passes imageUrl: null, we'll map it to null.
      // Wait, let's just assign them, and they will be encoded as null.
      body['imageUrl'] = imageUrl;
      body['videoUrl'] = videoUrl;
      body['audioUrl'] = audioUrl;
      body['videoThumbnail'] = videoThumbnail;
      body['audioThumbnail'] = audioThumbnail;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/communities/messages/$messageId'),
      headers: _headers(token),
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return true;
    }
    throw Exception('Failed to update admin message');
  }

  // POST /communities/:id/messages/:msgId/react
  static Future<bool> reactToAdminMessage(
    String token,
    String communityId,
    String msgId,
    String emoji,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/communities/$communityId/messages/$msgId/react'),
      headers: _headers(token),
      body: jsonEncode({'emoji': emoji}),
    );
    if (response.statusCode == 200) {
      return true;
    }
    throw Exception('Failed to react to admin message');
  }

  // POST /communities/:id/messages/comments/:commentId/like
  static Future<bool> toggleAdminMessageCommentLike(
    String token,
    String communityId,
    String commentId,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/communities/$communityId/messages/comments/$commentId/like',
      ),
      headers: _headers(token),
    );
    if (response.statusCode == 200) {
      return true;
    }
    throw Exception('Failed to toggle admin message comment like');
  }

  static Future<bool> deleteCommunityComment(
    String token,
    String commentId,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/communities/comments/$commentId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return true;
    }
    throw Exception('Failed to delete comment');
  }

  static Future<Map<String, dynamic>> createCommunityPost(
    String token,
    String communityId,
    String text, {
    String? image,
  }) async {
    final body = {
      'communityId': communityId,
      'text': text,
      if (image != null) 'image': image,
    };
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/communities/posts'),
        headers: _headers(token),
        body: jsonEncode(body),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /posts/:id/react
  static Future<Map<String, dynamic>> reactToCommunityPost(
    String token,
    String postId,
    String emoji,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/communities/posts/$postId/react'),
        headers: _headers(token),
        body: jsonEncode({'emoji': emoji}),
      ),
    );
    return jsonDecode(response.body);
  }

  // GET /posts/:postId/comments
  static Future<List<dynamic>> fetchCommunityPostComments(
    String token,
    String postId,
  ) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/communities/posts/$postId/comments'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // POST /posts/:postId/comments
  static Future<Map<String, dynamic>> addPostComment(
    String token,
    String postId,
    String text, {
    String? parentId,
  }) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/communities/posts/$postId/comments'),
        headers: _headers(token),
        body: jsonEncode({'text': text, 'parentId': parentId}),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /posts/:postId/report
  static Future<Map<String, dynamic>> reportCommunityPost(
    String token,
    String postId,
    String reason,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/communities/posts/$postId/report'),
        headers: _headers(token),
        body: jsonEncode({'reason': reason}),
      ),
    );
    return jsonDecode(response.body);
  }

  // DELETE /posts/:postId
  static Future<Map<String, dynamic>> updateCommunityPost(
    String token,
    String postId,
    String text,
  ) async {
    final response = _handleResponse(
      await http.put(
        Uri.parse('$baseUrl/communities/posts/$postId'),
        headers: _headers(token),
        body: jsonEncode({'text': text}),
      ),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteCommunityPost(
    String token,
    String postId,
  ) async {
    final response = _handleResponse(
      await http.delete(
        Uri.parse('$baseUrl/communities/posts/$postId'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteComment(
    String token,
    String commentId,
  ) async {
    final response = _handleResponse(
      await http.delete(
        Uri.parse('$baseUrl/communities/comments/$commentId'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /posts/:postId/comments/:commentId/react
  static Future<Map<String, dynamic>> reactToComment(
    String token,
    String postId,
    String commentId,
    String emoji,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse(
          '$baseUrl/communities/posts/$postId/comments/$commentId/react',
        ),
        headers: _headers(token),
        body: jsonEncode({'emoji': emoji}),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /communities/:id/events
  static Future<Map<String, dynamic>> createCommunityEvent(
    String token,
    String id,
    String title,
    String description,
    String date,
    String time,
    String location, {
    String? link,
    String? imageUrl,
  }) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/communities/$id/events'),
        headers: _headers(token),
        body: jsonEncode({
          'title': title,
          'description': description,
          'date': date,
          'time': time,
          'location': location,
          if (link != null) 'link': link,
          if (imageUrl != null) 'imageUrl': imageUrl,
        }),
      ),
    );
    return jsonDecode(response.body);
  }

  // PUT /communities/:id/events/:eventId
  static Future<Map<String, dynamic>> updateCommunityEvent(
    String token,
    String id,
    String eventId,
    String title,
    String description,
    String date,
    String time,
    String location, {
    String? link,
    String? imageUrl,
  }) async {
    final response = _handleResponse(
      await http.put(
        Uri.parse('$baseUrl/communities/$id/events/$eventId'),
        headers: _headers(token),
        body: jsonEncode({
          'title': title,
          'description': description,
          'date': date,
          'time': time,
          'location': location,
          if (link != null) 'link': link,
          if (imageUrl != null) 'imageUrl': imageUrl,
        }),
      ),
    );
    return jsonDecode(response.body);
  }

  // DELETE /communities/:id/events/:eventId
  static Future<void> deleteCommunityEvent(
    String token,
    String id,
    String eventId,
  ) async {
    _handleResponse(
      await http.delete(
        Uri.parse('$baseUrl/communities/$id/events/$eventId'),
        headers: _headers(token),
      ),
    );
  }

  // GET /communities/:id/events
  static Future<List<dynamic>> fetchCommunityEvents(
    String token,
    String id, {
    String? cursor,
  }) async {
    final uri =
        cursor != null
            ? '$baseUrl/communities/$id/events?cursor=$cursor'
            : '$baseUrl/communities/$id/events';
    final response = _handleResponse(
      await http.get(Uri.parse(uri), headers: _headers(token)),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // POST /communities/events/:id/attend
  static Future<Map<String, dynamic>> attendCommunityEvent(
    String token,
    String eventId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/communities/events/$eventId/attend'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /communities/events/:id/unattend
  static Future<Map<String, dynamic>> unattendCommunityEvent(
    String token,
    String eventId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/communities/events/$eventId/unattend'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // GET /communities/:id/forum
  // GET /communities/messages/saved
  static Future<Map<String, dynamic>> fetchSavedMessages(
    String token, {
    int page = 1,
    int limit = 20,
    String search = '',
  }) async {
    final queryParams = {
      'page': '$page',
      'limit': '$limit',
      if (search.isNotEmpty) 'search': search,
    };
    final response = _handleResponse(
      await http.get(
        Uri.parse(
          '$baseUrl/communities/messages/saved',
        ).replace(queryParameters: queryParams),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> fetchCommunityMessages(
    String token,
    String id, {
    String? cursor,
  }) async {
    final uri =
        cursor != null
            ? '$baseUrl/communities/$id/forum?cursor=$cursor'
            : '$baseUrl/communities/$id/forum';
    final response = _handleResponse(
      await http.get(Uri.parse(uri), headers: _headers(token)),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // GET /communities/:id/messages
  static Future<List<dynamic>> fetchAdminMessages(
    String token,
    String id, {
    String? cursor,
  }) async {
    final uri =
        cursor != null
            ? '$baseUrl/communities/$id/messages?cursor=$cursor'
            : '$baseUrl/communities/$id/messages';
    final response = _handleResponse(
      await http.get(Uri.parse(uri), headers: _headers(token)),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // POST /communities/:id/messages/:msgId/like
  static Future<Map<String, dynamic>> toggleAdminMessageLike(
    String token,
    String communityId,
    String msgId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/communities/$communityId/messages/$msgId/like'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /communities/:id/messages/:msgId/bookmark
  static Future<Map<String, dynamic>> toggleAdminMessageBookmark(
    String token,
    String communityId,
    String msgId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/communities/$communityId/messages/$msgId/bookmark'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /communities/:id/messages/:msgId/share
  static Future<Map<String, dynamic>> shareAdminMessage(
    String token,
    String communityId,
    String msgId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/communities/$communityId/messages/$msgId/share'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // GET /communities/:id/messages/:msgId/comments
  static Future<List<dynamic>> fetchAdminMessageComments(
    String token,
    String communityId,
    String msgId,
  ) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/communities/$communityId/messages/$msgId/comments'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // POST /communities/:id/messages/:msgId/comments
  static Future<Map<String, dynamic>> addAdminMessageComment(
    String token,
    String communityId,
    String msgId,
    String text, {
    String? parentId,
  }) async {
    final body = {'text': text, if (parentId != null) 'parentId': parentId};
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/communities/$communityId/messages/$msgId/comments'),
        headers: _headers(token),
        body: jsonEncode(body),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /communities/:id/forum/messages
  static Future<Map<String, dynamic>> sendForumMessage(
    String token,
    String id,
    String text, {
    String? imageUrl,
    String? videoUrl,
    String? audioUrl,
    String? videoThumbnail,
    String? audioThumbnail,
  }) async {
    final body = {'text': text};
    if (imageUrl != null) body['imageUrl'] = imageUrl;
    if (videoUrl != null) body['videoUrl'] = videoUrl;
    if (audioUrl != null) body['audioUrl'] = audioUrl;
    if (videoThumbnail != null) body['videoThumbnail'] = videoThumbnail;
    if (audioThumbnail != null) body['audioThumbnail'] = audioThumbnail;

    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/communities/$id/forum/messages'),
        headers: _headers(token),
        body: jsonEncode(body),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /communities/:id/messages
  static Future<Map<String, dynamic>> sendCommunityMessage(
    String token,
    String id,
    String text, {
    String? title,
    String? imageUrl,
    String? videoUrl,
    String? audioUrl,
    String? videoThumbnail,
    String? audioThumbnail,
  }) async {
    final body = {'text': text};
    if (title != null) body['title'] = title;
    if (imageUrl != null) body['imageUrl'] = imageUrl;
    if (videoUrl != null) body['videoUrl'] = videoUrl;
    if (audioUrl != null) body['audioUrl'] = audioUrl;
    if (videoThumbnail != null) body['videoThumbnail'] = videoThumbnail;
    if (audioThumbnail != null) body['audioThumbnail'] = audioThumbnail;

    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/communities/$id/messages'),
        headers: _headers(token),
        body: jsonEncode(body),
      ),
    );
    return jsonDecode(response.body);
  }

  // --- Chats Endpoints ---

  // GET /chats
  static Future<List<dynamic>> fetchChats(String token) async {
    final response = _handleResponse(
      await http.get(Uri.parse('$baseUrl/chats'), headers: _headers(token)),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // GET /chats/:chatId
  static Future<List<dynamic>> fetchChatMessages(
    String token,
    String chatId,
  ) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/chats/$chatId'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // POST /chats
  static Future<Map<String, dynamic>> startChat(
    String token,
    String friendId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/chats'),
        headers: _headers(token),
        body: jsonEncode({'friendId': friendId}),
      ),
    );
    return jsonDecode(response.body);
  }

  // PUT /chats/:chatId/read
  static Future<Map<String, dynamic>> markChatAsRead(
    String token,
    String chatId,
  ) async {
    final response = _handleResponse(
      await http.put(
        Uri.parse('$baseUrl/chats/$chatId/read'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /chats/:chatId/messages
  static Future<Map<String, dynamic>> sendMessage(
    String token,
    String chatId,
    String text, {
    String? image,
  }) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/chats/$chatId/messages'),
        headers: _headers(token),
        body: jsonEncode({'text': text, 'image': image}),
      ),
    );
    return jsonDecode(response.body);
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

  // GET /api/v1/media/upload/limit-check
  static Future<Map<String, dynamic>> checkUploadLimit(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/media/upload/limit-check'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // POST /api/v1/media/upload
  static Future<Map<String, dynamic>> uploadMedia(
    String token,
    String filePath, {
    bool isEdit = false,
    bool isReel = false,
    String? title,
    String? thumbnailPath,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/media/upload'),
    );
    request.headers.addAll({'Authorization': 'Bearer $token'});
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    if (thumbnailPath != null) {
      request.files.add(await http.MultipartFile.fromPath('thumbnail', thumbnailPath));
    }
    if (title != null && title.isNotEmpty) {
      request.fields['title'] = title;
    }
    if (isEdit) {
      request.fields['isEdit'] = 'true';
    }
    if (isReel) {
      request.fields['isReel'] = 'true';
    }
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final decoded = jsonDecode(responseBody);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(decoded['error'] ?? 'Failed to upload media');
    }

    return decoded;
  }

  // --- Devotion Endpoints ---

  // GET /devotions/plans
  static Future<List<dynamic>> fetchDevotionPlans(String token) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/devotions/plans'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // GET /devotions/search?q={query}
  static Future<List<dynamic>> searchDevotionPlans(
    String token,
    String query,
  ) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/devotions/search?q=$query'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // GET /devotions/my-plans
  static Future<List<dynamic>> fetchMyDevotionPlans(String token) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/devotions/my-plans'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // POST /devotions/plans/:id/subscribe
  static Future<Map<String, dynamic>> subscribeDevotionPlan(
    String token,
    String planId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/devotions/plans/$planId/subscribe'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // DELETE /devotions/plans/:id/unsubscribe
  static Future<Map<String, dynamic>> unsubscribeDevotionPlan(
    String token,
    String planId,
  ) async {
    final response = _handleResponse(
      await http.delete(
        Uri.parse('$baseUrl/devotions/plans/$planId/unsubscribe'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // GET /devotions/plans/:planId/days/:dayNum
  static Future<Map<String, dynamic>> fetchDevotionDay(
    String token,
    String planId,
    int dayNum,
  ) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/devotions/plans/$planId/days/$dayNum'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /devotions/plans/:planId/days/:dayNum/complete
  static Future<Map<String, dynamic>> completeDevotionDay(
    String token,
    String planId,
    int dayNum,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/devotions/plans/$planId/days/$dayNum/complete'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // PUT /devotions/plans/:planId/reminder
  static Future<Map<String, dynamic>> updateDevotionReminder(
    String token,
    String planId,
    String time,
    bool enabled,
  ) async {
    final response = _handleResponse(
      await http.put(
        Uri.parse('$baseUrl/devotions/plans/$planId/reminder'),
        headers: _headers(token),
        body: jsonEncode({'reminderTime': time, 'reminderEnabled': enabled}),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /devotions/plans/:id/like
  static Future<Map<String, dynamic>> likeDevotionDay(
    String token,
    String dayId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/devotions/plans/$dayId/like'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /devotions/plans/:id/share
  static Future<Map<String, dynamic>> shareDevotionPlan(
    String token,
    String planId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/devotions/plans/$planId/share'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
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

  // --- MEDIA ENDPOINTS ---

  // GET /media/videos (paginated)
  // Returns { items, nextCursor, hasMore }
  static Future<Map<String, dynamic>> fetchVideos(
    String token, {
    String? cursor,
    String? search,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{'limit': '$limit'};
    if (cursor != null) queryParams['cursor'] = cursor;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    final uri = Uri.parse(
      '$baseUrl/media/videos',
    ).replace(queryParameters: queryParams);
    final response = _handleResponse(
      await http.get(uri, headers: _headers(token)),
    );
    final decoded = jsonDecode(response.body);
    // Backend now returns { items, nextCursor, hasMore }
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    // Fallback for old non-paginated response
    return {'items': decoded, 'nextCursor': null, 'hasMore': false};
  }

  // GET /videos/categories
  static Future<List<dynamic>> fetchVideoCategories(String token) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/media/videos/categories'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // GET /videos/continue
  static Future<Map<String, dynamic>?> fetchContinueWatching(
    String token,
  ) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/media/videos/continue'),
        headers: _headers(token),
      ),
    );
    final data = jsonDecode(response.body);
    return data['item'];
  }

  // POST /videos/:id/like
  static Future<Map<String, dynamic>> likeVideo(
    String token,
    String videoId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/media/videos/$videoId/like'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /videos/:id/playback
  static Future<Map<String, dynamic>> trackVideoPlayback(
    String token,
    String videoId,
    int progressSeconds,
    bool completed,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/media/videos/$videoId/playback'),
        headers: _headers(token),
        body: jsonEncode({
          'progressSeconds': progressSeconds,
          'completed': completed,
        }),
      ),
    );
    return jsonDecode(response.body);
  }

  // GET /audio (paginated)
  // Returns { items, nextCursor, hasMore }
  static Future<Map<String, dynamic>> fetchAudio(
    String token, {
    String? cursor,
    String? search,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{'limit': '$limit'};
    if (cursor != null) queryParams['cursor'] = cursor;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    final uri = Uri.parse(
      '$baseUrl/media/audio',
    ).replace(queryParameters: queryParams);

    final response = _handleResponse(
      await http.get(uri, headers: _headers(token)),
    );

    final decoded = jsonDecode(response.body);
    // Backend now returns { items, nextCursor, hasMore }
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    // Fallback for old non-paginated response
    return {'items': decoded, 'nextCursor': null, 'hasMore': false};
  }

  // GET /audio/categories
  static Future<List<dynamic>> fetchAudioCategories(String token) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/media/audio/categories'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // GET /audio/continue
  static Future<Map<String, dynamic>?> fetchContinueListening(
    String token,
  ) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/media/audio/continue'),
        headers: _headers(token),
      ),
    );
    final data = jsonDecode(response.body);
    return data['item'];
  }

  // POST /audio/:id/like
  static Future<Map<String, dynamic>> likeAudio(
    String token,
    String audioId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/media/audio/$audioId/like'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // POST /audio/:id/playback
  static Future<Map<String, dynamic>> trackAudioPlayback(
    String token,
    String audioId,
    int progressSeconds,
    bool completed,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/media/audio/$audioId/playback'),
        headers: _headers(token),
        body: jsonEncode({
          'progressSeconds': progressSeconds,
          'completed': completed,
        }),
      ),
    );
    return jsonDecode(response.body);
  }

  // --- New Chat Methods ---
  static Future<Map<String, dynamic>> pinChat(
    String token,
    String chatId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/chats/$chatId/pin'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> unpinChat(
    String token,
    String chatId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/chats/$chatId/unpin'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> clearChat(
    String token,
    String chatId,
  ) async {
    final response = _handleResponse(
      await http.delete(
        Uri.parse('$baseUrl/chats/$chatId/clear'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> fetchPinnedChats(String token) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/chats/pins/list'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  // --- New User Profile Methods ---
  static Future<Map<String, dynamic>> blockUser(
    String token,
    String userId,
  ) async {
    final response = _handleResponse(
      await http.post(
        Uri.parse('$baseUrl/friends/$userId/block'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> fetchProfileStats(
    String token,
    String userId,
  ) async {
    final response = _handleResponse(
      await http.get(
        Uri.parse('$baseUrl/users/$userId/profile-stats'),
        headers: _headers(token),
      ),
    );
    return jsonDecode(response.body);
  }

  // ---------------------------------------------------------------------------
  // SUBSCRIPTIONS
  // ---------------------------------------------------------------------------

  static Future<Map<String, dynamic>> verifySubscription({
    required String token,
    required String platform,
    required String productId,
    required String receiptData,
    required String originalTxId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/subscriptions/verify'),
      headers: _headers(token),
      body: jsonEncode({
        'platform': platform,
        'productId': productId,
        'receiptData': receiptData,
        'originalTxId': originalTxId,
      }),
    );
    final finalRes = _handleResponse(response);
    return jsonDecode(finalRes.body);
  }

  static Future<Map<String, dynamic>> getSubscriptionStatus(
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/subscriptions/me'),
      headers: _headers(token),
    );
    final finalRes = _handleResponse(response);
    return jsonDecode(finalRes.body);
  }
}
