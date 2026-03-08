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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start, //
            mainAxisSize: MainAxisSize.max, //
            children: [
              const SizedBox(height: 20),

              Text(
                'Title',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Quizzes,\nPuzzles,\nPlay with\nFriends',
                style: theme.textTheme.displayMedium?.copyWith(
                fontSize: 42
                ),
              ),

              const SizedBox(height: 15),

              Image.asset("assets/images/Onboarding.png"),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () => _navigateToGetStartedScreen(context),
                child: Container(
                  width: 110,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppTheme.goldAccent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Play on',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),


              Text(
                '“Your word is a lamp to my feet and a light to my path.” — Psalm 119:105',
                textAlign: TextAlign.left,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          )

        ),
      ),
    );
  }
}
