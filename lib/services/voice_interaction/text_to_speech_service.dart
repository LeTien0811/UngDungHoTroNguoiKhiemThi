import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  final FlutterTts _flutterTts = FlutterTts();
  final List<String> _speechQueue = [];
  bool _isSpeaking = false;
  String _lastSpokenText = "";
  DateTime _lastSpokenTime = DateTime.now();

  Function(bool)? onSpeakingStateChanged;

  Future<void> init() async {
    await _flutterTts.setLanguage("vi-VN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.awaitSpeakCompletion(true);

    _flutterTts.setCompletionHandler(() {
      _setSpeakingState(false);
      _processQueue();
    });

    _flutterTts.setErrorHandler((msg) {
      _setSpeakingState(false);
      _processQueue();
    });

    _flutterTts.setCancelHandler(() {
      _setSpeakingState(false);
      _processQueue();
    });
  }

  void _setSpeakingState(bool state) {
    _isSpeaking = state;
    if (onSpeakingStateChanged != null) {
      onSpeakingStateChanged!(state);
    }
  }

  void speak(String text) {
    final now = DateTime.now();
    if (text == _lastSpokenText &&
        now.difference(_lastSpokenTime).inSeconds < 3) {
      return;
    }
    if (_speechQueue.isNotEmpty && _speechQueue.last == text) {
      return;
    }
    _speechQueue.add(text);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isSpeaking || _speechQueue.isEmpty) return;

    _setSpeakingState(true);

    String textToSpeak = _speechQueue.removeAt(0);
    _lastSpokenText = textToSpeak;
    _lastSpokenTime = DateTime.now();

    await _flutterTts.speak(textToSpeak);
  }

  Future<void> stop() async {
    _speechQueue.clear();
    await _flutterTts.stop();
    if (_isSpeaking) {
      _setSpeakingState(false);
    }
  }

  void dispose() {
    _flutterTts.stop();
  }
}
