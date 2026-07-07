import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:quest/components/media/video/video_card.dart';
import 'package:quest/screens/media/video_reel_screen.dart';

class SponsoredVideo extends StatelessWidget {
  const SponsoredVideo({super.key});

  void _navigateToVideo(BuildContext context) {
    final sponsored = {
      'id': 'sponsored-1',
      'title': 'Battle of the Mind',
      'author': 'Joyce Meyer',
      'likes': 300000,
      'imageUrl': 'assets/images/boy.png',
      // A public HLS stream so it actually plays
      'mediaUrl': 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
    };
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                VideoReelScreen(videos: [sponsored], initialIndex: 0),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.scaled,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          /// IMAGE + SPONSORED BADGE
          SizedBox(
            height: 500,
            child: Stack(
              children: [
                Positioned.fill(
                  child: VideoCard(
                    title: 'Battle of the Mind',
                    author: 'Joyce Meyer',
                    likes: '300k',
                    backgroundImage: 'assets/images/boy.png',
                    onTap: () {
                      _navigateToVideo(context);
                    },
                    height: 400,
                    width: double.infinity,
                  ),
                ),

                /// Sponsored badge
                Positioned(
                  top: 15,
                  left: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Sponsored",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
