import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:quest/screens/community/admin_message_screen.dart';
import 'package:quest/screens/books/book_screen.dart';
import 'package:quest/screens/more/saved_messages_screen.dart';
import 'package:quest/screens/more/saved_books_screen.dart';
import 'package:quest/components/action_pill/action_pill_button_2.dart';
import 'package:quest/components/feature_guard.dart';
import 'package:quest/components/more/journal_card.dart';
import 'package:quest/components/more/notes_card.dart';
import 'package:quest/components/more/saved_books_card.dart';
import 'package:quest/components/daily_feeling_popup.dart';
import 'package:quest/components/more/saved_card.dart';
import 'package:quest/components/more/saved_messages_card.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/section_header.dart';
import 'package:quest/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/bible_provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/screens/notes/new_note_screen.dart';
import 'package:quest/screens/journals/new_journal_screen.dart';
import 'package:quest/services/bible_service.dart';
import 'package:quest/screens/bible/bible_home_screen.dart';
import 'package:quest/utils/date_formatter.dart';
import 'package:quest/screens/bible/saved_verses_screen.dart' as quest_saved;
import 'package:quest/main.dart';
import '../../components/global_more_menu.dart';

class MoreScreen extends StatefulWidget {
  final String initialTab;
  const MoreScreen({super.key, this.initialTab = "Notes"});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> with RouteAware {
  late String selectedTab;
  bool _isLoading = false;
  List<dynamic> _notesList = [];
  List<dynamic> _journalsList = [];
  List<dynamic> _savedBooksList = [];
  List<dynamic> _savedMessagesList = [];
  String _searchQuery = "";

  int _notesPage = 1;
  bool _hasMoreNotes = true;
  bool _isLoadingMoreNotes = false;

  int _journalsPage = 1;
  bool _hasMoreJournals = true;
  bool _isLoadingMoreJournals = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _fetchData();
  }

