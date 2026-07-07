import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/components/media/video/video_card.dart';
import 'package:quest/components/menu/discover_more.dart';
import 'package:quest/components/tile/settings_switch_row.dart';
import 'package:quest/components/titles/section_header.dart';
import 'package:quest/components/titles/title_one.dart';
import 'package:quest/screens/media/video_reel_screen.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/media_provider.dart';
import 'package:quest/providers/auth_provider.dart';

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({super.key});

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        context.read<MediaProvider>().loadVideoData(auth.token!);
      }
    });
  }

  void _navigateToVideo(BuildContext context, int index) {
    final mediaProvider = context.read<MediaProvider>();
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder:
            (context, animation, secondaryAnimation) => VideoReelScreen(
              videos: mediaProvider.videos,
              initialIndex: index,
            ),
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

  void _openMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Filter",
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Center(child: _PostListMenuDialogBox());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaProvider = Provider.of<MediaProvider>(context);
    final videos = mediaProvider.videos;
    final isLoading = mediaProvider.isLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  children: [
                    /// TITLE BAR
                    TitleOne(
                      leadingIcon: HugeIcons.strokeRoundedArrowLeft01,
                      title: 'Videos',
                      trailingIcon: HugeIcons.strokeRoundedMoreVertical,
                      leadingIconTap: () => Navigator.pop(context),
                      trailingIconTap: () => _openMenu(context),
                    ),

                    const SizedBox(height: 25),

                    // SearchBar(
                    //   hintText: "Search communities",
                    //   onTap: () {
                    //     showModalBottomSheet(
                    //       context: context,
                    //       isScrollControlled: true,
                    //       backgroundColor: Colors.transparent,
                    //       builder: (context) {
                    //         return DiscoverMore();
                    //       },
                    //     );
                    //   },
                    //   onChanged: (value) {
                    //     print("Searching: $value");
                    //   },
                    // ),
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
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: HugeIcon(
                              icon:
                                  HugeIcons.strokeRoundedLeftToRightListBullet,
                              size: 22,
                              color: theme.colorScheme.onSurface,
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
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedSearch01,
                                  size: 18,
                                  color: theme.colorScheme.onSurface,
                                ),

                                const SizedBox(width: 8),

                                /// Search Input
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: "Search videos",
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

                    SizedBox(height: 25),

                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Title
                        Text(
                          "Continue watching",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),

                        /// Right Action
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (videos.isNotEmpty)
                      MediaCard(
                        imagePath: videos.first['imageUrl'] ?? '',
                        title: videos.first['title'] ?? 'The good stuff',
                        author: videos.first['author'] ?? 'Good kids',
                        likes: '${videos.first['likes'] ?? 0}',
                        onTap: () {
                          _navigateToVideo(context, 0);
                        },
                      ),

                    const SizedBox(height: 15),

                    SectionHeader(title: "All Videos", seeAllText: "See more"),
                    SizedBox(
                      height: 200,
                      child:
                          videos.isEmpty
                              ? const Center(child: Text("No videos found"))
                              : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: videos.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(width: 15),
                                itemBuilder: (context, index) {
                                  final video = videos[index];
                                  final image = video['imageUrl'] ?? '';
                                  return VideoCard(
                                    title: video['title'] ?? 'Video',
                                    author: video['author'] ?? 'Shalom',
                                    likes: '${video['likes'] ?? 0}',
                                    height: 150,
                                    width: 150,
                                    backgroundImage: image,
                                    onTap: () {
                                      _navigateToVideo(context, index);
                                    },
                                  );
                                },
                              ),
                    ),
                  ],
                ),
      ),
    );
  }
}

class _PostListMenuDialogBox extends StatelessWidget {
  const _PostListMenuDialogBox();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(height: 15),
            SettingsSwitchRow(
              icon: HugeIcons.strokeRoundedAiVideo,
              title: 'Auto Scroll',
              subtitle: 'Turn on video autoplay',
              switchValue: false,
            ),
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

class MediaCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String author;
  final String likes;
  final VoidCallback? onTap;

  const MediaCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.author,
    required this.likes,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 215,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              /// 🔹 Background Image (supports network + asset)
              if (imagePath.startsWith('http'))
                Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(color: Colors.grey[800]),
                )
              else if (imagePath.isNotEmpty)
                Image.asset(imagePath, fit: BoxFit.cover)
              else
                Container(color: Colors.grey[800]),

              /// 🔹 Gradient Overlay (better UI)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),

              /// 🔹 Bottom Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// LEFT CONTENT
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4),

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

                            const SizedBox(height: 6),

                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white30,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.favorite_border,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  likes,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      /// PLAY BUTTON
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.5,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
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
