import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import 'bible_quiz_screen.dart';

class BibleQuizDifficultyScreen extends StatelessWidget {
  const BibleQuizDifficultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Bible Quiz',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                'Choose a difficulty level to begin',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.95,
                  children: const [
                    _DifficultyCard(
                      title: 'Easy',
                      subtitle: 'Relaxed pace',
                      icon: Icons.sentiment_satisfied_alt_rounded,
                      difficulty: 'easy',
                      color: Colors.green,
                    ),
                    _DifficultyCard(
                      title: 'Medium',
                      subtitle: 'A bit challenging',
                      icon: Icons.sentiment_neutral_rounded,
                      difficulty: 'medium',
                      color: Colors.orange,
                    ),
                    _DifficultyCard(
                      title: 'Hard',
                      subtitle: 'Brain teaser',
                      icon: Icons.sentiment_very_dissatisfied_rounded,
                      difficulty: 'hard',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String difficulty;
  final MaterialColor color;

  const _DifficultyCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.difficulty,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BibleQuizScreen(difficulty: difficulty),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              offset: Offset(0, 6),
              color: Color(0x14000000),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 36, color: color.shade600),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
