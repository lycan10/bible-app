import 'package:flutter/material.dart';

import 'package:quest/screens/navigation_screen.dart';

import 'package:quest/screens/onboarding/flash_screen.dart';

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

      // home: const FlashScreen(),
      home: const NavigationScreen(),
    );
  }
}
