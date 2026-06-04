import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/feed_provider.dart';
import 'package:quest/theme/theme.dart';

class FeelingSelector {
  static void show(
    BuildContext context, {
    required Function(String feeling, String emoji) onSelected,
  }) {
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    feedProvider.loadFeelingsMetadata();

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Consumer<FeedProvider>(
          builder: (context, provider, child) {
            if (provider.feelingsMetadata.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How are you feeling?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.2,
                        ),
                    itemCount: provider.feelingsMetadata.length,
                    itemBuilder: (context, index) {
                      final item = provider.feelingsMetadata[index];
                      final feeling = item['feeling'] as String;
                      final emoji = item['emoji'] as String;

                      return GestureDetector(
                        onTap: () {
                          onSelected(feeling, emoji);
                          Navigator.pop(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withAlpha(20),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: AppTheme.primaryBlue.withAlpha(50),
                            ),
                          ),
                          child: Text(
                            '$emoji $feeling',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