  @override
  void initState() {
    super.initState();
    selectedTab = widget.initialTab;
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (selectedTab == "Notes" && !_isLoadingMoreNotes && _hasMoreNotes) {
        _loadMoreNotes();
      } else if (selectedTab == "Journal" &&
          !_isLoadingMoreJournals &&
          _hasMoreJournals) {
        _loadMoreJournals();
      }
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _notesPage = 1;
      _journalsPage = 1;
      _hasMoreNotes = true;
      _hasMoreJournals = true;
    });
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        final notes = await ApiService.getPersonalNotes(token, page: 1);
        final journals = await ApiService.getJournals(token, page: 1);
        List<dynamic> savedBooks = [];
        List<dynamic> savedMessages = [];
        try {
          final booksResp = await ApiService.fetchSavedBooks(token);
          final msgsResp = await ApiService.fetchSavedMessages(token);
          savedBooks = List<dynamic>.from(booksResp['data'] ?? []);
          savedMessages = List<dynamic>.from(msgsResp['data'] ?? []);
        } catch (_) {}

        if (mounted) {
          setState(() {
            _notesList = notes;
            _journalsList = journals;
            _savedBooksList = savedBooks;
            _savedMessagesList = savedMessages;
            if (notes.length < 20) _hasMoreNotes = false;
            if (journals.length < 20) _hasMoreJournals = false;
          });
        }
      }
    } catch (e) {
      // print("Error fetching notes: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMoreNotes() async {
    if (!mounted) return;
    setState(() => _isLoadingMoreNotes = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        final newNotes = await ApiService.getPersonalNotes(
          token,
          page: _notesPage + 1,
        );
        if (mounted) {
          setState(() {
            _notesPage++;
            _notesList.addAll(newNotes);
            if (newNotes.length < 20) _hasMoreNotes = false;
          });
        }
      }
    } catch (e) {
      // handle error
    } finally {
      if (mounted) setState(() => _isLoadingMoreNotes = false);
    }
  }

  Future<void> _loadMoreJournals() async {
    if (!mounted) return;
    setState(() => _isLoadingMoreJournals = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        final newJournals = await ApiService.getJournals(
          token,
          page: _journalsPage + 1,
        );
        if (mounted) {
          setState(() {
            _journalsPage++;
            _journalsList.addAll(newJournals);
            if (newJournals.length < 20) _hasMoreJournals = false;
          });
        }
      }
    } catch (e) {
      // handle error
    } finally {
      if (mounted) setState(() => _isLoadingMoreJournals = false);
    }
  }

  void _showAddModal() {
    if (selectedTab == "Journal") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NewJournalScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NewNoteScreen()),
      );
    }
  }

  void _showFeelingSelector() {
    DailyFeelingPopup.show(
      context,
      onSelected: (feeling, emoji) {
        // Navigate to NewJournalScreen with the selected feeling if needed.
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NewJournalScreen()),
        );
      },
    );
  }

  void _showVerseBottomSheet(String reference) async {
    final text = await BibleService.getVerseText(reference);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reference,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                text ?? "Verse not found.",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B4BFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // close sheet
                    final parsed = BibleService.parseReference(reference);
                    if (parsed != null) {
                      final bibleProvider = Provider.of<BibleProvider>(
                        context,
                        listen: false,
                      );
                      bibleProvider.loadVerses(
                        parsed['book']!,
                        parsed['chapter']!,
                      );
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BibleHomeScreen(),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Open in Bible",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bibleProvider = Provider.of<BibleProvider>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton:
          (selectedTab == "Notes" || selectedTab == "Journal")
              ? Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: FloatingActionButton(
                  onPressed: _showAddModal,
                  backgroundColor: const Color(0xFF4B4BFF),
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              )
              : null,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _fetchData,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedSearch01,
                              size: 18,
                              color: AppTheme.textColor2,
                            ),

                            const SizedBox(width: 8),

                            // Expanded around TextField so it stretches
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value.toLowerCase();
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: "Search notes, journal, saved...",
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintStyle: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// Tabs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            FeatureGuard(
                              featureKey: 'notes',
                              child: ActionPillButton2(
                                icon: HugeIcons.strokeRoundedGlobe02,
                                iconColor:
                                    selectedTab == "Notes"
                                        ? Colors.white
                                        : Colors.black,
                                label: "Notes",
                                backgroundColor:
                                    selectedTab == "Notes"
                                        ? Colors.black
                                        : Colors.transparent,
                                textColor:
                                    selectedTab == "Notes"
                                        ? Colors.white
                                        : AppTheme.textColor2,
                                onTap:
                                    () => setState(() => selectedTab = "Notes"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            FeatureGuard(
                              featureKey: 'journal',
                              child: ActionPillButton2(
                                icon: HugeIcons.strokeRoundedUserGroup,
                                iconColor:
                                    selectedTab == "Journal"
                                        ? Colors.white
                                        : Colors.black,
                                label: "Journal",
                                backgroundColor:
                                    selectedTab == "Journal"
                                        ? Colors.black
                                        : Colors.transparent,
                                textColor:
                                    selectedTab == "Journal"
                                        ? Colors.white
                                        : AppTheme.textColor2,
                                onTap:
                                    () =>
                                        setState(() => selectedTab = "Journal"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ActionPillButton2(
                              icon: HugeIcons.strokeRoundedMessage02,
                              iconColor:
                                  selectedTab == "Saved"
                                      ? Colors.white
                                      : Colors.black,
                              label: "Saved",
                              backgroundColor:
                                  selectedTab == "Saved"
                                      ? Colors.black
                                      : Colors.transparent,
                              textColor:
                                  selectedTab == "Saved"
                                      ? Colors.white
                                      : AppTheme.textColor2,
                              onTap:
                                  () => setState(() => selectedTab = "Saved"),
                            ),
                          ],
                        ),
                      ),

                      if (selectedTab == "Notes")
                        FeatureGuard(
                          featureKey: 'notes',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 7),
                              const SectionTitle(title: "Recent"),
                              if (_isLoading && _notesList.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              if (!_isLoading && _notesList.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    "No notes yet.",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ..._notesList
                                  .where((n) {
                                    final title =
                                        (n['title'] ?? '')
                                            .toString()
                                            .toLowerCase();
                                    final body =
                                        (n['bodyText'] ?? '')
                                            .toString()
                                            .toLowerCase();
                                    return title.contains(_searchQuery) ||
                                        body.contains(_searchQuery);
                                  })
                                  .map((n) {
                                    final formattedTime =
                                        DateFormatter.formatTimeAgo(
                                          n['createdAt'],
                                        );
                                    return NotesCard(
                                      id: n['id'] ?? '',
                                      title: n['title'] ?? 'Untitled',
                                      subtitle: n['bodyText'] ?? '',
                                      time: formattedTime,
                                      isFavorite: n['isFavorite'] ?? false,
                                      verses:
                                          n['verses'] != null
                                              ? List<String>.from(n['verses'])
                                              : [],
                                      onVerseTap: _showVerseBottomSheet,
                                      onFavoriteTap: () async {
                                        final token =
                                            Provider.of<AuthProvider>(
                                              context,
                                              listen: false,
                                            ).token;
                                        if (token != null && n['id'] != null) {
                                          await ApiService.togglePersonalNoteFavorite(
                                            token,
                                            n['id'],
                                          );
                                          _fetchData();
                                        }
                                      },
                                      onEditCompleted: _fetchData,
                                    );
                                  }),
                              if (_isLoadingMoreNotes)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              const SizedBox(height: 60), // padding for FAB
                            ],
                          ),
                        ),

                      if (selectedTab == "Journal")
                        FeatureGuard(
                          featureKey: 'journal',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 7),
                              const SectionTitle(title: "Recent Journals"),
                              if (_isLoading && _journalsList.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              if (!_isLoading && _journalsList.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    "No journals yet.",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ..._journalsList
                                  .where((j) {
                                    final title =
                                        (j['title'] ?? '')
                                            .toString()
                                            .toLowerCase();
                                    final body =
                                        (j['bodyText'] ?? '')
                                            .toString()
                                            .toLowerCase();
                                    return title.contains(_searchQuery) ||
                                        body.contains(_searchQuery);
                                  })
                                  .map((j) {
                                    final formattedTime =
                                        DateFormatter.formatTimeAgo(
                                          j['createdAt'],
                                        );
                                    final feelingsList =
                                        j['feelings'] != null
                                            ? List<String>.from(j['feelings'])
                                            : const <String>[];
                                    return JournalCard(
                                      id: j['id'] ?? '',
                                      title: j['title'] ?? 'Untitled',
                                      subtitle: j['bodyText'] ?? '',
                                      time: formattedTime,
                                      verses:
                                          j['verses'] != null
                                              ? List<String>.from(j['verses'])
                                              : [],
                                      feelings: feelingsList,
                                      onVerseTap: _showVerseBottomSheet,
                                      onEditCompleted: _fetchData,
                                    );
                                  }),
                              if (_isLoadingMoreJournals)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              const SizedBox(height: 60), // padding for FAB
                            ],
                          ),
                        ),

                      if (selectedTab == "Saved")
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 7),
                            SectionHeader(
                              title:
                                  "Verses (${bibleProvider.bookmarks.length})",
                              seeAllText: "See all",
                              onSeeAllTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const quest_saved.SavedVersesScreen(),
                                  ),
                                );
                              },
                            ),

                            if (bibleProvider.bookmarks.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  "No saved verses yet.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ...bibleProvider.bookmarks
                                .where((b) {
                                  final ref =
                                      (b['verseRef'] ?? '')
                                          .toString()
                                          .toLowerCase();
                                  return ref.contains(_searchQuery);
                                })
                                .map(
                                  (b) => GestureDetector(
                                    onTap: () async {
                                      final verseRef = b['verseRef'];
                                      if (verseRef != null) {
                                        final parsed = BibleService.parseReference(verseRef);
                                        if (parsed != null) {
                                          final bp = Provider.of<BibleProvider>(context, listen: false);
                                          await bp.loadVerses(parsed['book']!, parsed['chapter']!);
                                          if (context.mounted) {
                                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BibleHomeScreen()));
                                          }
                                        }
                                      }
                                    },
                                    child: SavedCard(
                                      title: b['verseRef'] ?? 'Unknown Reference',
                                      subtitle: "Bookmarked verse",
                                      verse: b['verseRef'] ?? '',
                                      time: DateFormatter.formatTimeAgo(
                                        b['createdAt'],
                                      ),
                                      onDelete: () async {
                                        final authProvider =
                                            Provider.of<AuthProvider>(
                                              context,
                                              listen: false,
                                            );
                                        if (authProvider.token != null) {
                                          final verseRef = b['verseRef'];
                                          if (verseRef != null) {
                                            final parsed =
                                                BibleService.parseReference(
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
                                        }
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                            SectionHeader(
                              title: "Messages (${_savedMessagesList.length})",
                              seeAllText: "See all",
                              onSeeAllTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SavedMessagesScreen(),
                                ),
                              ),
                            ),
                            if (_savedMessagesList.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  "No saved messages yet.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ..._savedMessagesList.map((m) {
                              final sender = m['sender'] ?? {};
                              String timeStr = "Unknown time";
                              if (m['createdAt'] != null) {
                                try {
                                  final dt = DateTime.parse(m['createdAt']);
                                  timeStr = timeago.format(dt);
                                } catch (_) {}
                              }
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AdminMessageScreen(
                                        message: {...m, 'hasBookmarked': true},
                                      ),
                                    ),
                                  );
                                },
                                child: SavedMessagesCard(
                                  title: m['title'] ?? m['text'] ?? 'Message',
                                  authorName: sender['fullName'] ?? sender['username'] ?? '',
                                  messageImage: m['imageUrl'] ?? sender['avatarUrl'],
                                  likesCount: m['likesCount'] ?? 0,
                                  time: timeStr,
                                ),
                              );
                            }),
                            SectionHeader(
                              title: "Books (${_savedBooksList.length})",
                              seeAllText: "See all",
                              onSeeAllTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SavedBooksScreen(),
                                ),
                              ),
                            ),
                            if (_savedBooksList.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  "No saved books yet.",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ..._savedBooksList.map((b) {
                              final book = b['book'] ?? {};
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BookScreen(book: book),
                                    ),
                                  );
                                },
                                child: SavedBooksCard(
                                  title: book['title'] ?? 'Unknown Title',
                                  subtitle: book['description'] ?? '',
                                  author: book['author'] ?? 'Unknown Author',
                                  imageUrl: book['imageUrl'],
                                ),
                              );
                            }),
                            const SizedBox(height: 60),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            /*if (selectedTab == "Journal")
              Positioned(
                bottom: 10,
                left: 16,
                right: 16, // Leave space for FAB
                child: GestureDetector(
                  onTap: _showFeelingSelector,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4C4DFF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4C4DFF),
                            shape: BoxShape.circle,
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedLeaf01,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'How are you feeling now?',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${DateFormatter.formatTimeAgo(DateTime.now().toIso8601String()).replaceAll(" ago", "")}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF4C4DFF),
                            shape: BoxShape.circle,
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedPencilEdit01,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),*/
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final double topSpacing;
  final double bottomSpacing;

  const SectionTitle({
    super.key,
    required this.title,
    this.topSpacing = 15,
    this.bottomSpacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: topSpacing),
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: bottomSpacing),
      ],
    );
  }
}

class _PostListMenuDialogBox extends StatelessWidget {
  const _PostListMenuDialogBox();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(height: 15),
            SettingsSwitchRow(
              icon: HugeIcons.strokeRoundedNotification01,
              title: 'Allow notifications',
              subtitle: 'Turn on or off',
              switchValue: false,
            ),
            SettingsSwitchRow(
              icon: HugeIcons.strokeRoundedSmartPhone03,
              title: 'Haptic Feedback',
              subtitle: 'Turn on haptic feedback',
              switchValue: false,
            ),
          ],
        ),
      ),
    );
  }
}
