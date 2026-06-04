import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:quest/screens/onboarding/get_started.dart';
import 'package:quest/theme/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _navigateToGetStartedScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder:
            (context, animation, secondaryAnimation) => const GetStarted(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.scaled,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quest',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Quizzes,\nPuzzles,\nPlay with\nFriends',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Image.asset(
                      "assets/images/Onboarding.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () => _navigateToGetStartedScreen(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldAccent,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                icon: const Text('Play on'),
                label: const Icon(Icons.arrow_forward_ios, size: 14),
              ),
              const SizedBox(height: 40),

              Text(
                '“Your word is a lamp to my feet and a light to my path.” \n— Psalm 119:105',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      theme.brightness == Brightness.dark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
