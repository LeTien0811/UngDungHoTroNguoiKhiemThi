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

  Future<void> initializeVoice(AppSettingsModel appSetting) async {
    _ttsService.onSpeakingStateChanged = (state) {
      if (isSpeaking != state) {
        isSpeaking = state;
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


  Future<void> speak(String text) async{
    _audioFeedbackService.stopProcessingSound();
    _ttsService.speak(text);
  }

  Future<void> stopSpeaking() async{
    _ttsService.stop();
  }

  Future<void> startListening() async {
    await _ttsService.stop();
    await _audioFeedbackService.playNotificationSound();
    await _sttService.startListening();
  }

  void stopListening() {
    _sttService.stopListening();
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

  // Trong class VoiceInteractionProvider

  Future<void> speakAndThenListen(String text) async {
    developer_log.log("TTS đang đọc: $text", name: "VoiceProvider");

    // Tắt mic nếu đang chạy
    stopListening();

    // Đợi Flutter TTS đọc xong chữ cuối cùng
    await speak(text);

    // NGHỈ 0.5 GIÂY: Để hệ điều hành Android kịp giải phóng phần cứng Loa và cấp quyền Mic
    await Future.delayed(const Duration(milliseconds: 500));

    developer_log.log("TTS đọc xong, Mic bắt đầu mở...", name: "VoiceProvider");
    startListening();
  }

  @override
  void dispose() {
    _audioFeedbackService.dispose();
    super.dispose();
  }
}
