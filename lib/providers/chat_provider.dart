import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<dynamic> _chats = [];
  final Map<String, List<dynamic>> _chatMessages = {};
  List<dynamic> _pinnedChats = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get chats => _chats;
  List<dynamic> get pinnedChats => _pinnedChats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalUnreadCount {
    int count = 0;
    for (var chat in _chats) {
      count += (chat['unreadCount'] ?? 0) as int;
    }
    return count;
  }

  List<dynamic> getMessages(String chatId) => _chatMessages[chatId] ?? [];

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

      // Update last message in chat list
      final index = _chats.indexWhere((c) => c['id'] == chatId);
      if (index != -1) {
        _chats[index]['lastMessage'] = msg;
        // Move chat to top
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
      // Reload pinned chats
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
