import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../theme/theme.dart';

class WordCrossScreen extends StatefulWidget {
  const WordCrossScreen({super.key});

  @override
  State<WordCrossScreen> createState() => _WordCrossScreenState();
}

class _WordCrossScreenState extends State<WordCrossScreen> {
  static const int gridSize = 8;

  final List<String> letters = [
    'M','O','S','E','S','A','B','C',
    'D','A','V','I','D','E','F','G',
    'P','A','U','L','H','I','J','K',
    'N','O','A','H','L','M','N','O',
    'Q','R','S','T','U','V','W','X',
    'Y','Z','A','B','C','D','E','F',
    'G','H','I','J','K','L','M','N',
    'O','P','Q','R','S','T','U','V',
  ];

  final List<String> words = [
    'MOSES',
    'DAVID',
    'PAUL',
    'NOAH',
    'AARON',
  ];

  final Set<int> selectedIndexes = {};
  final Set<int> lockedIndexes = {};
  final Set<String> foundWords = {};

  bool isDragging = false;

  void _checkSelectedWord() {
    final selectedWord = selectedIndexes
        .map((i) => letters[i])
        .join();

    final reversedWord =
    selectedWord.split('').reversed.join();

    final match = words.firstWhere(
          (w) =>
      w == selectedWord || w == reversedWord,
      orElse: () => '',
    );

    if (match.isNotEmpty && !foundWords.contains(match)) {
      setState(() {
        foundWords.add(match);
        lockedIndexes.addAll(selectedIndexes);
      });
    }

    setState(() {
      selectedIndexes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// 🔹 Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      size: 26,
                    ),
                  ),
                  Text(
                    'Word Cross',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 26),
                ],
              ),

              const SizedBox(height: 20),

              /// 🔹 Level
              Text(
                'Level 1',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              /// 🔹 Timer (placeholder)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryBlue),
                ),
                child: const Text(
                  '01 : 00',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 Word Grid
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridSize,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: letters.length,
                      itemBuilder: (context, index) {
                        final isSelected =
                        selectedIndexes.contains(index);
                        final isLocked =
                        lockedIndexes.contains(index);

                        return GestureDetector(
                          onPanStart: (_) {
                            setState(() {
                              selectedIndexes.clear();
                              isDragging = true;
                              selectedIndexes.add(index);
                            });
                          },
                          onPanUpdate: (_) {
                            if (!isDragging) return;
                            setState(() {
                              selectedIndexes.add(index);
                            });
                          },
                          onPanEnd: (_) {
                            isDragging = false;
                            _checkSelectedWord();
                          },
                          child: LetterTile(
                            letter: letters[index],
                            isSelected: isSelected,
                            isLocked: isLocked,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// 🔹 Found Words
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: const Text(
                  'FIND THE WORDS',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(
                height: 160,
                child: GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.8,
                  physics: const NeverScrollableScrollPhysics(),
                  children: words.map((word) {
                    return WordChip(
                      text: word,
                      isFound: foundWords.contains(word),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🔹 Letter Tile Widget
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
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isLocked
            ? Colors.green.withAlpha(70)
            : isSelected
            ? AppTheme.primaryBlue.withAlpha(80)
            : AppTheme.primaryBlue.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isLocked
              ? Colors.green
              : AppTheme.primaryBlue,
          width: 1.5,
        ),
      ),
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// 🔹 Word Chip Widget
class WordChip extends StatelessWidget {
  final String text;
  final bool isFound;

  const WordChip({
    super.key,
    required this.text,
    this.isFound = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isFound
            ? Colors.green.withAlpha(40)
            : Colors.grey.shade100,
        border: Border.all(
          color: isFound ? Colors.green : Colors.grey.shade300,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isFound ? Colors.green.shade800 : Colors.black,
        ),
      ),
    );
  }
}
