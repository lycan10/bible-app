import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class VoiceNoteBlockEmbed extends CustomBlockEmbed {
  const VoiceNoteBlockEmbed(String audioUrl) : super(voiceNoteType, audioUrl);

  static const String voiceNoteType = 'voiceNote';
}

class VoiceNoteEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'voiceNote';

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    final audioUrl = embedContext.node.value.data as String;
    return VoiceNotePlayerWidget(audioUrl: audioUrl, embedContext: embedContext);
  }
}

class VoiceNotePlayerWidget extends StatefulWidget {
  final String audioUrl;
  final EmbedContext? embedContext;
  const VoiceNotePlayerWidget({super.key, required this.audioUrl, this.embedContext});

  @override
  State<VoiceNotePlayerWidget> createState() => _VoiceNotePlayerWidgetState();
}

class _VoiceNotePlayerWidgetState extends State<VoiceNotePlayerWidget> {
  late PlayerController _playerController;
  bool _isPlaying = false;
  bool _isPrepared = false;
  bool _isLoading = true;
  int _maxDuration = 0;
  int _currentDuration = 0;

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController()
      ..setFinishMode(finishMode: FinishMode.pause)
      ..onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        }
      })
      ..onCurrentDurationChanged.listen((duration) {
        if (mounted) {
          setState(() {
            _currentDuration = duration;
          });
        }
      })
      ..onCompletion.listen((_) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _currentDuration = _maxDuration;
          });
        }
      });
    _preparePlayer();
  }

  Future<void> _preparePlayer() async {
    try {
      String path = widget.audioUrl;

      // If it's a remote URL, download it to a temp file first
      if (widget.audioUrl.startsWith('http') || widget.audioUrl.startsWith('/api')) {
        final fullUrl = ApiService.getFullImageUrl(widget.audioUrl);
        final uri = Uri.parse(fullUrl);

        final response = await http.get(uri);
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.aac');
        await file.writeAsBytes(response.bodyBytes);
        path = file.path;
      }
      // Local path — use directly (instant preview case)

      await _playerController.preparePlayer(
        path: path,
        shouldExtractWaveform: true,
      );
      if (mounted) {
        setState(() {
          _maxDuration = _playerController.maxDuration;
          _isPrepared = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error preparing audio: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  void _playPause() async {
    if (!_isPrepared) return;
    if (_isPlaying) {
      await _playerController.pausePlayer();
    } else {
      if (_currentDuration >= _maxDuration - 100) {
        await _playerController.seekTo(0);
      }
      await _playerController.startPlayer();
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Audio'),
        content: const Text('Are you sure you want to permanently delete this voice note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              
              final isRemote = widget.audioUrl.startsWith('http') || widget.audioUrl.startsWith('/api');
              if (isRemote) {
                final token = Provider.of<AuthProvider>(context, listen: false).token;
                if (token != null) {
                  try {
                    await ApiService.deleteMedia(token, widget.audioUrl);
                  } catch (e) {
                    debugPrint('Failed to delete remote audio: $e');
                  }
                }
              }

              // Remove from Quill Editor if we have embedContext
              if (widget.embedContext != null) {
                final nodeOffset = widget.embedContext!.node.documentOffset;
                final nodeLength = widget.embedContext!.node.length;
                widget.embedContext!.controller.replaceText(nodeOffset, nodeLength, '', TextSelection.collapsed(offset: nodeOffset));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 64,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Use MediaQuery for a concrete, finite width — LayoutBuilder fails during
    // Quill's offstage measurement pass where constraints can be unbounded.
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showDeleteButton = widget.embedContext != null && !widget.embedContext!.readOnly;
    final deleteButtonWidth = showDeleteButton ? 56.0 : 0.0;
    // Account for editor horizontal padding (24*2) + icon (48) + gap (8) + deleteButton (56)
    final waveWidth = (screenWidth - 24 * 2 - 48 - 8 - 24 - deleteButtonWidth).clamp(80.0, screenWidth);

    return SizedBox(
      height: 64,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                color: const Color(0xFF4C4DFF),
                size: 32,
              ),
              onPressed: _playPause,
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AudioFileWaveforms(
                  size: Size(waveWidth, 24),
                  playerController: _playerController,
                  enableSeekGesture: true,
                  waveformType: WaveformType.fitWidth,
                  playerWaveStyle: PlayerWaveStyle(
                    fixedWaveColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.26),
                    liveWaveColor: const Color(0xFF4C4DFF),
                    spacing: 6,
                  ),
                ),
                Text(
                  '${_formatDuration(_currentDuration)} / ${_formatDuration(_maxDuration)}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            if (widget.embedContext != null && !widget.embedContext!.readOnly) ...[
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 24),
                onPressed: _confirmDelete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
