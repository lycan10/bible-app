import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/feed_provider.dart';
import '../providers/auth_provider.dart';

String _formatCount(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}m';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
  return count.toString();
}

class TodayVerseGlass extends StatefulWidget {
  final Map<String, dynamic>? verseData;

  const TodayVerseGlass({super.key, this.verseData});

  @override
  State<TodayVerseGlass> createState() => _TodayVerseGlassState();
}

class _TodayVerseGlassState extends State<TodayVerseGlass>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 270;

    final String? text = widget.verseData?['text'];
    final String? reference = widget.verseData?['reference'];
    final String likesCount = _formatCount(
      widget.verseData?['likesCount'] ?? 0,
    );
    final String sharesCount = _formatCount(
      widget.verseData?['sharesCount'] ?? 0,
    );
    final String commentsCount = _formatCount(
      widget.verseData?['commentsCount'] ?? 0,
    );
    final bool hasLiked = widget.verseData?['hasLiked'] ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    FullScreenVerseScreen(verseData: widget.verseData),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              /// 🔹 Background Image
              Positioned.fill(
                child: Image.asset(
                  "assets/images/nature.jpg",
                  fit: BoxFit.cover,
                ),
              ),

              /// 🔹 Liquid Gradient Blur
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Stack(
                    children: [
                      _buildBlurLayer(
                        top: 0,
                        bottom: 0,
                        sigmaX: 15,
                        sigmaY: 15,
                        tintAlpha: 0.13,
                      ),
                    ],
                  ),
                ),
              ),

              /// 🔹 Content
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Share and earn a badge',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                        Image.asset(
                          "assets/images/bronze.png",
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                    Text(
                      'Today\'s verse',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      text ??
                          "Every good and perfect gift comes from above, from the Father of Lights.",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      reference != null ? '- $reference' : '- JAMES 1:17 KJV',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    const Spacer(),
                    Row(
                      children: [
                        _buildStatButton(
                          Icons.favorite,
                          likesCount,
                          isActive: hasLiked,
                          onTap: () async {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            final feedProvider = Provider.of<FeedProvider>(
                              context,
                              listen: false,
                            );
                            if (authProvider.token != null) {
                              await feedProvider.toggleDailyVerseLike(
                                authProvider.token!,
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 15),
                        _buildStatButton(
                          Icons.reply,
                          sharesCount,
                          isMirrored: true,
                          onTap: () async {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            final feedProvider = Provider.of<FeedProvider>(
                              context,
                              listen: false,
                            );
                            if (authProvider.token != null) {
                              await feedProvider.shareDailyVerse(
                                authProvider.token!,
                              );
                            }
                          },
                        ),
                        /*const SizedBox(width: 15),
                        _buildStatButton(
                          Icons.chat_bubble_rounded,
                          commentsCount,
                        ),*/
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            final feedProvider = Provider.of<FeedProvider>(
                              context,
                              listen: false,
                            );
                            if (authProvider.token != null) {
                              await feedProvider.shareDailyVerse(
                                authProvider.token!,
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blueAccent,
                            ),
                            child: const Icon(
                              Icons.reply,
                              textDirection: TextDirection.rtl,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildStatButton(
    IconData icon,
    String count, {
    bool isMirrored = false,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isActive
                        ? Colors.redAccent
                        : Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
              color:
                  isActive
                      ? Colors.redAccent.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.1),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.redAccent : Colors.white,
              size: 16,
              textDirection: isMirrored ? TextDirection.rtl : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            count,
            style: TextStyle(
              color: isActive ? Colors.redAccent : Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurLayer({
    required double top,
    required double bottom,
    required double sigmaX,
    required double sigmaY,
    required double tintAlpha,
    BorderRadius? borderRadius,
  }) {
    return Positioned(
      top: top,
      left: 0,
      right: 0,
      bottom: bottom,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: tintAlpha),
              border:
                  borderRadius != null
                      ? Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 1,
                      )
                      : null,
            ),
          ),
        ),
      ),
    );
  }
}

class FullScreenVerseScreen extends StatelessWidget {
  final Map<String, dynamic>? verseData;

  const FullScreenVerseScreen({super.key, this.verseData});

  @override
  Widget build(BuildContext context) {
    final String? text = verseData?['text'];
    final String? reference = verseData?['reference'];

    // Fallback counts if null
    final String likesCount = _formatCount(verseData?['likesCount'] ?? 0);
    final String sharesCount = _formatCount(verseData?['sharesCount'] ?? 0);
    final String commentsCount = _formatCount(verseData?['commentsCount'] ?? 0);
    final bool hasLiked = verseData?['hasLiked'] ?? false;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              "assets/images/dailyverspop.jpeg",
              fit: BoxFit.cover,
            ),
          ),

          // Darken overlay for the background instead of blur
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.1), // Darken effect
            ),
          ),

          // Full screen content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.3),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Text(
                    'Today\'s verse',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 15),

                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              text ??
                                  "Every good and perfect gift comes from above, from the Father of Lights.",
                              style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              reference != null
                                  ? '- $reference'
                                  : '- JAMES 1:17 KJV',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Share and earn a badge',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            Image.asset(
                              "assets/images/bronze.png",
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Consumer<FeedProvider>(
                    builder: (context, feedProvider, child) {
                      final updatedVerseData =
                          feedProvider.dailyVerse ?? verseData;
                      final likesCount = _formatCount(
                        updatedVerseData?['likesCount'] ?? 0,
                      );
                      final sharesCount = _formatCount(
                        updatedVerseData?['sharesCount'] ?? 0,
                      );
                      final hasLiked = updatedVerseData?['hasLiked'] ?? false;

                      return Row(
                        children: [
                          _buildStatButton(
                            Icons.favorite,
                            likesCount,
                            isActive: hasLiked,
                            onTap: () async {
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              if (authProvider.token != null) {
                                await feedProvider.toggleDailyVerseLike(
                                  authProvider.token!,
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 15),
                          _buildStatButton(
                            Icons.reply,
                            sharesCount,
                            isMirrored: true,
                            onTap: () async {
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              if (authProvider.token != null) {
                                await feedProvider.shareDailyVerse(
                                  authProvider.token!,
                                );
                              }
                            },
                          ),
                          const Spacer(),
                          _buildStatButton(
                            Icons.favorite,
                            null,
                            isActive: hasLiked,
                            onTap: () async {
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              if (authProvider.token != null) {
                                await feedProvider.toggleDailyVerseLike(
                                  authProvider.token!,
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              if (authProvider.token != null) {
                                await feedProvider.shareDailyVerse(
                                  authProvider.token!,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueAccent,
                              ),
                              child: const Icon(
                                Icons.reply,
                                textDirection: TextDirection.rtl,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatButton(
    IconData icon,
    String? count, {
    bool isMirrored = false,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isActive
                      ? Colors.redAccent.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.3),
              border: Border.all(
                color:
                    isActive
                        ? Colors.redAccent
                        : Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.redAccent : Colors.white,
              size: 20,
              textDirection: isMirrored ? TextDirection.rtl : null,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Text(
              count,
              style: TextStyle(
                color: isActive ? Colors.redAccent : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
