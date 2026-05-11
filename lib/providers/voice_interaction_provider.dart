import 'dart:async';

import 'package:build_access/core/base/base_model.dart';
import 'package:build_access/core/utils/dependency_injection.dart';
import 'package:build_access/models/setting/app_setting_model.dart';
import 'package:build_access/services/voice_interaction/audio_feedback_service.dart';
import 'package:build_access/services/voice_interaction/speech_to_text_service.dart';
import 'package:build_access/services/voice_interaction/text_to_speech_service.dart';
import 'dart:developer' as developer_log;

class VoiceInteractionProvider extends BaseModel {
  final TextToSpeechService _ttsService = getIt<TextToSpeechService>();
  final SpeechToTextService _sttService = getIt<SpeechToTextService>();
  final AudioFeedbackService _audioFeedbackService =
      getIt<AudioFeedbackService>();

  bool isSpeaking = false;
  bool isListening = false;
  String recognizedText = "";
  Completer<void>? _ttsCompleter;

  Future<void> initializeVoice(AppSettingsModel appSetting) async {
    _ttsService.onSpeakingStateChanged = (state) {
      if (isSpeaking != state) {
        isSpeaking = state;
        if (!state) {
          _completeTts();
        }
        notifyListeners();
      }
    };

    _sttService.onListeningStateChanged = (state) {
      if (isListening != state) {
        isListening = state;
        notifyListeners();
      }
    };

    _sttService.onResultText = (text) {
      recognizedText = text;
      notifyListeners();
    };

    await _ttsService.init(appSetting);
    await _sttService.init();
    await _audioFeedbackService.initialize();
  }

  void _completeTts() {
    if (_ttsCompleter != null && !_ttsCompleter!.isCompleted) {
      _ttsCompleter!.complete();
      _ttsCompleter = null;
    }
  }

  Future<void> speak(String text) async {
    _audioFeedbackService.stopProcessingSound();
    _completeTts();

    recognizedText = "";
    _ttsCompleter = Completer<void>();

    await _ttsService.speak(text);

    await _ttsCompleter!.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        developer_log.log("Cảnh báo: TTS Timeout", name: "VoiceProvider");
        _completeTts();
      },
    );
  }

  Future<void> stopSpeaking() async {
    await _ttsService.stop();
    _completeTts();
    notifyListeners();
  }

  Future<void> startListening() async {
    if (isSpeaking) await stopSpeaking();

    await _audioFeedbackService.playNotificationSound();
    await Future.delayed(const Duration(milliseconds: 200));
    await _sttService.startListening();
  }

  Future<void> stopListening() async {
    await _sttService.stopListening();
  }

  Future<void> playProcessingSound() async {
    await _ttsService.stop();
    await _audioFeedbackService.playProcessingSound();
  }

  Future<void> playSuccessSound() async {
    await _audioFeedbackService.playSuccessSound();
  }

  Future<void> playErrorSound() async {
    await _audioFeedbackService.playErrorSound();
  }

  @override
  void dispose() {
    _audioFeedbackService.dispose();
    stopSpeaking();
    _ttsService.dispose();
    _sttService.dispose();
    super.dispose();
  }
}
