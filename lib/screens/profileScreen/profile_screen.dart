import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:quest/components/action_pill/action_pill_button.dart';
import 'package:quest/components/action_pill/action_pill_button_2.dart';
import 'package:quest/components/badges/badge_card.dart';
import 'package:quest/components/badges/metric_card.dart';
import 'package:quest/components/friends/friend_card_snippet.dart';
import 'package:quest/components/posts/post_card_long.dart';
import 'package:quest/components/feature_guard.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/screens/profileScreen/edit_profile_screen.dart';
import 'package:quest/screens/post/post_screen.dart';
import 'package:quest/screens/profileScreen/profile_settings.dart';
import 'package:quest/theme/theme.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/feed_provider.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  String selectedTab = "Posts";

  List<dynamic> _friends = [];
  List<dynamic> _badgesProgress = [];
  Map<String, dynamic>? _gamesOverview;
  bool _loadingFriends = false;
  bool _loadingBadges = false;
  bool _loadingGames = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
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
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;
    if (token == null) return;

    setState(() {
      _loadingFriends = true;
      _loadingBadges = true;
      _loadingGames = true;
    });

    try {
      final friends = await ApiService.fetchFriends(token);
      if (mounted) {
        setState(() {
          _friends = friends;
          _loadingFriends = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingFriends = false);
      debugPrint("Error loading friends: $e");
    }

    try {
      final badges = await ApiService.fetchBadgesProgress(token);
      if (mounted) {
        setState(() {
          _badgesProgress = badges;
          _loadingBadges = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingBadges = false);
      debugPrint("Error loading badges: $e");
    }

    try {
      final gamesOverview = await ApiService.fetchGamesOverview(token);
      if (mounted) {
        setState(() {
          _gamesOverview = gamesOverview;
          _loadingGames = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingGames = false);
      debugPrint("Error loading games overview: $e");
    }
  }

  void _navigateToProfileSettings(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) => ProfileSettings(),
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

  void _navigateToEditProfile(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const EditProfileScreen(),
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
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final feedProvider = Provider.of<FeedProvider>(context);

    final user = authProvider.user;
    final String fullName =
        user != null
            ? '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim()
            : 'Lenny Daniels';
    final String username =
        user != null ? '@${user['username'] ?? ''}' : '@lenny123';
    final String avatarUrl = user?['avatarUrl'] ?? 'assets/images/boy.png';
    final String formattedAvatarUrl = ApiService.getFullImageUrl(avatarUrl);

    final userFullName = fullName.isNotEmpty ? fullName : 'Anonymous';

    // Calculate dynamic values
    final earnedBadgesCount =
        _badgesProgress.where((b) => b['isEarned'] == true).length;
    final int streakCount = user?['streakCount'] ?? 0;
    final int points = user?['points'] ?? 0;

    // Filter user posts
    final allPosts = feedProvider.feed?['posts'] as List<dynamic>? ?? [];
    final userPosts =
        allPosts.where((p) {
          final postUser = p['user'] ?? {};
          return postUser['username'] == user?['username'];
        }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Column(
            children: [
              TitleOne(
                leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                title: 'Profile',
                trailingIcon: HugeIcons.strokeRoundedSettings02,
                leadingIconTap: () {
                  Navigator.pop(context);
                },
                trailingIconTap: () => _navigateToProfileSettings(context),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xff00d4ff), Color(0xff4a3aff)],
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child:
                                  formattedAvatarUrl.startsWith('http')
                                      ? Image.network(
                                        formattedAvatarUrl,
                                        width: 62,
                                        height: 62,
                                        fit: BoxFit.cover,
                                      )
                                      : Image.asset(
                                        formattedAvatarUrl,
                                        width: 62,
                                        height: 62,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      height: 2.5,
                                    ),
                                    children: [
                                      TextSpan(text: '$userFullName\n'),
                                      TextSpan(
                                        text: username,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textColor2,
                                              fontSize: 12,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 13),
                                SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      ActionPillButton(
                                        icon: HugeIcons.strokeRoundedSettings02,
                                        label: "Edit",
                                        onTap:
                                            () =>
                                                _navigateToEditProfile(context),
                                      ),
                                      const SizedBox(width: 10),
                                      ActionPillButton(
                                        icon: HugeIcons.strokeRoundedShare08,
                                        label: "Share",
                                        onTap: () {},
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  children: [
                                    StatText(
                                      value: "${_friends.length}",
                                      label: "Friends",
                                    ),
                                    StatText(
                                      value: "$earnedBadgesCount",
                                      label: "Badges",
                                    ),
                                    StatText(
                                      value:
                                          "${user?['communities']?.length ?? 1}",
                                      label: "Communities",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FeatureGuard(
                              featureKey: 'community',
                              child: ActionPillButton2(
                                label: "Posts",
                                backgroundColor:
                                    selectedTab == "Posts"
                                        ? (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black)
                                        : Colors.transparent,
                                textColor:
                                    selectedTab == "Posts"
                                        ? (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.black
                                            : Colors.white)
                                        : AppTheme.textColor2,
                                onTap: () {
                                  setState(() => selectedTab = "Posts");
                                },
                              ),
                            ),
                            FeatureGuard(
                              featureKey: 'connect',
                              child: ActionPillButton2(
                                label: "Friends",
                                backgroundColor:
                                    selectedTab == "Friends"
                                        ? (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black)
                                        : Colors.transparent,
                                textColor:
                                    selectedTab == "Friends"
                                        ? (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.black
                                            : Colors.white)
                                        : AppTheme.textColor2,
                                onTap: () {
                                  setState(() => selectedTab = "Friends");
                                },
                              ),
                            ),
                            ActionPillButton2(
                              label: "Badges",
                              backgroundColor:
                                  selectedTab == "Badges"
                                      ? (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black)
                                      : Colors.transparent,
                              textColor:
                                  selectedTab == "Badges"
                                      ? (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black
                                          : Colors.white)
                                      : AppTheme.textColor2,
                              onTap: () {
                                setState(() => selectedTab = "Badges");
                              },
                            ),
                            ActionPillButton2(
                              label: "Metric",
                              backgroundColor:
                                  selectedTab == "Metric"
                                      ? (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black)
                                      : Colors.transparent,
                              textColor:
                                  selectedTab == "Metric"
                                      ? (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black
                                          : Colors.white)
                                      : AppTheme.textColor2,
                              onTap: () {
                                setState(() => selectedTab = "Metric");
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      if (selectedTab == "Posts")
                        FeatureGuard(
                          featureKey: 'community',
                          child:
                              userPosts.isEmpty
                                  ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 40,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "No posts yet",
                                        style: TextStyle(
                                          color:
                                              Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color
                                                  ?.withValues(alpha: 0.54) ??
                                              Colors.black54,
                                        ),
                                      ),
                                    ),
                                  )
                                  : Column(
                                    children:
                                        userPosts.map((post) {
                                          return PostCardLong(
                                            userName: userFullName,
                                            userImage: formattedAvatarUrl,
                                            postText: post['content'] ?? "",
                                            groupName:
                                                post['community']?['name'] ??
                                                "Community",
                                            postImage: post['mediaUrl'] ?? "",
                                            likes:
                                                '${post['reactions']?.length ?? 0}',
                                            comments:
                                                '${post['comments']?.length ?? 0}',
                                            time: "Today",
                                            onTap:
                                                () => _navigateToPostScreen(
                                                  context,
                                                  post,
                                                ),
                                          );
                                        }).toList(),
                                  ),
                        ),

                      if (selectedTab == "Friends")
                        FeatureGuard(
                          featureKey: 'connect',
                          child:
                              _loadingFriends
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : _friends.isEmpty
                                  ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 40,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "No friends yet",
                                        style: TextStyle(
                                          color:
                                              Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color
                                                  ?.withValues(alpha: 0.54) ??
                                              Colors.black54,
                                        ),
                                      ),
                                    ),
                                  )
                                  : Column(
                                    children:
                                        _friends.map((friend) {
                                          final fName =
                                              '${friend['firstName'] ?? ''} ${friend['lastName'] ?? ''}'
                                                  .trim();
                                          final fUsername =
                                              '@${friend['username'] ?? 'anonymous'}';
                                          final fAvatar =
                                              friend['avatarUrl'] != null
                                                  ? ApiService.getFullImageUrl(
                                                    friend['avatarUrl'],
                                                  )
                                                  : 'assets/images/boy.png';
                                          return FriendCardSnippet(
                                            userName: fUsername,
                                            userImage: fAvatar,
                                            fullName:
                                                fName.isNotEmpty
                                                    ? fName
                                                    : "Anonymous",
                                          );
                                        }).toList(),
                                  ),
                        ),

                      if (selectedTab == "Badges")
                        _loadingBadges
                            ? const Center(child: CircularProgressIndicator())
                            : _badgesProgress.isEmpty
                            ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  "No badges setup",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color
                                            ?.withValues(alpha: 0.54) ??
                                        Colors.black54,
                                  ),
                                ),
                              ),
                            )
                            : Column(
                              children: [
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 0.8,
                                      ),
                                  itemCount: _badgesProgress.length,
                                  itemBuilder: (context, index) {
                                    final bp = _badgesProgress[index];
                                    final badge = bp['badge'] ?? {};
                                    final String badgeName =
                                        badge['name'] ?? 'Badge';
                                    final String badgeImg =
                                        badge['imageUrl'] ??
                                        'assets/images/bronze.png';
                                    final int current = bp['currentValue'] ?? 0;
                                    final int target = bp['targetValue'] ?? 1;
                                    final double pct =
                                        (bp['percentage'] ?? 0) / 100.0;
                                    final String stat = "$current/$target";
                                    final bool isEarned = bp['isEarned'] ?? false;

                                    return BadgeCard(
                                      title: badgeName,
                                      progressStat: stat,
                                      badgeImage: badgeImg,
                                      progress: pct,
                                      isEarned: isEarned,
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      width: 1,
                                      color: Theme.of(
                                        context,
                                      ).dividerColor.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.grey[800]
                                                  : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          child: Image.asset(
                                            'assets/images/light_bulb.png',
                                            width: 25,
                                            height: 25,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Unlock Badges',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.color,
                                                    fontSize: 14,
                                                  ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              "Badges are earned when you stay consistent with your daily usage of Shalom App and completing milestones in your daily devotions, games, and activities",
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    fontSize: 12,
                                                    color: AppTheme.textColor2,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                      if (selectedTab == "Metric")
                        _loadingGames
                            ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                            : GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                          children: [
                            MetricCard(
                              title: "Quiz",
                              topLabel: "Lvl",
                              levelStat: "${_gamesOverview?['quiz']?['level'] ?? 1}",
                              bottomLabel: "Earned ${_gamesOverview?['quiz']?['points'] ?? 0} Points",
                              progress: (_gamesOverview?['quiz']?['progress']?.toDouble() ?? 0.0),
                            ),
                            MetricCard(
                              title: "Puzzle",
                              topLabel: "Streak",
                              levelStat: "${_gamesOverview?['puzzle']?['streak'] ?? 0}/${_gamesOverview?['puzzle']?['nextMilestone'] ?? 7} Days",
                              bottomLabel: "Solved ${_gamesOverview?['puzzle']?['solves'] ?? 0} Puzzles",
                              progress: (_gamesOverview?['puzzle']?['progress']?.toDouble() ?? 0.0),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatText extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  final Color? labelColor;
  final FontWeight? valueWeight;
  final FontWeight? labelWeight;
  final double spacing;

  const StatText({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
    this.labelColor,
    this.valueWeight,
    this.labelWeight,
    this.spacing = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Row(
          children: [
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: valueWeight ?? FontWeight.bold,
                color:
                    valueColor ?? Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            ),
            SizedBox(width: spacing),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: labelWeight ?? FontWeight.normal,
                color: labelColor ?? Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
