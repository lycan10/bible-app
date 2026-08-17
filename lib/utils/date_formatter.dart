class DateFormatter {
  static String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String formatTimeAgo(String? dateTimeStr) {
    if (dateTimeStr == null) return _formatDate(DateTime.now());
    try {
      final dateTime = DateTime.parse(dateTimeStr).toLocal();
      final now = DateTime.now();

      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final itemDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (itemDate == today) {
        final difference = now.difference(dateTime);
        if (difference.inSeconds < 60) {
          final secs = difference.inSeconds < 0 ? 0 : difference.inSeconds;
          return '$secs sec ago';
        } else if (difference.inMinutes < 60) {
          return '${difference.inMinutes} min ago';
        } else {
          return '${difference.inHours} hours ago';
        }
      } else if (itemDate == yesterday) {
        return 'yesterday';
      } else {
        final difference = now.difference(dateTime);
        if (difference.inDays < 7) {
          return '${difference.inDays} days ago';
        } else {
          return _formatDate(dateTime);
        }
      }
    } catch (e) {
      return dateTimeStr;
    }
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}
