import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/bible_provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/screens/bible/bible_home_screen.dart';
import 'package:quest/services/bible_service.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/main.dart';

class HighlightsScreen extends StatefulWidget {
  const HighlightsScreen({super.key});

  @override
  State<HighlightsScreen> createState() => _HighlightsScreenState();
}

class _HighlightsScreenState extends State<HighlightsScreen> with RouteAware {
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    _loadData();
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bibleProvider = Provider.of<BibleProvider>(context, listen: false);
    if (authProvider.token != null) {
      bibleProvider.syncData(authProvider.token!);
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final bibleProvider = Provider.of<BibleProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (bibleProvider.hasMoreHighlights &&
          !bibleProvider.isLoadingMoreHighlights &&
          authProvider.token != null) {
        bibleProvider.loadMoreHighlights(authProvider.token!);
      }
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    super.dispose();
  }

  void _showHighlightColorPicker(
    BuildContext context,
    BibleProvider bibleProvider,
    String token,
    String verseRef,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colors = [
          {'name': 'Yellow', 'value': '#FFFF00'},
          {'name': 'Green', 'value': '#00FF00'},
          {'name': 'Blue', 'value': '#0000FF'},
          {'name': 'Pink', 'value': '#FFC0CB'},
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Choose Highlight Color",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:
                      colors.map((c) {
                        Color bgColor = Color(
                          int.parse(c['value']!.replaceFirst('#', '0xFF')),
                        );
                        return InkWell(
                          onTap: () async {
                            Navigator.pop(context);
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
                              bool success = await bibleProvider.addHighlight(
                                token,
                                parsed['verse']!,
                                c['value']!,
                              );
                              await bibleProvider.loadVerses(
                                oldBook,
                                oldChapter,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? "Highlight updated"
                                          : "Failed to update highlight",
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: bgColor.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                              border: Border.all(color: bgColor, width: 2),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
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
          "Highlights",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body:
          bibleProvider.highlights.isEmpty
              ? const Center(
                child: Text(
                  "No highlighted verses yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
              : ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount:
                    bibleProvider.highlights.length +
                    (bibleProvider.isLoadingMoreHighlights ? 1 : 0),
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  if (index == bibleProvider.highlights.length) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final h = bibleProvider.highlights[index];
                  final verseRef = h['verseRef'] ?? '';
                  final colorHex = h['color'] ?? '#FFFF00';
                  final highlightColor = Color(
                    int.parse(colorHex.replaceFirst('#', '0xFF')),
                  ).withValues(alpha: 0.3);

                  return InkWell(
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
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: highlightColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  verseRef,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Highlighted verse",
                                  style: TextStyle(
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedPaintBrush01,
                              color: Colors.black,
                              size: 20,
                            ),
                            onPressed: () {
                              if (authProvider.token != null) {
                                _showHighlightColorPicker(
                                  context,
                                  bibleProvider,
                                  authProvider.token!,
                                  verseRef,
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              if (authProvider.token != null) {
                                final parsed = BibleService.parseReference(
                                  verseRef,
                                );
                                if (parsed != null) {
                                  final oldBook =
                                      bibleProvider.currentBookIndex;
                                  final oldChapter =
                                      bibleProvider.currentChapter;
                                  await bibleProvider.loadVerses(
                                    parsed['book']!,
                                    parsed['chapter']!,
                                  );
                                  await bibleProvider.removeHighlight(
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
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
