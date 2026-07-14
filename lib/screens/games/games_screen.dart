import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/avatar.dart';
import 'package:quest/screens/bible_quiz/play_mode_sheet.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/services/api_service.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  List<dynamic> _badges = [];
  bool _isLoadingBadges = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token == null) return;
      final badges = await ApiService.fetchBadgesProgress(authProvider.token!);
      if (mounted) {
        setState(() {
          _badges = badges;
          _isLoadingBadges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingBadges = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section with gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFF9A9E),
                    theme.scaffoldBackgroundColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 1.0],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Cube',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Featured Game Graphic
                      SizedBox(
                        height: 200,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            // TRIVIA image behind the icon
                            Positioned(
                              top: -30,
                              child: Image.asset(
                                'assets/images/trivia.png',
                                width: 260,
                                fit: BoxFit.contain,
                              ),
                            ),
                            // Game icon centered in the stack
                            Positioned(
                              bottom: 10,
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFFF9A9E),
                                      Color(0xFFFECFEF),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.pink.withAlpha(50),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/images/bible_game.png',
                                    width: 70,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // New Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'New',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title & Subtitle
                      Text(
                        'Bible Quiz',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Play to test your knowledge!',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Continue Playing Button
                      ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => const PlayModeSheet(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.onSurface,
                          foregroundColor: theme.colorScheme.surface,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Continue Playing',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Carousel dots indicator fake
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 6,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),

            // Games Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Games',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _GameCard(
                          title: 'Bible Quiz',
                          subtitle: 'Play to test your\nknowledge!',
                          iconAsset: 'assets/images/bible_game.png',
                          iconGradient: const [
                            Color(0xFFFF9A9E),
                            Color(0xFFFECFEF),
                          ],
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => const PlayModeSheet(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _GameCard(
                          title: 'Puzzle Bee',
                          subtitle: 'Play to test your\nknowledge!',
                          iconAsset: 'assets/images/puzzle_game.png',
                          iconGradient: const [
                            Color(0xFF84FAB0),
                            Color(0xFF8FD3F4),
                          ],
                          onTap: () {
                            // Empty for now, match requirement to skip extra
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Badges Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Badges',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isLoadingBadges 
                    ? const Center(child: CircularProgressIndicator())
                    : _badges.isEmpty
                      ? Center(
                          child: Text(
                            "No badges available",
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _badges.take(5).map((bp) {
                              final badge = bp['badge'] ?? {};
                              final String title = badge['name'] ?? 'Badge';
                              final String asset = badge['imageUrl'] ?? 'assets/images/bronze.png';
                              final bool isEarned = bp['isEarned'] ?? false;
                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: _BadgeItem(
                                  title: title,
                                  status: isEarned ? 'Owned' : 'Locked',
                                  asset: asset,
                                  isEarned: isEarned,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                  const SizedBox(height: 32),

                  // Leaderboard Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Leaderboard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 70,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _LeaderboardAvatar(
                          'assets/images/user_test.jpg',
                          rank: 1,
                        ),
                        const SizedBox(width: 16),
                        _LeaderboardAvatar('assets/images/boy.png', rank: 1),
                        const SizedBox(width: 16),
                        _LeaderboardAvatar(
                          'assets/images/user_test.jpg',
                          rank: 1,
                        ),
                        const SizedBox(width: 16),
                        _LeaderboardAvatar('assets/images/boy.png', rank: 1),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(80),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.black, size: 20),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconAsset;
  final List<Color> iconGradient;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.iconGradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: iconGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(child: Image.asset(iconAsset, width: 24)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Play',
                style: TextStyle(
                  color: theme.colorScheme.surface,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String title;
  final String status;
  final String asset;
  final bool isEarned;

  const _BadgeItem({
    required this.title,
    required this.status,
    required this.asset,
    this.isEarned = true,
  });

  ImageProvider _getBadgeImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    }
    if (imagePath.contains('first_word')) {
      return const AssetImage('assets/images/bronze.png');
    }
    if (imagePath.contains('quiz_master')) {
      return const AssetImage('assets/images/silver.png');
    }
    if (imagePath.contains('streak_builder')) {
      return const AssetImage('assets/images/gold.png');
    }
    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    if (cleanPath.startsWith('assets/')) return AssetImage(cleanPath);
    return AssetImage('assets/images/$cleanPath');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ColorFiltered(
          colorFilter: isEarned 
            ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply) 
            : const ColorFilter.matrix([
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0,      0,      0,      1, 0,
              ]),
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _getBadgeImage(asset),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          status,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _LeaderboardAvatar extends StatelessWidget {
  final String asset;
  final int rank;

  const _LeaderboardAvatar(this.asset, {required this.rank});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomAvatar(radius: 35, imageUrl: asset),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
