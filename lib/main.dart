import 'package:flutter/material.dart';
import 'package:quest/screens/explore/explore_screen.dart';
import 'package:quest/screens/home/home_screen.dart';

import 'package:quest/screens/navigation_screen.dart';
import 'package:quest/screens/notification/Notification_screen.dart';

import 'package:quest/screens/onboarding/flash_screen.dart';
import 'package:quest/screens/profileScreen/profile_screen.dart';

import 'package:quest/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // home: const ExploreScreen(),
      home: const NavigationScreen(),
    );
  }
}
