import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quest/main.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:quest/providers/bible_provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/services/bible_service.dart';
import 'package:quest/screens/bible/saved_verses_screen.dart';
import 'package:quest/screens/bible/highlights_screen.dart';
import 'package:quest/screens/bible/bible_settings_screen.dart';
import 'bible_search_delegate.dart';

class BibleHomeScreen extends StatefulWidget {
  final int? initialScrollIndex;

  const BibleHomeScreen({super.key, this.initialScrollIndex});

  @override
  State<BibleHomeScreen> createState() => _BibleHomeScreenState();
}

class _BibleHomeScreenState extends State<BibleHomeScreen> with RouteAware {
  final ItemScrollController _itemScrollController = ItemScrollController();

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
      if (widget.initialScrollIndex != null) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_itemScrollController.isAttached) {
            _itemScrollController.scrollTo(
              index: widget.initialScrollIndex!,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        // TODO: Implement Notes
                        Navigator.pop(context);
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: InkWell(
          onTap: () => _showBookChapterPicker(context, bibleProvider),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${BibleService.bookNames[bibleProvider.currentBookIndex]} ${bibleProvider.currentChapter}",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowDown01,
                  color:
                      Theme.of(context).textTheme.bodyMedium?.color ??
                      Colors.black,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
              size: 24,
            ),
            onPressed: () async {
              var result = await showSearch<Map<String, dynamic>?>(
                context: context,
                delegate: BibleSearchDelegate(),
              );
              if (result != null && context.mounted) {
                int book = result['Book'];
                int chapter = result['Chapter'];
                int verse = result['Versecount'];

                if (bibleProvider.currentBookIndex != book ||
                    bibleProvider.currentChapter != chapter) {
                  await bibleProvider.loadVerses(book, chapter);
                }

                // Header is index 0, verse 1 is index 1, so verse index is `verse`
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
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
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
              : ScrollablePositionedList.builder(
                itemScrollController: _itemScrollController,
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
                        "${BibleService.bookNames[bibleProvider.currentBookIndex]} ${bibleProvider.currentChapter}",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
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

                  final highlightColorHex = bibleProvider.getHighlightColor(
                    verseCount,
                  );
                  Color? highlightColor;
                  if (highlightColorHex != null) {
                    highlightColor = Color(
                      int.parse(highlightColorHex.replaceFirst('#', '0xFF')),
                    ).withValues(alpha: 0.3);
                  }

                  final isBookmarked = bibleProvider.isBookmarked(verseCount);

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
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: bibleProvider.fontSize,
                                height: 1.5,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                          if (isBookmarked)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedBookmark02,
                                size: 16,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color ??
                                    Colors.black,
                              ),
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
    int count = await BibleService.getChaptersCount(_selectedBookIndex);
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
                            fontWeight: FontWeight.bold,
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
                            Navigator.pop(context);
                            if (widget.bibleProvider.currentBookIndex !=
                                    _selectedBookIndex ||
                                widget.bibleProvider.currentChapter !=
                                    _selectedChapter) {
                              await widget.bibleProvider.loadVerses(
                                _selectedBookIndex,
                                _selectedChapter,
                              );
                            }
                            // Jump to verse, header is index 0, verse 1 is index 1
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
                                fontWeight: FontWeight.bold,
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
