import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecorderModal extends StatefulWidget {
  const VoiceRecorderModal({super.key});

  static Future<String?> show(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const VoiceRecorderModal(),
    );
  }

  @override
  State<VoiceRecorderModal> createState() => _VoiceRecorderModalState();
}

class _VoiceRecorderModalState extends State<VoiceRecorderModal> {
  late RecorderController _recorderController;
  late PlayerController _playerController;
  
  bool _isRecording = false;
  bool _isRecordingCompleted = false;
  bool _isPlaying = false;
  String? _path;

  @override
  void initState() {
    super.initState();
    _initialiseControllers();
  }

  void _initialiseControllers() {
    _recorderController = RecorderController();
      
    _playerController = PlayerController()
      ..setFinishMode(finishMode: FinishMode.pause)
      ..onPlayerStateChanged.listen((state) {
        if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
      });
  }

  @override
  void dispose() {
    _recorderController.dispose();
    _playerController.dispose();
    super.dispose();
  }

  void _startOrStopRecording() async {
    try {
      if (_isRecording) {
        final path = await _recorderController.stop();
        if (path != null) {
          setState(() {
            _isRecording = false;
            _isRecordingCompleted = true;
            _path = path;
          });
          await _playerController.preparePlayer(
            path: path,
            shouldExtractWaveform: true,
            noOfSamples: 100,
            volume: 1.0,
          );
        }
      } else {
        final hasPermission = await _recorderController.checkPermission();
        if (!hasPermission) return;
        
        final tempDir = await getTemporaryDirectory();
        _path = '${tempDir.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _recorderController.record(path: _path);
        setState(() {
          _isRecording = true;
          _isRecordingCompleted = false;
        });
      }
    } catch (e) {
      debugPrint("Recording error: $e");
    }
  }

  void _playOrPause() async {
    if (_isPlaying) {
      await _playerController.pausePlayer();
    } else {
      await _playerController.startPlayer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isRecordingCompleted ? 'Preview Voice Note' : 'Record Voice Note',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 24),
            if (!_isRecordingCompleted)
              AudioWaveforms(
                size: const Size(double.infinity, 80),
                recorderController: _recorderController,
                waveStyle: const WaveStyle(
                  waveColor: Color(0xFF4C4DFF),
                  extendWaveform: true,
                  showMiddleLine: false,
                ),
              )
            else
              AudioFileWaveforms(
                size: const Size(double.infinity, 80),
                playerController: _playerController,
                enableSeekGesture: true,
                waveformType: WaveformType.fitWidth,
                playerWaveStyle: PlayerWaveStyle(
                  fixedWaveColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.26),
                  liveWaveColor: const Color(0xFF4C4DFF),
                  spacing: 6,
                ),
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_isRecordingCompleted)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 32),
                    onPressed: () {
                      setState(() {
                        _isRecordingCompleted = false;
                        _path = null;
                      });
                    },
                  )
                else
                  IconButton(
                    icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), size: 32),
                    onPressed: () => Navigator.pop(context),
                  ),
                
                GestureDetector(
                  onTap: _isRecordingCompleted ? _playOrPause : _startOrStopRecording,
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: _isRecording ? Colors.red : const Color(0xFF4C4DFF),
                    child: Icon(
                      _isRecordingCompleted
                          ? (_isPlaying ? Icons.pause : Icons.play_arrow)
                          : (_isRecording ? Icons.stop : Icons.mic),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                
                if (_isRecordingCompleted)
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green, size: 32),
                    onPressed: () {
                      Navigator.pop(context, _path);
                    },
                  )
                else
                  const SizedBox(width: 48), // Balance spacing
              ],
            ),
          ],
        ),
      ),
    );
  }
}
