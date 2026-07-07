import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quest/screens/word_match/word_match_finish_screen.dart';
import 'package:quest/services/game_service.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/game_settings_provider.dart';
import 'package:quest/screens/games/game_settings_sheet.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../theme/theme.dart';

class WordMatchGameScreen extends StatefulWidget {
  final String difficulty;

  const WordMatchGameScreen({super.key, required this.difficulty});

  @override
  State<WordMatchGameScreen> createState() => _WordMatchGameScreenState();
}

class _WordMatchGameScreenState extends State<WordMatchGameScreen>
    with TickerProviderStateMixin {
  int score = 0;
  bool isLoading = true;

  String? selectedLeft;
  String? selectedRight;
  bool _showError = false;

  Map<String, String> matchData = {};
  List<String> leftItems = [];
  List<String> rightItems = [];

  final Set<String> matchedLeft = {};
  final Set<String> matchedRight = {};

  final Map<String, AnimationController> _shakeControllers = {};
  final Map<String, Animation<double>> _shakeAnimations = {};
  final Map<String, AnimationController> _scaleControllers = {};
  final Map<String, Animation<double>> _scaleAnimations = {};

  bool _isChecking = false;

  int timeRemaining = 60;
  Timer? _timer;

  int topScore = 0;
  int lastScore = 0;

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
      _gameSettings?.playBackgroundMusic('audio/word_match.aac');
    });
  }

  Future<void> _loadData() async {
    try {
      final res = await GameService.fetchWordMatchQuestions(widget.difficulty);
      final List<dynamic> questions = res['questions'];

      final scores = await GameService.fetchScores('WORD_MATCH');

      if (mounted) {
        setState(() {
          timeRemaining = res['durationSecs'] ?? 60;
          topScore = scores['topScore'] ?? 0;
          lastScore = scores['lastScore'] ?? 0;

          for (var q in questions) {
            matchData[q['word']] = q['match'];
          }

          leftItems = matchData.keys.toList()..shuffle();
          rightItems = matchData.values.toList()..shuffle();

          for (final key in [...leftItems, ...rightItems]) {
            final shakeCtrl = AnimationController(
              vsync: this,
              duration: const Duration(milliseconds: 400),
            );
            _shakeControllers[key] = shakeCtrl;
            _shakeAnimations[key] = TweenSequence<double>([
              TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
              TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
              TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
              TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
              TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
            ]).animate(
              CurvedAnimation(parent: shakeCtrl, curve: Curves.easeInOut),
            );

            final scaleCtrl = AnimationController(
              vsync: this,
              duration: const Duration(milliseconds: 300),
            );
            _scaleControllers[key] = scaleCtrl;
            _scaleAnimations[key] = TweenSequence<double>([
              TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.12), weight: 1),
              TweenSequenceItem(tween: Tween(begin: 1.12, end: 1.0), weight: 1),
            ]).animate(
              CurvedAnimation(parent: scaleCtrl, curve: Curves.easeOut),
            );
          }

          isLoading = false;
        });

        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load questions.')));
        Navigator.pop(context);
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
      } else {
        timer.cancel();
        _finishGame();
      }
    });
  }

  void _onLeftTap(String value) {
    if (_isChecking || matchedLeft.contains(value)) return;
    setState(() {
      selectedLeft = value;
      _showError = false;
    });
    _tryCheckMatch();
  }

  void _onRightTap(String value) {
    if (_isChecking || matchedRight.contains(value)) return;
    setState(() {
      selectedRight = value;
      _showError = false;
    });
    _tryCheckMatch();
  }

  void _tryCheckMatch() {
    final left = selectedLeft;
    final right = selectedRight;
    if (left == null || right == null) return;

    _isChecking = true;
    final isCorrect = matchData[left] == right;

    if (isCorrect) {
      _gameSettings?.playCorrectSound();
      _scaleControllers[left]?.forward(from: 0);
      _scaleControllers[right]?.forward(from: 0);

      setState(() {
        matchedLeft.add(left);
        matchedRight.add(right);
        score++;
        selectedLeft = null;
        selectedRight = null;
        _isChecking = false;
      });

      if (matchedLeft.length == matchData.length) {
        _timer?.cancel();
        Timer(const Duration(milliseconds: 400), _finishGame);
      }
    } else {
      _gameSettings?.playIncorrectSound();
      setState(() => _showError = true);
      _shakeControllers[left]?.forward(from: 0);
      _shakeControllers[right]?.forward(from: 0);

      Timer(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          selectedLeft = null;
          selectedRight = null;
          _showError = false;
          _isChecking = false;
        });
      });
    }
  }

  Future<void> _finishGame() async {
    if (!mounted) return;

    // Play end-of-game sound: win if all pairs matched, otherwise time ran out
    _gameSettings?.playGameEndSound(
      won: matchedLeft.length == matchData.length,
    );

    // Submit score
    try {
      await GameService.submitScore('WORD_MATCH', widget.difficulty, score);
    } catch (e) {
      debugPrint('Could not submit score: $e');
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (_) => WordMatchFinishScreen(
              score: score,
              total: matchData.length,
              difficulty: widget.difficulty,
            ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _shakeControllers.values) {
      c.dispose();
    }
    for (final c in _scaleControllers.values) {
      c.dispose();
    }
    _gameSettings?.stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildTopScoreBanner(),
              const SizedBox(height: 16),
              _buildProgressBar(),
              const SizedBox(height: 30),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColumn(
                      items: leftItems,
                      selected: selectedLeft,
                      matched: matchedLeft,
                      onTap: _onLeftTap,
                    ),
                    const SizedBox(width: 12),
                    _buildColumn(
                      items: rightItems,
                      selected: selectedRight,
                      matched: matchedRight,
                      onTap: _onRightTap,
                      isRight: true,
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

  Widget _buildTopScoreBanner() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Top Score: $topScore',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
        ),
        Text(
          'Last Score: $lastScore',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _confirmExit(),
          child: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Word Match', style: Theme.of(context).textTheme.titleLarge),
            Text(
              '${timeRemaining}s left',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: timeRemaining < 10 ? Colors.red : Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.goldAccent.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$score / ${matchData.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.goldAccent,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
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
      ],
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: matchData.isEmpty ? 0 : matchedLeft.length / matchData.length,
        backgroundColor: Colors.grey.shade200,
        color: AppTheme.goldAccent,
        minHeight: 7,
      ),
    );
  }

  Future<void> _confirmExit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Quit game?'),
            content: const Text('Your progress will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep playing'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Quit'),
              ),
            ],
          ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildColumn({
    required List<String> items,
    required String? selected,
    required Set<String> matched,
    required Function(String) onTap,
    bool isRight = false,
  }) {
    return Expanded(
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final value = items[index];
          final isSelected = value == selected;
          final isMatched = matched.contains(value);
          final isError = isSelected && _showError;

          Color bgColor = Theme.of(context).colorScheme.surface;
          Color borderColor = Theme.of(context).dividerColor;

          if (isMatched) {
            bgColor = Colors.green.withAlpha(25);
            borderColor = Colors.green.shade400;
          } else if (isError) {
            bgColor = Colors.red.withAlpha(20);
            borderColor = Colors.red.shade400;
          } else if (isSelected) {
            bgColor = AppTheme.goldAccent.withAlpha(35);
            borderColor = AppTheme.goldAccent;
          }

          Widget card = AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
              boxShadow:
                  isSelected && !isMatched
                      ? [
                        BoxShadow(
                          color: (isError ? Colors.red : AppTheme.goldAccent)
                              .withAlpha(60),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                      : null,
            ),
            child: Row(
              mainAxisAlignment:
                  isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (isMatched)
                  Padding(
                    padding: EdgeInsets.only(
                      left: isRight ? 0 : 0,
                      right: isRight ? 6 : 0,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.green.shade500,
                    ),
                  ),
                Flexible(
                  child: Text(
                    value,
                    textAlign: isRight ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected || isMatched
                              ? FontWeight.w600
                              : FontWeight.normal,
                      color: isMatched ? Colors.green.shade700 : null,
                    ),
                  ),
                ),
                if (isMatched && !isRight)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
          );

          if (_scaleAnimations[value] != null) {
            card = AnimatedBuilder(
              animation: _scaleAnimations[value]!,
              builder:
                  (_, child) => Transform.scale(
                    scale: _scaleAnimations[value]!.value,
                    child: child,
                  ),
              child: card,
            );
          }

          if (_shakeAnimations[value] != null) {
            card = AnimatedBuilder(
              animation: _shakeAnimations[value]!,
              builder:
                  (_, child) => Transform.translate(
                    offset: Offset(_shakeAnimations[value]!.value, 0),
                    child: child,
                  ),
              child: card,
            );
          }

          return GestureDetector(
            onTap: isMatched ? null : () => onTap(value),
            child: card,
          );
        },
      ),
    );
  }
}
