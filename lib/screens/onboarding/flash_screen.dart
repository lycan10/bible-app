import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quest/screens/onboarding/welcome_screen.dart';

class FlashScreen extends StatefulWidget {
  const FlashScreen({super.key});

  @override
  State<FlashScreen> createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Make status bar transparent so splash fills the whole screen
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1200),
          pageBuilder: (_, animation, __) => const WelcomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;

            final tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: Curves.easeOutExpo));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ColorFiltered(
            // Invert the logo so it appears white on the black background
            colorFilter: const ColorFilter.matrix(<double>[
              -1, 0, 0, 0, 255,
               0,-1, 0, 0, 255,
               0, 0,-1, 0, 255,
               0, 0, 0, 1,   0,
            ]),
            child: Image.asset('assets/images/logo.png', width: 120),
          ),
        ),
      ),
    );
  }
}
