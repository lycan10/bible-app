import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quest/screens/word_match/word_match_finish_screen.dart';
import 'package:quest/screens/word_match/word_match_mode.dart';
import '../../theme/theme.dart';


class WordMatchGameScreen extends StatefulWidget {
  final WordMatchMode mode;

  const WordMatchGameScreen({super.key, required this.mode});

  @override
  State<WordMatchGameScreen> createState() => _WordMatchGameScreenState();
}

class _WordMatchGameScreenState extends State<WordMatchGameScreen> {
  int score = 0;

  String? selectedLeft;
  String? selectedRight;

  late Map<String, String> matchData;
  late List<String> leftItems;
  late List<String> rightItems;

  final Set<String> matchedLeft = {};
  final Set<String> matchedRight = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    matchData = _getDataForMode(widget.mode);

    leftItems = matchData.keys.toList()..shuffle();
    rightItems = matchData.values.toList()..shuffle();
  }

  Map<String, String> _getDataForMode(WordMatchMode mode) {
    switch (mode) {
      case WordMatchMode.wordMeaning:
        return {
          'Faith': 'Trust in God',
          'Grace': 'Undeserved favor',
          'Salvation': 'Deliverance from sin',
          'Covenant': 'Sacred agreement',
        };

      case WordMatchMode.character:
        return {
          'Moses': 'Led Israel out of Egypt',
          'David': 'Defeated Goliath',
          'Paul': 'Apostle to the Gentiles',
          'Noah': 'Built the Ark',
        };

      case WordMatchMode.place:
        return {
          'Bethlehem': 'Birth of Jesus',
          'Mount Sinai': 'Ten Commandments',
          'Jericho': 'Fell after trumpet blast',
          'Jerusalem': 'Crucifixion of Jesus',
        };
    }
  }

  void _onLeftTap(String value) {
    if (matchedLeft.contains(value)) return;

    setState(() {
      selectedLeft = value;
    });

    _checkMatch();
  }

  void _onRightTap(String value) {
    if (matchedRight.contains(value)) return;

    setState(() {
      selectedRight = value;
    });

    _checkMatch();
  }

  void _checkMatch() {
    if (selectedLeft != null && selectedRight != null) {
      final isCorrect = matchData[selectedLeft] == selectedRight;

      if (isCorrect) {
        setState(() {
          matchedLeft.add(selectedLeft!);
          matchedRight.add(selectedRight!);
          score++;
        });
      }

      Timer(const Duration(milliseconds: 600), () {
        setState(() {
          selectedLeft = null;
          selectedRight = null;
        });

        if (matchedLeft.length == matchData.length) {
          _finishGame();
        }
      });
    }
  }

  void _finishGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WordMatchFinishScreen(
          score: score,
          total: matchData.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Word Match',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Text('$score / ${matchData.length}'),
                ],
              ),

              const SizedBox(height: 20),

              LinearProgressIndicator(
                value: matchedLeft.length / matchData.length,
                backgroundColor: Colors.grey.shade300,
                color: AppTheme.goldAccent,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: Row(
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

          Color bgColor = Colors.white;
          Color borderColor = Colors.grey.shade300;

          if (isMatched) {
            bgColor = Colors.green.withAlpha(30);
            borderColor = Colors.green;
          } else if (isSelected) {
            bgColor = AppTheme.goldAccent.withAlpha(40);
            borderColor = AppTheme.goldAccent;
          }

          return GestureDetector(
            onTap: () => onTap(value),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Text(
                value,
                textAlign: isRight ? TextAlign.right : TextAlign.left,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          );
        },
      ),
    );
  }
}
