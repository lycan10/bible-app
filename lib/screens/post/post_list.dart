import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:quest/components/posts/post_card_long.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/screens/post/post_screen.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/providers/community_provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../components/global_more_menu.dart';
import 'package:quest/main.dart';

class PostList extends StatefulWidget {
  const PostList({super.key});

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> with RouteAware {
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPosts(refresh: true);
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadPosts(refresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadPosts(refresh: false);
    }
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    
    if (auth.token != null) {
      await communityProvider.loadGlobalPosts(auth.token!, refresh: refresh);
    }
  }

  void _navigateToPostScreen(BuildContext context, Map<String, dynamic> post) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) => PostScreen(post: post),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.scaled,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            children: [
              TitleOne(
                leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                title: 'Posts',
                trailingIcon: HugeIcons.strokeRoundedMoreVertical,
                leadingIconTap: () {
                  Navigator.pop(context);
                },
                trailingIconTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return const GlobalMoreMenu();
                    },
                  );
                },
              ),
              const SizedBox(height: 25),
              Expanded(
                child: Consumer<CommunityProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.globalPosts.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.globalPosts.isEmpty) {
                      return const Center(
                        child: Text("No posts found."),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => _loadPosts(refresh: true),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: provider.globalPosts.length + (provider.hasMoreGlobalPosts ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == provider.globalPosts.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final post = provider.globalPosts[index];
                          final user = post['user'] ?? {};
                          final community = post['community'] ?? {};
                          
                          final userName = "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim();
                          final userImage = user['avatarUrl'] ?? "assets/images/boy.png";
                          final groupName = community['name'] ?? "Community";
                          final likes = ((post['reactions'] as List?)?.length ?? 0).toString();
                          final comments = (post['_count']?['comments'] ?? 0).toString();
                          
                          DateTime createdAt = DateTime.now();
                          if (post['createdAt'] != null) {
                            createdAt = DateTime.tryParse(post['createdAt']) ?? DateTime.now();
                          }
                          final timeStr = timeago.format(createdAt);

                          return PostCardLong(
                            userName: userName.isNotEmpty ? userName : user['username'] ?? '',
                            userImage: userImage,
                            verificationBadge: user['verificationBadge'] ?? 'NONE',
                            postText: post['text'] ?? '',
                            groupName: groupName,
                            postImage: post['image'] ?? '',
                            likes: likes,
                            comments: comments,
                            time: timeStr,
                            onTap: () => _navigateToPostScreen(context, post),
                          );
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

class _PostListMenuDialogBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
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
