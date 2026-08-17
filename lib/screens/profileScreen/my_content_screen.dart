import 'package:flutter/material.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/screens/profileScreen/edit_content_screen.dart';

class MyContentScreen extends StatefulWidget {
  final String token;
  const MyContentScreen({Key? key, required this.token}) : super(key: key);

  @override
  _MyContentScreenState createState() => _MyContentScreenState();
}

class _MyContentScreenState extends State<MyContentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('My Content', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: AppTheme.primaryBlue,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Devotions'),
            Tab(text: 'Books'),
            Tab(text: 'Media'),
            Tab(text: 'Posts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContentList('devotions'),
          _buildContentList('books'),
          _buildContentList('media'),
          _buildContentList('posts'),
        ],
      ),
    );
  }

  Widget _buildContentList(String type) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchData(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Text('No $type found.', style: Theme.of(context).textTheme.bodyLarge),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: Text(
                    item['title'] ?? item['text'] ?? 'Untitled',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: item['status'] == 'PENDING_REVIEW'
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['status'] ?? 'Active',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: item['status'] == 'PENDING_REVIEW'
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: AppTheme.primaryBlue),
                        onPressed: () => _editItem(type, item),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                        onPressed: () => _deleteItem(type, item['id']),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _fetchData(String type) async {
    switch (type) {
      case 'devotions':
        return ApiService.fetchCreatedDevotions(widget.token);
      case 'books':
        return ApiService.fetchCreatedBooks(widget.token);
      case 'media':
        return ApiService.fetchCreatedUserMedia(widget.token);
      case 'posts':
        return ApiService.fetchCreatedPosts(widget.token);
      default:
        return [];
    }
  }

  Future<void> _editItem(String type, Map<String, dynamic> item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                EditContentScreen(token: widget.token, type: type, item: item),
      ),
    );

    if (result == true) {
      setState(() {}); // refresh
    }
  }

  Future<void> _deleteItem(String type, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        switch (type) {
          case 'devotions':
            await ApiService.deleteDevotionPlan(widget.token, id);
            break;
          case 'books':
            await ApiService.deleteBook(widget.token, id);
            break;
          case 'media':
            await ApiService.deleteUserMedia(widget.token, id);
            break;
          case 'posts':
            // TODO: implement ApiService.deletePost
            break;
        }
        setState(() {}); // refresh
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }
}
