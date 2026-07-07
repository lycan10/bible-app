import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/theme.dart';
import 'bible_quiz_screen.dart';

class QuizFinishScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int level;

  const QuizFinishScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.level,
  });

  double get _percentage =>
      totalQuestions > 0 ? (score / totalQuestions).clamp(0.0, 1.0) : 0.0;

  String get _performanceLabel {
    if (_percentage >= 0.9) return 'Excellent!';
    if (_percentage >= 0.7) return 'Well Done!';
    if (_percentage >= 0.5) return 'Good Effort!';
    return 'Keep Practising!';
  }

  String get _performanceMessage {
    if (_percentage >= 0.9) {
      return 'Outstanding! You really know your Bible.';
    } else if (_percentage >= 0.7) {
      return 'Great work! A little more study and you\'ll ace it.';
    } else if (_percentage >= 0.5) {
      return 'You\'re on the right track. Keep reading and growing!';
    }
    return 'Don\'t give up — every quiz is a chance to learn more.';
  }

  Color get _scoreColor {
    if (_percentage >= 0.7) return Colors.green.shade600;
    if (_percentage >= 0.5) return Colors.orange.shade700;
    return Colors.red.shade500;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final String userName =
        user?['firstName'] ?? user?['username'] ?? 'Champion';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Title ─────────────────────────────────────────────
              Text(
                'Quiz Complete!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Hi $userName 👋',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 36),

              // ── Circular score ring ───────────────────────────────
              _ScoreRing(
                percentage: _percentage,
                score: score,
                totalQuestions: totalQuestions,
                scoreColor: _scoreColor,
              ),

              const SizedBox(height: 28),

              // ── Performance label ─────────────────────────────────
              Text(
                _performanceLabel,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.goldAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _performanceMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // ── Stats row ─────────────────────────────────────────
              Row(
                children: [
                  _StatCard(
                    label: 'Score',
                    value: '$score / $totalQuestions',
                    icon: Icons.check_circle_outline_rounded,
                    color: _scoreColor,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Level',
                    value: '$level',
                    icon: Icons.emoji_events_rounded,
                    color: AppTheme.goldAccent,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Restart button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => BibleQuizScreen(level: level),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'Restart Quiz',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Exit button ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context)
                      ..pop()
                      ..pop();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: const Text(
                    'Back to Levels',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────

class _ScoreRing extends StatelessWidget {
  final double percentage;
  final int score;
  final int totalQuestions;
  final Color scoreColor;

  const _ScoreRing({
    required this.percentage,
    required this.score,
    required this.totalQuestions,
    required this.scoreColor,
  });

  @override
  Widget build(BuildContext context) {
    final int percentInt = (percentage * 100).round();

    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(160, 160),
            painter: _RingPainter(
              progress: percentage,
              progressColor: scoreColor,
              trackColor: Colors.grey.shade200,
              strokeWidth: 12,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentInt%',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
              Text(
                '$score / $totalQuestions',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // start at top
      2 * math.pi * progress,
      false,
      Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.progressColor != progressColor;
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
