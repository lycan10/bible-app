import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/services/game_service.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/game_settings_provider.dart';
import 'package:quest/screens/games/game_settings_sheet.dart';
import '../../theme/theme.dart';

class WordCrossScreen extends StatefulWidget {
  final String difficulty;

  const WordCrossScreen({super.key, required this.difficulty});

  @override
  State<WordCrossScreen> createState() => _WordCrossScreenState();
}

class _WordCrossScreenState extends State<WordCrossScreen>
    with SingleTickerProviderStateMixin {
  int gridSize = 10;
  int get totalCells => gridSize * gridSize;

  String _hint = 'Find the biblical words';
  bool _isLoading = true;

  List<String> letters = [];
  List<String> words = [];
  Map<String, String> wordClues = {};

  final List<int> selectedIndexes = [];
  final Set<int> lockedIndexes = {};
  final Set<String> foundWords = {};

  bool _isWrongFlash = false;
  late final AnimationController _flashController;
  late final Animation<double> _flashAnim;

  bool isDragging = false;
  List<GlobalKey> _keys = [];

  int timeRemaining = 60;
  Timer? _timer;

  int topScore = 0;
  int lastScore = 0;
  int score = 0;

  GameSettingsProvider? _gameSettings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gameSettings ??= Provider.of<GameSettingsProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flashAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 1),
    ]).animate(_flashController);

    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameSettings?.playBackgroundMusic('audio/word_cross.aac');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flashController.dispose();
    _gameSettings?.stopBackgroundMusic();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final res = await GameService.fetchWordCrossQuestions(widget.difficulty);
      final List<dynamic> questionsData = res['questions'];

      final scores = await GameService.fetchScores('WORD_CROSS');

      if (!mounted) return;

      setState(() {
        timeRemaining = res['durationSecs'] ?? 60;
        topScore = scores['topScore'] ?? 0;
        lastScore = scores['lastScore'] ?? 0;

        int maxWordLength = 0;
        for (var q in questionsData) {
          final w = q['word'].toString().toUpperCase();
          if (w.length > maxWordLength) maxWordLength = w.length;
          words.add(w);
          wordClues[w] = q['clue'].toString();
        }

        // Dynamically calculate grid size
        gridSize = max(10, maxWordLength + 1);
        // Add more space if there are many words
        if (words.length > 6) {
          gridSize = max(gridSize, 12);
        }
        // Cap the grid size to avoid too small tiles
        gridSize = min(14, gridSize);

        _keys = List.generate(totalCells, (_) => GlobalKey());

        letters = _generateGrid(words, gridSize);

        if (wordClues.isNotEmpty && words.isNotEmpty) {
          _hint = wordClues[words.first] ?? 'Find the biblical words';
        } else {
          _hint = 'No words loaded';
        }

        _isLoading = false;
      });

      _startTimer();
    } catch (e) {
      debugPrint('Error loading puzzle: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load puzzle.')));
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
        _submitScoreAndShowCompletion();
      }
    });
  }

  List<String> _generateGrid(List<String> wordList, int size) {
    final random = Random();
    List<List<String>> grid = List.generate(
      size,
      (_) => List.filled(size, ' '),
    );

    bool placeWord(String word) {
      final directions = [
        [0, 1], // horizontal
        [1, 0], // vertical
        [1, 1], // diagonal
      ];
      directions.shuffle(random);

      for (int attempts = 0; attempts < 100; attempts++) {
        final d = directions.first;
        final row = random.nextInt(size);
        final col = random.nextInt(size);

        if (row + d[0] * word.length <= size &&
            col + d[1] * word.length <= size) {
          bool fits = true;
          for (int i = 0; i < word.length; i++) {
            final r = row + d[0] * i;
            final c = col + d[1] * i;
            if (grid[r][c] != ' ' && grid[r][c] != word[i]) {
              fits = false;
              break;
            }
          }
          if (fits) {
            for (int i = 0; i < word.length; i++) {
              grid[row + d[0] * i][col + d[1] * i] = word[i];
            }
            return true;
          }
        }
      }
      return false;
    }

    List<String> placedWords = [];
    for (var word in wordList) {
      if (placeWord(word)) {
        placedWords.add(word);
      }
    }

    // Update state to only include words that actually fit in the grid
    words = placedWords;
    wordClues.removeWhere((k, v) => !placedWords.contains(k));

    const pool = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    List<String> flatGrid = [];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c] == ' ') {
          flatGrid.add(pool[random.nextInt(pool.length)]);
        } else {
          flatGrid.add(grid[r][c]);
        }
      }
    }
    return flatGrid;
  }

  void _checkSelection(Offset globalPosition) {
    for (int i = 0; i < letters.length; i++) {
      final renderBox =
          _keys[i].currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) continue;

      final rect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
      if (rect.contains(globalPosition)) {
        if (!selectedIndexes.contains(i)) {
          setState(() => selectedIndexes.add(i));
        }
        break;
      }
    }
  }

  Future<void> _checkSelectedWord() async {
    final snapshot = List<int>.from(selectedIndexes);

    if (!mounted) return;
    setState(() => selectedIndexes.clear());

    if (snapshot.isEmpty) return;

    final selectedWord = snapshot.map((i) => letters[i]).join();
    final reversedWord = selectedWord.split('').reversed.join();

    final match = words.firstWhere(
      (w) => w == selectedWord || w == reversedWord,
      orElse: () => '',
    );

    if (match.isNotEmpty && !foundWords.contains(match)) {
      _gameSettings?.playCorrectSound();
      setState(() {
        foundWords.add(match);
        lockedIndexes.addAll(snapshot);
        score += 10;

        // update hint to next unfound word
        final unfound = words.where((w) => !foundWords.contains(w)).toList();
        if (unfound.isNotEmpty) {
          _hint = wordClues[unfound.first] ?? 'Find the biblical words';
        } else {
          _hint = 'All words found!';
        }
      });

      if (foundWords.length == words.length) {
        _timer?.cancel();
        await Future.delayed(const Duration(milliseconds: 400));
        _submitScoreAndShowCompletion();
      }
    } else {
      _gameSettings?.playIncorrectSound();
      setState(() => _isWrongFlash = true);
      _flashController.forward(from: 0).then((_) {
        if (mounted) setState(() => _isWrongFlash = false);
      });
    }
  }

  Future<void> _submitScoreAndShowCompletion() async {
    // Play end-of-game sound: win if all words found, otherwise lose
    _gameSettings?.playGameEndSound(won: foundWords.length == words.length);

    try {
      await GameService.submitScore('WORD_CROSS', widget.difficulty, score);
    } catch (e) {
      debugPrint('Error saving score: $e');
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('🎉 Time\'s Up!', textAlign: TextAlign.center),
            content: Text(
              'You found ${foundWords.length} out of ${words.length} words.\nScore: $score',
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.goldAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Done'),
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 10),
                      _buildTopScoreBanner(),
                      const SizedBox(height: 10),
                      _buildHintCard(),
                      const SizedBox(height: 16),
                      Expanded(child: _buildGrid()),
                      const SizedBox(height: 16),
                      _buildWordList(),
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
          'Score: $score',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.goldAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => _confirmExit(),
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            size: 26,
            color: Colors.black,
          ),
        ),
        Column(
          children: [
            Text(
              'Word Cross',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              '${timeRemaining}s left',
              style: TextStyle(
                color: timeRemaining < 10 ? Colors.red : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.goldAccent.withAlpha(30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${foundWords.length}/${words.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.goldAccent,
                  fontSize: 13,
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

  Widget _buildHintCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryBlue.withAlpha(40)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 18,
            color: AppTheme.goldAccent,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _hint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedBuilder(
          animation: _flashAnim,
          builder: (_, child) {
            return Stack(
              children: [
                child!,
                if (_isWrongFlash)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.red.withValues(
                            alpha: _flashAnim.value * 0.12,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          child: Listener(
            onPointerDown: (event) {
              setState(() {
                isDragging = true;
                selectedIndexes.clear();
                _isWrongFlash = false;
              });
              _checkSelection(event.position);
            },
            onPointerMove: (event) {
              if (isDragging) _checkSelection(event.position);
            },
            onPointerUp: (_) {
              setState(() => isDragging = false);
              _checkSelectedWord();
            },
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: letters.length,
              itemBuilder: (context, index) {
                return LetterTile(
                  key: _keys[index],
                  letter: letters[index],
                  isSelected: selectedIndexes.contains(index),
                  isLocked: lockedIndexes.contains(index),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWordList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text(
                'WORDS TO FIND',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${foundWords.length} of ${words.length} found',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              words
                  .map(
                    (word) => WordChip(
                      text: word,
                      isFound: foundWords.contains(word),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

class LetterTile extends StatelessWidget {
  final String letter;
  final bool isSelected;
  final bool isLocked;

  const LetterTile({
    super.key,
    required this.letter,
    this.isSelected = false,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;

    if (isLocked) {
      bgColor = Colors.green.withAlpha(55);
      borderColor = Colors.green.shade400;
    } else if (isSelected) {
      bgColor = AppTheme.primaryBlue.withAlpha(80);
      borderColor = AppTheme.primaryBlue;
    } else {
      bgColor = Theme.of(context).colorScheme.surface;
      borderColor = Theme.of(context).dividerColor;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow:
            isSelected
                ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withAlpha(50),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color:
                  isLocked
                      ? Colors.green.shade800
                      : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class WordChip extends StatelessWidget {
  final String text;
  final bool isFound;

  const WordChip({super.key, required this.text, this.isFound = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color:
            isFound
                ? Colors.green.withAlpha(40)
                : Theme.of(context).colorScheme.surface,
        border: Border.all(
          color:
              isFound ? Colors.green.shade400 : Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isFound) ...[
            Icon(Icons.check_circle, size: 13, color: Colors.green.shade600),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color:
                  isFound
                      ? Colors.green.shade800
                      : Theme.of(context).colorScheme.onSurface,
              decoration: isFound ? TextDecoration.lineThrough : null,
              decorationColor: Colors.green.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
