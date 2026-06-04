import 'package:flutter/material.dart';
import 'package:quest/screens/word_match/word_match_game_screen.dart';
import '../../theme/theme.dart';

class WordMatchFinishScreen extends StatelessWidget {
  final int score;
  final int total;
  final String difficulty;

  const WordMatchFinishScreen({
    super.key,
    required this.score,
    required this.total,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = score / total;
    String message;
    IconData icon;
    Color color;

    if (percentage == 1.0) {
      message = 'Perfect Score!';
      icon = Icons.star_rounded;
      color = AppTheme.goldAccent;
    } else if (percentage >= 0.7) {
      message = 'Great Job!';
      icon = Icons.thumb_up_rounded;
      color = Colors.green;
    } else if (percentage >= 0.5) {
      message = 'Good Effort!';
      icon = Icons.sentiment_satisfied_rounded;
      color = Colors.orange;
    } else {
      message = 'Keep Trying!';
      icon = Icons.refresh_rounded;
      color = Colors.red;
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 80, color: color),
              ),
              const SizedBox(height: 32),
              Text(
                message,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'You matched',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$score',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  Text(
                    ' / $total',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Difficulty: ${difficulty.toUpperCase()}',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: Colors.grey.shade500),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => WordMatchGameScreen(difficulty: difficulty),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Play Again',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Back to Menu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
