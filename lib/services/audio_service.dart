import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  AudioPlayer? _musicPlayer;
  AudioPlayer? _sfxPlayer;
  bool _isMuted = false;

  AudioService() {
    if (!kIsWeb) {
      _musicPlayer = AudioPlayer();
      _sfxPlayer = AudioPlayer();
    } else {
      _musicPlayer = AudioPlayer();
      _sfxPlayer = AudioPlayer();
    }
  }

  bool get isMuted => _isMuted;

  Future<void> playLullaby() async {
    if (_isMuted) return;
    try {
      await _musicPlayer?.stop();
      await _musicPlayer?.play(
        AssetSource('audio/pip_lullaby.mp3'),
        volume: 0.6,
      );
    } catch (e) {
      debugPrint('Audio error (lullaby): $e');
    }
  }

  Future<void> pauseLullaby() async {
    try {
      await _musicPlayer?.pause();
    } catch (e) {
      debugPrint('Audio error (pause): $e');
    }
  }

  Future<void> resumeLullaby() async {
    if (_isMuted) return;
    try {
      await _musicPlayer?.resume();
    } catch (e) {
      debugPrint('Audio error (resume): $e');
    }
  }

  Future<void> stopLullaby() async {
    try {
      await _musicPlayer?.stop();
    } catch (e) {
      debugPrint('Audio error (stop): $e');
    }
  }

  Future<void> playChime() async {
    if (_isMuted) return;
    try {
      await _sfxPlayer?.stop();
      await _sfxPlayer?.play(
        AssetSource('audio/pip_click.mp3'),
        volume: 0.4,
      );
    } catch (e) {
      debugPrint('Audio error (chime): $e');
    }
  }

  Future<void> playStarSound() async {
    if (_isMuted) return;
    try {
      await _sfxPlayer?.stop();
      await _sfxPlayer?.play(
        AssetSource('audio/pip_click.mp3'),
        volume: 0.5,
      );
    } catch (e) {
      debugPrint('Audio error (star): $e');
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _musicPlayer?.setVolume(0);
      _sfxPlayer?.setVolume(0);
    } else {
      _musicPlayer?.setVolume(0.6);
      _sfxPlayer?.setVolume(0.4);
    }
  }

  void dispose() {
    _musicPlayer?.dispose();
    _sfxPlayer?.dispose();
  }
}
