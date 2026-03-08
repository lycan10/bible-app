import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/screens/bible_quiz/quiz_finish_screen.dart';

import '../../theme/theme.dart';

class BibleQuizScreen extends StatefulWidget {
  const BibleQuizScreen({super.key});

  @override
  State<BibleQuizScreen> createState() => _BibleQuizScreenState();
}

class _BibleQuizScreenState extends State<BibleQuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;

  int? _selectedOptionIndex; // track which option is tapped

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Who led the Israelites out of Egypt?',
      'options': ['Moses', 'Abraham', 'David', 'Noah'],
      'answer': 'Moses',
    },
    {
      'question': 'Which disciple denied Jesus three times?',
      'options': ['Peter', 'John', 'James', 'Matthew'],
      'answer': 'Peter',
    },
  ];

  void _selectOption(int index) {
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _nextQuestion() {
    final correctAnswer = _questions[_currentQuestionIndex]['answer'];
    final selectedOption =
        _questions[_currentQuestionIndex]['options'][_selectedOptionIndex ??
            -1];

    if (selectedOption == correctAnswer) {
      _score++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null; // reset selection
      });
    } else {
      // Navigate to finish screen instead of dialog
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => QuizFinishScreen(
                score: _score,
                totalQuestions: _questions.length,
                onRestart: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const BibleQuizScreen()),
                  );
                },
              ),
        ),
      );
    }
  }

  void _showScoreDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Quiz Complete!'),
            content: Text('Your score is $_score / ${_questions.length}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _currentQuestionIndex = 0;
                    _score = 0;
                    _selectedOptionIndex = null;
                  });
                },
                child: const Text('Restart'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Exit'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        size: 25.0,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      'Bible Quiz',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                QuestionHeader(
                  currentQuestionIndex: _currentQuestionIndex,
                  totalQuestions: _questions.length,
                ),
                const SizedBox(height: 20),
                QuestionProgressBar(
                  currentQuestionIndex: _currentQuestionIndex,
                  totalQuestions: _questions.length,
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.goldAccent, width: 2),
                    color: AppTheme.goldAccent.withAlpha(40),
                  ),
                  child: Text(
                    question['question'],
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Options
                ...List.generate(question['options'].length, (index) {
                  final option = question['options'][index];
                  final isSelected = _selectedOptionIndex == index;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () => _selectOption(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: isSelected ? 2 : 0,
                            color:
                                isSelected
                                    ? AppTheme.primaryBlue
                                    : Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color:
                              isSelected
                                  ? AppTheme.primaryBlue.withAlpha(
                                    150,
                                  ) // selected color
                                  : AppTheme.primaryBlue.withAlpha(25),
                        ),
                        child: Text(
                          option,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const Spacer(),
                ElevatedButton(
                  onPressed:
                      _selectedOptionIndex != null ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Next', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuestionHeader extends StatefulWidget {
  final int currentQuestionIndex;
  final int totalQuestions;

  const QuestionHeader({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
  });

  @override
  _QuestionHeaderState createState() => _QuestionHeaderState();
}

class _QuestionHeaderState extends State<QuestionHeader> {
  int _secondsLeft = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 30; // reset timer
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
        // Optionally handle timeout here
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            Text(
              '${widget.currentQuestionIndex + 1}/${widget.totalQuestions}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 28,
              ),
            ),
          ],
        ),

        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 65, // size of the circle
                height: 65,
                child: CircularProgressIndicator(
                  value: _secondsLeft / 30,
                  strokeWidth: 4,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryBlue,
                  ),
                ),
              ),
              Text(
                '00:$_secondsLeft s',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class QuestionProgressBar extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;

  const QuestionProgressBar({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (currentQuestionIndex + 1) / totalQuestions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
          ),
        ),
      ],
    );
  }
}
