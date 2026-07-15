import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/components/more/saved_messages_card.dart';
import 'package:quest/screens/community/admin_message_screen.dart';
import 'package:quest/theme/theme.dart';

class SavedMessagesScreen extends StatefulWidget {
  const SavedMessagesScreen({super.key});

  @override
  State<SavedMessagesScreen> createState() => _SavedMessagesScreenState();
}

class _SavedMessagesScreenState extends State<SavedMessagesScreen> {
  // Data
  final List<dynamic> _messages = [];
  int _page = 1;
  bool _hasMore = true;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;

  // Search
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  Timer? _debounce;

  // Scroll
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 250) {
      if (_hasMore && !_isLoadingMore && !_isLoading) {
        _loadMore();
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (_search != value) {
        setState(() => _search = value);
        _load(reset: true);
      }
    });
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _page = 1;
        _hasMore = true;
        _messages.clear();
        _error = null;
      });
    }
    try {
      final token =
          Provider.of<AuthProvider>(context, listen: false).token ?? '';
      final resp = await ApiService.fetchSavedMessages(
        token,
        page: _page,
        search: _search,
      );
      if (mounted) {
        final data = List<dynamic>.from(resp['data'] ?? []);
        setState(() {
          _messages.addAll(data);
          _hasMore = resp['hasMore'] == true;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
      _page++;
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Saved Messages',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search saved messages...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textColor2,
                ),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                        : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    width: 0.3,
                    color: AppTheme.textColor2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    width: 0.3,
                    color: AppTheme.textColor2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load messages',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _load(reset: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _messages.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _search.isEmpty
                          ? 'No saved messages yet.'
                          : 'No results for "$_search".',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: () => _load(reset: true),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final m = _messages[index];
                    final sender = m['sender'] ?? {};
                    String timeStr = 'Unknown time';
                    if (m['createdAt'] != null) {
                      try {
                        final dt = DateTime.parse(m['createdAt']);
                        timeStr = timeago.format(dt);
                      } catch (_) {}
                    }
                    return GestureDetector(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => AdminMessageScreen(
                                    message: {...m, 'hasBookmarked': true},
                                  ),
                            ),
                          ),
                      child: SavedMessagesCard(
                        title: m['title'] ?? m['text'] ?? 'Message',
                        authorName:
                            sender['fullName'] ??
                            sender['username'] ??
                            'Unknown',
                        messageImage: m['imageUrl'] ?? sender['avatarUrl'],
                        likesCount: m['likesCount'] ?? 0,
                        time: timeStr,
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
