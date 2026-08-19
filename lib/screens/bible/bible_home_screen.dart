import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quest/main.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:quest/providers/bible_provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/services/bible_service.dart';
import 'package:quest/screens/bible/saved_verses_screen.dart';
import 'package:quest/screens/bible/highlights_screen.dart';
import 'package:quest/screens/bible/bible_settings_screen.dart';
import 'package:quest/screens/notes/new_note_screen.dart';
import 'bible_search_delegate.dart';

class BibleHomeScreen extends StatefulWidget {
  final int? initialScrollIndex;

  const BibleHomeScreen({super.key, this.initialScrollIndex});

  @override
  State<BibleHomeScreen> createState() => _BibleHomeScreenState();
}

class _BibleHomeScreenState extends State<BibleHomeScreen> with RouteAware {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  bool _hasInitialScrolled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        Provider.of<BibleProvider>(
          context,
          listen: false,
        ).syncData(authProvider.token!);
      }
    });

    _itemPositionsListener.itemPositions.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!_hasInitialScrolled) return;
    
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isNotEmpty) {
      int topIndex = positions
          .where((p) => p.itemTrailingEdge > 0)
          .map((p) => p.index)
          .reduce((a, b) => a < b ? a : b);

      final provider = Provider.of<BibleProvider>(context, listen: false);
      if (topIndex > 0 && topIndex <= provider.verses.length) {
        int verse = provider.verses[topIndex - 1]['Versecount'];
        provider.updateCurrentVerse(verse);
      }
    }
  }

  void _handleInitialScroll(BibleProvider provider) {
    if (_hasInitialScrolled) return;
    if (provider.isLoading || !provider.isDbReady) return;

    _hasInitialScrolled = true;
    int targetIndex = widget.initialScrollIndex ?? provider.currentVerse;

    // Ensure index is within bounds
    if (targetIndex < 0) targetIndex = 0;
    if (targetIndex > provider.verses.length)
      targetIndex = provider.verses.length;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_itemScrollController.isAttached) {
        _itemScrollController.scrollTo(
          index: targetIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _itemPositionsListener.itemPositions.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  void didPopNext() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.token != null) {
      Provider.of<BibleProvider>(
        context,
        listen: false,
      ).syncData(authProvider.token!);
    }
  }

  void _showBookChapterPicker(
    BuildContext context,
    BibleProvider bibleProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _BookChapterVersePicker(
          bibleProvider: bibleProvider,
          itemScrollController: _itemScrollController,
        );
      },
    );
  }

  void _showVerseActionSheet(
    BuildContext context,
    BibleProvider bibleProvider,
    String token,
    int verseCount,
    String verseText,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        bool isBookmarked = bibleProvider.isBookmarked(verseCount);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  BibleService.formatReference(
                    bibleProvider.currentBookIndex,
                    bibleProvider.currentChapter,
                    verseCount,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.spaceEvenly,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildActionIcon(
                      context: context,
                      icon:
                          isBookmarked
                              ? HugeIcons.strokeRoundedBookmark02
                              : HugeIcons.strokeRoundedBookmark01,
                      label: "Bookmark",
                      color: isBookmarked ? Colors.blue : null,
                      onTap: () async {
                        Navigator.pop(context);
                        bool success = await bibleProvider.toggleBookmark(
                          token,
                          verseCount,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? "Bookmark updated successfully"
                                    : "Failed to update bookmark",
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    _buildActionIcon(
                      context: context,
                      icon: HugeIcons.strokeRoundedPaintBrush01,
                      label: "Highlight",
                      onTap: () {
                        Navigator.pop(context);
                        _showHighlightColorPicker(
                          context,
                          bibleProvider,
                          token,
                          verseCount,
                        );
                      },
                    ),
                    _buildActionIcon(
                      context: context,
                      icon: HugeIcons.strokeRoundedNote01,
                      label: "Note",
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => NewNoteScreen(
                                  initialBibleReference:
                                      BibleService.formatReference(
                                        bibleProvider.currentBookIndex,
                                        bibleProvider.currentChapter,
                                        verseCount,
                                      ),
                                ),
                          ),
                        );
                      },
                    ),
                    _buildActionIcon(
                      context: context,
                      icon: HugeIcons.strokeRoundedCopy01,
                      label: "Copy",
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(
                            text:
                                "${BibleService.formatReference(bibleProvider.currentBookIndex, bibleProvider.currentChapter, verseCount)}\n$verseText",
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Verse copied to clipboard"),
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                    if (bibleProvider.showActionSheetCrossReferences)
                      _buildActionIcon(
                        context: context,
                        icon: HugeIcons.strokeRoundedLink01,
                        label: "References",
                        onTap: () {
                          Navigator.pop(context);
                          _showCrossReferencesSheet(
                            context,
                            bibleProvider.currentBookIndex,
                            bibleProvider.currentChapter,
                            verseCount,
                            bibleProvider.currentTranslation,
                          );
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHighlightColorPicker(
    BuildContext context,
    BibleProvider bibleProvider,
    String token,
    int verseCount,
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
                            bool success = await bibleProvider.addHighlight(
                              token,
                              verseCount,
                              c['value']!,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? "Highlight added"
                                        : "Failed to add highlight",
                                  ),
                                ),
                              );
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
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    bool success = await bibleProvider.removeHighlight(
                      token,
                      verseCount,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? "Highlight removed"
                                : "Failed to remove highlight",
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Remove Highlight",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCrossReferencesSheet(
    BuildContext context,
    int bookIndex,
    int chapter,
    int verse,
    String translationTable,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: () async {
                var refs = await BibleService.getCrossReferences(
                  bookIndex,
                  chapter,
                  verse,
                );
                List<int> vids = refs.map((r) => r['sv'] as int).toList();
                return await BibleService.getVersesByVids(
                  vids,
                  translationTable,
                );
              }(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No cross-references found."),
                  );
                }

                final crossRefs = snapshot.data!;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Cross-References for ${BibleService.formatReference(bookIndex, chapter, verse)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: crossRefs.length,
                        itemBuilder: (context, index) {
                          final ref = crossRefs[index];
                          return ListTile(
                            title: Text(
                              "${ref['bookName']} ${ref['chapter']}:${ref['Versecount']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(ref['verse']),
                            onTap: () {
                              Navigator.pop(context);
                              // Navigate to that verse if needed.
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildActionIcon({
    required BuildContext context,
    required dynamic icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final iconColor = color ?? Theme.of(context).iconTheme.color ?? Colors.grey;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: HugeIcon(icon: icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bibleProvider = Provider.of<BibleProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final theme = Theme.of(context);

    // Call handleInitialScroll to jump to the last read verse once ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialScroll(bibleProvider);
    });

    if (!bibleProvider.isDbReady) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Download Bible Data",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  "We need to download the offline database to continue. This is a one-time process.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (bibleProvider.downloadProgress > 0) ...[
                  LinearProgressIndicator(
                    value: bibleProvider.downloadProgress,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${(bibleProvider.downloadProgress * 100).toStringAsFixed(1)}%",
                  ),
                ] else ...[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 1,
                      ),
                    ),
                    onPressed: () {
                      if (authProvider.token != null) {
                        bibleProvider.startDownload(authProvider.token!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please login to download the Bible data",
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text("Start Download"),
                  ),
                ],
                if (bibleProvider.downloadError != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    "Error: ${bibleProvider.downloadError}",
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    String currentAbbrev = 'KJV';
    if (bibleProvider.availableTranslations.isNotEmpty) {
      final t = bibleProvider.availableTranslations.firstWhere(
        (t) => t['table'] == bibleProvider.currentTranslation,
        orElse: () => bibleProvider.availableTranslations.first,
      );
      currentAbbrev = t['abbreviation'] ?? 'KJV';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: InkWell(
          onTap: () => _showBookChapterPicker(context, bibleProvider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:
                  theme.brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  BibleService.bookNames.isNotEmpty &&
                          bibleProvider.currentBookIndex <
                              BibleService.bookNames.length
                      ? "${BibleService.bookNames[bibleProvider.currentBookIndex]} ${bibleProvider.currentChapter}"
                      : "...",
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowDown01,
                  color: theme.textTheme.bodyMedium?.color ?? Colors.black,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                currentAbbrev,
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            onSelected: (value) {
              bibleProvider.setTranslation(value);
            },
            itemBuilder: (BuildContext context) {
              return bibleProvider.availableTranslations.map((t) {
                return PopupMenuItem<String>(
                  value: t['table'],
                  child: Text("${t['version']} (${t['abbreviation']})"),
                );
              }).toList();
            },
          ),
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color: theme.textTheme.bodyMedium?.color ?? Colors.black,
              size: 24,
            ),
            onPressed: () async {
              var result = await showSearch<Map<String, dynamic>?>(
                context: context,
                delegate: BibleSearchDelegate(
                  translationTable: bibleProvider.currentTranslation,
                ),
              );
              if (result != null && context.mounted) {
                int book = result['Book'];
                int chapter = result['Chapter'];
                int verse = result['Versecount'];

                if (bibleProvider.currentBookIndex != book ||
                    bibleProvider.currentChapter != chapter) {
                  await bibleProvider.loadVerses(book, chapter);
                }

                Future.delayed(const Duration(milliseconds: 100), () {
                  if (_itemScrollController.isAttached) {
                    _itemScrollController.scrollTo(
                      index: verse,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                });
              }
            },
          ),
          PopupMenuButton<String>(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedMenu01,
              color: theme.textTheme.bodyMedium?.color ?? Colors.black,
              size: 24,
            ),
            onSelected: (value) {
              if (value == 'bookmarks') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SavedVersesScreen()),
                );
              } else if (value == 'highlights') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HighlightsScreen()),
                );
              } else if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BibleSettingsScreen(),
                  ),
                );
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'bookmarks',
                    child: Text('Bookmarks'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'highlights',
                    child: Text('Highlights'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: Text('Settings'),
                  ),
                ],
          ),
        ],
      ),
      body:
          bibleProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: ScrollablePositionedList.builder(
                      itemScrollController: _itemScrollController,
                      itemPositionsListener: _itemPositionsListener,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      itemCount:
                          bibleProvider.verses.length +
                          2, // +2 for header and footer spacing
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              BibleService.bookNames.isNotEmpty &&
                                      bibleProvider.currentBookIndex <
                                          BibleService.bookNames.length
                                  ? "${BibleService.bookNames[bibleProvider.currentBookIndex]} ${bibleProvider.currentChapter}"
                                  : "...",
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          );
                        }
                        if (index == bibleProvider.verses.length + 1) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    bibleProvider.previousChapter();
                                    _itemScrollController.jumpTo(index: 0);
                                  },
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text("Previous"),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    bibleProvider.nextChapter();
                                    _itemScrollController.jumpTo(index: 0);
                                  },
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text("Next"),
                                ),
                              ],
                            ),
                          );
                        }

                        final verseData = bibleProvider.verses[index - 1];
                        final verseCount = verseData['Versecount'] as int;
                        final text = verseData['verse'] as String;

                        final highlightColorHex = bibleProvider
                            .getHighlightColor(verseCount);
                        Color? highlightColor;
                        if (highlightColorHex != null) {
                          highlightColor = Color(
                            int.parse(
                              highlightColorHex.replaceFirst('#', '0xFF'),
                            ),
                          ).withValues(alpha: 0.3);
                        }

                        final isBookmarked = bibleProvider.isBookmarked(
                          verseCount,
                        );

                        return InkWell(
                          onLongPress: () {
                            if (authProvider.token != null) {
                              _showVerseActionSheet(
                                context,
                                bibleProvider,
                                authProvider.token!,
                                verseCount,
                                text,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Please sign in to use these features",
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: highlightColor ?? Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 30,
                                  child: Text(
                                    "$verseCount",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child:
                                      !bibleProvider.showInlineCrossReferences
                                          ? Text(
                                            text,
                                            style: TextStyle(
                                              fontSize: bibleProvider.fontSize,
                                              height: 1.5,
                                              color:
                                                  theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                            ),
                                          )
                                          : FutureBuilder<
                                            List<Map<String, dynamic>>
                                          >(
                                            future:
                                                BibleService.getCrossReferences(
                                                  bibleProvider
                                                      .currentBookIndex,
                                                  bibleProvider.currentChapter,
                                                  verseCount,
                                                ),
                                            builder: (context, snapshot) {
                                              bool hasRefs =
                                                  snapshot.hasData &&
                                                  snapshot.data!.isNotEmpty;
                                              return RichText(
                                                text: TextSpan(
                                                  text: text,
                                                  style: TextStyle(
                                                    fontSize:
                                                        bibleProvider.fontSize,
                                                    height: 1.5,
                                                    color:
                                                        theme
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.color,
                                                  ),
                                                  children: [
                                                    if (hasRefs)
                                                      WidgetSpan(
                                                        alignment:
                                                            PlaceholderAlignment
                                                                .middle,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                left: 6.0,
                                                              ),
                                                          child: InkWell(
                                                            onTap: () {
                                                              _showCrossReferencesSheet(
                                                                context,
                                                                bibleProvider
                                                                    .currentBookIndex,
                                                                bibleProvider
                                                                    .currentChapter,
                                                                verseCount,
                                                                bibleProvider
                                                                    .currentTranslation,
                                                              );
                                                            },
                                                            child: HugeIcon(
                                                              icon:
                                                                  HugeIcons
                                                                      .strokeRoundedLink01,
                                                              size:
                                                                  bibleProvider
                                                                      .fontSize *
                                                                  0.8,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                ),
                                if (isBookmarked)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: HugeIcon(
                                      icon: HugeIcons.strokeRoundedBookmark02,
                                      size: 16,
                                      color:
                                          theme.textTheme.bodyMedium?.color ??
                                          Colors.black,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (bibleProvider.enableStudyMode) ...[
                    const Divider(height: 1),
                    Expanded(
                      flex: 2,
                      child: _StudyModePanel(
                        bibleProvider: bibleProvider,
                        itemPositionsListener: _itemPositionsListener,
                      ),
                    ),
                  ],
                ],
              ),
    );
  }
}

class _StudyModePanel extends StatefulWidget {
  final BibleProvider bibleProvider;
  final ItemPositionsListener itemPositionsListener;

  const _StudyModePanel({
    required this.bibleProvider,
    required this.itemPositionsListener,
  });

  @override
  State<_StudyModePanel> createState() => _StudyModePanelState();
}

class _StudyModePanelState extends State<_StudyModePanel> {
  int _currentTopVerse = 1;

  @override
  void initState() {
    super.initState();
    widget.itemPositionsListener.itemPositions.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.itemPositionsListener.itemPositions.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final positions = widget.itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final topIndex = positions
        .where((p) => p.itemTrailingEdge > 0)
        .map((p) => p.index)
        .reduce((a, b) => a < b ? a : b);

    if (topIndex > 0 && topIndex <= widget.bibleProvider.verses.length) {
      int verse = widget.bibleProvider.verses[topIndex - 1]['Versecount'];
      if (verse != _currentTopVerse) {
        setState(() {
          _currentTopVerse = verse;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: () async {
        var refs = await BibleService.getCrossReferences(
          widget.bibleProvider.currentBookIndex,
          widget.bibleProvider.currentChapter,
          _currentTopVerse,
        );
        List<int> vids = refs.map((r) => r['sv'] as int).toList();
        return await BibleService.getVersesByVids(
          vids,
          widget.bibleProvider.currentTranslation,
        );
      }(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              "No cross-references for Verse $_currentTopVerse.",
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
          );
        }

        final crossRefs = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Text(
                "Cross-References: v. $_currentTopVerse",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: crossRefs.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final ref = crossRefs[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${ref['bookName']} ${ref['chapter']}:${ref['Versecount']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ref['verse'],
                        style: TextStyle(
                          fontSize: widget.bibleProvider.fontSize * 0.85,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BookChapterVersePicker extends StatefulWidget {
  final BibleProvider bibleProvider;
  final ItemScrollController itemScrollController;

  const _BookChapterVersePicker({
    required this.bibleProvider,
    required this.itemScrollController,
  });

  @override
  State<_BookChapterVersePicker> createState() =>
      _BookChapterVersePickerState();
}

class _BookChapterVersePickerState extends State<_BookChapterVersePicker>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedBookIndex = 0;
  int _selectedChapter = 1;
  int _chaptersCount = 0;
  int _versesCount = 0;
  bool _isLoadingVerses = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedBookIndex = widget.bibleProvider.currentBookIndex;
    _selectedChapter = widget.bibleProvider.currentChapter;
    _chaptersCount = widget.bibleProvider.chaptersCount;
  }

  Future<void> _loadChaptersCount() async {
    int count = await BibleService.getChaptersCount(
      _selectedBookIndex,
      widget.bibleProvider.currentTranslation,
    );
    if (mounted) {
      setState(() {
        _chaptersCount = count;
        _tabController.animateTo(1);
      });
    }
  }

  Future<void> _loadVersesCount() async {
    setState(() {
      _isLoadingVerses = true;
    });
    var verses = await BibleService.getVerses(
      _selectedBookIndex,
      _selectedChapter,
      widget.bibleProvider.currentTranslation,
    );
    if (mounted) {
      setState(() {
        _versesCount = verses.length;
        _isLoadingVerses = false;
        _tabController.animateTo(2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).textTheme.bodyMedium?.color,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).textTheme.bodyMedium?.color,
            tabs: const [
              Tab(text: "Books"),
              Tab(text: "Chapters"),
              Tab(text: "Verses"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Books Tab
                ListView.builder(
                  itemCount: BibleService.bookNames.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedBookIndex == index;
                    return ListTile(
                      title: Text(
                        BibleService.bookNames[index],
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color:
                              isSelected
                                  ? Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.color
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withValues(alpha: 0.6),
                        ),
                      ),
                      trailing:
                          isSelected
                              ? Icon(
                                Icons.check,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                              )
                              : null,
                      onTap: () {
                        setState(() {
                          _selectedBookIndex = index;
                          _selectedChapter = 1;
                        });
                        _loadChaptersCount();
                      },
                    );
                  },
                ),
                // Chapters Tab
                GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _chaptersCount,
                  itemBuilder: (context, index) {
                    int chapter = index + 1;
                    bool isSelected = _selectedChapter == chapter;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedChapter = chapter;
                        });
                        _loadVersesCount();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black)
                                  : Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "$chapter",
                          style: TextStyle(
                            color:
                                isSelected
                                    ? (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.black
                                        : Colors.white)
                                    : Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Verses Tab
                _isLoadingVerses
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemCount: _versesCount,
                      itemBuilder: (context, index) {
                        int verse = index + 1;
                        return InkWell(
                          onTap: () async {
                            if (widget.bibleProvider.currentBookIndex !=
                                    _selectedBookIndex ||
                                widget.bibleProvider.currentChapter !=
                                    _selectedChapter) {
                              await widget.bibleProvider.loadVerses(
                                _selectedBookIndex,
                                _selectedChapter,
                              );
                            }
                            Navigator.pop(context);
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                if (widget.itemScrollController.isAttached) {
                                  widget.itemScrollController.scrollTo(
                                    index: verse,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "$verse",
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
