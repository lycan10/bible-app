import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/feed_provider.dart';
import 'package:quest/providers/chat_provider.dart';
import 'package:quest/providers/quiz_provider.dart';
import 'package:quest/providers/bible_provider.dart';
import 'package:quest/providers/notification_provider.dart';
import 'package:quest/providers/feature_provider.dart';
import 'package:quest/providers/game_settings_provider.dart';
import 'package:quest/providers/community_provider.dart';
import 'package:quest/providers/devotion_provider.dart';
import 'package:quest/providers/media_provider.dart';
import 'package:quest/screens/navigation_screen.dart';
import 'package:quest/screens/onboarding/flash_screen.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/services/deeplink_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:quest/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService().showLocalNotification(message);
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// Global navigator key for navigation from outside widget tree (e.g. notifications)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Background handler MUST be registered before any other Firebase calls.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Full notification setup (channels, listeners, permission requests).
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadSession()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => BibleProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(
          create: (_) => FeatureProvider()..loadFeatures(),
        ),
        ChangeNotifierProvider(create: (_) => GameSettingsProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => DevotionProvider()),
        ChangeNotifierProvider(create: (_) => MediaProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    DeepLinkService.init();
    // Wire up global 401 → auto-logout. We defer by one frame so the provider
    // tree is guaranteed to be mounted when the callback fires.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      ApiService.onUnauthorized = () {
        // Guard: only logout if currently authenticated to avoid redundant calls.
        if (auth.isAuthenticated) {
          auth.logout();
        }
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final appearance = authProvider.user?['appearance'] as String?;

    ThemeMode themeMode = ThemeMode.system;
    if (appearance == 'light') {
      themeMode = ThemeMode.light;
    } else if (appearance == 'dark') {
      themeMode = ThemeMode.dark;
    }

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Quest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],
      navigatorObservers: [routeObserver],
      home:
          authProvider.isAuthenticated && authProvider.isOnboardingComplete
              ? const NavigationScreen()
              : const FlashScreen(),
    );
  }
}
