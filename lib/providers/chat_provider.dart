import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<dynamic> _chats = [];
  final Map<String, List<dynamic>> _chatMessages = {};
  List<dynamic> _pinnedChats = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// The chatId of the conversation currently open on screen.
  /// Used to suppress the unread-badge increment when the user is already
  /// reading that conversation and to suppress the foreground notification.
  String? _activeChatId;

  StreamSubscription<RemoteMessage>? _fcmSubscription;

  // ─── Public getters ────────────────────────────────────────────────────────

  List<dynamic> get chats => _chats;
  List<dynamic> get pinnedChats => _pinnedChats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get activeChatId => _activeChatId;

  int get totalUnreadCount {
    int count = 0;
    for (var chat in _chats) {
      count += (chat['unreadCount'] ?? 0) as int;
    }
    return count;
  }

  List<dynamic> getMessages(String chatId) => _chatMessages[chatId] ?? [];

  // ─── Active-chat tracking ──────────────────────────────────────────────────

  /// Call when entering a chat screen; prevents the FCM handler from bumping
  /// the unread badge while the user is already in that conversation.
  void setActiveChatId(String? chatId) {
    _activeChatId = chatId;
  }

  // ─── Unread message helpers ────────────────────────────────────────────────

  /// Returns the list index of the **first** message in [chatId] whose sender
  /// is not [currentUserId] and that has not yet been read.
  /// Returns -1 when there are no unread messages.
  int firstUnreadMessageIndex(String chatId, String currentUserId) {
    final messages = _chatMessages[chatId] ?? [];
    for (int i = 0; i < messages.length; i++) {
      final msg = messages[i];
      if (msg['senderId'] != currentUserId &&
          (msg['isRead'] == false || msg['isRead'] == null)) {
        return i;
      }
    }
    return -1;
  }

  // ─── FCM foreground listener ───────────────────────────────────────────────

  /// Subscribes to [stream] (the broadcast stream from [NotificationService]).
  /// When a CHAT_MESSAGE event arrives the provider immediately refreshes that
  /// chat's messages, making delivery feel instant for the receiver.
  void startFCMListener(Stream<RemoteMessage> stream, String token) {
    _fcmSubscription?.cancel();
    _fcmSubscription = stream.listen((RemoteMessage message) {
      final type = message.data['type'];
      final chatId = message.data['chatId'] as String?;
      if (type != 'CHAT_MESSAGE' || chatId == null) return;

      // Refresh messages immediately — this is what makes delivery feel instant.
      loadMessages(token, chatId);

      // Only bump the unread badge when the user is NOT already in this chat.
      if (_activeChatId != chatId) {
        final idx = _chats.indexWhere((c) => c['id'] == chatId);
        if (idx != -1) {
          final updated = Map<String, dynamic>.from(
            _chats[idx] as Map<String, dynamic>,
          );
          updated['unreadCount'] = (updated['unreadCount'] as int? ?? 0) + 1;
          _chats[idx] = updated;
          notifyListeners();
        } else {
          // This chat is not yet loaded — refresh the whole list.
          loadChats(token);
        }
      }
    });
  }

  /// Cancels the FCM foreground subscription (e.g. on logout).
  void stopFCMListener() {
    _fcmSubscription?.cancel();
    _fcmSubscription = null;
  }

  // ─── REST API operations ───────────────────────────────────────────────────

  Future<void> loadChats(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      _chats = await ApiService.fetchChats(token);
      _pinnedChats = await ApiService.fetchPinnedChats(token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markChatAsRead(String token, String chatId) async {
    final index = _chats.indexWhere((c) => c['id'] == chatId);
    if (index != -1 && (_chats[index]['unreadCount'] ?? 0) > 0) {
      _chats[index]['unreadCount'] = 0;
      notifyListeners();
      try {
        await ApiService.markChatAsRead(token, chatId);
      } catch (e) {
        debugPrint("Error marking chat as read: $e");
      }
    }
  }

  Future<void> loadMessages(String token, String chatId) async {
    try {
      final messages = await ApiService.fetchChatMessages(token, chatId);
      _chatMessages[chatId] = messages;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading messages: $e");
    }
  }

  Future<Map<String, dynamic>?> startChat(String token, String friendId) async {
    try {
      final newChat = await ApiService.startChat(token, friendId);
      final index = _chats.indexWhere((c) => c['id'] == newChat['id']);
      if (index == -1) {
        _chats.insert(0, newChat);
        notifyListeners();
      }
      return newChat;
    } catch (e) {
      debugPrint("Error starting chat: $e");
      return null;
    }
  }

  Future<bool> sendMessage(
    String token,
    String chatId,
    String text, {
    String? image,
  }) async {
    try {
      final msg = await ApiService.sendMessage(
        token,
        chatId,
        text,
        image: image,
      );
      if (_chatMessages[chatId] != null) {
        _chatMessages[chatId]!.add(msg);
      } else {
        _chatMessages[chatId] = [msg];
      }

      // Update last message preview in the chat list
      final index = _chats.indexWhere((c) => c['id'] == chatId);
      if (index != -1) {
        _chats[index]['lastMessage'] = msg;
        // Move chat to top of the list
        final chat = _chats.removeAt(index);
        _chats.insert(0, chat);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error sending message: $e");
      return false;
    }
  }

  Future<bool> pinChat(String token, String chatId) async {
    try {
      await ApiService.pinChat(token, chatId);
      _pinnedChats = await ApiService.fetchPinnedChats(token);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error pinning chat: $e");
      return false;
    }
  }

  Future<bool> unpinChat(String token, String chatId) async {
    try {
      await ApiService.unpinChat(token, chatId);
      _pinnedChats.removeWhere((c) => c['id'] == chatId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error unpinning chat: $e");
      return false;
    }
  }

  Future<bool> clearChat(String token, String chatId) async {
    try {
      await ApiService.clearChat(token, chatId);
      _chatMessages[chatId]?.clear();

      final index = _chats.indexWhere((c) => c['id'] == chatId);
      if (index != -1) {
        _chats[index]['lastMessage'] = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error clearing chat: $e");
      return false;
    }
  }

  bool isChatPinned(String chatId) {
    return _pinnedChats.any((c) => c['id'] == chatId);
  }
}
