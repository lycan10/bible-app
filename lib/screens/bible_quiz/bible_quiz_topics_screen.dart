import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../theme/theme.dart';
import 'bible_quiz_screen.dart';

class BibleTopicsScreen extends StatelessWidget {
  BibleTopicsScreen({super.key});

  final List<QuizTopic> topics = [
    QuizTopic(
      title: 'Old Testament',
      icon: Icons.menu_book_rounded,
      questionCount: 20,
    ),
    QuizTopic(
      title: 'New Testament',
      icon: Icons.auto_stories_rounded,
      questionCount: 20,
    ),
    QuizTopic(
      title: 'Life of Jesus',
      icon: Icons.star_rounded,
      questionCount: 15,
    ),
    QuizTopic(
      title: 'Parables',
      icon: Icons.lightbulb_rounded,
      questionCount: 10,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      size: 25.0,
                    ),
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
                'Choose a topic to begin',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 30),

              /// Topics list
              Expanded(
                child: ListView.separated(
                  itemCount: topics.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final topic = topics[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BibleQuizScreen(
                              // later you can pass topic data here
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppTheme.primaryBlue.withAlpha(50),
                          border: Border.all(
                            color: AppTheme.primaryBlue.withAlpha(40),
                          ),
                        ),
                        child: Row(
                          children: [
                            /// Icon
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withAlpha(20),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                topic.icon,
                                size: 30,
                                color: AppTheme.primaryBlue,
                              ),
                            ),

                            const SizedBox(width: 16),

                            /// Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    topic.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${topic.questionCount} questions',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class QuizTopic {
  final String title;
  final IconData icon;
  final int questionCount;

  QuizTopic({
    required this.title,
    required this.icon,
    required this.questionCount,
  });
}
