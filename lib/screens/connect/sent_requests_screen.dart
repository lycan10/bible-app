import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/feed_provider.dart';
import 'package:quest/components/connect/connect_card.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:hugeicons/hugeicons.dart';

class SentRequestsScreen extends StatefulWidget {
  const SentRequestsScreen({super.key});

  @override
  State<SentRequestsScreen> createState() => _SentRequestsScreenState();
}

class _SentRequestsScreenState extends State<SentRequestsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        Provider.of<FeedProvider>(context, listen: false)
            .loadMoreSentRequests(authProvider.token!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedProvider = Provider.of<FeedProvider>(context);
    final sentRequests = feedProvider.sentRequests;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15, left: 16, right: 16),
          child: Column(
            children: [
              TitleOne(
                leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                title: 'Sent Requests',
                leadingIconTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
              if (sentRequests.isEmpty && !feedProvider.isLoading)
                const Expanded(
                  child: Center(
                    child: Text('No sent requests.'),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: sentRequests.length +
                        (feedProvider.isLoadingMoreSent ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == sentRequests.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      final user = sentRequests[index];
                      return ConnectCard(
                        name: '${user['firstName']} ${user['lastName'] ?? ''}'.trim(),
                        username: '@${user['username']}',
                        imagePath: user['avatarUrl'] ?? 'assets/images/boy.png',
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () async {
                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            if (authProvider.token != null) {
                              bool ok = await feedProvider.cancelFriendRequest(
                                authProvider.token!,
                                user['id'],
                              );
                              if (ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Request cancelled')),
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
