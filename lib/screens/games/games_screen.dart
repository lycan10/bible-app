import 'package:flutter/material.dart';
import 'package:quest/screens/bible_quiz/bible_quiz_topics_screen.dart';
import 'package:quest/screens/word_cross/word_cross_difficulty_screen.dart';
import 'package:quest/screens/word_match/word_match_topic_screen.dart';
import 'package:quest/screens/home/home_screen.dart'; // To use GamesReelCard

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "All Games",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.8,
            children: [
              GamesReelCard(
                title: 'Bible Quiz',
                description: "Play to test your knowledge!",
                gameIcon: 'assets/images/bible_game.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BibleQuizDifficultyScreen(),
                    ),
                  );
                },
              ),
              GamesReelCard(
                title: 'Word Cross',
                description: "Find hidden words!",
                gameIcon: 'assets/images/puzzle_game.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WordCrossDifficultyScreen(),
                    ),
                  );
                },
              ),
              GamesReelCard(
                title: 'Word Match',
                description: "Match biblical terms!",
                gameIcon: 'assets/images/puzzle_game.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WordMatchDifficultyScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
