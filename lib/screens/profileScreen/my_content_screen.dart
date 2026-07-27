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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('My Content', style: AppTheme.headingStyle),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.secondaryTextColor,
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
            child: Text('No $type found.', style: AppTheme.bodyStyle),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              color: AppTheme.surfaceColor,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  item['title'] ?? item['text'] ?? 'Untitled',
                  style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  item['status'] ?? 'Active',
                  style: TextStyle(
                    color:
                        item['status'] == 'PENDING_REVIEW'
                            ? Colors.orange
                            : Colors.green,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppTheme.primaryBlue),
                      onPressed: () => _editItem(type, item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteItem(type, item['id']),
                    ),
                  ],
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
