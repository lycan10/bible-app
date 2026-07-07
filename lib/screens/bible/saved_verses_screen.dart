import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/bible_provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/components/more/saved_card.dart';
import 'package:quest/screens/bible/bible_home_screen.dart';
import 'package:quest/services/bible_service.dart';

import 'package:quest/utils/date_formatter.dart';

class SavedVersesScreen extends StatefulWidget {
  const SavedVersesScreen({super.key});

  @override
  State<SavedVersesScreen> createState() => _SavedVersesScreenState();
}

class _SavedVersesScreenState extends State<SavedVersesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final bibleProvider = Provider.of<BibleProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (bibleProvider.hasMoreBookmarks &&
          !bibleProvider.isLoadingMoreBookmarks &&
          authProvider.token != null) {
        bibleProvider.loadMoreBookmarks(authProvider.token!);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bibleProvider = Provider.of<BibleProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Saved Verses",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body:
          bibleProvider.bookmarks.isEmpty
              ? const Center(
                child: Text(
                  "No saved verses yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
              : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount:
                    bibleProvider.bookmarks.length +
                    (bibleProvider.isLoadingMoreBookmarks ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == bibleProvider.bookmarks.length) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final b = bibleProvider.bookmarks[index];
                  final verseRef = b['verseRef'] ?? '';
                  final createdAt = b['createdAt'];

                  return Dismissible(
                    key: Key(b['id']?.toString() ?? verseRef),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) async {
                      if (authProvider.token != null) {
                        final parsed = BibleService.parseReference(verseRef);
                        if (parsed != null) {
                          final oldBook = bibleProvider.currentBookIndex;
                          final oldChapter = bibleProvider.currentChapter;
                          await bibleProvider.loadVerses(
                            parsed['book']!,
                            parsed['chapter']!,
                          );
                          await bibleProvider.toggleBookmark(
                            authProvider.token!,
                            parsed['verse']!,
                          );
                          await bibleProvider.loadVerses(oldBook, oldChapter);
                        }
                      }
                    },
                    child: InkWell(
                      onTap: () async {
                        final parsed = BibleService.parseReference(verseRef);
                        if (parsed != null) {
                          await bibleProvider.loadVerses(
                            parsed['book']!,
                            parsed['chapter']!,
                          );
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => BibleHomeScreen(
                                      initialScrollIndex: parsed['verse'],
                                    ),
                              ),
                            );
                          }
                        }
                      },
                      child: SavedCard(
                        title: verseRef,
                        subtitle: "Bookmarked verse",
                        verse: verseRef,
                        time: DateFormatter.formatTimeAgo(createdAt),
                        onDelete: () async {
                          if (authProvider.token != null) {
                            final parsed = BibleService.parseReference(
                              verseRef,
                            );
                            if (parsed != null) {
                              final oldBook = bibleProvider.currentBookIndex;
                              final oldChapter = bibleProvider.currentChapter;
                              await bibleProvider.loadVerses(
                                parsed['book']!,
                                parsed['chapter']!,
                              );
                              await bibleProvider.toggleBookmark(
                                authProvider.token!,
                                parsed['verse']!,
                              );
                              await bibleProvider.loadVerses(
                                oldBook,
                                oldChapter,
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
