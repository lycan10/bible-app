import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/bible_provider.dart';

class BibleSettingsScreen extends StatelessWidget {
  const BibleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bibleProvider = Provider.of<BibleProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Bible Settings",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Font Size",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("A", style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Slider(
                      value: bibleProvider.fontSize,
                      min: 12.0,
                      max: 36.0,
                      divisions: 12,
                      label: bibleProvider.fontSize.round().toString(),
                      onChanged: (double value) {
                        bibleProvider.setFontSize(value);
                      },
                    ),
                  ),
                  const Text("A", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "In the beginning God created the heaven and the earth.\n\nAnd the earth was without form, and void; and darkness was upon the face of the deep. And the Spirit of God moved upon the face of the waters.",
                  style: TextStyle(
                    fontSize: bibleProvider.fontSize,
                    height: 1.5,
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
