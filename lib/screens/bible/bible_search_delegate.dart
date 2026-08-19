import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/services/bible_service.dart';
import 'package:quest/theme/theme.dart';

class BibleSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final String translationTable;

  BibleSearchDelegate({required this.translationTable});

  @override
  String get searchFieldLabel => "Search the Bible...";

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppTheme.primaryBlue),
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onSurface,
          fontSize: 18,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppTheme.primaryBlue,
        selectionColor: AppTheme.primaryBlue.withOpacity(0.3),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(
            Icons.close_rounded, // or HugeIcons.strokeRoundedCancel01
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 24,
          ),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedArrowLeft01,
        color: AppTheme.primaryBlue,
        size: 24,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return _buildMessageState(
        context,
        icon: HugeIcons.strokeRoundedSearch01,
        title: "Start Typing",
        message: "Enter a keyword to search the scriptures.",
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: BibleService.searchVerses(query, translationTable),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.primaryBlue),
          );
        } else if (snapshot.hasError) {
          return _buildMessageState(
            context,
            icon: HugeIcons.strokeRoundedAlert01,
            title: "Oops!",
            message: "An error occurred: ${snapshot.error}",
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildMessageState(
            context,
            icon: HugeIcons.strokeRoundedBookOpen01,
            title: "No Results",
            message: "We couldn't find any verses matching '${query.trim()}'.",
          );
        }

        var results = snapshot.data!;
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: results.length,
          itemBuilder: (context, index) {
            var result = results[index];
            // Subtract 1 because the DB 'b' column is 1-indexed (1=Genesis)
            int bookIndex = (result['Book'] as int) - 1;
            int chapter = result['Chapter'];
            int verse = result['Versecount'];
            String text = result['verse'];
            String reference = BibleService.formatReference(
              bookIndex,
              chapter,
              verse,
            );

            return _buildResultCard(
              context: context,
              reference: reference,
              text: text,
              onTap: () {
                // Return the 0-indexed book back to the caller
                close(context, {
                  'Book': bookIndex,
                  'Chapter': chapter,
                  'Versecount': verse,
                });
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildMessageState(
      context,
      icon: HugeIcons.strokeRoundedSearch01,
      title: "Search the Bible",
      message: "Look for keywords or phrases (e.g., 'Jesus wept').",
    );
  }

  // --- UI Helper Methods ---

  Widget _buildResultCard({
    required BuildContext context,
    required String reference,
    required String text,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 16,
                      color: AppTheme.primaryBlue.withOpacity(0.8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      reference,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(
                        0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: theme.colorScheme.onSurface.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageState(
    BuildContext context, {
    required dynamic icon,
    required String title,
    required String message,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: icon,
                color: AppTheme.primaryBlue,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
