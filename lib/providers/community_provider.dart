import 'package:flutter/material.dart';
import 'package:quest/services/api_service.dart';

class CommunityProvider with ChangeNotifier {
  List<dynamic> _communities = [];
  List<dynamic> _recommendedCommunities = [];
  List<dynamic> _searchResults = [];

  Map<String, dynamic>? _currentCommunity;
  List<dynamic> _currentPosts = [];
  List<dynamic> _currentEvents = [];
  List<dynamic> _currentMessages = [];
  bool _isLoadingMoreMessages = false;
  bool _hasMoreMessages = true;

  List<dynamic> _adminMessages = [];
  bool _isLoadingMoreAdminMessages = false;
  bool _hasMoreAdminMessages = true;

  bool _isLoadingMorePosts = false;
  bool _hasMorePosts = true;

  bool _isLoadingMoreEvents = false;
  bool _hasMoreEvents = true;

  Map<String, dynamic>? _currentVerse;
  bool _isLoadingVerse = false;

  bool _isLoading = false;

  List<dynamic> get communities => _communities;
  List<dynamic> get recommendedCommunities => _recommendedCommunities;
  List<dynamic> get searchResults => _searchResults;

  Map<String, dynamic>? get currentCommunity => _currentCommunity;
  List<dynamic> get currentPosts => _currentPosts;
  List<dynamic> get currentEvents => _currentEvents;
  List<dynamic> get currentMessages => _currentMessages;
  Map<String, dynamic>? get currentVerse => _currentVerse;
  bool get isLoadingVerse => _isLoadingVerse;
  bool get isLoadingMoreMessages => _isLoadingMoreMessages;
  bool get hasMoreMessages => _hasMoreMessages;

  List<dynamic> get adminMessages => _adminMessages;
  bool get isLoadingMoreAdminMessages => _isLoadingMoreAdminMessages;
  bool get hasMoreAdminMessages => _hasMoreAdminMessages;

  bool get isLoadingMorePosts => _isLoadingMorePosts;
  bool get hasMorePosts => _hasMorePosts;

  bool get isLoadingMoreEvents => _isLoadingMoreEvents;
  bool get hasMoreEvents => _hasMoreEvents;

  List<dynamic> _globalPosts = [];
  bool _isLoadingMoreGlobalPosts = false;
  bool _hasMoreGlobalPosts = true;

  List<dynamic> get globalPosts => _globalPosts;
  bool get isLoadingMoreGlobalPosts => _isLoadingMoreGlobalPosts;
  bool get hasMoreGlobalPosts => _hasMoreGlobalPosts;

  bool get isLoading => _isLoading;

  Future<void> loadGlobalPosts(String token, {bool refresh = false}) async {
    if (refresh) {
      _globalPosts = [];
      _hasMoreGlobalPosts = true;
      _isLoading = true;
      notifyListeners();
    } else if (!_hasMoreGlobalPosts || _isLoadingMoreGlobalPosts) {
      return;
    } else {
      _isLoadingMoreGlobalPosts = true;
      notifyListeners();
    }

    try {
      final cursor = _globalPosts.isNotEmpty ? _globalPosts.last['id'] : null;
      final newPosts = await ApiService.fetchGlobalPosts(token, cursor: cursor);
      if (newPosts.isEmpty) {
        _hasMoreGlobalPosts = false;
      } else {
        _globalPosts.addAll(newPosts);
      }
    } catch (e) {
      debugPrint("Error loading global posts: $e");
    } finally {
      _isLoading = false;
      _isLoadingMoreGlobalPosts = false;
      notifyListeners();
    }
  }

