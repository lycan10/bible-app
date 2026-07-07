import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:quest/main.dart';
import 'package:quest/screens/notification/Notification_screen.dart';

// ---------------------------------------------------------------------------
// Android notification channel definitions
// ---------------------------------------------------------------------------
const AndroidNotificationChannel _pushChannel = AndroidNotificationChannel(
  'quest_push_channel',
  'Quest Push Notifications',
  description: 'General push notifications from Quest',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

const AndroidNotificationChannel _reminderChannel = AndroidNotificationChannel(
  'quest_reminder_channel',
  'Quest Reminders',
  description: 'Daily study reminders',
  importance: Importance.high,
  playSound: true,
);

// ---------------------------------------------------------------------------
// Top-level background notification response handler.
// Must be a top-level (non-anonymous) function annotated with
// @pragma('vm:entry-point') so the AOT compiler keeps it.
// ---------------------------------------------------------------------------
@pragma('vm:entry-point')
void _onDidReceiveBackgroundNotificationResponse(NotificationResponse details) {
  // Handle local notification tap while app is in the background/terminated.
  // Navigation cannot be done here (no BuildContext). Instead, you can store
  // the payload and handle it when the app resumes.
  debugPrint('[NotificationService] Background tap: ${details.payload}');
}

// ---------------------------------------------------------------------------
// NotificationService
// ---------------------------------------------------------------------------
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Stream for foreground messages to allow providers to react
  final StreamController<RemoteMessage> _foregroundMessageController =
      StreamController<RemoteMessage>.broadcast();

  Stream<RemoteMessage> get onForegroundMessage =>
      _foregroundMessageController.stream;

  // -------------------------------------------------------------------------
  // initialize() — call once from main() in the main isolate.
  // -------------------------------------------------------------------------
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    // -- 1. FCM permissions ---------------------------------------------------
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: false,
      announcement: false,
      carPlay: false,
      provisional: false,
    );

    // -- 2. Android: create notification channels BEFORE showing any notification.
    final androidPlugin =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_pushChannel);
      await androidPlugin.createNotificationChannel(_reminderChannel);
      // Request POST_NOTIFICATIONS permission on Android 13+
      await androidPlugin.requestNotificationsPermission();
    }

    // -- 3. Initialise local notifications plugin ----------------------------
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      // Foreground tap handler (app is open).
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      // Background tap handler (app is in background / terminated).
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
    );

    // -- 4. FCM: foreground messages -----------------------------------------
    // By default FCM suppresses the heads-up notification when the app is in
    // the foreground. We intercept and show a local notification instead.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Foreground message: ${message.messageId}');
      _foregroundMessageController.add(message);
      showLocalNotification(message);
    });

    // -- 5. FCM: notification tapped while app in background (not terminated) -
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Opened from background: ${message.messageId}');
      _handleMessageNavigation(message);
    });

    // -- 6. FCM: notification tapped while app was terminated ----------------
    final RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM] Launched from terminated: ${initialMessage.messageId}');
      // Delay to let the widget tree finish building.
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleMessageNavigation(initialMessage);
      });
    }

    // -- 7. iOS: foreground presentation options -----------------------------
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _initialized = true;
  }

  // -------------------------------------------------------------------------
  // showLocalNotification — safe to call from background isolate.
  // -------------------------------------------------------------------------
  Future<void> showLocalNotification(RemoteMessage message) async {
    // In the background isolate _initialized is always false (fresh isolate).
    // We must initialise the plugin without the FCM listeners to avoid
    // duplicate listeners in the main isolate.
    if (!_initialized) {
      await _initForBackgroundIsolate();
    }

    final notification = message.notification;
    final String? title = notification?.title ?? message.data['title'];
    final String? body = notification?.body ?? message.data['body'];
    final String? imageUrl =
        notification?.android?.imageUrl ?? message.data['image'];

    if (title == null && body == null) return;

    // Use a stable, unique ID derived from the message so duplicate suppression works.
    final int notifId =
        (message.messageId ?? message.hashCode.toString()).hashCode.abs() %
        100000;

    final androidDetails = AndroidNotificationDetails(
      _pushChannel.id,
      _pushChannel.name,
      channelDescription: _pushChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      largeIcon:
          imageUrl != null
              ? DrawableResourceAndroidBitmap('@mipmap/ic_launcher')
              : null,
      styleInformation:
          body != null && body.length > 40
              ? BigTextStyleInformation(body)
              : null,
      ticker: title,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      id: notifId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: message.data.isNotEmpty ? message.data.toString() : null,
    );
  }

  // -------------------------------------------------------------------------
  // Schedule a daily recurring reminder
  // -------------------------------------------------------------------------
  Future<void> scheduleDailyReminder(
    int id,
    String title,
    String body,
    TimeOfDay time,
  ) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannel.id,
          _reminderChannel.name,
          channelDescription: _reminderChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelReminder(int id) async => _plugin.cancel(id: id);

  Future<void> cancelAllReminders() async => _plugin.cancelAll();

  Future<String?> getFCMToken() async => _firebaseMessaging.getToken();

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  /// Minimal initialisation for the background isolate — no FCM listeners.
  Future<void> _initForBackgroundIsolate() async {
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onDidReceiveBackgroundNotificationResponse,
    );

    _initialized = true;
  }

  /// Handle navigation when a notification is tapped.
  void _handleMessageNavigation(RemoteMessage message) {
    debugPrint('[FCM] Navigate for data: ${message.data}');
    navigateFromNotificationPayload(message.data);
  }
}

// ---------------------------------------------------------------------------
// Top-level foreground tap handler — kept outside the class so it can be
// referenced without an instance, but still has access to the service if needed.
// ---------------------------------------------------------------------------
void _onDidReceiveNotificationResponse(NotificationResponse details) {
  debugPrint('[NotificationService] Foreground tap: ${details.payload}');
  if (details.payload != null && details.payload!.isNotEmpty) {
    // Basic parsing of payload if it's sent as a string representation of a map
    // In a real scenario, consider using jsonDecode if the payload is JSON
    navigateFromNotificationPayload({});
  } else {
    _navigateToNotificationScreen();
  }
}

void _navigateToNotificationScreen() {
  final context = navigatorKey.currentContext;
  if (context != null) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const NotificationScreen()));
  }
}

void navigateFromNotificationPayload(Map<String, dynamic> data) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  final type = data['type'] ?? '';
  // You can extend this to route to specific screens based on type
  // e.g., if (type == 'CHAT_MESSAGE') Navigator.push(...)
  
  // Default fallback
  _navigateToNotificationScreen();
}

// iOS-only: called when a local notification arrives while the app is in foreground.
// Empty replacement because method is not used anymore
