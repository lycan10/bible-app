import 'package:flutter/material.dart';
import 'package:quest/theme/theme.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String badgeStat;
  final String levelStat;
  final double progress;

  const MetricCard({
    super.key,
    required this.title,
    required this.badgeStat,
    required this.levelStat,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double size = 80; // Avatar + ring size
    double strokeWidth = 5; // Ring thickness

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 1, color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular progress around avatar
          Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: strokeWidth,
                  color: Colors.grey.shade200,
                ),
              ),

              // Progress ring
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: strokeWidth,
                  color: Color(0xff00d4ff),
                  backgroundColor: Colors.transparent,
                ),
              ),
              Column(
                children: [
                  Text(
                    "Lvl",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor2,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    levelStat,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Collected $badgeStat Badges',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: AppTheme.textColor2,
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 45, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.buttonColor3.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'Play',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: AppTheme.buttonColor3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