  Future<void> loadCommunities(String token, {String? query}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _communities = await ApiService.fetchCommunities(token, query: query);
      _recommendedCommunities = await ApiService.fetchRecommendedCommunities(
        token,
        query: query,
      );
    } catch (e) {
      debugPrint("Error loading communities: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCommunity(String token, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newCommunity = await ApiService.createCommunity(token, data);
      if (newCommunity.containsKey('error')) {
        throw Exception(newCommunity['error']);
      }
      _communities.insert(0, newCommunity);
    } catch (e) {
      debugPrint("Error creating community: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCommunityDetails(String token, String communityId, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedCommunity = await ApiService.updateCommunity(token, communityId, data);
      if (updatedCommunity.containsKey('error')) {
        throw Exception(updatedCommunity['error']);
      }
      
      // Update local state if the community exists in the list
      final index = _communities.indexWhere((c) => c['id'] == communityId);
      if (index != -1) {
        _communities[index] = {
          ..._communities[index],
          ...updatedCommunity
        };
      }

      // Update current community details if it's the one being viewed
      if (_currentCommunity != null && _currentCommunity!['id'] == communityId) {
        _currentCommunity = {
          ..._currentCommunity!,
          ...updatedCommunity
        };
      }
    } catch (e) {
      debugPrint("Error updating community: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchCommunities(String token, String query) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = await ApiService.searchCommunities(token, query);
      }
    } catch (e) {
      debugPrint("Error searching communities: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCommunityDetails(String token, String id) async {
    _isLoading = true;
    _hasMoreMessages = true;
    notifyListeners();
    try {
      _currentCommunity = await ApiService.fetchCommunityDetails(token, id);
      if (_currentCommunity != null) {
        _currentCommunity!['members'] = await ApiService.fetchCommunityMembers(
          token,
          id,
        );
      }
      _hasMorePosts = true;
      _hasMoreEvents = true;
      
      final results = await Future.wait([
        ApiService.fetchCommunityPosts(token, id).catchError((e) {
          debugPrint("Error loading posts: \$e");
          return <dynamic>[];
        }),
        ApiService.fetchCommunityEvents(token, id).catchError((e) {
          debugPrint("Error loading events: \$e");
          return <dynamic>[];
        }),
        ApiService.fetchCommunityMessages(token, id).catchError((e) {
          debugPrint("Error loading forum messages: \$e");
          return <dynamic>[];
        }),
        ApiService.fetchAdminMessages(token, id).catchError((e) {
          debugPrint("Error loading admin messages: \$e");
          return <dynamic>[];
        }),
      ]);

      _currentPosts = results[0];
      _currentEvents = results[1];
      _currentMessages = results[2];
      _adminMessages = results[3];
    } catch (e) {
      debugPrint("Error loading community details: \$e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAdminMessages(String token, String id) async {
    _hasMoreAdminMessages = true;
    notifyListeners();
    try {
      _adminMessages = await ApiService.fetchAdminMessages(token, id);
    } catch (e) {
      debugPrint("Error loading admin messages: \$e");
    } finally {
      notifyListeners();
    }
  }

  Future<void> refreshCommunityMessages(String token, String id) async {
    try {
      final messages = await ApiService.fetchCommunityMessages(token, id);
      _currentMessages = messages;
      notifyListeners();
    } catch (e) {
      debugPrint("Error refreshing community messages: \$e");
    }
  }

  Future<void> loadMoreCommunityMessages(String token, String id) async {
    if (_isLoadingMoreMessages || !_hasMoreMessages || _currentMessages.isEmpty)
      return;

    _isLoadingMoreMessages = true;
    notifyListeners();

    try {
      final lastMsg = _currentMessages.last;
      final cursor = lastMsg['id'];

      final moreMessages = await ApiService.fetchCommunityMessages(
        token,
        id,
        cursor: cursor,
      );
      if (moreMessages.isEmpty) {
        _hasMoreMessages = false;
      } else {
        _currentMessages.addAll(moreMessages);
      }
    } catch (e) {
      debugPrint("Error loading more community messages: \$e");
    } finally {
      _isLoadingMoreMessages = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreAdminMessages(String token, String id) async {
    if (_isLoadingMoreAdminMessages || !_hasMoreAdminMessages || _adminMessages.isEmpty)
      return;

    _isLoadingMoreAdminMessages = true;
    notifyListeners();

    try {
      final lastMsg = _adminMessages.last;
      final cursor = lastMsg['id'];

      final moreMessages = await ApiService.fetchAdminMessages(
        token,
        id,
        cursor: cursor,
      );
      if (moreMessages.isEmpty) {
        _hasMoreAdminMessages = false;
      } else {
        _adminMessages.addAll(moreMessages);
      }
    } catch (e) {
      debugPrint("Error loading more admin messages: \$e");
    } finally {
      _isLoadingMoreAdminMessages = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreCommunityPosts(String token, String id) async {
    if (_isLoadingMorePosts || !_hasMorePosts || _currentPosts.isEmpty) return;

    _isLoadingMorePosts = true;
    notifyListeners();

    try {
      final lastPost = _currentPosts.last;
      final cursor = lastPost['id'];

      final morePosts = await ApiService.fetchCommunityPosts(
        token,
        id,
        cursor: cursor,
      );
      if (morePosts.isEmpty) {
        _hasMorePosts = false;
      } else {
        _currentPosts.addAll(morePosts);
      }
    } catch (e) {
      debugPrint("Error loading more community posts: \$e");
    } finally {
      _isLoadingMorePosts = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreCommunityEvents(String token, String id) async {
    if (_isLoadingMoreEvents || !_hasMoreEvents || _currentEvents.isEmpty) return;

    _isLoadingMoreEvents = true;
    notifyListeners();

    try {
      final lastEvent = _currentEvents.last;
      final cursor = lastEvent['id'];

      final moreEvents = await ApiService.fetchCommunityEvents(
        token,
        id,
        cursor: cursor,
      );
      if (moreEvents.isEmpty) {
        _hasMoreEvents = false;
      } else {
        _currentEvents.addAll(moreEvents);
      }
    } catch (e) {
      debugPrint("Error loading more community events: \$e");
    } finally {
      _isLoadingMoreEvents = false;
      notifyListeners();
    }
  }

  Future<bool> joinCommunity(String token, String id) async {
    try {
      await ApiService.joinCommunity(token, id);
      await loadCommunityDetails(token, id);
      await loadCommunities(token);
      return true;
    } catch (e) {
      debugPrint("Error joining community: \$e");
      return false;
    }
  }

  Future<bool> leaveCommunity(String token, String id) async {
    try {
      await ApiService.leaveCommunity(token, id);
      await loadCommunityDetails(token, id);
      await loadCommunities(token);
      return true;
    } catch (e) {
      debugPrint("Error leaving community: \$e");
      return false;
    }
  }

  Future<bool> createPost(
    String token,
    String communityId,
    String text, {
    String? image,
  }) async {
    try {
      final newPost = await ApiService.createCommunityPost(
        token,
        communityId,
        text,
        image: image,
      );
      _currentPosts.insert(0, newPost);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error creating post: \$e");
      return false;
    }
  }

  Future<bool> reactToPost(String token, String postId, String emoji) async {
    try {
      final res = await ApiService.reactToCommunityPost(token, postId, emoji);
      // Update local post state
      final postIndex = _currentPosts.indexWhere((p) => p['id'] == postId);
      if (postIndex != -1) {
        final post = _currentPosts[postIndex];
        List reactions = List.from(post['reactions'] ?? []);

        if (res['reacted'] == true) {
          reactions.add(res['reaction']);
        } else {
          // Remove reaction for this user
          final userId =
              res['userId']; // We might need to handle this manually, but assuming reload is safer, or just basic optimistic update.
          reactions.removeWhere((r) => r['emoji'] == emoji); // naive removal
        }
        post['reactions'] = reactions;
        _currentPosts[postIndex] = post;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error reacting to post: $e");
      return false;
    }
  }

  Future<bool> likePost(String token, String postId) async {
    try {
      final res = await ApiService.likeCommunityPost(token, postId);
      final postIndex = _currentPosts.indexWhere((p) => p['id'] == postId);
      if (postIndex != -1) {
        final post = _currentPosts[postIndex];
        
        if (res['liked'] == true) {
          post['likesCount'] = (post['likesCount'] ?? 0) + 1;
          post['postLikes'] = [...(post['postLikes'] ?? []), res['like']];
        } else {
          post['likesCount'] = (post['likesCount'] ?? 1) - 1;
          List likes = List.from(post['postLikes'] ?? []);
          if (likes.isNotEmpty) {
            likes.removeLast(); // naive removal, or filter by userId
          }
          post['postLikes'] = likes;
        }
        
        _currentPosts[postIndex] = post;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error liking post: $e");
      return false;
    }
  }

  Future<List<dynamic>> fetchPostComments(String token, String postId) async {
    try {
      return await ApiService.fetchCommunityPostComments(token, postId);
    } catch (e) {
      debugPrint("Error fetching comments: \$e");
      return [];
    }
  }

  Future<bool> addPostComment(
    String token,
    String postId,
    String text, {
    String? parentId,
  }) async {
    try {
      final comment = await ApiService.addPostComment(
        token,
        postId,
        text,
        parentId: parentId,
      );
      final postIndex = _currentPosts.indexWhere((p) => p['id'] == postId);
      if (postIndex != -1) {
        final post = _currentPosts[postIndex];
        final count = post['_count']?['comments'] ?? 0;
        post['_count'] ??= {};
        post['_count']['comments'] = count + 1;
        _currentPosts[postIndex] = post;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error adding comment: \$e");
      return false;
    }
  }

  Future<bool> reactToComment(
    String token,
    String postId,
    String commentId,
    String emoji,
  ) async {
    try {
      await ApiService.reactToComment(token, postId, commentId, emoji);
      return true;
    } catch (e) {
      debugPrint("Error reacting to comment: \$e");
      return false;
    }
  }

  Future<bool> reportPost(String token, String postId, String reason) async {
    try {
      await ApiService.reportCommunityPost(token, postId, reason);
      return true;
    } catch (e) {
      debugPrint("Error reporting post: \$e");
      return false;
    }
  }

  Future<bool> updatePost(String token, String postId, String text) async {
    try {
      final updatedPost = await ApiService.updateCommunityPost(
        token,
        postId,
        text,
      );
      final idx = _currentPosts.indexWhere((p) => p['id'] == postId);
      if (idx != -1) {
        // Keep existing relationships that might not be fully returned in a simple update
        // We know text is what changed.
        _currentPosts[idx] = {
          ..._currentPosts[idx],
          'text': updatedPost['text'],
        };
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error updating post: $e");
      return false;
    }
  }

  Future<bool> deletePost(String token, String postId) async {
    try {
      await ApiService.deleteCommunityPost(token, postId);
      _currentPosts.removeWhere((p) => p['id'] == postId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error deleting post: \$e");
      return false;
    }
  }

  Future<bool> createEvent(
    String token,
    String communityId,
    String title,
    String description,
    String date,
    String time,
    String location, {
    String? link,
    String? imagePath,
  }) async {
    try {
      String? imageUrl;
      if (imagePath != null) {
        final uploadRes = await ApiService.uploadMedia(token, imagePath);
        imageUrl = uploadRes['url'];
      }

      final newEvent = await ApiService.createCommunityEvent(
        token,
        communityId,
        title,
        description,
        date,
        time,
        location,
        link: link,
        imageUrl: imageUrl,
      );
      _currentEvents.insert(0, newEvent);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error creating event: $e");
      return false;
    }
  }

  Future<bool> updateEvent(
    String token,
    String communityId,
    String eventId,
    String title,
    String description,
    String date,
    String time,
    String location, {
    String? link,
    String? imagePath,
    String? existingImageUrl,
  }) async {
    try {
      String? imageUrl = existingImageUrl;
      if (imagePath != null && imagePath.isNotEmpty) {
        final uploadRes = await ApiService.uploadMedia(token, imagePath);
        imageUrl = uploadRes['url'];
      }

      final updatedEvent = await ApiService.updateCommunityEvent(
        token,
        communityId,
        eventId,
        title,
        description,
        date,
        time,
        location,
        link: link,
        imageUrl: imageUrl,
      );
      
      final index = _currentEvents.indexWhere((e) => e['id'] == eventId);
      if (index != -1) {
        _currentEvents[index] = updatedEvent;
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error updating event: $e");
      return false;
    }
  }

  Future<bool> deleteEvent(String token, String communityId, String eventId) async {
    try {
      await ApiService.deleteCommunityEvent(token, communityId, eventId);
      _currentEvents.removeWhere((e) => e['id'] == eventId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error deleting event: $e");
      return false;
    }
  }

  Future<bool> attendEvent(String token, String eventId) async {
    try {
      await ApiService.attendCommunityEvent(token, eventId);
      if (_currentCommunity != null) {
        // Reload events
        _currentEvents = await ApiService.fetchCommunityEvents(
          token,
          _currentCommunity!['id'],
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error attending event: \$e");
      return false;
    }
  }

  Future<bool> unattendEvent(String token, String eventId) async {
    try {
      await ApiService.unattendCommunityEvent(token, eventId);
      if (_currentCommunity != null) {
        _currentEvents = await ApiService.fetchCommunityEvents(
          token,
          _currentCommunity!['id'],
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error unattending event: \$e");
      return false;
    }
  }

  Future<bool> sendForumMessage(
    String token,
    String communityId,
    String text, {
    String? mediaPath,
    bool isVideo = false,
  }) async {
    try {
      String? imageUrl;
      String? videoUrl;

      if (mediaPath != null) {
        final uploadRes = await ApiService.uploadMedia(token, mediaPath);
        if (uploadRes['url'] != null) {
          if (isVideo) {
            videoUrl = uploadRes['url'];
          } else {
            imageUrl = uploadRes['url'];
          }
        }
      }

      final newMsg = await ApiService.sendForumMessage(
        token,
        communityId,
        text,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
      );
      _currentMessages.insert(0, newMsg);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error sending forum message: $e");
      return false;
    }
  }

  Future<bool> sendAdminMessage(
    String token,
    String communityId,
    String text, {
    String? title,
    String? imageUrl,
    String? videoUrl,
    String? audioUrl,
    String? videoThumbnail,
    String? audioThumbnail,
  }) async {
    try {
      final newMsg = await ApiService.sendCommunityMessage(
        token,
        communityId,
        text,
        title: title,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        audioUrl: audioUrl,
        videoThumbnail: videoThumbnail,
        audioThumbnail: audioThumbnail,
      );
      _adminMessages.insert(0, newMsg);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error sending admin message: $e");
      return false;
    }
  }

  Future<bool> toggleAdminMessageLike(String token, String msgId) async {
    if (_currentCommunity == null) return false;
    try {
      final res = await ApiService.toggleAdminMessageLike(token, _currentCommunity!['id'], msgId);
      final index = _adminMessages.indexWhere((m) => m['id'] == msgId);
      if (index != -1) {
        _adminMessages[index]['hasLiked'] = res['liked'];
        _adminMessages[index]['likesCount'] += res['liked'] ? 1 : -1;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error toggling admin message like: $e");
      return false;
    }
  }

  Future<bool> toggleAdminMessageBookmark(String token, String msgId) async {
    if (_currentCommunity == null) return false;
    try {
      final res = await ApiService.toggleAdminMessageBookmark(token, _currentCommunity!['id'], msgId);
      final index = _adminMessages.indexWhere((m) => m['id'] == msgId);
      if (index != -1) {
        _adminMessages[index]['hasBookmarked'] = res['bookmarked'];
        _adminMessages[index]['bookmarksCount'] += res['bookmarked'] ? 1 : -1;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error toggling admin message bookmark: $e");
      return false;
    }
  }

  Future<bool> shareAdminMessage(String token, String msgId) async {
    if (_currentCommunity == null) return false;
    try {
      await ApiService.shareAdminMessage(token, _currentCommunity!['id'], msgId);
      final index = _adminMessages.indexWhere((m) => m['id'] == msgId);
      if (index != -1) {
        _adminMessages[index]['sharesCount'] = (_adminMessages[index]['sharesCount'] ?? 0) + 1;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error sharing admin message: $e");
      return false;
    }
  }

  Future<List<dynamic>> fetchAdminMessageComments(String token, String msgId) async {
    if (_currentCommunity == null) return [];
    try {
      return await ApiService.fetchAdminMessageComments(token, _currentCommunity!['id'], msgId);
    } catch (e) {
      debugPrint("Error fetching admin message comments: $e");
      return [];
    }
  }

  Future<bool> addAdminMessageComment(String token, String msgId, String text, {String? parentId}) async {
    if (_currentCommunity == null) return false;
    try {
      await ApiService.addAdminMessageComment(token, _currentCommunity!['id'], msgId, text, parentId: parentId);
      final index = _adminMessages.indexWhere((m) => m['id'] == msgId);
      if (index != -1) {
        _adminMessages[index]['commentsCount'] = (_adminMessages[index]['commentsCount'] ?? 0) + 1;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error adding admin message comment: $e");
      return false;
    }
  }

  Future<bool> deleteForumMessage(String token, String messageId) async {
    try {
      await ApiService.deleteForumMessage(token, messageId);
      _currentMessages.removeWhere((p) => p['id'] == messageId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error deleting forum message: $e");
      return false;
    }
  }

  Future<bool> deleteAdminMessage(String token, String messageId) async {
    try {
      await ApiService.deleteAdminMessage(token, messageId);
      _adminMessages.removeWhere((p) => p['id'] == messageId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error deleting admin message: $e");
      return false;
    }
  }

  Future<bool> updateAdminMessage(
    String token,
    String messageId,
    String text, {
    String? imageUrl,
    String? videoUrl,
    String? audioUrl,
    String? videoThumbnail,
    String? audioThumbnail,
  }) async {
    try {
      await ApiService.updateAdminMessage(
        token,
        messageId,
        text,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        audioUrl: audioUrl,
        videoThumbnail: videoThumbnail,
        audioThumbnail: audioThumbnail,
      );
      final index = _adminMessages.indexWhere((p) => p['id'] == messageId);
      if (index != -1) {
        _adminMessages[index]['text'] = text;
        _adminMessages[index]['imageUrl'] = imageUrl;
        _adminMessages[index]['videoUrl'] = videoUrl;
        _adminMessages[index]['audioUrl'] = audioUrl;
        _adminMessages[index]['videoThumbnail'] = videoThumbnail;
        _adminMessages[index]['audioThumbnail'] = audioThumbnail;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error updating admin message: $e");
      return false;
    }
  }

  Future<bool> reactToAdminMessage(String token, String communityId, String msgId, String emoji) async {
    try {
      await ApiService.reactToAdminMessage(token, communityId, msgId, emoji);
      // We aren't fully managing reaction state locally yet without a re-fetch, but can just return true.
      // A full implementation would update _adminMessages locally.
      return true;
    } catch (e) {
      debugPrint("Error reacting to admin message: $e");
      return false;
    }
  }

  Future<bool> toggleAdminMessageCommentLike(String token, String communityId, String commentId) async {
    try {
      await ApiService.toggleAdminMessageCommentLike(token, communityId, commentId);
      return true;
    } catch (e) {
      debugPrint("Error toggling admin message comment like: $e");
      return false;
    }
  }

  Future<bool> deleteCommunityPost(String token, String postId) async {
    try {
      await ApiService.deleteCommunityPost(token, postId);
      if (_currentCommunity != null) {
        final posts = _currentCommunity!['posts'] as List<dynamic>?;
        if (posts != null) {
          posts.removeWhere((p) => p['id'] == postId);
          notifyListeners();
        }
      }
      return true;
    } catch (e) {
      debugPrint("Error deleting post: $e");
      return false;
    }
  }

  Future<bool> deleteCommunityComment(String token, String commentId) async {
    try {
      await ApiService.deleteCommunityComment(token, commentId);
      // Let the UI reload or just assume it deleted via FeedProvider, etc.
      return true;
    } catch (e) {
      debugPrint("Error deleting comment: $e");
      return false;
    }
  }

  Future<bool> updateCommunitySettings(
    String token,
    String communityId, {
    bool? isForumDisabledGlobally,
  }) async {
    try {
      await ApiService.updateCommunitySettings(
        token,
        communityId,
        isForumDisabledGlobally: isForumDisabledGlobally,
      );
      if (_currentCommunity != null && _currentCommunity!['id'] == communityId) {
        if (isForumDisabledGlobally != null) {
          _currentCommunity!['isForumDisabledGlobally'] = isForumDisabledGlobally;
        }
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error updating settings: $e");
      return false;
    }
  }

  Future<bool> moderateCommunityMember(
    String token,
    String communityId,
    String memberUserId, {
    bool? isSuspended,
    bool? canPostForum,
  }) async {
    try {
      await ApiService.moderateCommunityMember(
        token,
        communityId,
        memberUserId,
        isSuspended: isSuspended,
        canPostForum: canPostForum,
      );
      if (_currentCommunity != null && _currentCommunity!['id'] == communityId) {
        final members = _currentCommunity!['members'] as List<dynamic>?;
        if (members != null) {
          final index = members.indexWhere((m) => m['id'] == memberUserId);
          if (index != -1) {
            if (isSuspended != null) members[index]['isSuspended'] = isSuspended;
            if (canPostForum != null) members[index]['canPostForum'] = canPostForum;
            notifyListeners();
          }
        }
      }
      return true;
    } catch (e) {
      debugPrint("Error moderating member: $e");
      return false;
    }
  }

  Future<void> loadCommunityVerse(String token, String communityId) async {
    _isLoadingVerse = true;
    notifyListeners();
    try {
      _currentVerse = await ApiService.fetchCommunityDailyVerse(token, communityId);
    } catch (e) {
      debugPrint("Error loading community verse: $e");
      _currentVerse = null;
    } finally {
      _isLoadingVerse = false;
      notifyListeners();
    }
  }

  Future<bool> toggleCommunityVerseLike(String token, String communityId) async {
    try {
      final res = await ApiService.toggleCommunityDailyVerseLike(token, communityId);
      if (_currentVerse != null) {
        _currentVerse!['hasLiked'] = res['liked'];
        if (res['liked'] == true) {
          _currentVerse!['likesCount'] = (_currentVerse!['likesCount'] ?? 0) + 1;
        } else {
          _currentVerse!['likesCount'] = (_currentVerse!['likesCount'] ?? 1) - 1;
        }
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error toggling community verse like: $e");
      return false;
    }
  }

  Future<bool> shareCommunityVerse(String token, String communityId) async {
    try {
      await ApiService.shareCommunityDailyVerse(token, communityId);
      if (_currentVerse != null) {
        _currentVerse!['sharesCount'] = (_currentVerse!['sharesCount'] ?? 0) + 1;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint("Error sharing community verse: $e");
      return false;
    }
  }

  Future<bool> overrideCommunityVerse(
    String token,
    String communityId,
    String date,
    String reference,
    String text,
    String explanation,
  ) async {
    try {
      await ApiService.overrideCommunityDailyVerse(token, communityId, {
        'date': date,
        'reference': reference,
        'text': text,
        'explanation': explanation,
      });
      // Optionally reload verse if overriding today's date
      final todayStr = DateTime.now().toIso8601String().split('T')[0];
      if (date == todayStr) {
        await loadCommunityVerse(token, communityId);
      }
      return true;
    } catch (e) {
      debugPrint("Error overriding community verse: $e");
      return false;
    }
  }
}
