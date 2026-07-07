import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:quest/theme/theme.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:quest/providers/media_provider.dart';
import 'package:quest/providers/auth_provider.dart';
import 'package:quest/components/share/in_app_share_sheet.dart';

class AudioReelScreen extends StatefulWidget {
  final List<dynamic> audios;
  final int initialIndex;

  const AudioReelScreen({
    super.key,
    required this.audios,
    this.initialIndex = 0,
  });

  @override
  State<AudioReelScreen> createState() => _AudioReelScreenState();
}

class _AudioReelScreenState extends State<AudioReelScreen> {
  late final PageController _pageController;
  final Map<int, AudioPlayer> _players = {};

  late List<dynamic> _audios;
  int _currentIndex = 0;
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _audios = List<dynamic>.from(widget.audios);
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    _initPlayer(widget.initialIndex);
    for (int i = 1; i <= 3; i++) {
      if (widget.initialIndex + i < _audios.length) {
        _initPlayer(widget.initialIndex + i);
      }
    }
    if (widget.initialIndex - 1 >= 0) {
      _initPlayer(widget.initialIndex - 1);
    }
  }

  void _initPlayer(int index) {
    if (_players.containsKey(index)) return;
    final rawUrl = _audios[index]['mediaUrl']?.toString() ?? '';
    if (rawUrl.isEmpty) return;

    final url = rawUrl.startsWith('http') ? rawUrl : 'http://10.0.2.2:3000$rawUrl';
    final player = AudioPlayer();
    _players[index] = player;
    
    player.setSource(UrlSource(url)).catchError((e) {
      debugPrint('Audio init error at index $index: $e');
    });

    if (index == _currentIndex) {
      player.resume();
    }
  }

  void _disposePlayer(int index) {
    final p = _players.remove(index);
    p?.dispose();
  }

  void _onPageChanged(int index) {
    _players[_currentIndex]?.pause();
    _currentIndex = index;

    _players[index]?.resume();

    for (int i = 1; i <= 3; i++) {
      if (index + i < _audios.length) _initPlayer(index + i);
    }
    if (index - 1 >= 0) _initPlayer(index - 1);

    final toDispose = _players.keys.where((k) => (k - index).abs() > 3).toList();
    for (final k in toDispose) {
      _disposePlayer(k);
    }

    if (index >= _audios.length - 3) _loadMore();

    setState(() {});
  }

  Future<void> _loadMore() async {
    if (_isFetchingMore) return;
    final mediaProvider = context.read<MediaProvider>();
    final auth = context.read<AuthProvider>();

    setState(() => _isFetchingMore = true);

    if (mediaProvider.audio.isEmpty) {
      if (auth.token != null) {
        await mediaProvider.loadAudioData(auth.token!);
      }
    } else if (mediaProvider.hasMoreAudios) {
      await mediaProvider.loadMoreAudios();
    }

    if (!mounted) return;

    final existingIds = _audios.map((a) => a['id']).toSet();
    final newItems =
        mediaProvider.audio.where((a) => !existingIds.contains(a['id'])).toList();

    setState(() {
      _audios = [..._audios, ...newItems];
      _isFetchingMore = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final p in _players.values) {
      p.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _audios.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return _AudioPage(
                key: ValueKey(_audios[index]['id'] ?? index),
                audioData: _audios[index],
                player: _players[index],
              );
            },
          ),

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

          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    child: const HugeIcon(
                      icon: HugeIcons.strokeRoundedMoreVertical,
                      size: 20,
                      color: Colors.white,
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
}

class _AudioPage extends StatefulWidget {
  final dynamic audioData;
  final AudioPlayer? player;

  const _AudioPage({
    super.key,
    required this.audioData,
    required this.player,
  });

  @override
  State<_AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<_AudioPage> {
  bool _isPlaying = false;
  double _progress = 0.0;
  String _positionText = '-0:00';
  Duration _duration = Duration.zero;
  bool _completed = false;
  bool _isLiked = false;

  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _stateSub;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.audioData['hasLiked'] == true;
    _setupPlayerListeners();
  }

  Future<void> _setupPlayerListeners() async {
    _cancelListeners();
    final player = widget.player;
    if (player == null) return;

    // Fetch existing state since the player might already be initialized (preloaded)
    final initialDuration = await player.getDuration();
    if (mounted && initialDuration != null) {
      setState(() => _duration = initialDuration);
    }
    final initialState = player.state;
    if (mounted) {
      setState(() => _isPlaying = initialState == PlayerState.playing);
    }

    _durationSub = player.onDurationChanged.listen((Duration d) {
      if (mounted) setState(() => _duration = d);
    });

    _positionSub = player.onPositionChanged.listen((Duration p) {
      if (mounted) {
        setState(() {
          if (_duration.inMilliseconds > 0) {
            _progress = p.inMilliseconds / _duration.inMilliseconds;

            final remaining = _duration - p;
            final minutes = remaining.inMinutes;
            final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
            _positionText = '-$minutes:$seconds';
          }
        });

        if (!_completed && _progress >= 0.95) {
          _completed = true;
          _trackPlayback();
        }
      }
    });

    _stateSub = player.onPlayerStateChanged.listen((PlayerState s) {
      if (mounted) {
        setState(() {
          _isPlaying = s == PlayerState.playing;
        });
      }
    });
  }

  void _cancelListeners() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _stateSub?.cancel();
  }

  @override
  void didUpdateWidget(covariant _AudioPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.player != oldWidget.player) {
      _setupPlayerListeners();
      _progress = 0;
      _positionText = '-0:00';
      _completed = false;
    }
  }

  void _trackPlayback() async {
    final auth = context.read<AuthProvider>();
    final mediaProvider = context.read<MediaProvider>();
    if (auth.token != null && widget.player != null) {
      final position = await widget.player!.getCurrentPosition();
      if (mounted) {
        mediaProvider.trackAudioPlayback(
          auth.token!,
          widget.audioData['id'],
          position?.inSeconds ?? 0,
          _completed,
        );
      }
    }
  }

  @override
  void dispose() {
    _cancelListeners();
    if (!_completed) {
      _trackPlayback();
    }
    super.dispose();
  }

  void _togglePlayPause() {
    if (widget.player == null) return;
    if (_isPlaying) {
      widget.player!.pause();
    } else {
      widget.player!.resume();
    }
  }

  void _likeAudio() {
    setState(() {
      _isLiked = !_isLiked;
    });
    final auth = context.read<AuthProvider>();
    if (auth.token != null) {
      context.read<MediaProvider>().likeAudio(
        auth.token!,
        widget.audioData['id'],
      );
    }
  }

  void _shareAudio(BuildContext context) {
    final title = widget.audioData['title'] ?? 'Audio';
    final audioId = widget.audioData['id'];
    final link =
        audioId != null ? 'https://quest.vidarave.com/audio/$audioId' : null;
    showInAppShareSheet(
      context,
      shareMessage:
          link != null
              ? 'Check out this audio on Quest! $link'
              : 'Check out this audio: $title',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = widget.audioData;
    final title = data['title'] ?? 'Audio';
    final author = data['author'] ?? 'Author';
    final bgImage = data['imageUrl'] ?? 'assets/images/alucard.png';

    final int baseLikes = data['likes'] ?? 0;
    final bool baseHasLiked = data['hasLiked'] == true;
    final int likes =
        baseLikes + (baseHasLiked != _isLiked ? (_isLiked ? 1 : -1) : 0);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (bgImage.startsWith('http'))
          Image.network(
            bgImage,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) =>
                    Image.asset('assets/images/alucard.png', fit: BoxFit.cover),
          )
        else
          Image.asset(bgImage, fit: BoxFit.cover),

        Container(color: Colors.black.withValues(alpha: 0.4)),

        Center(
          child: GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedAudioWave01,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
        ),

        Positioned(
          left: 15,
          right: 15,
          bottom: 30,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14,
                        ),
                        activeTrackColor: Colors.pink,
                        inactiveTrackColor: const Color(0xFF2C2C2C),
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: _progress.clamp(0.0, 1.0),
                        onChanged: (value) {
                          if (widget.player == null) return;
                          final newPosition = Duration(
                            milliseconds:
                                (_duration.inMilliseconds * value).round(),
                          );
                          widget.player!.seek(newPosition);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _positionText,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child:
                        bgImage.startsWith('http')
                            ? Image.network(
                              bgImage,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Image.asset(
                                    'assets/images/alucard.png',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                            )
                            : Image.asset(
                              bgImage,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Image.asset(
                                    'assets/images/alucard.png',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                            ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'From: ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 14,
                                ),
                              ),
                              TextSpan(
                                text: author,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontSize: 14,
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
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Listen to the end to earn \n points',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 30),
                        Image.asset(
                          'assets/images/bronze.png',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white70, width: 0.5),
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      child: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _likeAudio,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white30,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: _isLiked ? Colors.pinkAccent : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$likes',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _shareAudio(context),
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
        ),
      ],
    );
  }
}
