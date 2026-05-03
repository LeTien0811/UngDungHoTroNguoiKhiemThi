import 'package:audioplayers/audioplayers.dart';

class AudioFeedbackService {
  final AudioPlayer _effectPlayer = AudioPlayer();
  final AudioPlayer _loopPlayer = AudioPlayer();

  static const String _processingPath = 'sounds/effect/in_process.mp3';
  static const String _successPath = 'sounds/effect/success_process.mp3';
  static const String _errorPath = 'sounds/effect/error_process.mp3';
  static const String _notificationPath = 'sounds/effect/new_notification.mp3';

  Future<void> initialize() async {
    await _effectPlayer.setReleaseMode(ReleaseMode.stop);
    await _loopPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playProcessingSound() async {
    await _loopPlayer.play(AssetSource(_processingPath));
  }

  Future<void> stopProcessingSound() async {
    if (_loopPlayer.state == PlayerState.playing) {
      await _loopPlayer.stop();
    }
  }

  Future<void> playSuccessSound() async {
    if (_loopPlayer.state == PlayerState.playing) {
      await _loopPlayer.stop();
    }
    await _effectPlayer.play(AssetSource(_successPath));
  }

  Future<void> playErrorSound() async {
    if (_loopPlayer.state == PlayerState.playing) {
      await _loopPlayer.stop();
    }
    await _effectPlayer.play(AssetSource(_errorPath));
  }

  Future<void> playNotificationSound() async {
    await _effectPlayer.play(AssetSource(_notificationPath));
  }

  void dispose() {
    _effectPlayer.dispose();
    _loopPlayer.dispose();
  }
}
