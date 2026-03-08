import 'package:flutter/material.dart';

class WordMatchFinishScreen extends StatelessWidget {
  final int score;
  final int total;

  const WordMatchFinishScreen({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Well Done!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text('You matched $score out of $total'),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Topics'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
