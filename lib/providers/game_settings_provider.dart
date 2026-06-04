import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class GameSettingsProvider with ChangeNotifier, WidgetsBindingObserver {
  bool _soundEffectsEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  double _musicVolume = 0.5;
  double _sfxVolume = 0.8;

  bool get soundEffectsEnabled => _soundEffectsEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  final AudioPlayer _bgMusicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Track the currently playing asset so we can resume after pause
  String? _currentMusicTrack;

  GameSettingsProvider() {
    _bgMusicPlayer.setReleaseMode(ReleaseMode.loop);
    _loadSettings();
    WidgetsBinding.instance.addObserver(this);
  }

  // ── Lifecycle: pause music when app goes to background ──────────────────────
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      _bgMusicPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (_musicEnabled && _currentMusicTrack != null) {
        _bgMusicPlayer.resume();
      }
    }
  }

  // ── Load from SharedPreferences ─────────────────────────────────────────────
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEffectsEnabled = prefs.getBool('soundEffectsEnabled') ?? true;
    _musicEnabled = prefs.getBool('musicEnabled') ?? true;
    _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    _musicVolume = prefs.getDouble('musicVolume') ?? 0.5;
    _sfxVolume = prefs.getDouble('sfxVolume') ?? 0.8;
    await _bgMusicPlayer.setVolume(_musicVolume);
    await _sfxPlayer.setVolume(_sfxVolume);
    notifyListeners();
  }

  // ── Toggles ─────────────────────────────────────────────────────────────────
  Future<void> toggleSoundEffects() async {
    _soundEffectsEnabled = !_soundEffectsEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEffectsEnabled', _soundEffectsEnabled);
    notifyListeners();
  }

  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('musicEnabled', _musicEnabled);
    if (!_musicEnabled) {
      await _bgMusicPlayer.pause();
    } else if (_currentMusicTrack != null) {
      await _bgMusicPlayer.resume();
    }
    notifyListeners();
  }

  Future<void> toggleVibration() async {
    _vibrationEnabled = !_vibrationEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibrationEnabled', _vibrationEnabled);
    notifyListeners();
  }

  // ── Volume controls ──────────────────────────────────────────────────────────
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _bgMusicPlayer.setVolume(_musicVolume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('musicVolume', _musicVolume);
    notifyListeners();
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    await _sfxPlayer.setVolume(_sfxVolume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sfxVolume', _sfxVolume);
    notifyListeners();
  }

  // ── Music playback ───────────────────────────────────────────────────────────
  /// Pass the asset filename for the specific game, e.g. 'audio/bible_quiz.aac'
  Future<void> playBackgroundMusic(String assetPath) async {
    _currentMusicTrack = assetPath;
    if (_musicEnabled) {
      await _bgMusicPlayer.setVolume(_musicVolume);
      await _bgMusicPlayer.play(AssetSource(assetPath));
    }
  }

  Future<void> stopBackgroundMusic() async {
    _currentMusicTrack = null;
    await _bgMusicPlayer.stop();
  }

  // ── SFX ─────────────────────────────────────────────────────────────────────
  /// Vibrates on correct answer (no sound — sound plays only at end of game).
  Future<void> playCorrectSound() async {
    if (_vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Vibrates on incorrect answer (no sound — sound plays only at end of game).
  Future<void> playIncorrectSound() async {
    if (_vibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  /// Plays a win or lose sound effect at the end of a game.
  Future<void> playGameEndSound({required bool won}) async {
    if (_soundEffectsEnabled) {
      await _sfxPlayer.setVolume(_sfxVolume);
      await _sfxPlayer.play(
        AssetSource(won ? 'audio/correct.wav' : 'audio/incorrect.wav'),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bgMusicPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }
}
