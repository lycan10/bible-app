import 'dart:convert';
import 'package:quest/main.dart';
import 'package:quest/providers/chat_provider.dart';
import 'package:quest/screens/media/audio_list_screen.dart';
import 'package:quest/screens/media/audio_reel_screen.dart';
import 'package:quest/screens/media/video_list_screen.dart';
import 'package:quest/screens/media/video_reel_screen.dart';
import 'package:quest/services/api_service.dart';
import 'package:quest/utils/date_formatter.dart';
import 'package:quest/utils/text_parser.dart';
import 'package:quest/screens/notes/view_note_screen.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quest/components/devotion/ongoing_devotion_card.dart';
import 'package:quest/components/media/audio/audio_reel_card.dart';
import 'package:quest/components/feature_guard.dart';
import 'package:quest/components/media/video/video_card.dart';
import 'package:quest/components/titles/section_header.dart';
import 'package:quest/components/today_verse_glass.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/providers/feed_provider.dart';
import 'package:quest/providers/devotion_provider.dart';
import 'package:quest/providers/media_provider.dart';
import 'package:quest/screens/devotion/devotion_article_card.dart';
import 'package:quest/screens/devotion/devotion_list_screen.dart';
import 'package:quest/screens/devotion/devotion_screen.dart';
import 'package:quest/screens/bible_quiz/play_mode_sheet.dart';
import 'package:quest/screens/word_cross/word_cross_difficulty_screen.dart';
import 'package:quest/screens/messages/message_list_screen.dart';
import 'package:quest/screens/notification/Notification_screen.dart';
import 'package:quest/providers/notification_provider.dart';
import 'package:quest/theme/theme.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/daily_feeling_popup.dart';
import 'package:quest/screens/more/more_screen.dart';
import 'package:quest/screens/profileScreen/profile_screen.dart';
import 'package:quest/screens/games/games_screen.dart' as quest_games;
import 'package:quest/screens/donate/donate_screen.dart';
import 'package:quest/screens/community/community_list_screen.dart';
import 'package:quest/screens/community/community_individual_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
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
    _fetchData();
  }

  void _fetchData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    final notifProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final devotionProvider = Provider.of<DevotionProvider>(
      context,
      listen: false,
    );
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    if (authProvider.token != null && authProvider.user?['id'] != null) {
      feedProvider.loadHomeData(authProvider.token!, authProvider.user!['id']);
      notifProvider.fetchNotifications(authProvider.token!);
      chatProvider.loadChats(authProvider.token!);
      devotionProvider.loadPlans(authProvider.token!);
      // Refresh media so home screen shows latest uploaded videos/audio
      mediaProvider.loadVideoData(authProvider.token!);
      mediaProvider.loadAudioData(authProvider.token!);
    }
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
        pageBuilder:
            (context, animation, secondaryAnimation) => MessageListScreen(),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final feedProvider = Provider.of<FeedProvider>(context);
    final devotionProvider = Provider.of<DevotionProvider>(context);

    final devotions =
        feedProvider.feed?['recommendedDevotions'] as List<dynamic>? ?? [];
    final recommendedMedia =
        feedProvider.feed?['recommendedMedia'] as List<dynamic>? ?? [];
    final videos = recommendedMedia.where((m) => m['type'] == 'VIDEO').toList();
    final audios = recommendedMedia.where((m) => m['type'] == 'AUDIO').toList();
    final communities =
        feedProvider.feed?['communities'] as List<dynamic>? ?? [];

    final latestJournal =
        feedProvider.feed?['latestJournal'] as Map<String, dynamic>?;
    final user = authProvider.user;
    final String avatarUrl = user?['avatarUrl'] ?? 'assets/images/boy.png';
    final String formattedAvatarUrl = ApiService.getFullImageUrl(avatarUrl);
    String parsedFeelings = '';
    List<String> parsedFeelingsList = [];
    if (latestJournal != null && latestJournal['feelings'] != null) {
      final f = latestJournal['feelings'];
      if (f is List) {
        parsedFeelingsList = List<String>.from(f);
        parsedFeelings = f.join(', ');
      } else if (f is String) {
        if (f.startsWith('[')) {
          try {
            final List<dynamic> list = jsonDecode(f);
            parsedFeelingsList = List<String>.from(list);
            parsedFeelings = list.join(', ');
          } catch (_) {
            parsedFeelings = f;
            parsedFeelingsList = [f];
          }
        } else {
          parsedFeelings = f;
          parsedFeelingsList = [f];
        }
      }
    }

    List<String> parsedVersesList = [];
    if (latestJournal != null && latestJournal['verses'] != null) {
      final v = latestJournal['verses'];
      if (v is List) {
        parsedVersesList = List<String>.from(v);
      } else if (v is String) {
        if (v.startsWith('[')) {
          try {
            final List<dynamic> list = jsonDecode(v);
            parsedVersesList = List<String>.from(list);
          } catch (_) {
            parsedVersesList = [v];
          }
        } else {
          parsedVersesList = [v];
        }
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 16, right: 16),

          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 10),

                        Image.asset(
                          Theme.of(context).brightness == Brightness.dark
                              ? 'assets/images/logo-dark.png'
                              : 'assets/images/logo.png',
                          width: 40,
                          height: 40,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FeatureGuard(
                          featureKey: 'connect',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => _navigateToMessage(context),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    HugeIcon(
                                      icon: HugeIcons.strokeRoundedMessage02,
                                      size: 20.0,
                                      color: Theme.of(context).iconTheme.color,
                                      strokeWidth: 1.5,
                                    ),
                                    Consumer<ChatProvider>(
                                      builder: (context, chatProvider, child) {
                                        if (chatProvider.totalUnreadCount > 0) {
                                          return Positioned(
                                            right: -2,
                                            top: -2,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Text(
                                                '${chatProvider.totalUnreadCount}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 13),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _navigateToNotification(context),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedNotification01,
                                size: 20.0,
                                color: Theme.of(context).iconTheme.color,
                                strokeWidth: 2,
                              ),
                              Consumer<NotificationProvider>(
                                builder: (context, notifProvider, child) {
                                  if (notifProvider.unreadCount > 0) {
                                    return Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${notifProvider.unreadCount}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 13),
                        GestureDetector(
                          onTap: () => _navigateToProfile(context),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xff00d4ff), Color(0xff4a3aff)],
                              ),

                              borderRadius: BorderRadius.circular(
                                30,
                              ), // matches image roundness
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                15,
                              ), // half of image width/height
                              child:
                                  formattedAvatarUrl.startsWith('http')
                                      ? Image.network(
                                        formattedAvatarUrl,
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                      )
                                      : Image.asset(
                                        formattedAvatarUrl,
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '${DateFormatter.getGreeting()} ${authProvider.user?['firstName'] ?? ''}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          height: 2,
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Say ",
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff4A3AFF),
                                fontSize: 16,
                              ),
                            ),
                            TextSpan(
                              text: "'${feedProvider.affirmation}'",
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.normal,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                TodayVerseGlass(verseData: feedProvider.dailyVerse),
                FeatureGuard(
                  featureKey: 'journal',
                  child: Column(
                    children: [
                      SectionHeader(
                        title: "Journal",
                        seeAllText: "See all",
                        onSeeAllTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      const MoreScreen(initialTab: "Journal"),
                            ),
                          );
                        },
                      ),
                      if (latestJournal == null)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const MoreScreen(initialTab: "Journal"),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              "Write your first journal today!",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.textColor2),
                            ),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ViewNoteScreen(
                                      id: latestJournal['id'] ?? '',
                                      title:
                                          latestJournal['title'] ?? 'Untitled',
                                      bodyText: latestJournal['bodyText'] ?? '',
                                      time: DateFormatter.formatTimeAgo(
                                        latestJournal['createdAt'],
                                      ),
                                      verses: parsedVersesList,
                                      feelings: parsedFeelingsList,
                                      type: "Journal",
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// 🔹 Avatar
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.greenColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedLeaf02,
                                    size: 30,
                                    color: AppTheme.greenColor,
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
                                        latestJournal['title'] ?? 'Untitled',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.color,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 250,
                                        ),
                                        child: Text(
                                          TextParser.extractTextFromDelta(
                                            latestJournal['bodyText'] ?? '',
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: theme.colorScheme.onTertiary,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxWidth: 250,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              '- ${DateFormatter.formatTimeAgo(latestJournal['createdAt'])}',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.copyWith(
                                                fontSize: 12,
                                                color:
                                                    Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                              ),
                                            ),
                                            const SizedBox(width: 6),

                                            if (parsedFeelings.isNotEmpty) ...[
                                              SizedBox(
                                                height: 10,
                                                child: VerticalDivider(
                                                  thickness: 1.5,
                                                  color: AppTheme.textColor2
                                                      .withValues(alpha: 0.5),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '- Feelings: $parsedFeelings',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontSize: 12,
                                                        color:
                                                            Theme.of(context)
                                                                .textTheme
                                                                .bodyMedium
                                                                ?.color,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 13),
                GestureDetector(
                  onTap: () {
                    DailyFeelingPopup.show(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppTheme.purpleColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// 🔹 Avatar
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.purpleColor.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedLeaf02,
                                size: 30,
                                color: AppTheme.purpleColor,
                              ),
                            ),

                            const SizedBox(width: 10),

                            /// 🔹 Text Content
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  feedProvider.currentFeeling != null
                                      ? 'Feeling: ${feedProvider.currentFeeling!['emoji']} ${feedProvider.currentFeeling!['feeling']}'
                                      : 'How are you feeling?',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                if (feedProvider.currentFeeling != null) ...[
                                  const SizedBox(height: 4),

                                  Text(
                                    '- ${DateFormatter.formatTimeAgo(feedProvider.currentFeeling!['createdAt'])}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontSize: 13),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.purpleColor,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedPencilEdit01,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                FeatureGuard(
                  featureKey: 'devotion',
                  child: Column(
                    children: [
                      if (devotionProvider.myPlans.isNotEmpty) ...[
                        SectionHeader(
                          title: "Ongoing devotion",
                          showSeeAll: false,
                        ),
                        Builder(
                          builder: (context) {
                            final plan = devotionProvider.myPlans[0]['plan'];
                            final currentDay =
                                devotionProvider.myPlans[0]['currentDay'];
                            return OngoingDevotionCard(
                              title: plan['title'] ?? "",
                              author: plan['authorName'] ?? "",
                              imagePath:
                                  plan['image'] ?? "assets/images/boy.png",
                              likes: "${plan['durationDays']} Days Plan",
                              planText: plan['tag'] ?? "",
                              day: currentDay ?? 1,
                              onContinue: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => DevotionScreen(
                                          planId: plan['id'],
                                          dayNum: 1,
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                      if (devotions.length > 1) ...[
                        SectionHeader(
                          title: "Devotion for you",
                          seeAllText: "See more",
                          onSeeAllTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const DevotionListScreen(),
                              ),
                            );
                          },
                        ),
                        DevotionArticleCard(
                          title: devotions[1]['title'] ?? "",
                          description: devotions[1]['description'] ?? "",
                          author: devotions[1]['authorName'] ?? "",
                          imagePath:
                              devotions[1]['image'] ?? "assets/images/boy.png",
                          likes: "${devotions[1]['durationDays']} Days",
                          tag: devotions[1]['tag'] ?? "",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const DevotionListScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                FeatureGuard(
                  featureKey: 'videos',
                  child: Column(
                    children: [
                      SectionHeader(
                        title: "Video",
                        seeAllText: "See more",
                        onSeeAllTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VideoListScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 275,
                        child:
                            videos.isEmpty
                                ? Center(
                                  child: Text(
                                    "No videos available",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withValues(alpha: 0.54),
                                    ),
                                  ),
                                )
                                : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: videos.length,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(width: 15),
                                  itemBuilder: (context, index) {
                                    final m = videos[index];
                                    return VideoCard(
                                      title: m['title'] ?? '',
                                      author: m['author'] ?? '',
                                      likes: '${m['likes'] ?? 0}',
                                      backgroundImage:
                                          m['imageUrl'] ??
                                          'assets/images/boy.png',
                                      onTap: () {
                                        Navigator.of(context).push(
                                          PageRouteBuilder(
                                            transitionDuration: const Duration(
                                              milliseconds: 600,
                                            ),
                                            pageBuilder:
                                                (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                ) => VideoReelScreen(
                                                  videos: videos,
                                                  initialIndex: index,
                                                ),
                                            transitionsBuilder: (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                              child,
                                            ) {
                                              return SharedAxisTransition(
                                                animation: animation,
                                                secondaryAnimation:
                                                    secondaryAnimation,
                                                transitionType:
                                                    SharedAxisTransitionType
                                                        .scaled,
                                                child: child,
                                              );
                                            },
                                          ),
                                        );
                                      },
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
                        title: "Audio Sermon",
                        seeAllText: "See more",
                        onSeeAllTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AudioListScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 165,
                        child:
                            audios.isEmpty
                                ? Center(
                                  child: Text(
                                    "No audio messages available",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withValues(alpha: 0.54),
                                    ),
                                  ),
                                )
                                : ListView.separated(
                                  scrollDirection: Axis.horizontal,
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
                                          'assets/images/boy.png',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => AudioReelScreen(
                                                  audios: audios,
                                                  initialIndex: index,
                                                ),
                                          ),
                                        );
                                      },
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
                        title: "Community For You",
                        seeAllText: "See more",
                        onSeeAllTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CommunityListScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 230,
                        child:
                            communities.isEmpty
                                ? Center(
                                  child: Text(
                                    "No communities yet",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withValues(alpha: 0.54),
                                    ),
                                  ),
                                )
                                : ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: communities.length,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(width: 15),
                                  itemBuilder: (context, index) {
                                    final community = communities[index];
                                    return CommunityReelCard(
                                      title: community['name'] ?? '',
                                      author: community['description'] ?? '',
                                      followers:
                                          '${community['_count']?['members'] ?? 0} members',
                                      backgroundImage:
                                          community['image'] != null
                                              ? ApiService.getFullImageUrl(
                                                community['image'],
                                              )
                                              : 'assets/images/test.jpg',
                                      onTap: () {
                                        Navigator.of(context).push(
                                          PageRouteBuilder(
                                            transitionDuration: const Duration(
                                              milliseconds: 600,
                                            ),
                                            pageBuilder:
                                                (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                ) => CommunityIndividualScreen(
                                                  communityId: community['id'],
                                                  initialData: community,
                                                ),
                                            transitionsBuilder: (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                              child,
                                            ) {
                                              return SharedAxisTransition(
                                                animation: animation,
                                                secondaryAnimation:
                                                    secondaryAnimation,
                                                transitionType:
                                                    SharedAxisTransitionType
                                                        .scaled,
                                                child: child,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      width: 209,
                                      height: 180,
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
                FeatureGuard(
                  featureKey: 'games',
                  child: Column(
                    children: [
                      SectionHeader(
                        title: "Games",
                        seeAllText: "See all",
                        onSeeAllTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const quest_games.GamesScreen(),
                            ),
                          );
                        },
                      ),
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.815,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          GamesReelCard(
                            title: 'Bible Quiz',
                            description: "Test your knowledge!",
                            gameIcon: 'assets/images/bible_game.png',
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => const PlayModeSheet(),
                              );
                            },
                          ),
                          GamesReelCard(
                            title: 'Word Cross',
                            description: "Find hidden words!",
                            gameIcon: 'assets/images/puzzle_game.png',

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const WordCrossDifficultyScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 45,
                        height: 45,
                      ),
                      const SizedBox(height: 13),
                      Text(
                        "Support Sozo App",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Help keep Sozo free. Every donation helps us maintain and improve the app for everyone.",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          color: Colors.black.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 27),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DonateScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedFavourite,
                                size: 16,
                                color:
                                    Theme.of(context).colorScheme.tertiaryFixed,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Donate",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.tertiaryFixed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GamesReelCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;
  final String gameIcon;
  // final double? width;
  // final double? height;

  const GamesReelCard({
    super.key,
    required this.title,
    required this.description,
    this.onTap,
    // this.width,
    // this.height = 30,
    required this.gameIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:
              theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),

          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(gameIcon, width: 50, height: 50),
              const SizedBox(height: 13),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  color: theme.textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: theme.textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color:
                      theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Play',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color:
                        theme.brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
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
              backgroundImage.startsWith('http')
                  ? Image.network(backgroundImage, fit: BoxFit.cover)
                  : Image.asset(backgroundImage, fit: BoxFit.cover),

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
                            text: 'Author: ',
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
                        Expanded(
                          child: Text(
                            followers,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            ' - Recently active',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontSize: 12, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
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
