class DateFormatter {
  static String formatTimeAgo(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Today';
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
          final months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
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
