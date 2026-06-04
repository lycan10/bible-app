import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';

class VideoReelScreen extends StatelessWidget {
  final String? title;
  final String? author;
  final String? likes;
  final String? backgroundImage;

  const VideoReelScreen({
    super.key,
    this.title,
    this.author,
    this.likes,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// Background Image / Video placeholder
          Image.asset(
            backgroundImage ?? 'assets/images/boy.png',
            fit: BoxFit.cover,
          ),

          /// Dark overlay
          Container(color: Colors.black.withValues(alpha: 0.4)),

          /// Center Play Button

          /// Top Controls
          Positioned(
            top: 10,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedMoreVertical,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Bottom Content
          Positioned(
            left: 15,
            right: 15,
            bottom: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Watch to the end to earn \n points',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 30),
                          Image.asset(
                            'assets/images/bronze.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70, width: 0.5),
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title ?? 'Battle of the Mind',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '0:45',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'From: ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(
                        text: author ?? 'Joyce Meyer',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.favorite_border,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          likes ?? '300k',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.buttonColor3,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedLinkForward,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                GradientProgressBar(
                  progress: 0.5,
                  gradient: const LinearGradient(
                    colors: [Colors.pink, Colors.purple],
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

class GradientProgressBar extends StatelessWidget {
  final double progress; // 0.0 → 1.0
  final double height;
  final Gradient gradient;
  final Color backgroundColor;
  final BorderRadius borderRadius;

  const GradientProgressBar({
    super.key,
    required this.progress,
    this.height = 10,
    required this.gradient,
    this.backgroundColor = const Color(0xFF2C2C2C),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: height,
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: borderRadius,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
