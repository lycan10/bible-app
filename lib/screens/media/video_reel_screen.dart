import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/media_provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/main.dart';
import 'package:quest/components/share/in_app_share_sheet.dart';

///
/// [videos]        – the full list of video items the user will scroll through.
/// [initialIndex]  – the index of the video the user tapped on.
class VideoReelScreen extends StatefulWidget {
  final List<dynamic> videos;
  final int initialIndex;

  const VideoReelScreen({
    super.key,
    required this.videos,
    this.initialIndex = 0,
  });

  @override
  State<VideoReelScreen> createState() => _VideoReelScreenState();
}

class _VideoReelScreenState extends State<VideoReelScreen>
    with WidgetsBindingObserver, RouteAware {
  late final PageController _pageController;

  /// Map of page-index → VideoPlayerController so we can manage each
  /// separately and dispose them when they scroll far away.
  final Map<int, VideoPlayerController> _controllers = {};

  late List<dynamic> _videos;
  int _currentIndex = 0;
  bool _isFetchingMore = false;
  bool _isMuted = false;
  /// True only when this route is the top-most visible route.
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _videos = List<dynamic>.from(widget.videos);
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Pre-initialise controllers around the starting index
    _initController(widget.initialIndex);
    if (widget.initialIndex + 1 < _videos.length) {
      _initController(widget.initialIndex + 1);
    }
    if (widget.initialIndex - 1 >= 0) {
      _initController(widget.initialIndex - 1);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route events so we know when we are the top route.
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  // ── RouteAware callbacks ─────────────────────────────────────────────────
  @override
  void didPush() {
    // This screen just became the top route.
    _isActive = true;
  }

  @override
  void didPopNext() {
    // Returned to this screen after a sub-route was popped.
    _isActive = true;
    _controllers[_currentIndex]?.play();
  }

  @override
  void didPushNext() {
    // A new route was pushed on top of this one – pause immediately.
    _isActive = false;
    _controllers[_currentIndex]?.pause();
  }

  @override
  void didPop() {
    // This screen is being popped.
    _isActive = false;
  }

  // ──────────────────────────── Controller management ────────────────────────

  void _initController(int index) {
    if (_controllers.containsKey(index)) return;
    final rawUrl = _videos[index]['mediaUrl']?.toString() ?? '';
    if (rawUrl.isEmpty) return;

    final uri =
        rawUrl.startsWith('http')
            ? Uri.parse(rawUrl)
            : Uri.parse('http://10.0.2.2:3000$rawUrl');

    final controller = VideoPlayerController.networkUrl(uri);
    _controllers[index] = controller;

    controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          controller.setVolume(_isMuted ? 0.0 : 1.0);
          if (index == _currentIndex) {
            controller.play();
            controller.setLooping(true);
          }
          setState(() {});
        })
        .catchError((e) {
          debugPrint('Video init error at index $index: $e');
        });
  }

  void _disposeController(int index) {
    final c = _controllers.remove(index);
    c?.dispose();
  }

  void _onPageChanged(int index) {
    // Stop and dispose the previous page's controller immediately to free memory
    final prevController = _controllers[_currentIndex];
    if (prevController != null) {
      prevController.pause();
      // Schedule disposal after frame so the widget tree has a chance to update
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_controllers.containsKey(_currentIndex) || _currentIndex != index) {
          prevController.dispose();
        }
      });
    }
    _currentIndex = index;

    // Play the current page
    _controllers[index]?.play();
    _controllers[index]?.setLooping(true);

    // Pre-load ahead and behind (only 1 step)
    if (index + 1 < _videos.length) _initController(index + 1);
    if (index - 1 >= 0) _initController(index - 1);

    // Dispose controllers that are > 1 page away (free memory as requested)
    final toDispose =
        _controllers.keys.where((k) => (k - index).abs() > 1).toList();
    for (final k in toDispose) {
      _disposeController(k);
    }

    // Fetch next page when approaching the end
    if (index >= _videos.length - 3) _loadMore();

    setState(() {});
  }

  Future<void> _loadMore() async {
    if (_isFetchingMore) return;
    final mediaProvider = context.read<MediaProvider>();
    final auth = context.read<AuthProvider>();

    setState(() => _isFetchingMore = true);

    if (mediaProvider.videos.isEmpty) {
      if (auth.token != null) {
        await mediaProvider.loadVideoData(auth.token!);
      }
    } else if (mediaProvider.hasMore) {
      await mediaProvider.loadMoreVideos();
    }

    if (!mounted) return;

    final existingIds = _videos.map((v) => v['id']).toSet();
    final newItems =
        mediaProvider.videos
            .where((v) => !existingIds.contains(v['id']))
            .toList();

    setState(() {
      _videos = [..._videos, ...newItems];
      _isFetchingMore = false;
    });
  }

  // ──────────────────────────── Actions ──────────────────────────────────────

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      final vol = _isMuted ? 0.0 : 1.0;
      for (final c in _controllers.values) {
        c.setVolume(vol);
      }
    });
  }

  void _togglePlayPause(int index) {
    final c = _controllers[index];
    if (c == null) return;
    setState(() => c.value.isPlaying ? c.pause() : c.play());
  }

  void _likeVideo(dynamic videoData) {
    final auth = context.read<AuthProvider>();
    if (auth.token != null) {
      context.read<MediaProvider>().likeVideo(auth.token!, videoData['id']);
    }
  }

  void _trackPlayback(dynamic videoData, int index, bool completed) {
    final auth = context.read<AuthProvider>();
    if (auth.token != null) {
      context.read<MediaProvider>().trackVideoPlayback(
        auth.token!,
        videoData['id'],
        _controllers[index]?.value.position.inSeconds ?? 0,
        completed,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only act if this screen is actually visible to the user.
    if (!_isActive) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _controllers[_currentIndex]?.pause();
    } else if (state == AppLifecycleState.resumed) {
      _controllers[_currentIndex]?.play();
    }
  }

  @override
  void dispose() {
    _isActive = false;
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _pageController.dispose();
    // Stop all active players immediately to free memory and audio session
    for (final ctrl in _controllers.values) {
      ctrl.pause();
      ctrl.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  // ──────────────────────────── Build ────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        // Mark inactive so lifecycle observer won't restart playback
        _isActive = false;
        // Stop and release all video players when user navigates back
        for (final ctrl in _controllers.values) {
          ctrl.pause();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
          children: [
            // ── Vertical PageView ──
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _videos.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return _VideoPage(
                  key: ValueKey(_videos[index]['id'] ?? index),
                  videoData: _videos[index],
                  controller: _controllers[index],
                  isCurrentPage: index == _currentIndex,
                  isMuted: _isMuted,
                  onTogglePlay: () => _togglePlayPause(index),
                  onToggleMute: _toggleMute,
                  onLike: () => _likeVideo(_videos[index]),
                  onTrackPlayback:
                      (completed) =>
                          _trackPlayback(_videos[index], index, completed),
                  onNext:
                      () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                  onPrevious:
                      () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                );
              },
            ),

            // ── Back button ──
            Positioned(
              top: 10,
              left: 16,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // ── Loading more indicator ──
            if (_isFetchingMore)
              const Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white54,
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Single video page
// ─────────────────────────────────────────────────────────────────────────────

class _VideoPage extends StatefulWidget {
  final dynamic videoData;
  final VideoPlayerController? controller;
  final bool isCurrentPage;
  final bool isMuted;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleMute;
  final VoidCallback onLike;
  final Function(bool completed) onTrackPlayback;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const _VideoPage({
    super.key,
    required this.videoData,
    required this.controller,
    required this.isCurrentPage,
    required this.isMuted,
    required this.onTogglePlay,
    required this.onToggleMute,
    required this.onLike,
    required this.onTrackPlayback,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage> {
  double _progress = 0.0;
  String _positionText = '0:00';
  bool _completed = false;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.videoData['hasLiked'] == true;
    widget.controller?.addListener(_onControllerUpdate);
  }

  @override
  void didUpdateWidget(covariant _VideoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoData['hasLiked'] != widget.videoData['hasLiked']) {
      _isLiked = widget.videoData['hasLiked'] == true;
    }

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerUpdate);
      widget.controller?.addListener(_onControllerUpdate);
      _progress = 0;
      _positionText = '0:00';
      _completed = false;
    }
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    final c = widget.controller;
    if (c == null || !c.value.isInitialized) return;

    final position = c.value.position;
    final duration = c.value.duration;

    setState(() {
      if (duration.inMilliseconds > 0) {
        _progress = position.inMilliseconds / duration.inMilliseconds;
        final minutes = position.inMinutes;
        final seconds = (position.inSeconds % 60).toString().padLeft(2, '0');
        _positionText = '$minutes:$seconds';
      }
    });

    if (!_completed && _progress >= 0.95) {
      _completed = true;
      widget.onTrackPlayback(true);
      final auth = context.read<AuthProvider>();
      final autoScroll = auth.user?['autoScroll'] ?? false;
      if (autoScroll) {
        widget.onNext();
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerUpdate);
    if (!_completed) {
      widget.onTrackPlayback(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.videoData;
    final title = data['title'] ?? 'Video';
    final author = data['author'] ?? '';
    // Because we update optimistic state _isLiked instantly, but the true state from data['likes'] hasn't updated yet,
    // we need to offset it. Wait, the simplest approach is just to rely on data['likes'] if it matches our optimistic state.
    // Actually, to make it simple: if data['hasLiked'] == _isLiked, use data['likes'].
    // If _isLiked is true but data['hasLiked'] is false, we optimistically add 1.
    // If _isLiked is false but data['hasLiked'] is true, we optimistically subtract 1.
    final int baseLikes = data['likes'] ?? 0;
    final bool baseHasLiked = data['hasLiked'] == true;
    final int likes =
        baseLikes + (baseHasLiked != _isLiked ? (_isLiked ? 1 : -1) : 0);

    final thumbnailUrl = data['imageUrl'] ?? '';
    final controller = widget.controller;
    final isInitialized = controller?.value.isInitialized ?? false;
    final isPlaying = controller?.value.isPlaying ?? false;

    return GestureDetector(
      onTap: widget.onTogglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background: video or thumbnail ──
          if (isInitialized) ...[
            // Background blur layer
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller!.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
            // Darken the blurred background
            Container(color: Colors.black.withValues(alpha: 0.6)),
            // Foreground video keeping aspect ratio
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
          ] else if (thumbnailUrl.isNotEmpty && thumbnailUrl.startsWith('http'))
            Image.network(
              thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _gradientPlaceholder(),
            )
          else
            _gradientPlaceholder(),

          // ── Bottom gradient scrim ──
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Color(0xBB000000),
                  Colors.black,
                ],
                stops: [0.0, 0.35, 0.70, 1.0],
              ),
            ),
          ),

          // ── Subtle dark overlay ──
          ColoredBox(color: Colors.black.withValues(alpha: 0.12)),

          // ── Loading spinner ──
          if (!isInitialized)
            Center(
              child: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white60,
                  ),
                ),
              ),
            ),

          // ── Pause icon (tapped while playing → shows briefly) ──
          if (isInitialized && !isPlaying)
            IgnorePointer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 1),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),

          // ── Right-side navigation hints ──
          Positioned(
            right: 14,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NavHint(
                  icon: Icons.keyboard_arrow_up_rounded,
                  onTap: widget.onPrevious,
                ),
                const SizedBox(height: 24),
                _NavHint(
                  icon: Icons.keyboard_arrow_down_rounded,
                  onTap: widget.onNext,
                ),
              ],
            ),
          ),

          // ── Bottom content overlay ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Points banner + play/pause
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: Colors.white24,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.stars_rounded,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Watch to the end to earn points',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: widget.onTogglePlay,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white38,
                              width: 0.5,
                            ),
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                          child: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 26,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Title + position
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _positionText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Author
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'By ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ),
                        TextSpan(
                          text: author,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Like + share
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() => _isLiked = !_isLiked);
                          widget.onLike();
                        },
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    _isLiked
                                        ? Colors.pink.withValues(alpha: 0.25)
                                        : Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                _isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 18,
                                color:
                                    _isLiked ? Colors.pinkAccent : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$likes',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right action buttons (Mute & Share)
                      Row(
                        children: [
                          GestureDetector(
                            onTap: widget.onToggleMute,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                widget.isMuted
                                    ? Icons.volume_off_rounded
                                    : Icons.volume_up_rounded,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              final videoId = data['id'];
                              if (videoId != null) {
                                final link =
                                    'https://quest.vidarave.com/video/$videoId';
                                showInAppShareSheet(
                                  context,
                                  shareMessage:
                                      'Check out this video on Quest! $link',
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.buttonColor3,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const HugeIcon(
                                icon: HugeIcons.strokeRoundedLinkForward,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Progress bar
                  GradientProgressBar(
                    progress: _progress,
                    gradient: const LinearGradient(
                      colors: [Colors.pinkAccent, Color(0xFF8B5CF6)],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation hint arrow
// ─────────────────────────────────────────────────────────────────────────────

class _NavHint extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavHint({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12, width: 0.5),
        ),
        child: Icon(icon, color: Colors.white54, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient progress bar
// ─────────────────────────────────────────────────────────────────────────────

class GradientProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Gradient gradient;
  final Color backgroundColor;
  final BorderRadius borderRadius;

  const GradientProgressBar({
    super.key,
    required this.progress,
    this.height = 4,
    required this.gradient,
    this.backgroundColor = const Color(0xFF3A3A3A),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: height,
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: borderRadius,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
