import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:quest/components/circle_stuff.dart';
import 'package:quest/components/event/event_dotted_card.dart';
import 'package:quest/components/media/audio/audio_reel_card.dart';
import 'package:quest/components/media/video/video_card.dart';
import 'package:quest/components/menu/discover_more.dart';
import 'package:quest/components/posts/post_card_long.dart';
import 'package:quest/components/posts/post_card_short.dart';
import 'package:quest/components/sponsored/sponsored_post.dart';
import 'package:quest/components/sponsored/sponsored_post_card.dart';
import 'package:quest/components/sponsored/sponsored_video.dart';
import 'package:quest/components/titles/section_header.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/feed_provider.dart';
import 'package:quest/screens/books/books_list_screen.dart';
import 'package:quest/screens/community/community_list_screen.dart';
import 'package:quest/screens/connect/connect_screen.dart';
import 'package:quest/screens/devotion/devotion_list_screen.dart';
import 'package:quest/screens/messages/message_list.dart';
import 'package:quest/screens/messages/message_list_screen.dart';
import 'package:quest/screens/notification/Notification_screen.dart';
import 'package:quest/screens/post/post_list.dart';
import 'package:quest/screens/post/post_screen.dart';
import 'package:quest/screens/profileScreen/profile_screen.dart';
import 'package:quest/screens/media/video_list_screen.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/theme/theme.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/feature_guard.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);
      if (authProvider.token != null) {
        feedProvider.loadExploreData(authProvider.token!);
      }
    });
  }

  void _navigateToNotification(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) => NotificationScreen(),
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

  void _navigateToMessage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => MessageList(),
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

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) => ProfileScreen(),
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

  void _navigateToPostScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => PostScreen(),
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

  void _navigateToSponsoredPostScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) => SponsoredPostScreen(),
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

  void _navigateToPostList(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => PostList(),
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
    final feedProvider = Provider.of<FeedProvider>(context);
    final explore = feedProvider.explore;

    final devotionPlans = explore?['devotionPlans'] as List<dynamic>? ?? [];
    final communities = explore?['communities'] as List<dynamic>? ?? [];
    final videos = explore?['videos'] as List<dynamic>? ?? [];
    final audios = explore?['audios'] as List<dynamic>? ?? [];
    final posts = explore?['posts'] as List<dynamic>? ?? [];
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15, left: 16, right: 16),

          child: ListView(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            'Explore',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _navigateToMessage(context),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedMessage02,
                              size: 20.0,
                              color: Colors.black,
                              strokeWidth: 1.5,
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () => _navigateToNotification(context),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedNotification01,
                              size: 20.0,
                              color: Colors.black,
                              strokeWidth: 1.5,
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () => _navigateToProfile(context),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xff00d4ff),
                                    Color(0xff4a3aff),
                                  ],
                                ),

                                borderRadius: BorderRadius.circular(
                                  30,
                                ), // matches image roundness
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  25,
                                ), // half of image width/height
                                child: Image.asset(
                                  'assets/images/boy.png',
                                  width: 20,
                                  height: 20,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /// Menu / List Icon Button
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) {
                              return DiscoverMore();
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedLeftToRightListBullet,
                            size: 22,
                            color: Colors.black,
                            strokeWidth: 1,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// Search Bar
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
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

                              /// Search Input
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText:
                                        "Search for devotions, books, communities...",
                                    border: InputBorder.none,
                                    isDense: true,
                                    hintStyle: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      children: [
                        FeatureGuard(
                          featureKey: 'devotion',
                          child: TagChip(
                            label: "Devotion",
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DevotionListScreen(),
                                  ),
                                ),
                          ),
                        ),
                        FeatureGuard(
                          featureKey: 'books',
                          child: TagChip(
                            label: "Books",
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BooksListScreen(),
                                  ),
                                ),
                          ),
                        ),
                        FeatureGuard(
                          featureKey: 'community',
                          child: TagChip(
                            label: "Communities",
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommunityListScreen(),
                                  ),
                                ),
                          ),
                        ),
                        FeatureGuard(
                          featureKey: 'videos',
                          child: TagChip(
                            label: "Videos",
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoListScreen(),
                                  ),
                                ),
                          ),
                        ),
                        FeatureGuard(
                          featureKey: 'audioMessages',
                          child: TagChip(
                            label: "Messages",
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MessageListScreen(),
                                  ),
                                ),
                          ),
                        ),
                        FeatureGuard(
                          featureKey: 'games',
                          child: TagChip(label: "Games", onTap: () {}),
                        ),
                        FeatureGuard(
                          featureKey: 'connect',
                          child: TagChip(
                            label: "Connect",
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ConnectScreen(),
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  FeatureGuard(
                    featureKey: 'devotion',
                    child: Column(
                      children: [
                        SectionHeader(
                          title: "Most Read Plans",
                          seeAllText: "See more",
                        ),
                        SizedBox(
                          height: 200,
                          child:
                              devotionPlans.isEmpty
                                  ? const Center(
                                    child: Text(
                                      "No plans available",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  )
                                  : ListView.separated(
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: devotionPlans.length,
                                    separatorBuilder:
                                        (_, __) => const SizedBox(width: 15),
                                    itemBuilder: (context, index) {
                                      final plan = devotionPlans[index];
                                      return BooksReelCard(
                                        title: plan['title'] ?? '',
                                        author: plan['authorName'] ?? 'Shalom',
                                        likes:
                                            '${plan['durationDays'] ?? 0} Days',
                                        backgroundImage:
                                            plan['image'] ??
                                            'assets/images/book.jpeg',
                                        onTap: () {},
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),
                  FeatureGuard(
                    featureKey: 'videos',
                    child: Column(
                      children: [
                        SectionHeader(title: "Video", seeAllText: "See more"),
                        SizedBox(
                          height: 200,
                          child:
                              videos.isEmpty
                                  ? const Center(
                                    child: Text(
                                      "No videos available",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  )
                                  : ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: videos.length,
                                    separatorBuilder:
                                        (_, __) => const SizedBox(width: 15),
                                    itemBuilder: (context, index) {
                                      final m = videos[index];
                                      return VideoCard(
                                        title: m['title'] ?? '',
                                        author: m['author'] ?? '',
                                        likes: '${m['likes'] ?? 0}',
                                        height: 150,
                                        width: 150,
                                        backgroundImage:
                                            m['imageUrl'] ??
                                            'assets/images/boy.png',
                                        onTap: () {},
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),
                  FeatureGuard(
                    featureKey: 'audioMessages',
                    child: Column(
                      children: [
                        SectionHeader(
                          title: "Audio Messages",
                          seeAllText: "See more",
                        ),
                        SizedBox(
                          height: 165,
                          child:
                              audios.isEmpty
                                  ? const Center(
                                    child: Text(
                                      "No audio messages available",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  )
                                  : ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: audios.length,
                                    separatorBuilder:
                                        (_, __) => const SizedBox(width: 15),
                                    itemBuilder: (context, index) {
                                      final m = audios[index];
                                      return AudioReelCard(
                                        title: m['title'] ?? '',
                                        author: m['author'] ?? '',
                                        likes: '${m['likes'] ?? 0}',
                                        backgroundImage:
                                            m['imageUrl'] ??
                                            'assets/images/alucard.png',
                                        onTap: () {},
                                        width: 147,
                                        height: 150,
                                        duration: m['duration'] ?? "2:30",
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),
                  FeatureGuard(
                    featureKey: 'community',
                    child: Column(
                      children: [
                        SectionHeader(
                          title: "Discover communities",
                          seeAllText: 'see more',
                        ),
                        SizedBox(
                          height: 175,
                          child:
                              communities.isEmpty
                                  ? const Center(
                                    child: Text(
                                      "No communities found",
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  )
                                  : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: communities.length,
                                    itemBuilder: (context, index) {
                                      final c = communities[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        child: CircleStuff(
                                          width: 100,
                                          height: 100,
                                          title: c['name'] ?? '',
                                          description:
                                              '${c['_count']?['members'] ?? 0} members',
                                          avatarUrl: c['avatarUrl'],
                                          onTap: () {},
                                        ),
                                      );
                                    },
                                  ),
                        ),
                        SponsoredPostCard(
                          onTap: () => _navigateToSponsoredPostScreen(context),
                        ),
                        SectionHeader(
                          title: "Community Posts",
                          seeAllText: "See more",
                          onSeeAllTap: () => _navigateToPostList(context),
                        ),
                        if (posts.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                "No community posts yet",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          )
                        else
                          ...posts.map((post) {
                            final userName =
                                post['user']?['firstName'] ??
                                post['user']?['username'] ??
                                "Anonymous";
                            final userImage =
                                post['user']?['avatarUrl'] != null
                                    ? ApiService.getFullImageUrl(
                                      post['user']!['avatarUrl'],
                                    )
                                    : 'assets/images/boy.png';
                            return PostCardLong(
                              userName: userName,
                              userImage: userImage,
                              postText: post['content'] ?? "",
                              groupName:
                                  post['community']?['name'] ?? "Community",
                              postImage: post['mediaUrl'] ?? "",
                              likes: '${post['reactions']?.length ?? 0}',
                              comments: '${post['comments']?.length ?? 0}',
                              time: "Today",
                              onTap: () => _navigateToPostScreen(context),
                            );
                          }),
                      ],
                    ),
                  ),
                  SectionHeader(
                    title: "Devotion for you",
                    seeAllText: "See more",
                  ),
                  if (devotionPlans.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          "No recommended devotions yet",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    )
                  else
                    ...devotionPlans.take(2).map((plan) {
                      final image =
                          plan['image'] ?? 'assets/images/user_test.jpg';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 0.5,
                              color: AppTheme.buttonColor2,
                            ),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child:
                                        image.startsWith('http')
                                            ? Image.network(
                                              image,
                                              width: 62,
                                              height: 62,
                                              fit: BoxFit.cover,
                                            )
                                            : Image.asset(
                                              image,
                                              width: 62,
                                              height: 62,
                                              fit: BoxFit.cover,
                                            ),
                                  ),
                                  const SizedBox(width: 10),

                                  /// 🔹 Text Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          plan['title'] ?? '',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          plan['tag'] ?? 'Weekly inspiration',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                            color: AppTheme.textColor2,
                                          ),
                                        ),
                                        const SizedBox(height: 5),

                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'From: ',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontSize: 12,
                                                      color:
                                                          AppTheme.textColor2,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                              ),
                                              TextSpan(
                                                text:
                                                    plan['authorName'] ??
                                                    "Believer's Journal",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const HugeIcon(
                                              icon:
                                                  HugeIcons
                                                      .strokeRoundedThumbsUp,
                                              size: 16,
                                              color: Color(0xff8e8e93),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "385",
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    fontSize: 11,
                                                    color: AppTheme.textColor2,
                                                  ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              ' - ${plan['durationDays'] ?? 0} Days Plan',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.copyWith(
                                                fontSize: 12,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 7,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  width: 1,
                                                  color: Colors.black,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Read',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                          fontSize: 13,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  SizedBox(height: 15),
                  SponsoredVideo(),
                  SectionHeader(
                    title: "Recommended Messages",
                    seeAllText: "see more",
                  ),
                  PostCardShort(
                    postText:
                        "Christian fellowship is a beautiful expression...",
                    author: "Lekki Christian Youths",
                    postImage: "assets/images/test.jpg",
                    likes: "370k",
                    comments: "29",
                    time: "Today 3:25pm",
                    onTap: () {},
                  ),
                  PostCardShort(
                    postText:
                        "Christian fellowship is a beautiful expression...",
                    author: "Lekki Christian Youths",
                    postImage: "assets/images/test.jpg",
                    likes: "370k",
                    comments: "29",
                    time: "Today 3:25pm",
                    onTap: () {},
                  ),
                  FeatureGuard(
                    featureKey: 'connect',
                    child: Column(
                      children: [
                        SectionHeader(title: "Friend", seeAllText: 'see more'),
                        SizedBox(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: 8,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(right: 7),
                                child: CircleStuff(
                                  titleFont: 14,
                                  descriptionFont: 12,
                                  titleWidth: 50,
                                  title: 'Noah',
                                  description: 'City',
                                  onTap: () {},
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SectionHeader(
                    title: "Upcoming community events",
                    showSeeAll: false,
                  ),
                  EventDottedCard(onTap: () {}),
                  const SizedBox(height: 30),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;

  const TagChip({
    super.key,
    required this.label,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 1,
            color:
                isSelected
                    ? Colors.black
                    : AppTheme.textColor2.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class BooksReelCard extends StatelessWidget {
  final String title;
  final String author;
  final String likes;
  final String backgroundImage;
  final VoidCallback? onTap;
  final double? height;

  const BooksReelCard({
    super.key,
    required this.title,
    required this.author,
    required this.likes,
    required this.backgroundImage,
    this.onTap,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              backgroundImage.startsWith('http')
                  ? Image.network(backgroundImage, fit: BoxFit.cover)
                  : Image.asset(backgroundImage, fit: BoxFit.cover),

              /// 🔹 Dark overlay for readability
              Container(color: Colors.black.withValues(alpha: 0.5)),

              /// 🔹 Play Button (Centered)

              /// 🔹 Bottom Content
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),

                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_outline,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedLibrary,
                              size: 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '- ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              TextSpan(
                                text: author,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 3),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommunityReelCard extends StatelessWidget {
  final String title;
  final String author;
  final String followers;
  final String backgroundImage;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const CommunityReelCard({
    super.key,
    required this.title,
    required this.author,
    required this.followers,
    required this.backgroundImage,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height ?? 275,
        width: width ?? 204,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              /// 🔹 Background Image
              Image.asset(backgroundImage, fit: BoxFit.cover),

              /// 🔹 Dark overlay for readability
              Container(color: Colors.black.withValues(alpha: 0.5)),

              /// 🔹 Bottom Content
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 0),

                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'From: ',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          TextSpan(
                            text: author,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const HugeIcon(
                          icon: HugeIcons.strokeRoundedUserGroup,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          followers,

                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          ' - Today 2:49pm',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontSize: 12, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OtherCategoryProgressTile extends StatelessWidget {
  final String title;
  final String level;
  final IconData icon;
  final String status;
  final Color statusColor;

  const OtherCategoryProgressTile({
    super.key,
    required this.title,
    required this.level,
    required this.icon,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withAlpha(
                        (0.05 * 255).round(),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 40, color: AppTheme.goldAccent),
                  ),
                  const SizedBox(width: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$title\n',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        TextSpan(
                          text: 'Level: $level',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //   decoration: BoxDecoration(
              //     color: statusColor.withAlpha((0.05 * 255).round()),
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: Text(
              //     status,
              //     style: theme.textTheme.bodySmall?.copyWith(
              //       fontWeight: FontWeight.w500,
              //       color: statusColor,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class CategoryProgressTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String status;
  final Color statusColor;

  const CategoryProgressTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withAlpha(
                        (0.05 * 255).round(),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 40, color: AppTheme.goldAccent),
                  ),
                  const SizedBox(width: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$title\n',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        TextSpan(
                          text: subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha((0.05 * 255).round()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
