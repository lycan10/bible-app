import 'package:flutter/material.dart';
import 'package:quest/services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<dynamic> _notifications = [];
  final Set<String> _readIds = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Number of notifications the user hasn't tapped/read yet.
  int get unreadCount =>
      _notifications.where((n) => !_readIds.contains(n['id']?.toString())).length;

  bool isRead(dynamic notif) => _readIds.contains(notif['id']?.toString());

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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await ApiService.fetchNotifications(token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
