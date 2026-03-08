import 'package:flutter/material.dart';
import 'package:quest/screens/word_match/word_match_game_screen.dart';
import 'package:quest/screens/word_match/word_match_mode.dart';
import '../../theme/theme.dart';

class WordMatchTopicsScreen extends StatelessWidget {
  const WordMatchTopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    'Word Match',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                'Choose a topic to begin',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 30),

              // Topics Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.95,
                  children: const [
                    _TopicCard(
                      title: 'Word Meaning',
                      subtitle: 'Match words to meanings',
                      icon: Icons.menu_book_rounded,
                      mode: WordMatchMode.wordMeaning,
                    ),
                    _TopicCard(
                      title: 'Bible Characters',
                      subtitle: 'Match characters to roles',
                      icon: Icons.person_rounded,
                      mode: WordMatchMode.character,
                    ),
                    _TopicCard(
                      title: 'Places & Events',
                      subtitle: 'Match places to events',
                      icon: Icons.location_on_rounded,
                      mode: WordMatchMode.place,
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

class _TopicCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final WordMatchMode mode;

  const _TopicCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WordMatchGameScreen(mode: WordMatchMode.character),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(blurRadius: 10, offset: const Offset(0, 6))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.goldAccent.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 36, color: AppTheme.goldAccent),
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
