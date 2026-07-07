import 'package:flutter/material.dart';
import 'package:quest/services/api_service.dart';

class CommunityProvider with ChangeNotifier {
  List<dynamic> _communities = [];
  List<dynamic> _recommendedCommunities = [];

  Map<String, dynamic>? _currentCommunity;
  List<dynamic> _currentPosts = [];
  List<dynamic> _currentEvents = [];
  List<dynamic> _currentMessages = [];
  bool _isLoadingMoreMessages = false;
  bool _hasMoreMessages = true;

  bool _isLoadingMorePosts = false;
  bool _hasMorePosts = true;

  bool _isLoadingMoreEvents = false;
  bool _hasMoreEvents = true;

  bool _isLoading = false;

  List<dynamic> get communities => _communities;
  List<dynamic> get recommendedCommunities => _recommendedCommunities;

  Map<String, dynamic>? get currentCommunity => _currentCommunity;
  List<dynamic> get currentPosts => _currentPosts;
  List<dynamic> get currentEvents => _currentEvents;
  List<dynamic> get currentMessages => _currentMessages;
  bool get isLoadingMoreMessages => _isLoadingMoreMessages;
  bool get hasMoreMessages => _hasMoreMessages;

  bool get isLoading => _isLoading;

  Future<void> loadCommunities(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      _communities = await ApiService.fetchCommunities(token);
      _recommendedCommunities = await ApiService.fetchRecommendedCommunities(
        token,
      );
    } catch (e) {
      debugPrint("Error loading communities: \$e");
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
      _currentPosts = await ApiService.fetchCommunityPosts(token, id);
      _currentEvents = await ApiService.fetchCommunityEvents(token, id);
      _currentMessages = await ApiService.fetchCommunityMessages(token, id);
    } catch (e) {
      debugPrint("Error loading community details: \$e");
    } finally {
      _isLoading = false;
      notifyListeners();
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
      debugPrint("Error reacting to post: \$e");
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
    String location,
  ) async {
    try {
      final newEvent = await ApiService.createCommunityEvent(
        token,
        communityId,
        title,
        description,
        date,
        time,
        location,
      );
      // Automatically add to local events
      _currentEvents.insert(0, newEvent);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error creating event: $e");
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

      final newMsg = await ApiService.sendCommunityMessage(
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
      debugPrint("Error sending forum message: \$e");
      return false;
    }
  }
}
