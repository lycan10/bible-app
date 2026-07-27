import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/game_settings_provider.dart';
import 'package:quest/screens/bible_quiz/quiz_finish_screen.dart';
import 'package:quest/providers/game_settings_provider.dart';
import 'package:quest/services/game_service.dart';

class BibleQuizScreen extends StatefulWidget {
  final int level;

  const BibleQuizScreen({super.key, required this.level});

  @override
  State<BibleQuizScreen> createState() => _BibleQuizScreenState();
}

class _BibleQuizScreenState extends State<BibleQuizScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  List<dynamic> _questions = [];
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswerLocked = false;
  int _score = 0;
  int _maxLevel = 302;

  int _topScore = 0;
  int _lastScore = 0;
  final int _coins = 0;

  GameSettingsProvider? _gameSettings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gameSettings ??= Provider.of<GameSettingsProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameSettings?.playBackgroundMusic('audio/bible_quiz.aac');
    });
  }

  Future<void> _loadData() async {
    try {
      // we assume the game service fetch uses the level instead of difficulty
      final res = await GameService.fetchBibleQuizQuestions(widget.level);
      final scores = await GameService.fetchScores('BIBLE_QUIZ');

      if (!mounted) return;
      setState(() {
        _questions = res['questions'];
        _topScore = scores['topScore'] ?? 0;
        _lastScore = scores['lastScore'] ?? 0;
        _maxLevel = res['maxLevel'] ?? 302;
        _isLoading = false;
      });

      if (_questions.isNotEmpty) {
        setState(() {
          _isAnswerLocked = false;
          _selectedOptionIndex = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load questions.";
          _isLoading = false;
        });
      }
    }
  }

  void _selectOption(int index) {
    if (_isAnswerLocked) return;
    setState(() {
      _selectedOptionIndex = index;
      _isAnswerLocked = true;
    });

    final question = _questions[_currentQuestionIndex];
    if (index == question['correctAnswerIndex']) {
      _score++;
      _gameSettings?.playCorrectSound();
    } else {
      _gameSettings?.playIncorrectSound();
    }

    // Delay before next question
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _advanceOrSubmit();
    });
  }

  void _showFailedLevelDialog(int cutoff) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final firstName = user?['firstName'] ?? 'Player';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/star.png', height: 150),
                const SizedBox(height: 16),
                Text(
                  'You scored $_score/${_questions.length}. You need $cutoff to pass this level, $firstName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    _retryLevel();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Try again',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // leave screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.black,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _retryLevel() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _isAnswerLocked = false;
      _selectedOptionIndex = null;
    });
  }

  void _showBadgeUnlockedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/star.png',
                  height: 150,
                ), // using star.png as substitute for the stairs/star graphic
                const SizedBox(height: 16),
                const Text(
                  "You're winning!",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You have unlocked a new badge",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // close dialog

                    // Increment level and persist
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    authProvider.updateUserLocally({
                      'bibleQuizLevel': widget.level + 1,
                    });

                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                BibleQuizScreen(level: widget.level + 1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Play On',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // exit to games screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.black,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _advanceOrSubmit() async {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswerLocked = false;
        _selectedOptionIndex = null;
      });
    } else {
      await _submitAnswers();
    }
  }

  Future<void> _submitAnswers() async {
    int cutoff = 7;
    if (widget.level > 100 && widget.level <= 200) {
      cutoff = 8;
    } else if (widget.level > 200) {
      cutoff = 9;
    }

    if (_score < cutoff) {
      _showFailedLevelDialog(cutoff);
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    int earnedCoins = 0;
    try {
      final res = await GameService.submitScore(
        'BIBLE_QUIZ',
        widget.level.toString(),
        _score,
      );
      earnedCoins = res['pointsEarned'] ?? 0;
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.updateUserLocally({
        'points': (authProvider.user?['points'] ?? 0) + earnedCoins,
        if (authProvider.user?['bibleQuizLevel'] <= widget.level)
          'bibleQuizLevel': widget.level + 1,
      });
    } catch (e) {
      debugPrint('Failed to submit score: $e');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => QuizFinishScreen(
              score: _score,
              totalQuestions: _questions.length,
              level: widget.level,
              coinsEarned: earnedCoins,
            ),
      ),
    );
  }

  @override
  void dispose() {
    _gameSettings?.stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF3C38C3),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_errorMessage != null || _questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF3C38C3),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                _errorMessage ?? 'No questions found.',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];
    List<dynamic> options = [];
    if (question['options'] is String) {
      options = json.decode(question['options']);
    } else {
      options = question['options'];
    }

    final user = Provider.of<AuthProvider>(context).user;
    final firstName = user?['firstName'] ?? 'Player';

    return Scaffold(
      backgroundColor: const Color(0xFF3C38C3),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/images/bible_game.png',
                          width: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Bible Quiz',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showExitDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Profile & Level info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // User Profile Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          firstName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Level and coin
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Level',
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 12,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${widget.level}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: '/$_maxLevel',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withAlpha(150),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Text(
                            '${user?['points'] ?? 0}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Image.asset('assets/images/gold.png', width: 28),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Main Game Area (expanded to push bottom illustrations down)
            Expanded(
              child: Stack(
                children: [
                  // Bottom illustrations placeholder (using opacity or basic shapes if no exact image)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(50),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Two top images
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/images/bible-quiz-top1.png',
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        height: 120,
                                        color: Colors.grey,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/images/bible-quiz-top2.png',
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        height: 120,
                                        color: Colors.grey,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Question Card
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(150),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                question['questionText'] ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Pick the correct answer text
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Pick the correct answer',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Options grid (2x2)
                        Expanded(
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 2.5,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options[index];
                              final isSelected = _selectedOptionIndex == index;

                              bool isCorrectAnswer = false;
                              bool isWrongAnswer = false;

                              if (_isAnswerLocked) {
                                if (index == question['correctAnswerIndex']) {
                                  isCorrectAnswer = true;
                                } else if (isSelected) {
                                  isWrongAnswer = true;
                                }
                              }

                              Color bgColor = const Color(
                                0xFF4C46E8,
                              ); // default pill blue
                              if (isCorrectAnswer) bgColor = Colors.green;
                              if (isWrongAnswer) bgColor = Colors.red;

                              return GestureDetector(
                                onTap: () => _selectOption(index),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 12),
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            String.fromCharCode(
                                              97 + index,
                                            ), // a, b, c, d
                                            style: TextStyle(
                                              color: bgColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          option.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Exit Quiz?'),
            content: const Text('Your progress will be lost if you exit now.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // exit quiz
                },
                child: const Text('Exit', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
