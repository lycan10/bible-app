import 'package:flutter/material.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<dynamic> _notifications = [];
  final Set<String> _readIds = {};
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentToken;

  NotificationProvider() {
    NotificationService().onForegroundMessage.listen((message) {
      if (_currentToken != null) {
        // Option 1: fetch from backend again to ensure consistency
        fetchNotifications(_currentToken!);
        // Option 2: manually inject to _notifications
      }
    });
  }

  List<dynamic> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Number of notifications the user hasn't tapped/read yet.
  int get unreadCount =>
      _notifications
          .where((n) => !_readIds.contains(n['id']?.toString()) && n['isRead'] != true && n['read'] != true)
          .length;

  bool isRead(dynamic notif) => 
      _readIds.contains(notif['id']?.toString()) || notif['isRead'] == true || notif['read'] == true;

  /// Mark a single notification as read locally and sync with backend.
  Future<void> markAsRead(String token, dynamic notif) async {
    final id = notif['id']?.toString();
    if (id != null && _readIds.add(id)) {
      notifyListeners();
      try {
        await ApiService.markNotificationAsRead(token, id);
      } catch (e) {
        _readIds.remove(id);
        notifyListeners();
      }
    }
  }

  /// Mark all notifications as read.
  void markAllAsRead() {
    for (final n in _notifications) {
      final id = n['id']?.toString();
      if (id != null) _readIds.add(id);
    }
    notifyListeners();
  }

  Future<void> fetchNotifications(String token) async {
    _currentToken = token;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await ApiService.fetchNotifications(token);
      for (var n in _notifications) {
        if (n['isRead'] == true || n['read'] == true) {
          final id = n['id']?.toString();
          if (id != null) {
            _readIds.add(id);
          }
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
