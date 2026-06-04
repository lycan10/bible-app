import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/services/game_service.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/game_settings_provider.dart';
import 'package:quest/screens/games/game_settings_sheet.dart';
import '../../theme/theme.dart';
import 'quiz_finish_screen.dart';

class BibleQuizScreen extends StatefulWidget {
  final String difficulty;

  const BibleQuizScreen({
    super.key,
    required this.difficulty,
  });

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
  
  late int _timerDuration;
  late int _secondsLeft;
  Timer? _timer;

  int _topScore = 0;
  int _lastScore = 0;

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
      final res = await GameService.fetchBibleQuizQuestions(widget.difficulty);
      final scores = await GameService.fetchScores('BIBLE_QUIZ');
      
      if (!mounted) return;
      setState(() {
        _questions = res['questions'];
        _timerDuration = res['durationSecs'] ?? 30;
        _secondsLeft = _timerDuration;
        _topScore = scores['topScore'] ?? 0;
        _lastScore = scores['lastScore'] ?? 0;
        _isLoading = false;
      });

      if (_questions.isNotEmpty) {
        _startTimer();
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

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = _timerDuration;
      _isAnswerLocked = false;
      _selectedOptionIndex = null;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        _onTimerExpired();
      }
    });
  }

  void _onTimerExpired() {
    if (!mounted || _isAnswerLocked) return;
    setState(() => _isAnswerLocked = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _advanceOrSubmit();
    });
  }

  void _selectOption(int index) {
    if (_isAnswerLocked) return;
    setState(() => _selectedOptionIndex = index);
  }

  Future<void> _nextQuestion() async {
    if (_selectedOptionIndex == null || _isAnswerLocked) return;

    _timer?.cancel();
    setState(() => _isAnswerLocked = true);

    final question = _questions[_currentQuestionIndex];
    if (_selectedOptionIndex == question['correctAnswerIndex']) {
      _score++;
      _gameSettings?.playCorrectSound();
    } else {
      _gameSettings?.playIncorrectSound();
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _advanceOrSubmit();
  }

  Future<void> _advanceOrSubmit() async {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _startTimer();
    } else {
      await _submitAnswers();
    }
  }

  Future<void> _submitAnswers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // Play end-of-game sound: win if score > 50%, otherwise lose
    _gameSettings?.playGameEndSound(
      won: _questions.isNotEmpty && _score / _questions.length >= 0.5,
    );

    try {
      await GameService.submitScore('BIBLE_QUIZ', widget.difficulty, _score);
    } catch (e) {
      debugPrint('Failed to submit score: $e');
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => QuizFinishScreen(
              score: _score,
              totalQuestions: _questions.length,
              difficulty: widget.difficulty,
            ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _gameSettings?.stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _questions.isEmpty) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _questions.isEmpty) {
      return _ErrorScreen(
        message: _errorMessage ?? 'No questions found.',
        onBack: () => Navigator.pop(context),
      );
    }

    final question = _questions[_currentQuestionIndex];
    // parse options if it's a string
    List<dynamic> options = [];
    if (question['options'] is String) {
      options = json.decode(question['options']);
    } else {
      options = question['options'];
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top scores
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Top Score: $_topScore',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                  ),
                  Text(
                    'Last Score: $_lastScore',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // App bar
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showExitDialog(context),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      size: 25.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'Bible Quiz',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (context) => const GameSettingsSheet(),
                      );
                    },
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedSettings02,
                      size: 26,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Timer + Question count
              _QuestionHeader(
                currentQuestionIndex: _currentQuestionIndex,
                totalQuestions: _questions.length,
                secondsLeft: _secondsLeft,
                timerDuration: _timerDuration,
              ),

              const SizedBox(height: 14),

              // Dot progress
              _DotProgressBar(
                currentQuestionIndex: _currentQuestionIndex,
                totalQuestions: _questions.length,
              ),

              const SizedBox(height: 32),

              // Question card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.goldAccent,
                    width: 2,
                  ),
                  color: AppTheme.goldAccent.withAlpha(35),
                ),
                child: Text(
                  question['questionText'] ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Options
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: options.length,
                  separatorBuilder:
                      (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = _selectedOptionIndex == index;
                    final isTimedOut =
                        _isAnswerLocked &&
                        _secondsLeft == 0 &&
                        !isSelected;

                    bool isCorrectAnswer = false;
                    bool isWrongAnswer = false;

                    if (_isAnswerLocked) {
                      if (index == question['correctAnswerIndex']) {
                        isCorrectAnswer = true;
                      } else if (isSelected) {
                        isWrongAnswer = true;
                      }
                    }

                    Color borderColor = Colors.grey.shade300;
                    Color bgColor = Colors.white;
                    Color textColor = Colors.black87;

                    if (isCorrectAnswer) {
                      borderColor = Colors.green;
                      bgColor = Colors.green.withAlpha(40);
                    } else if (isWrongAnswer) {
                      borderColor = Colors.red;
                      bgColor = Colors.red.withAlpha(40);
                    } else if (isSelected) {
                      borderColor = AppTheme.primaryBlue;
                      bgColor = AppTheme.primaryBlue.withAlpha(200);
                      textColor = Colors.white;
                    } else if (isTimedOut) {
                      bgColor = Colors.grey.shade100;
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: GestureDetector(
                        onTap: () => _selectOption(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: (isSelected || isCorrectAnswer || isWrongAnswer) ? 2 : 1,
                              color: borderColor,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: bgColor,
                          ),
                          child: Row(
                            children: [
                              // Option letter badge
                              Container(
                                width: 30,
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      isSelected
                                          ? Colors.white.withAlpha(60)
                                          : AppTheme.primaryBlue
                                              .withAlpha(30),
                                ),
                                child: Text(
                                  String.fromCharCode(
                                    65 + index,
                                  ), // A, B, C, D
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : AppTheme.primaryBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option.toString(),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (isCorrectAnswer)
                                const Icon(Icons.check_circle, color: Colors.green),
                              if (isWrongAnswer)
                                const Icon(Icons.cancel, color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Next button
              ElevatedButton(
                onPressed:
                    (_selectedOptionIndex != null && !_isAnswerLocked)
                        ? () => _nextQuestion()
                        : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentQuestionIndex == _questions.length - 1
                      ? 'Submit'
                      : 'Next',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
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

// ── Supporting widgets ──────────────────────────────────────────────────────

class _QuestionHeader extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;
  final int secondsLeft;
  final int timerDuration;

  const _QuestionHeader({
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.secondsLeft,
    required this.timerDuration,
  });

  Color get _timerColor {
    if (secondsLeft > timerDuration / 2) return AppTheme.primaryBlue;
    if (secondsLeft > timerDuration / 4) return Colors.orange;
    return Colors.red;
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            Text(
              '${currentQuestionIndex + 1} / $totalQuestions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(
          width: 68,
          height: 68,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: secondsLeft / timerDuration,
                  strokeWidth: 5,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(_timerColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$secondsLeft',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _timerColor,
                    ),
                  ),
                  Text(
                    'sec',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DotProgressBar extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;

  const _DotProgressBar({
    required this.currentQuestionIndex,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    if (totalQuestions <= 15) {
      return Row(
        children: List.generate(totalQuestions, (i) {
          final isDone = i < currentQuestionIndex;
          final isCurrent = i == currentQuestionIndex;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: isCurrent ? 8 : 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color:
                    isDone
                        ? AppTheme.primaryBlue
                        : isCurrent
                        ? AppTheme.primaryBlue.withAlpha(180)
                        : Colors.grey.shade300,
              ),
            ),
          );
        }),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: (currentQuestionIndex + 1) / totalQuestions,
        minHeight: 6,
        backgroundColor: Colors.grey.shade300,
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onBack;

  const _ErrorScreen({required this.message, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onBack, child: const Text('Go Back')),
            ],
          ),
        ),
      ),
    );
  }
}
