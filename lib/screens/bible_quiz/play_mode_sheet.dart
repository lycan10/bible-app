import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:quest/components/avatar.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/screens/bible_quiz/bible_quiz_screen.dart';
import 'package:quest/services/game_service.dart';

class PlayModeSheet extends StatefulWidget {
  const PlayModeSheet({super.key});

  @override
  State<PlayModeSheet> createState() => _PlayModeSheetState();
}

class _PlayModeSheetState extends State<PlayModeSheet> {
  int _currentLevel = 1;
  int _maxLevel = 302;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProgress();
    });
  }

  Future<void> _loadProgress() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final maxLvl = await GameService.fetchBibleQuizMaxLevel();
    if (!mounted) return;
    setState(() {
      _currentLevel = authProvider.user?['bibleQuizLevel'] ?? 1;
      _maxLevel = maxLvl;
    });
  }

  void _startGame(BuildContext context, int level) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BibleQuizScreen(level: level)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 28),
                  ),
                  const Text(
                    'Play Mode',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 28), // balance
                ],
              ),
              const SizedBox(height: 32),

              // Game Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/bible_game.png',
                            width: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Bible Quiz',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Level',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '$_currentLevel',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: '/$_maxLevel',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Buttons
              if (_currentLevel > 1) ...[
                ElevatedButton(
                  onPressed: () => _startGame(context, _currentLevel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.black,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Continue Playing',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: () => _startGame(context, 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'New Game',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 32),

              // Play with friends section
              /*Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Play with Friends',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _FriendAvatar(
                    name: 'Noarah',
                    location: 'City',
                    imageAsset: 'assets/images/user_test.jpg',
                  ),
                  _FriendAvatar(
                    name: 'Elysia',
                    location: 'Town',
                    imageAsset: 'assets/images/boy.png',
                  ),
                  _FriendAvatar(
                    name: 'Kairo',
                    location: 'Village',
                    imageAsset: 'assets/images/user_test.jpg',
                  ),
                  _FriendAvatar(
                    name: 'Zyra',
                    location: 'District',
                    imageAsset: 'assets/images/boy.png',
                  ),
                ],
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  final String name;
  final String location;
  final String imageAsset;

  const _FriendAvatar({
    required this.name,
    required this.location,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAvatar(radius: 30, imageUrl: imageAsset),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          location,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
